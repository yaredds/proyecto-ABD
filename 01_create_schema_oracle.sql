-- ============================================================================
-- COURSE: DATABASE ADMINISTRATION (UNMSM - FISI - EPIS)
-- PROJECT: GEOSPATIAL CITIZEN COMPLAINT MANAGEMENT, EXTORTION ALERTS & POLICE OPERATIONS
-- SCRIPT: 01_create_schema_oracle.sql
-- DESCRIPTION: DDL FOR PHYSICAL AND LOGICAL DATA MODEL (ORACLE DATABASE & POWERDESIGNER)
-- CORPORATE POLICY: 100% ENGLISH OBJECTS, VARIABLES, COMMENTS AND CONSTRAINTS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. CLEANUP (DROP EXISTING TABLES IN REVERSE DEPENDENCY ORDER)
-- ----------------------------------------------------------------------------
BEGIN
    FOR t IN (
        SELECT table_name FROM user_tables 
        WHERE table_name IN (
            'INTERVENTION_OFFICERS', 'INTERVENTION_COMPLAINTS', 'FIELD_INTERVENTIONS',
            'PATROL_UNITS', 'COMPLAINT_STATUS_HISTORIES', 'INVESTIGATION_CASES',
            'COMPLAINT_STATUSES', 'DIGITAL_EVIDENCES', 'COMPLAINT_SUSPECTS',
            'CRIMINAL_ORGANIZATIONS', 'COMPLAINTS', 'AFFECTED_ESTABLISHMENTS',
            'COMPLAINANTS', 'EXTORTION_MODALITIES', 'CURRENCIES',
            'COMMUNITY_COORDINATORS', 'COMMUNITY_WATCHES', 'SUPPORT_TEAM_MEMBERS',
            'SUPPORT_TEAMS', 'POLICE_OFFICERS', 'POLICE_RANKS',
            'NEIGHBORHOOD_SECTORS', 'POLICE_STATIONS', 'POLICE_DIVISIONS'
        )
    ) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/

-- ============================================================================
-- AREA 1: TERRITORY & POLICE JURISDICTION
-- ============================================================================

CREATE TABLE POLICE_DIVISIONS (
    division_id                 NUMBER(10)          NOT NULL,
    division_code               VARCHAR2(20)        NOT NULL,
    division_name               VARCHAR2(100)       NOT NULL,
    region_name                 VARCHAR2(100)       NOT NULL,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE POLICE_DIVISIONS IS 'Police Divisions (Divpol) supervising multiple police stations within a regional jurisdiction.';
COMMENT ON COLUMN POLICE_DIVISIONS.division_id IS 'Unique identifier for the police division.';
COMMENT ON COLUMN POLICE_DIVISIONS.division_code IS 'Official code for the division (e.g. DIVPOL-CENTRO-1).';
COMMENT ON COLUMN POLICE_DIVISIONS.division_name IS 'Full descriptive name of the division.';
COMMENT ON COLUMN POLICE_DIVISIONS.region_name IS 'Geographical region (e.g. Lima Metropolitana).';

CREATE TABLE POLICE_STATIONS (
    station_id                  NUMBER(10)          NOT NULL,
    division_id                 NUMBER(10)          NOT NULL,
    station_code                VARCHAR2(20)        NOT NULL,
    station_name                VARCHAR2(120)       NOT NULL,
    address                     VARCHAR2(255)       NOT NULL,
    phone_number                VARCHAR2(30)        NOT NULL,
    latitude                    NUMBER(10, 7)       NOT NULL,
    longitude                   NUMBER(10, 7)       NOT NULL,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE POLICE_STATIONS IS 'Local police stations (Comisarías) under a specific police division.';
COMMENT ON COLUMN POLICE_STATIONS.station_id IS 'Primary key of the police station.';
COMMENT ON COLUMN POLICE_STATIONS.division_id IS 'Foreign key referencing the parent division.';
COMMENT ON COLUMN POLICE_STATIONS.station_code IS 'Institutional station identifier (e.g. COM-ALF-UGARTE).';
COMMENT ON COLUMN POLICE_STATIONS.station_name IS 'Name of the police precinct.';
COMMENT ON COLUMN POLICE_STATIONS.latitude IS 'Precise station GPS latitude.';
COMMENT ON COLUMN POLICE_STATIONS.longitude IS 'Precise station GPS longitude.';

CREATE TABLE NEIGHBORHOOD_SECTORS (
    sector_id                   NUMBER(10)          NOT NULL,
    station_id                  NUMBER(10)          NOT NULL,
    sector_code                 VARCHAR2(30)        NOT NULL,
    sector_name                 VARCHAR2(120)       NOT NULL,
    boundary_coordinates        CLOB                NOT NULL,
    centroid_latitude           NUMBER(10, 7),
    centroid_longitude          NUMBER(10, 7),
    risk_level                  VARCHAR2(20)        DEFAULT 'MEDIUM' NOT NULL,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE NEIGHBORHOOD_SECTORS IS 'Territorial sectors/quadrants delimited by geospatial polygons under station custody.';
COMMENT ON COLUMN NEIGHBORHOOD_SECTORS.sector_id IS 'Primary key of the sector.';
COMMENT ON COLUMN NEIGHBORHOOD_SECTORS.station_id IS 'Foreign key referencing the responsible station.';
COMMENT ON COLUMN NEIGHBORHOOD_SECTORS.sector_code IS 'Operational quadrant code (e.g. SEC-AU-01).';
COMMENT ON COLUMN NEIGHBORHOOD_SECTORS.boundary_coordinates IS 'Geospatial boundary polygon in WKT / GeoJSON format.';
COMMENT ON COLUMN NEIGHBORHOOD_SECTORS.risk_level IS 'Delinquency risk classification (LOW, MEDIUM, HIGH, CRITICAL).';

-- ============================================================================
-- AREA 2: COMMUNITY NETWORK & NEIGHBORHOOD WATCH
-- ============================================================================

CREATE TABLE COMMUNITY_WATCHES (
    watch_id                    NUMBER(10)          NOT NULL,
    sector_id                   NUMBER(10)          NOT NULL,
    watch_name                  VARCHAR2(150)       NOT NULL,
    communication_channel       VARCHAR2(150)       NOT NULL,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE COMMUNITY_WATCHES IS 'Registered citizen neighborhood watches (Juntas Vecinales).';
COMMENT ON COLUMN COMMUNITY_WATCHES.watch_id IS 'Primary key of the neighborhood watch organization.';
COMMENT ON COLUMN COMMUNITY_WATCHES.sector_id IS 'Sector where the community watch operates.';
COMMENT ON COLUMN COMMUNITY_WATCHES.communication_channel IS 'Authorized contact channel (e.g. WhatsApp Red Central, Radio VHF).';

CREATE TABLE COMMUNITY_COORDINATORS (
    coordinator_id              NUMBER(10)          NOT NULL,
    watch_id                    NUMBER(10)          NOT NULL,
    first_name                  VARCHAR2(80)        NOT NULL,
    last_name                   VARCHAR2(80)        NOT NULL,
    id_card_number              VARCHAR2(20)        NOT NULL,
    phone_number                VARCHAR2(30)        NOT NULL,
    email                       VARCHAR2(100),
    is_active                   CHAR(1)             DEFAULT 'Y' NOT NULL
);

COMMENT ON TABLE COMMUNITY_COORDINATORS IS 'Appointed neighborhood coordinators leading community watches.';
COMMENT ON COLUMN COMMUNITY_COORDINATORS.is_active IS 'Active status flag (Y/N).';

-- ============================================================================
-- AREA 3: POLICE PERSONNEL & COMMAND HIERARCHY
-- ============================================================================

CREATE TABLE POLICE_RANKS (
    rank_id                     NUMBER(10)          NOT NULL,
    rank_name                   VARCHAR2(60)        NOT NULL,
    hierarchy_order             NUMBER(3)           NOT NULL,
    category                    VARCHAR2(40)        NOT NULL
);

COMMENT ON TABLE POLICE_RANKS IS 'Official ranks of police officers (e.g. Suboficial, Teniente, Capitán, Comandante).';
COMMENT ON COLUMN POLICE_RANKS.hierarchy_order IS 'Numeric order of precedence in military/police hierarchy.';

CREATE TABLE POLICE_OFFICERS (
    officer_id                  NUMBER(10)          NOT NULL,
    cip                         VARCHAR2(15)        NOT NULL,
    first_name                  VARCHAR2(80)        NOT NULL,
    last_name                   VARCHAR2(80)        NOT NULL,
    rank_id                     NUMBER(10)          NOT NULL,
    station_id                  NUMBER(10)          NOT NULL,
    supervisor_officer_id       NUMBER(10),
    specialty                   VARCHAR2(80)        NOT NULL,
    phone_number                VARCHAR2(30),
    email                       VARCHAR2(100),
    badge_status                VARCHAR2(20)        DEFAULT 'ACTIVE' NOT NULL,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE POLICE_OFFICERS IS 'Individual police personnel identified by unique CIP with hierarchical supervision.';
COMMENT ON COLUMN POLICE_OFFICERS.cip IS 'Police Identification Code (CIP unique identifier).';
COMMENT ON COLUMN POLICE_OFFICERS.supervisor_officer_id IS 'Self-referencing foreign key pointing to the commanding supervisor.';
COMMENT ON COLUMN POLICE_OFFICERS.specialty IS 'Unit specialty (Extortion/Kidnapping, Homicide, Intelligence, Patrol).';

CREATE TABLE SUPPORT_TEAMS (
    team_id                     NUMBER(10)          NOT NULL,
    station_id                  NUMBER(10)          NOT NULL,
    team_code                   VARCHAR2(30)        NOT NULL,
    team_name                   VARCHAR2(100)       NOT NULL,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE SUPPORT_TEAMS IS 'Tactical police support squads deployed to assist detectives in complex cases.';

CREATE TABLE SUPPORT_TEAM_MEMBERS (
    team_id                     NUMBER(10)          NOT NULL,
    officer_id                  NUMBER(10)          NOT NULL,
    role_in_team                VARCHAR2(60)        DEFAULT 'TACTICAL_SUPPORT' NOT NULL,
    joined_date                 DATE                DEFAULT SYSDATE NOT NULL
);

COMMENT ON TABLE SUPPORT_TEAM_MEMBERS IS 'Intersection table registering officers assigned to a tactical support team.';

-- ============================================================================
-- AREA 4: EXTORTION INTELLIGENCE & CITIZEN COMPLAINTS
-- ============================================================================

CREATE TABLE CURRENCIES (
    currency_id                 NUMBER(10)          NOT NULL,
    currency_code               CHAR(3)             NOT NULL,
    currency_name               VARCHAR2(50)        NOT NULL,
    currency_symbol             VARCHAR2(10)        NOT NULL,
    is_active                   CHAR(1)             DEFAULT 'Y' NOT NULL
);

COMMENT ON TABLE CURRENCIES IS 'ISO 4217 Currency catalog supporting multi-currency extortion demands (PEN, USD, EUR).';

CREATE TABLE EXTORTION_MODALITIES (
    modality_id                 NUMBER(10)          NOT NULL,
    modality_code               VARCHAR2(30)        NOT NULL,
    modality_name               VARCHAR2(100)       NOT NULL,
    description                 VARCHAR2(400)       NOT NULL
);

COMMENT ON TABLE EXTORTION_MODALITIES IS 'Extortion modality catalog (Cobro de Cupos, Phone Blackmail, Gota a Gota, Explosive Attacks).';

CREATE TABLE COMPLAINANTS (
    complainant_id              NUMBER(10)          NOT NULL,
    first_name                  VARCHAR2(80),
    last_name                   VARCHAR2(80),
    id_card_number              VARCHAR2(30),
    phone_number                VARCHAR2(40),
    address                     VARCHAR2(255),
    is_identity_protected       CHAR(1)             DEFAULT 'N' NOT NULL,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE COMPLAINANTS IS 'Citizen filing the complaint with guaranteed legal identity reservation/anonymity option.';
COMMENT ON COLUMN COMPLAINANTS.is_identity_protected IS 'Y if the victim requested protected identity / anonymity to safeguard personal integrity.';

CREATE TABLE AFFECTED_ESTABLISHMENTS (
    establishment_id            NUMBER(10)          NOT NULL,
    sector_id                   NUMBER(10)          NOT NULL,
    trade_name                  VARCHAR2(150)       NOT NULL,
    establishment_type          VARCHAR2(60)        NOT NULL,
    address                     VARCHAR2(255)       NOT NULL,
    latitude                    NUMBER(10, 7)       NOT NULL,
    longitude                   NUMBER(10, 7)       NOT NULL,
    owner_contact_name          VARCHAR2(120),
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE AFFECTED_ESTABLISHMENTS IS 'Commercial business, transit stop or warehouse targeted by extortionists.';

CREATE TABLE CRIMINAL_ORGANIZATIONS (
    organization_id             NUMBER(10)          NOT NULL,
    organization_name           VARCHAR2(120)       NOT NULL,
    operating_territory         VARCHAR2(200),
    description                 VARCHAR2(400),
    threat_level                VARCHAR2(20)        DEFAULT 'HIGH' NOT NULL,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE CRIMINAL_ORGANIZATIONS IS 'Identified crime syndicates or gangs (e.g. Tren de Aragua, Los Pulpos, Los Hijos de Dios).';

CREATE TABLE COMPLAINTS (
    complaint_id                NUMBER(10)          NOT NULL,
    incident_number             VARCHAR2(30)        NOT NULL,
    incident_timestamp          TIMESTAMP           NOT NULL,
    registration_timestamp      TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL,
    sector_id                   NUMBER(10)          NOT NULL,
    complainant_id              NUMBER(10),
    modality_id                 NUMBER(10)          NOT NULL,
    establishment_id            NUMBER(10),
    demanded_amount             NUMBER(12, 2),
    currency_id                 NUMBER(10),
    payment_frequency           VARCHAR2(30)        DEFAULT 'ONCE' NOT NULL,
    latitude                    NUMBER(10, 7)       NOT NULL,
    longitude                   NUMBER(10, 7)       NOT NULL,
    address_description         VARCHAR2(300)       NOT NULL,
    incident_narrative          CLOB                NOT NULL,
    current_status_code         VARCHAR2(30)        DEFAULT 'REGISTERED' NOT NULL,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE COMPLAINTS IS 'Primary extortion complaint record with geospatial positioning and financial detail.';
COMMENT ON COLUMN COMPLAINTS.demanded_amount IS 'Extortion money demanded by criminals.';
COMMENT ON COLUMN COMPLAINTS.currency_id IS 'Foreign key linking the extortion demand to currency (PEN, USD, EUR).';

CREATE TABLE COMPLAINT_SUSPECTS (
    suspect_id                  NUMBER(10)          NOT NULL,
    complaint_id                NUMBER(10)          NOT NULL,
    organization_id             NUMBER(10),
    alias_name                  VARCHAR2(100),
    extortion_phone             VARCHAR2(40),
    suspect_description         VARCHAR2(400)
);

COMMENT ON TABLE COMPLAINT_SUSPECTS IS 'Extortionist suspects, nicknames, mobile numbers used and gang affiliations linked to cases.';

CREATE TABLE DIGITAL_EVIDENCES (
    evidence_id                 NUMBER(10)          NOT NULL,
    complaint_id                NUMBER(10)          NOT NULL,
    evidence_type               VARCHAR2(40)        NOT NULL,
    file_name                   VARCHAR2(200)       NOT NULL,
    file_storage_uri            VARCHAR2(500)       NOT NULL,
    file_hash_sha256            VARCHAR2(64)        NOT NULL,
    mime_type                   VARCHAR2(80)        NOT NULL,
    description                 VARCHAR2(300),
    uploaded_at                 TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE DIGITAL_EVIDENCES IS 'Digital forensic evidence (threatening audios, chat screenshots, surveillance video).';

-- ============================================================================
-- AREA 5: INVESTIGATION LIFECYCLE & WORKFLOW
-- ============================================================================

CREATE TABLE COMPLAINT_STATUSES (
    status_id                   NUMBER(2)           NOT NULL,
    status_code                 VARCHAR2(30)        NOT NULL,
    status_name                 VARCHAR2(80)        NOT NULL,
    sequence_order              NUMBER(2)           NOT NULL,
    description                 VARCHAR2(255)       NOT NULL
);

COMMENT ON TABLE COMPLAINT_STATUSES IS 'Mandatory sequential investigation lifecycle stages (1 to 6).';

CREATE TABLE INVESTIGATION_CASES (
    case_id                     NUMBER(10)          NOT NULL,
    complaint_id                NUMBER(10)          NOT NULL,
    lead_officer_id             NUMBER(10)          NOT NULL,
    support_team_id             NUMBER(10),
    assigned_by_officer_id      NUMBER(10)          NOT NULL,
    case_start_date             DATE                DEFAULT SYSDATE NOT NULL,
    case_closed_date            DATE,
    is_active                   CHAR(1)             DEFAULT 'Y' NOT NULL,
    investigation_notes         CLOB,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE INVESTIGATION_CASES IS 'Official police detective assignment tracking lead investigators and active caseloads.';
COMMENT ON COLUMN INVESTIGATION_CASES.is_active IS 'Flag to enforce maximum N concurrent active cases per lead investigator.';

CREATE TABLE COMPLAINT_STATUS_HISTORIES (
    history_id                  NUMBER(10)          NOT NULL,
    complaint_id                NUMBER(10)          NOT NULL,
    from_status_id              NUMBER(2),
    to_status_id                NUMBER(2)           NOT NULL,
    authorized_by_officer_id    NUMBER(10)          NOT NULL,
    change_timestamp            TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL,
    transition_reason           VARCHAR2(255)       NOT NULL,
    investigation_notes         CLOB
);

COMMENT ON TABLE COMPLAINT_STATUS_HISTORIES IS 'Audit log of state transitions with timestamp, responsible officer and legal observations.';

-- ============================================================================
-- AREA 6: FIELD OPERATIONS, PATROLS & INTERVENTIONS
-- ============================================================================

CREATE TABLE PATROL_UNITS (
    patrol_id                   NUMBER(10)          NOT NULL,
    station_id                  NUMBER(10)          NOT NULL,
    unit_code                   VARCHAR2(30)        NOT NULL,
    unit_type                   VARCHAR2(40)        NOT NULL,
    is_available                CHAR(1)             DEFAULT 'Y' NOT NULL,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE PATROL_UNITS IS 'Police vehicles, motorcycles and mobile squads deployed in field sectors.';

CREATE TABLE FIELD_INTERVENTIONS (
    intervention_id             NUMBER(10)          NOT NULL,
    sector_id                   NUMBER(10)          NOT NULL,
    patrol_id                   NUMBER(10),
    intervention_timestamp      TIMESTAMP           NOT NULL,
    intervention_type           VARCHAR2(50)        NOT NULL,
    operational_result          VARCHAR2(60)        NOT NULL,
    summary_report              CLOB                NOT NULL,
    created_at                  TIMESTAMP           DEFAULT CURRENT_TIMESTAMP NOT NULL
);

COMMENT ON TABLE FIELD_INTERVENTIONS IS 'Operational police raids, targeted patrols or sting operations conducted in field.';

CREATE TABLE INTERVENTION_COMPLAINTS (
    intervention_id             NUMBER(10)          NOT NULL,
    complaint_id                NUMBER(10)          NOT NULL
);

COMMENT ON TABLE INTERVENTION_COMPLAINTS IS 'Associative entity linking an intervention to one or several extortion complaints in a sector.';

CREATE TABLE INTERVENTION_OFFICERS (
    intervention_id             NUMBER(10)          NOT NULL,
    officer_id                  NUMBER(10)          NOT NULL,
    tactical_role               VARCHAR2(60)        DEFAULT 'TACTICAL_OPERATOR' NOT NULL
);

COMMENT ON TABLE INTERVENTION_OFFICERS IS 'Police personnel deployed on-site during a field intervention.';

-- ============================================================================
-- PRIMARY KEY CONSTRAINTS
-- ============================================================================

ALTER TABLE POLICE_DIVISIONS ADD CONSTRAINT PK_POLICE_DIVISIONS PRIMARY KEY (division_id);
ALTER TABLE POLICE_STATIONS ADD CONSTRAINT PK_POLICE_STATIONS PRIMARY KEY (station_id);
ALTER TABLE NEIGHBORHOOD_SECTORS ADD CONSTRAINT PK_NEIGHBORHOOD_SECTORS PRIMARY KEY (sector_id);
ALTER TABLE COMMUNITY_WATCHES ADD CONSTRAINT PK_COMMUNITY_WATCHES PRIMARY KEY (watch_id);
ALTER TABLE COMMUNITY_COORDINATORS ADD CONSTRAINT PK_COMMUNITY_COORDINATORS PRIMARY KEY (coordinator_id);
ALTER TABLE POLICE_RANKS ADD CONSTRAINT PK_POLICE_RANKS PRIMARY KEY (rank_id);
ALTER TABLE POLICE_OFFICERS ADD CONSTRAINT PK_POLICE_OFFICERS PRIMARY KEY (officer_id);
ALTER TABLE SUPPORT_TEAMS ADD CONSTRAINT PK_SUPPORT_TEAMS PRIMARY KEY (team_id);
ALTER TABLE SUPPORT_TEAM_MEMBERS ADD CONSTRAINT PK_SUPPORT_TEAM_MEMBERS PRIMARY KEY (team_id, officer_id);
ALTER TABLE CURRENCIES ADD CONSTRAINT PK_CURRENCIES PRIMARY KEY (currency_id);
ALTER TABLE EXTORTION_MODALITIES ADD CONSTRAINT PK_EXTORTION_MODALITIES PRIMARY KEY (modality_id);
ALTER TABLE COMPLAINANTS ADD CONSTRAINT PK_COMPLAINANTS PRIMARY KEY (complainant_id);
ALTER TABLE AFFECTED_ESTABLISHMENTS ADD CONSTRAINT PK_AFFECTED_ESTABLISHMENTS PRIMARY KEY (establishment_id);
ALTER TABLE CRIMINAL_ORGANIZATIONS ADD CONSTRAINT PK_CRIMINAL_ORGANIZATIONS PRIMARY KEY (organization_id);
ALTER TABLE COMPLAINTS ADD CONSTRAINT PK_COMPLAINTS PRIMARY KEY (complaint_id);
ALTER TABLE COMPLAINT_SUSPECTS ADD CONSTRAINT PK_COMPLAINT_SUSPECTS PRIMARY KEY (suspect_id);
ALTER TABLE DIGITAL_EVIDENCES ADD CONSTRAINT PK_DIGITAL_EVIDENCES PRIMARY KEY (evidence_id);
ALTER TABLE COMPLAINT_STATUSES ADD CONSTRAINT PK_COMPLAINT_STATUSES PRIMARY KEY (status_id);
ALTER TABLE INVESTIGATION_CASES ADD CONSTRAINT PK_INVESTIGATION_CASES PRIMARY KEY (case_id);
ALTER TABLE COMPLAINT_STATUS_HISTORIES ADD CONSTRAINT PK_COMPLAINT_STATUS_HISTORIES PRIMARY KEY (history_id);
ALTER TABLE PATROL_UNITS ADD CONSTRAINT PK_PATROL_UNITS PRIMARY KEY (patrol_id);
ALTER TABLE FIELD_INTERVENTIONS ADD CONSTRAINT PK_FIELD_INTERVENTIONS PRIMARY KEY (intervention_id);
ALTER TABLE INTERVENTION_COMPLAINTS ADD CONSTRAINT PK_INTERVENTION_COMPLAINTS PRIMARY KEY (intervention_id, complaint_id);
ALTER TABLE INTERVENTION_OFFICERS ADD CONSTRAINT PK_INTERVENTION_OFFICERS PRIMARY KEY (intervention_id, officer_id);

-- ============================================================================
-- UNIQUE CONSTRAINTS
-- ============================================================================

ALTER TABLE POLICE_DIVISIONS ADD CONSTRAINT UQ_POLICE_DIVISIONS_CODE UNIQUE (division_code);
ALTER TABLE POLICE_STATIONS ADD CONSTRAINT UQ_POLICE_STATIONS_CODE UNIQUE (station_code);
ALTER TABLE NEIGHBORHOOD_SECTORS ADD CONSTRAINT UQ_NEIGHBORHOOD_SECTORS_CODE UNIQUE (sector_code);
ALTER TABLE COMMUNITY_COORDINATORS ADD CONSTRAINT UQ_COMM_COORD_DNI UNIQUE (id_card_number);
ALTER TABLE POLICE_OFFICERS ADD CONSTRAINT UQ_POLICE_OFFICERS_CIP UNIQUE (cip);
ALTER TABLE SUPPORT_TEAMS ADD CONSTRAINT UQ_SUPPORT_TEAMS_CODE UNIQUE (station_id, team_code);
ALTER TABLE CURRENCIES ADD CONSTRAINT UQ_CURRENCIES_CODE UNIQUE (currency_code);
ALTER TABLE EXTORTION_MODALITIES ADD CONSTRAINT UQ_EXTORTION_MOD_CODE UNIQUE (modality_code);
ALTER TABLE COMPLAINTS ADD CONSTRAINT UQ_COMPLAINTS_INCIDENT_NUM UNIQUE (incident_number);
ALTER TABLE COMPLAINT_STATUSES ADD CONSTRAINT UQ_COMPLAINT_STATUSES_CODE UNIQUE (status_code);
ALTER TABLE INVESTIGATION_CASES ADD CONSTRAINT UQ_INVESTIGATION_CASES_COMPL UNIQUE (complaint_id);
ALTER TABLE PATROL_UNITS ADD CONSTRAINT UQ_PATROL_UNITS_CODE UNIQUE (unit_code);

-- ============================================================================
-- CHECK CONSTRAINTS
-- ============================================================================

ALTER TABLE COMMUNITY_COORDINATORS ADD CONSTRAINT CK_COMM_COORD_ACTIVE CHECK (is_active IN ('Y', 'N'));
ALTER TABLE POLICE_OFFICERS ADD CONSTRAINT CK_OFFICER_STATUS CHECK (badge_status IN ('ACTIVE', 'ON_LEAVE', 'SUSPENDED', 'RETIRED'));
ALTER TABLE CURRENCIES ADD CONSTRAINT CK_CURRENCIES_ACTIVE CHECK (is_active IN ('Y', 'N'));
ALTER TABLE COMPLAINANTS ADD CONSTRAINT CK_COMPLAINANT_PROTECTED CHECK (is_identity_protected IN ('Y', 'N'));
ALTER TABLE COMPLAINTS ADD CONSTRAINT CK_COMPLAINTS_FREQUENCY CHECK (payment_frequency IN ('DAILY', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'ONCE'));
ALTER TABLE COMPLAINTS ADD CONSTRAINT CK_COMPLAINTS_STATUS CHECK (current_status_code IN ('REGISTERED', 'VALIDATED_STATION', 'UNDER_INVESTIGATION', 'INTERVENTION_SCHEDULED', 'REFERRED_PROSECUTOR', 'ARCHIVED_RESOLVED'));
ALTER TABLE INVESTIGATION_CASES ADD CONSTRAINT CK_INVESTIGATION_ACTIVE CHECK (is_active IN ('Y', 'N'));
ALTER TABLE PATROL_UNITS ADD CONSTRAINT CK_PATROL_UNITS_AVAIL CHECK (is_available IN ('Y', 'N'));
ALTER TABLE DIGITAL_EVIDENCES ADD CONSTRAINT CK_EVIDENCE_TYPE CHECK (evidence_type IN ('AUDIO_RECORDING', 'CHAT_SCREENSHOT', 'SECURITY_VIDEO', 'CRIME_PHOTO', 'EXTORTION_LETTER', 'OTHER'));

-- ============================================================================
-- FOREIGN KEY CONSTRAINTS
-- ============================================================================

-- Area 1: Territory
ALTER TABLE POLICE_STATIONS ADD CONSTRAINT FK_STATIONS_DIVISIONS
    FOREIGN KEY (division_id) REFERENCES POLICE_DIVISIONS (division_id);

ALTER TABLE NEIGHBORHOOD_SECTORS ADD CONSTRAINT FK_SECTORS_STATIONS
    FOREIGN KEY (station_id) REFERENCES POLICE_STATIONS (station_id);

-- Area 2: Community
ALTER TABLE COMMUNITY_WATCHES ADD CONSTRAINT FK_WATCHES_SECTORS
    FOREIGN KEY (sector_id) REFERENCES NEIGHBORHOOD_SECTORS (sector_id);

ALTER TABLE COMMUNITY_COORDINATORS ADD CONSTRAINT FK_COORDINATORS_WATCHES
    FOREIGN KEY (watch_id) REFERENCES COMMUNITY_WATCHES (watch_id);

-- Area 3: Personnel
ALTER TABLE POLICE_OFFICERS ADD CONSTRAINT FK_OFFICERS_RANKS
    FOREIGN KEY (rank_id) REFERENCES POLICE_RANKS (rank_id);

ALTER TABLE POLICE_OFFICERS ADD CONSTRAINT FK_OFFICERS_STATIONS
    FOREIGN KEY (station_id) REFERENCES POLICE_STATIONS (station_id);

ALTER TABLE POLICE_OFFICERS ADD CONSTRAINT FK_OFFICERS_SUPERVISOR
    FOREIGN KEY (supervisor_officer_id) REFERENCES POLICE_OFFICERS (officer_id);

ALTER TABLE SUPPORT_TEAMS ADD CONSTRAINT FK_TEAMS_STATIONS
    FOREIGN KEY (station_id) REFERENCES POLICE_STATIONS (station_id);

ALTER TABLE SUPPORT_TEAM_MEMBERS ADD CONSTRAINT FK_TEAM_MEMBERS_TEAM
    FOREIGN KEY (team_id) REFERENCES SUPPORT_TEAMS (team_id);

ALTER TABLE SUPPORT_TEAM_MEMBERS ADD CONSTRAINT FK_TEAM_MEMBERS_OFFICER
    FOREIGN KEY (officer_id) REFERENCES POLICE_OFFICERS (officer_id);

-- Area 4: Complaints & Intel
ALTER TABLE AFFECTED_ESTABLISHMENTS ADD CONSTRAINT FK_ESTABLISHMENTS_SECTORS
    FOREIGN KEY (sector_id) REFERENCES NEIGHBORHOOD_SECTORS (sector_id);

ALTER TABLE COMPLAINTS ADD CONSTRAINT FK_COMPLAINTS_SECTORS
    FOREIGN KEY (sector_id) REFERENCES NEIGHBORHOOD_SECTORS (sector_id);

ALTER TABLE COMPLAINTS ADD CONSTRAINT FK_COMPLAINTS_COMPLAINANTS
    FOREIGN KEY (complainant_id) REFERENCES COMPLAINANTS (complainant_id);

ALTER TABLE COMPLAINTS ADD CONSTRAINT FK_COMPLAINTS_MODALITIES
    FOREIGN KEY (modality_id) REFERENCES EXTORTION_MODALITIES (modality_id);

ALTER TABLE COMPLAINTS ADD CONSTRAINT FK_COMPLAINTS_ESTABLISHMENTS
    FOREIGN KEY (establishment_id) REFERENCES AFFECTED_ESTABLISHMENTS (establishment_id);

ALTER TABLE COMPLAINTS ADD CONSTRAINT FK_COMPLAINTS_CURRENCIES
    FOREIGN KEY (currency_id) REFERENCES CURRENCIES (currency_id);

ALTER TABLE COMPLAINT_SUSPECTS ADD CONSTRAINT FK_SUSPECTS_COMPLAINTS
    FOREIGN KEY (complaint_id) REFERENCES COMPLAINTS (complaint_id);

ALTER TABLE COMPLAINT_SUSPECTS ADD CONSTRAINT FK_SUSPECTS_ORGANIZATIONS
    FOREIGN KEY (organization_id) REFERENCES CRIMINAL_ORGANIZATIONS (organization_id);

ALTER TABLE DIGITAL_EVIDENCES ADD CONSTRAINT FK_EVIDENCES_COMPLAINTS
    FOREIGN KEY (complaint_id) REFERENCES COMPLAINTS (complaint_id);

-- Area 5: Investigation Lifecycle
ALTER TABLE INVESTIGATION_CASES ADD CONSTRAINT FK_CASES_COMPLAINTS
    FOREIGN KEY (complaint_id) REFERENCES COMPLAINTS (complaint_id);

ALTER TABLE INVESTIGATION_CASES ADD CONSTRAINT FK_CASES_LEAD_OFFICER
    FOREIGN KEY (lead_officer_id) REFERENCES POLICE_OFFICERS (officer_id);

ALTER TABLE INVESTIGATION_CASES ADD CONSTRAINT FK_CASES_SUPPORT_TEAMS
    FOREIGN KEY (support_team_id) REFERENCES SUPPORT_TEAMS (team_id);

ALTER TABLE INVESTIGATION_CASES ADD CONSTRAINT FK_CASES_ASSIGNED_BY
    FOREIGN KEY (assigned_by_officer_id) REFERENCES POLICE_OFFICERS (officer_id);

ALTER TABLE COMPLAINT_STATUS_HISTORIES ADD CONSTRAINT FK_HISTORIES_COMPLAINTS
    FOREIGN KEY (complaint_id) REFERENCES COMPLAINTS (complaint_id);

ALTER TABLE COMPLAINT_STATUS_HISTORIES ADD CONSTRAINT FK_HISTORIES_FROM_STATUS
    FOREIGN KEY (from_status_id) REFERENCES COMPLAINT_STATUSES (status_id);

ALTER TABLE COMPLAINT_STATUS_HISTORIES ADD CONSTRAINT FK_HISTORIES_TO_STATUS
    FOREIGN KEY (to_status_id) REFERENCES COMPLAINT_STATUSES (status_id);

ALTER TABLE COMPLAINT_STATUS_HISTORIES ADD CONSTRAINT FK_HISTORIES_OFFICERS
    FOREIGN KEY (authorized_by_officer_id) REFERENCES POLICE_OFFICERS (officer_id);

-- Area 6: Field Operations
ALTER TABLE PATROL_UNITS ADD CONSTRAINT FK_PATROLS_STATIONS
    FOREIGN KEY (station_id) REFERENCES POLICE_STATIONS (station_id);

ALTER TABLE FIELD_INTERVENTIONS ADD CONSTRAINT FK_INTERVENTIONS_SECTORS
    FOREIGN KEY (sector_id) REFERENCES NEIGHBORHOOD_SECTORS (sector_id);

ALTER TABLE FIELD_INTERVENTIONS ADD CONSTRAINT FK_INTERVENTIONS_PATROLS
    FOREIGN KEY (patrol_id) REFERENCES PATROL_UNITS (patrol_id);

ALTER TABLE INTERVENTION_COMPLAINTS ADD CONSTRAINT FK_INT_COMPL_INTERVENTIONS
    FOREIGN KEY (intervention_id) REFERENCES FIELD_INTERVENTIONS (intervention_id);

ALTER TABLE INTERVENTION_COMPLAINTS ADD CONSTRAINT FK_INT_COMPL_COMPLAINTS
    FOREIGN KEY (complaint_id) REFERENCES COMPLAINTS (complaint_id);

ALTER TABLE INTERVENTION_OFFICERS ADD CONSTRAINT FK_INT_OFF_INTERVENTIONS
    FOREIGN KEY (intervention_id) REFERENCES FIELD_INTERVENTIONS (intervention_id);

ALTER TABLE INTERVENTION_OFFICERS ADD CONSTRAINT FK_INT_OFF_OFFICERS
    FOREIGN KEY (officer_id) REFERENCES POLICE_OFFICERS (officer_id);

-- ============================================================================
-- PERFORMANCE & GEOSPATIAL INDEXES (B-TREE & COVERING INDEXES)
-- ============================================================================

CREATE INDEX IDX_COMPLAINTS_SECTOR ON COMPLAINTS (sector_id);
CREATE INDEX IDX_COMPLAINTS_STATUS ON COMPLAINTS (current_status_code);
CREATE INDEX IDX_COMPLAINTS_GEO ON COMPLAINTS (latitude, longitude);
CREATE INDEX IDX_COMPLAINTS_REG_DATE ON COMPLAINTS (registration_timestamp);
CREATE INDEX IDX_OFFICERS_STATION ON POLICE_OFFICERS (station_id);
CREATE INDEX IDX_OFFICERS_RANK ON POLICE_OFFICERS (rank_id);
CREATE INDEX IDX_CASES_LEAD_ACTIVE ON INVESTIGATION_CASES (lead_officer_id, is_active);
CREATE INDEX IDX_HISTORIES_COMPLAINT ON COMPLAINT_STATUS_HISTORIES (complaint_id, change_timestamp);
CREATE INDEX IDX_ESTABLISHMENTS_GEO ON AFFECTED_ESTABLISHMENTS (latitude, longitude);
CREATE INDEX IDX_INTERVENTIONS_DATE ON FIELD_INTERVENTIONS (intervention_timestamp);

PROMPT Database Schema for Geospatial Extortion Management generated successfully!
