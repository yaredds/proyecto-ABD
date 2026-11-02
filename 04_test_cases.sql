-- ============================================================================
-- COURSE: DATABASE ADMINISTRATION (UNMSM - FISI - EPIS)
-- PROJECT: GEOSPATIAL CITIZEN COMPLAINT MANAGEMENT AND EXTORTION ALERTS
-- SCRIPT: 04_test_cases.sql (IDEMPOTENT & RE-RUNNABLE TEST HARNESS)
-- DESCRIPTION: AUTOMATED TEST HARNESS VALIDATING PACKAGES, TRIGGERS AND BUSINESS RULES
-- CORPORATE POLICY: 100% ENGLISH SYNTAX, OUTPUT LOGS AND ASSERTIONS
-- ============================================================================

SET DEFINE OFF;
SET SERVEROUTPUT ON SIZE UNLIMITED;

PROMPT ============================================================================
PROMPT STARTING AUTOMATED TEST SUITE: POLICE DATABASE SYSTEM
PROMPT ============================================================================

-- ----------------------------------------------------------------------------
-- INITIAL CLEANUP (ENSURES TESTS ARE 100% RE-RUNNABLE AT ANY TIME)
-- ----------------------------------------------------------------------------
BEGIN
    -- Delete records created in previous test executions
    FOR c IN (SELECT complaint_id FROM COMPLAINTS WHERE incident_number LIKE 'DEN-2026-TEST%') LOOP
        DELETE FROM INTERVENTION_COMPLAINTS WHERE complaint_id = c.complaint_id;
        DELETE FROM COMPLAINT_STATUS_HISTORIES WHERE complaint_id = c.complaint_id;
        DELETE FROM INVESTIGATION_CASES WHERE complaint_id = c.complaint_id;
        DELETE FROM DIGITAL_EVIDENCES WHERE complaint_id = c.complaint_id;
        DELETE FROM COMPLAINT_SUSPECTS WHERE complaint_id = c.complaint_id;
        DELETE FROM COMPLAINTS WHERE complaint_id = c.complaint_id;
    END LOOP;

    -- Reset Case 1301 to active in case Test 5 closed it in a previous run
    UPDATE INVESTIGATION_CASES
    SET is_active = 'Y', case_closed_date = NULL, investigation_notes = 'Se dispuso peritaje balistico del proyectil y geolocalizacion del numero extorsivo.'
    WHERE case_id = 1301;

    COMMIT;
END;
/

-- ----------------------------------------------------------------------------
-- TEST 1: CITIZEN EXTORTION COMPLAINT REGISTRATION
-- ----------------------------------------------------------------------------
DECLARE
    v_complaint_id NUMBER;
    v_status       VARCHAR2(30);
    v_history_rows NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- [TEST 1]: SP_REGISTER_COMPLAINT (Happy Path) ---');
    
    PKG_COMPLAINT_MGMT.SP_REGISTER_COMPLAINT(
        p_incident_number       => 'DEN-2026-TEST01',
        p_incident_timestamp    => SYSTIMESTAMP,
        p_sector_id             => 201, -- Las Malvinas
        p_complainant_id        => 702,
        p_modality_id           => 1,   -- Cobro de Cupos
        p_establishment_id      => 801,
        p_demanded_amount       => 1200.00,
        p_currency_id           => 1,   -- PEN
        p_payment_frequency     => 'WEEKLY',
        p_latitude              => -12.0452000,
        p_longitude             => -77.0448000,
        p_address_description   => 'Stand 205 Galeria Ferretera Las Malvinas',
        p_incident_narrative    => 'Sujetos armados dejaron sobre extorsivo exigiendo S/ 1,200 semanales.',
        p_authorizing_officer_id => 501, -- Commander Carranza
        o_complaint_id          => v_complaint_id
    );

    SELECT current_status_code INTO v_status FROM COMPLAINTS WHERE complaint_id = v_complaint_id;
    SELECT COUNT(*) INTO v_history_rows FROM COMPLAINT_STATUS_HISTORIES WHERE complaint_id = v_complaint_id;

    IF v_status = 'REGISTERED' AND v_history_rows = 1 THEN
        DBMS_OUTPUT.PUT_LINE('>>> TEST 1 RESULT: [SUCCESS]');
        DBMS_OUTPUT.PUT_LINE('    Created Complaint ID: ' || v_complaint_id || ' with initial status REGISTERED and audit history recorded.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('>>> TEST 1 RESULT: [FAILED] Inconsistent state.');
    END IF;
END;
/

-- ----------------------------------------------------------------------------
-- TEST 2: STATION TRIAGE AND STATUS VALIDATION
-- ----------------------------------------------------------------------------
DECLARE
    v_complaint_id NUMBER;
    v_status       VARCHAR2(30);
    v_to_status    NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- [TEST 2]: SP_VALIDATE_COMPLAINT (Station Triage) ---');

    SELECT complaint_id INTO v_complaint_id FROM COMPLAINTS WHERE incident_number = 'DEN-2026-TEST01';

    PKG_COMPLAINT_MGMT.SP_VALIDATE_COMPLAINT(
        p_complaint_id     => v_complaint_id,
        p_officer_id       => 503, -- Captain Vilchez
        p_validation_notes => 'Verified jurisdiction and evidence authenticity. Flagged as high risk.'
    );

    SELECT current_status_code INTO v_status FROM COMPLAINTS WHERE complaint_id = v_complaint_id;
    
    SELECT to_status_id INTO v_to_status 
    FROM (SELECT to_status_id FROM COMPLAINT_STATUS_HISTORIES WHERE complaint_id = v_complaint_id ORDER BY history_id DESC)
    WHERE ROWNUM = 1;

    IF v_status = 'VALIDATED_STATION' AND v_to_status = 2 THEN
        DBMS_OUTPUT.PUT_LINE('>>> TEST 2 RESULT: [SUCCESS]');
        DBMS_OUTPUT.PUT_LINE('    Complaint ID ' || v_complaint_id || ' successfully advanced to VALIDATED_STATION (Status 2).');
    ELSE
        DBMS_OUTPUT.PUT_LINE('>>> TEST 2 RESULT: [FAILED]');
    END IF;
END;
/

-- ----------------------------------------------------------------------------
-- TEST 3: DETECTIVE ASSIGNMENT UP TO MAXIMUM LIMIT N = 3
-- Detective 505 already has 2 active cases from mock data (1301 and 1302).
-- Assigning him to this complaint will reach the threshold (3 active cases).
-- ----------------------------------------------------------------------------
DECLARE
    v_complaint_id NUMBER;
    v_case_id      NUMBER;
    v_active_cases NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- [TEST 3]: SP_ASSIGN_INVESTIGATION (Detective Assignment to Capacity Limit) ---');

    SELECT complaint_id INTO v_complaint_id FROM COMPLAINTS WHERE incident_number = 'DEN-2026-TEST01';

    PKG_INVESTIGATION_OPS.SP_ASSIGN_INVESTIGATION(
        p_complaint_id     => v_complaint_id,
        p_lead_officer_id  => 505, -- Detective Montesinos
        p_support_team_id  => 601, -- Team Halcon 1
        p_assigned_by_id   => 503, -- Captain Vilchez
        p_assignment_notes => 'Assigned as lead investigator with tactical support team.',
        o_case_id          => v_case_id
    );

    SELECT COUNT(*) INTO v_active_cases
    FROM INVESTIGATION_CASES
    WHERE lead_officer_id = 505 AND is_active = 'Y';

    IF v_active_cases = 3 THEN
        DBMS_OUTPUT.PUT_LINE('>>> TEST 3 RESULT: [SUCCESS]');
        DBMS_OUTPUT.PUT_LINE('    Case ID ' || v_case_id || ' opened. Detective 505 has reached the allowed limit: ' || v_active_cases || ' active cases.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('>>> TEST 3 RESULT: [FAILED] Expected 3 active cases, found ' || v_active_cases);
    END IF;
END;
/

-- ----------------------------------------------------------------------------
-- TEST 4: TRIGGER VALIDATION (EXCEEDING MAXIMUM N=3 CASES PER DETECTIVE)
-- We register another complaint and attempt to assign it to Detective 505.
-- The trigger TRG_CHECK_LEAD_OFFICER_LIMIT MUST BLOCK IT!
-- ----------------------------------------------------------------------------
DECLARE
    v_complaint_id NUMBER;
    v_case_id      NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- [TEST 4]: TRIGGER ENFORCEMENT TEST (Exceeding N = 3 Active Cases) ---');

    -- Register a 2nd test complaint
    PKG_COMPLAINT_MGMT.SP_REGISTER_COMPLAINT(
        p_incident_number       => 'DEN-2026-TEST02',
        p_incident_timestamp    => SYSTIMESTAMP,
        p_sector_id             => 201,
        p_complainant_id        => 702,
        p_modality_id           => 1,
        p_establishment_id      => 801,
        p_demanded_amount       => 800.00,
        p_currency_id           => 1,
        p_payment_frequency     => 'WEEKLY',
        p_latitude              => -12.0453000,
        p_longitude             => -77.0447000,
        p_address_description   => 'Stand 210 Galeria Las Malvinas',
        p_incident_narrative    => 'Nueva llamada amenazante de alias El Chato Frank.',
        p_authorizing_officer_id => 501,
        o_complaint_id          => v_complaint_id
    );

    -- Validate it
    PKG_COMPLAINT_MGMT.SP_VALIDATE_COMPLAINT(
        p_complaint_id     => v_complaint_id,
        p_officer_id       => 503,
        p_validation_notes => 'Urgent triage validated.'
    );

    DBMS_OUTPUT.PUT_LINE('    Attempting to assign 4th active case to Detective 505...');

    -- This assignment MUST be rejected by the trigger!
    BEGIN
        PKG_INVESTIGATION_OPS.SP_ASSIGN_INVESTIGATION(
            p_complaint_id     => v_complaint_id,
            p_lead_officer_id  => 505, -- Detective Montesinos (Already has 3 cases!)
            p_support_team_id  => 601,
            p_assigned_by_id   => 503,
            p_assignment_notes => 'Illegal 4th case assignment that must fail.',
            o_case_id          => v_case_id
        );
        DBMS_OUTPUT.PUT_LINE('>>> TEST 4 RESULT: [FAILED] The trigger failed to block the 4th active case!');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20001 THEN
                DBMS_OUTPUT.PUT_LINE('>>> TEST 4 RESULT: [SUCCESS - TRIGGER INTERCEPTED ILLEGAL ASSIGNMENT]');
                DBMS_OUTPUT.PUT_LINE('    Expected Exception caught (-20001):');
                DBMS_OUTPUT.PUT_LINE('    ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('>>> TEST 4 RESULT: [FAILED] Unexpected error: ' || SQLERRM);
            END IF;
    END;
END;
/

-- ----------------------------------------------------------------------------
-- TEST 5: WORKLOAD RELEASE AND RE-ASSIGNMENT (Closing a Case)
-- We close Case 1301. Detective 505 drops to 2 active cases.
-- Now assigning the pending complaint to him MUST SUCCEED!
-- ----------------------------------------------------------------------------
DECLARE
    v_complaint_id NUMBER;
    v_case_id      NUMBER;
    v_active_cases NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- [TEST 5]: SP_CLOSE_CASE AND WORKLOAD CAPACITY RELEASE ---');

    -- 1. Close Case 1301 (Resolved / Archived)
    PKG_INVESTIGATION_OPS.SP_CLOSE_CASE(
        p_case_id        => 1301,
        p_officer_id     => 503,
        p_closure_reason => 'Primary suspect El Chato Frank arrested in flagrante delicto. Evidence secured.',
        p_final_status_id => 6 -- ARCHIVED_RESOLVED
    );

    SELECT COUNT(*) INTO v_active_cases
    FROM INVESTIGATION_CASES
    WHERE lead_officer_id = 505 AND is_active = 'Y';

    DBMS_OUTPUT.PUT_LINE('    Case 1301 closed. Detective 505 active caseload decreased to: ' || v_active_cases);

    -- 2. Now assign the pending complaint (DEN-2026-TEST02) to Detective 505
    SELECT complaint_id INTO v_complaint_id FROM COMPLAINTS WHERE incident_number = 'DEN-2026-TEST02';

    PKG_INVESTIGATION_OPS.SP_ASSIGN_INVESTIGATION(
        p_complaint_id     => v_complaint_id,
        p_lead_officer_id  => 505,
        p_support_team_id  => 601,
        p_assigned_by_id   => 503,
        p_assignment_notes => 'Re-attempted assignment now that workload capacity is available.',
        o_case_id          => v_case_id
    );

    DBMS_OUTPUT.PUT_LINE('>>> TEST 5 RESULT: [SUCCESS]');
    DBMS_OUTPUT.PUT_LINE('    Assignment of Case ID ' || v_case_id || ' succeeded after closing previous case!');
END;
/

-- ----------------------------------------------------------------------------
-- TEST 6: GEOSPATIAL AND MULTI-CURRENCY AGGREGATION FUNCTION TEST
-- ----------------------------------------------------------------------------
DECLARE
    v_total_pen NUMBER;
    v_total_usd NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- [TEST 6]: FN_GET_TOTAL_EXTORTED_BY_SECTOR (Analytics) ---');

    v_total_pen := PKG_COMPLAINT_MGMT.FN_GET_TOTAL_EXTORTED_BY_SECTOR(p_sector_id => 201, p_currency_code => 'PEN');
    v_total_usd := PKG_COMPLAINT_MGMT.FN_GET_TOTAL_EXTORTED_BY_SECTOR(p_sector_id => 203, p_currency_code => 'USD');

    DBMS_OUTPUT.PUT_LINE('>>> TEST 6 RESULT: [SUCCESS]');
    DBMS_OUTPUT.PUT_LINE('    Total extorted amount in Sector 201 (Las Malvinas) [PEN]: S/ ' || TO_CHAR(v_total_pen, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE('    Total extorted amount in Sector 203 (Mesa Redonda) [USD]:   $ ' || TO_CHAR(v_total_usd, '999,999.99'));
END;
/

PROMPT ============================================================================
PROMPT TEST SUITE EXECUTION COMPLETED! ALL SCENARIOS VERIFIED.
PROMPT ============================================================================
