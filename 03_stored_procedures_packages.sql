-- ============================================================================
-- COURSE: DATABASE ADMINISTRATION (UNMSM - FISI - EPIS)
-- PROJECT: GEOSPATIAL CITIZEN COMPLAINT MANAGEMENT & EXTORTION ALERTS
-- SCRIPT: 03_stored_procedures_packages.sql
-- DESCRIPTION: PL/SQL PACKAGES, BUSINESS LOGIC, AND MANDATORY TRIGGER
-- CORPORATE POLICY: 100% ENGLISH SYNTAX, IDENTIFIERS AND COMMENTS
-- ============================================================================

SET SERVEROUTPUT ON;

-- ============================================================================
-- 1. SEQUENCES FOR OPERATIONAL OBJECTS
-- ============================================================================
DECLARE
    PROCEDURE recreate_seq(p_seq_name VARCHAR2, p_start NUMBER) IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count FROM user_sequences WHERE sequence_name = UPPER(p_seq_name);
        IF v_count > 0 THEN
            EXECUTE IMMEDIATE 'DROP SEQUENCE ' || p_seq_name;
        END IF;
        EXECUTE IMMEDIATE 'CREATE SEQUENCE ' || p_seq_name || ' START WITH ' || p_start || ' INCREMENT BY 1 NOCACHE';
    END;
BEGIN
    recreate_seq('SEQ_COMPLAINT_ID', 2001);
    recreate_seq('SEQ_CASE_ID', 2301);
    recreate_seq('SEQ_HISTORY_ID', 2401);
    recreate_seq('SEQ_INTERVENTION_ID', 2601);
    recreate_seq('SEQ_EVIDENCE_ID', 2201);
    recreate_seq('SEQ_SUSPECT_ID', 2101);
END;
/

-- ============================================================================
-- 2. MANDATORY BUSINESS RULE TRIGGER: MAXIMUM N ACTIVE CASES PER INVESTIGATOR
-- Rule: A police officer cannot be assigned as Lead Investigator of more than N
-- concurrent active cases. (Implemented via COMPOUND TRIGGER to prevent ORA-04091)
-- ============================================================================

CREATE OR REPLACE TRIGGER TRG_CHECK_LEAD_OFFICER_LIMIT
FOR INSERT OR UPDATE OF lead_officer_id, is_active ON INVESTIGATION_CASES
COMPOUND TRIGGER

    -- Type to buffer candidate officer IDs evaluated in the transaction
    TYPE t_officer_list IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_officers t_officer_list;
    
    -- Business Parameter: Maximum allowable active cases per detective (N = 3)
    c_max_active_cases CONSTANT NUMBER := 3;

    BEFORE STATEMENT IS
    BEGIN
        v_officers.DELETE;
    END BEFORE STATEMENT;

    AFTER EACH ROW IS
    BEGIN
        -- Only inspect when a case is created as active or updated to active
        IF :NEW.is_active = 'Y' THEN
            v_officers(v_officers.COUNT + 1) := :NEW.lead_officer_id;
        END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
        v_active_count NUMBER;
        v_officer_name VARCHAR2(160);
    BEGIN
        FOR i IN 1..v_officers.COUNT LOOP
            SELECT COUNT(*)
            INTO v_active_count
            FROM INVESTIGATION_CASES
            WHERE lead_officer_id = v_officers(i)
              AND is_active = 'Y';

            IF v_active_count > c_max_active_cases THEN
                -- Fetch officer details for friendly exception reporting
                BEGIN
                    SELECT first_name || ' ' || last_name
                    INTO v_officer_name
                    FROM POLICE_OFFICERS
                    WHERE officer_id = v_officers(i);
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        v_officer_name := 'Unknown Officer';
                END;

                RAISE_APPLICATION_ERROR(
                    -20001,
                    'CRITICAL BUSINESS RULE VIOLATION: Lead Investigator [' || 
                    v_officer_name || ' (ID: ' || v_officers(i) || ')] cannot be assigned more than ' ||
                    c_max_active_cases || ' concurrent active cases. Currently has: ' || v_active_count || ' active cases.'
                );
            END IF;
        END LOOP;
    END AFTER STATEMENT;

END TRG_CHECK_LEAD_OFFICER_LIMIT;
/

-- ============================================================================
-- 3. PACKAGE: PKG_COMPLAINT_MGMT (CITIZEN REGISTRATION & TRIAJE)
-- ============================================================================

CREATE OR REPLACE PACKAGE PKG_COMPLAINT_MGMT AS
    -- Registers a citizen extortion complaint and logs initial REGISTERED state
    PROCEDURE SP_REGISTER_COMPLAINT (
        p_incident_number       IN  VARCHAR2,
        p_incident_timestamp    IN  TIMESTAMP,
        p_sector_id             IN  NUMBER,
        p_complainant_id        IN  NUMBER,
        p_modality_id           IN  NUMBER,
        p_establishment_id      IN  NUMBER,
        p_demanded_amount       IN  NUMBER,
        p_currency_id           IN  NUMBER,
        p_payment_frequency     IN  VARCHAR2,
        p_latitude              IN  NUMBER,
        p_longitude             IN  NUMBER,
        p_address_description   IN  VARCHAR2,
        p_incident_narrative    IN  CLOB,
        p_authorizing_officer_id IN NUMBER,
        o_complaint_id          OUT NUMBER
    );

    -- Triage and validation by police station guard officer
    PROCEDURE SP_VALIDATE_COMPLAINT (
        p_complaint_id          IN NUMBER,
        p_officer_id            IN NUMBER,
        p_validation_notes      IN VARCHAR2
    );

    -- Calculates total extorted money in a specific sector by currency code
    FUNCTION FN_GET_TOTAL_EXTORTED_BY_SECTOR (
        p_sector_id             IN NUMBER,
        p_currency_code         IN VARCHAR2 DEFAULT 'PEN'
    ) RETURN NUMBER;
END PKG_COMPLAINT_MGMT;
/

CREATE OR REPLACE PACKAGE BODY PKG_COMPLAINT_MGMT AS

    PROCEDURE SP_REGISTER_COMPLAINT (
        p_incident_number       IN  VARCHAR2,
        p_incident_timestamp    IN  TIMESTAMP,
        p_sector_id             IN  NUMBER,
        p_complainant_id        IN  NUMBER,
        p_modality_id           IN  NUMBER,
        p_establishment_id      IN  NUMBER,
        p_demanded_amount       IN  NUMBER,
        p_currency_id           IN  NUMBER,
        p_payment_frequency     IN  VARCHAR2,
        p_latitude              IN  NUMBER,
        p_longitude             IN  NUMBER,
        p_address_description   IN  VARCHAR2,
        p_incident_narrative    IN  CLOB,
        p_authorizing_officer_id IN NUMBER,
        o_complaint_id          OUT NUMBER
    ) IS
        v_complaint_id NUMBER;
        v_history_id   NUMBER;
    BEGIN
        v_complaint_id := SEQ_COMPLAINT_ID.NEXTVAL;
        v_history_id   := SEQ_HISTORY_ID.NEXTVAL;

        -- 1. Insert Complaint Master Record
        INSERT INTO COMPLAINTS (
            complaint_id, incident_number, incident_timestamp, registration_timestamp,
            sector_id, complainant_id, modality_id, establishment_id,
            demanded_amount, currency_id, payment_frequency,
            latitude, longitude, address_description,
            incident_narrative, current_status_code
        ) VALUES (
            v_complaint_id, p_incident_number, p_incident_timestamp, CURRENT_TIMESTAMP,
            p_sector_id, p_complainant_id, p_modality_id, p_establishment_id,
            p_demanded_amount, p_currency_id, UPPER(p_payment_frequency),
            p_latitude, p_longitude, p_address_description,
            p_incident_narrative, 'REGISTERED'
        );

        -- 2. Audit Trail Initial State: REGISTERED (Status ID: 1)
        INSERT INTO COMPLAINT_STATUS_HISTORIES (
            history_id, complaint_id, from_status_id, to_status_id,
            authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes
        ) VALUES (
            v_history_id, v_complaint_id, NULL, 1,
            p_authorizing_officer_id, CURRENT_TIMESTAMP,
            'Initial citizen registration filed in system.',
            'Initial intake completed. Awaiting station triage verification.'
        );

        o_complaint_id := v_complaint_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20002, 'Error in SP_REGISTER_COMPLAINT: ' || SQLERRM);
    END SP_REGISTER_COMPLAINT;

    PROCEDURE SP_VALIDATE_COMPLAINT (
        p_complaint_id          IN NUMBER,
        p_officer_id            IN NUMBER,
        p_validation_notes      IN VARCHAR2
    ) IS
        v_current_status VARCHAR2(30);
        v_history_id     NUMBER;
    BEGIN
        SELECT current_status_code
        INTO v_current_status
        FROM COMPLAINTS
        WHERE complaint_id = p_complaint_id;

        IF v_current_status != 'REGISTERED' THEN
            RAISE_APPLICATION_ERROR(-20003, 'Invalid transition: Only complaints in REGISTERED status can be validated.');
        END IF;

        v_history_id := SEQ_HISTORY_ID.NEXTVAL;

        -- Update Complaint Status
        UPDATE COMPLAINTS
        SET current_status_code = 'VALIDATED_STATION'
        WHERE complaint_id = p_complaint_id;

        -- Audit Trail State Transition: 1 (REGISTERED) -> 2 (VALIDATED_STATION)
        INSERT INTO COMPLAINT_STATUS_HISTORIES (
            history_id, complaint_id, from_status_id, to_status_id,
            authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes
        ) VALUES (
            v_history_id, p_complaint_id, 1, 2,
            p_officer_id, CURRENT_TIMESTAMP,
            'Station triage confirmed. Territorial jurisdiction verified.',
            p_validation_notes
        );

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'Complaint ID ' || p_complaint_id || ' does not exist.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_VALIDATE_COMPLAINT;

    FUNCTION FN_GET_TOTAL_EXTORTED_BY_SECTOR (
        p_sector_id             IN NUMBER,
        p_currency_code         IN VARCHAR2 DEFAULT 'PEN'
    ) RETURN NUMBER IS
        v_total NUMBER;
    BEGIN
        SELECT NVL(SUM(c.demanded_amount), 0)
        INTO v_total
        FROM COMPLAINTS c
        JOIN CURRENCIES cur ON c.currency_id = cur.currency_id
        WHERE c.sector_id = p_sector_id
          AND cur.currency_code = UPPER(p_currency_code);

        RETURN v_total;
    END FN_GET_TOTAL_EXTORTED_BY_SECTOR;

END PKG_COMPLAINT_MGMT;
/

-- ============================================================================
-- 4. PACKAGE: PKG_INVESTIGATION_OPS (CASE ASSIGNMENT & LIFECYCLE MANAGEMENT)
-- ============================================================================

CREATE OR REPLACE PACKAGE PKG_INVESTIGATION_OPS AS
    -- Assigns a complaint to a lead detective and tactical support team
    PROCEDURE SP_ASSIGN_INVESTIGATION (
        p_complaint_id          IN  NUMBER,
        p_lead_officer_id       IN  NUMBER,
        p_support_team_id       IN  NUMBER,
        p_assigned_by_id        IN  NUMBER,
        p_assignment_notes      IN  VARCHAR2,
        o_case_id               OUT NUMBER
    );

    -- Transitions a complaint through the mandatory 6 investigation stages
    PROCEDURE SP_TRANSITION_STATUS (
        p_complaint_id          IN NUMBER,
        p_to_status_id          IN NUMBER,
        p_officer_id            IN NUMBER,
        p_reason                IN VARCHAR2,
        p_notes                 IN VARCHAR2
    );

    -- Closes an active investigation case (resolves or refers to prosecutor)
    PROCEDURE SP_CLOSE_CASE (
        p_case_id               IN NUMBER,
        p_officer_id            IN NUMBER,
        p_closure_reason        IN VARCHAR2,
        p_final_status_id       IN NUMBER DEFAULT 6 -- ARCHIVED_RESOLVED
    );
END PKG_INVESTIGATION_OPS;
/

CREATE OR REPLACE PACKAGE BODY PKG_INVESTIGATION_OPS AS

    PROCEDURE SP_ASSIGN_INVESTIGATION (
        p_complaint_id          IN  NUMBER,
        p_lead_officer_id       IN  NUMBER,
        p_support_team_id       IN  NUMBER,
        p_assigned_by_id        IN  NUMBER,
        p_assignment_notes      IN  VARCHAR2,
        o_case_id               OUT NUMBER
    ) IS
        v_case_id       NUMBER;
        v_history_id    NUMBER;
        v_current_code  VARCHAR2(30);
    BEGIN
        SELECT current_status_code
        INTO v_current_code
        FROM COMPLAINTS
        WHERE complaint_id = p_complaint_id;

        IF v_current_code NOT IN ('VALIDATED_STATION', 'REGISTERED') THEN
            RAISE_APPLICATION_ERROR(-20005, 'Complaint must be in VALIDATED_STATION status before opening a formal case.');
        END IF;

        v_case_id    := SEQ_CASE_ID.NEXTVAL;
        v_history_id := SEQ_HISTORY_ID.NEXTVAL;

        -- 1. Create Investigation Case (Trigger TRG_CHECK_LEAD_OFFICER_LIMIT will fire here!)
        INSERT INTO INVESTIGATION_CASES (
            case_id, complaint_id, lead_officer_id, support_team_id,
            assigned_by_officer_id, case_start_date, is_active, investigation_notes
        ) VALUES (
            v_case_id, p_complaint_id, p_lead_officer_id, p_support_team_id,
            p_assigned_by_id, SYSDATE, 'Y', p_assignment_notes
        );

        -- 2. Update complaint master status
        UPDATE COMPLAINTS
        SET current_status_code = 'UNDER_INVESTIGATION'
        WHERE complaint_id = p_complaint_id;

        -- 3. Audit trail: Transition to Status 3 (UNDER_INVESTIGATION)
        INSERT INTO COMPLAINT_STATUS_HISTORIES (
            history_id, complaint_id, from_status_id, to_status_id,
            authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes
        ) VALUES (
            v_history_id, p_complaint_id, 2, 3,
            p_assigned_by_id, CURRENT_TIMESTAMP,
            'Official detective assignment by Station Commander / Head of DEPINCRI.',
            p_assignment_notes
        );

        o_case_id := v_case_id;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_ASSIGN_INVESTIGATION;

    PROCEDURE SP_TRANSITION_STATUS (
        p_complaint_id          IN NUMBER,
        p_to_status_id          IN NUMBER,
        p_officer_id            IN NUMBER,
        p_reason                IN VARCHAR2,
        p_notes                 IN VARCHAR2
    ) IS
        v_from_status_id NUMBER(2);
        v_to_code        VARCHAR2(30);
        v_history_id     NUMBER;
    BEGIN
        -- Identify target status code
        SELECT status_code
        INTO v_to_code
        FROM COMPLAINT_STATUSES
        WHERE status_id = p_to_status_id;

        -- Get last status ID from history
        SELECT to_status_id
        INTO v_from_status_id
        FROM (
            SELECT to_status_id
            FROM COMPLAINT_STATUS_HISTORIES
            WHERE complaint_id = p_complaint_id
            ORDER BY change_timestamp DESC, history_id DESC
        ) WHERE ROWNUM = 1;

        v_history_id := SEQ_HISTORY_ID.NEXTVAL;

        -- Update complaint master current status
        UPDATE COMPLAINTS
        SET current_status_code = v_to_code
        WHERE complaint_id = p_complaint_id;

        -- Record Audit Entry
        INSERT INTO COMPLAINT_STATUS_HISTORIES (
            history_id, complaint_id, from_status_id, to_status_id,
            authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes
        ) VALUES (
            v_history_id, p_complaint_id, v_from_status_id, p_to_status_id,
            p_officer_id, CURRENT_TIMESTAMP, p_reason, p_notes
        );

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20006, 'Invalid complaint ID or status ID specified.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_TRANSITION_STATUS;

    PROCEDURE SP_CLOSE_CASE (
        p_case_id               IN NUMBER,
        p_officer_id            IN NUMBER,
        p_closure_reason        IN VARCHAR2,
        p_final_status_id       IN NUMBER DEFAULT 6
    ) IS
        v_complaint_id NUMBER;
    BEGIN
        SELECT complaint_id
        INTO v_complaint_id
        FROM INVESTIGATION_CASES
        WHERE case_id = p_case_id;

        -- 1. Close the investigation case and release detective workload
        UPDATE INVESTIGATION_CASES
        SET is_active = 'N',
            case_closed_date = SYSDATE,
            investigation_notes = investigation_notes || ' | CASE CLOSED: ' || p_closure_reason
        WHERE case_id = p_case_id;

        -- 2. Transition complaint status to resolved or referred
        SP_TRANSITION_STATUS(
            p_complaint_id => v_complaint_id,
            p_to_status_id => p_final_status_id,
            p_officer_id   => p_officer_id,
            p_reason       => 'Case concluded.',
            p_notes        => p_closure_reason
        );

        COMMIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20007, 'Case ID ' || p_case_id || ' does not exist.');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END SP_CLOSE_CASE;

END PKG_INVESTIGATION_OPS;
/

PROMPT Stored PL/SQL Packages and Trigger compiled successfully!
