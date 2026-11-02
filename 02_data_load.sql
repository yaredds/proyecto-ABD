-- ============================================================================
-- COURSE: DATABASE ADMINISTRATION (UNMSM - FISI - EPIS)
-- PROJECT: GEOSPATIAL CITIZEN COMPLAINT MANAGEMENT & EXTORTION ALERTS
-- SCRIPT: 02_data_load.sql
-- DESCRIPTION: COMPREHENSIVE MOCK DATA POPULATION (REALISTIC PERUVIAN POLICE DATA)
-- CORPORATE POLICY: 100% ENGLISH SYNTAX, DATA VALUES & COMMENTS
-- ============================================================================

SET DEFINE OFF;

-- Clear previous data in correct dependency sequence (optional safety)
DELETE FROM INTERVENTION_OFFICERS;
DELETE FROM INTERVENTION_COMPLAINTS;
DELETE FROM FIELD_INTERVENTIONS;
DELETE FROM PATROL_UNITS;
DELETE FROM COMPLAINT_STATUS_HISTORIES;
DELETE FROM INVESTIGATION_CASES;
DELETE FROM COMPLAINT_STATUSES;
DELETE FROM DIGITAL_EVIDENCES;
DELETE FROM COMPLAINT_SUSPECTS;
DELETE FROM COMPLAINTS;
DELETE FROM CRIMINAL_ORGANIZATIONS;
DELETE FROM AFFECTED_ESTABLISHMENTS;
DELETE FROM COMPLAINANTS;
DELETE FROM EXTORTION_MODALITIES;
DELETE FROM CURRENCIES;
DELETE FROM SUPPORT_TEAM_MEMBERS;
DELETE FROM SUPPORT_TEAMS;
DELETE FROM POLICE_OFFICERS;
DELETE FROM POLICE_RANKS;
DELETE FROM COMMUNITY_COORDINATORS;
DELETE FROM COMMUNITY_WATCHES;
DELETE FROM NEIGHBORHOOD_SECTORS;
DELETE FROM POLICE_STATIONS;
DELETE FROM POLICE_DIVISIONS;
COMMIT;

PROMPT Loading Area 1: Territory and Jurisdictions...

-- ----------------------------------------------------------------------------
-- 1. POLICE DIVISIONS (DIVPOL)
-- ----------------------------------------------------------------------------
INSERT INTO POLICE_DIVISIONS (division_id, division_code, division_name, region_name)
VALUES (1, 'DIVPOL-CENTRO-1', 'Division Policial Centro 1 - Lima Cercado', 'Lima Metropolitana');

INSERT INTO POLICE_DIVISIONS (division_id, division_code, division_name, region_name)
VALUES (2, 'DIVPOL-NORTE-2', 'Division Policial Norte 2 - Los Olivos e Independencia', 'Lima Metropolitana');

INSERT INTO POLICE_DIVISIONS (division_id, division_code, division_name, region_name)
VALUES (3, 'DIVPOL-ESTE-1', 'Division Policial Este 1 - San Juan de Lurigancho', 'Lima Metropolitana');

INSERT INTO POLICE_DIVISIONS (division_id, division_code, division_name, region_name)
VALUES (4, 'DIVPOL-SUR-1', 'Division Policial Sur 1 - San Borja y Surquillo', 'Lima Metropolitana');

-- ----------------------------------------------------------------------------
-- 2. POLICE STATIONS (COMISARIAS)
-- ----------------------------------------------------------------------------
INSERT INTO POLICE_STATIONS (station_id, division_id, station_code, station_name, address, phone_number, latitude, longitude)
VALUES (101, 1, 'COM-ALF-UGARTE', 'Comisaria Alfonso Ugarte', 'Av. Alfonso Ugarte 1245, Cercado de Lima', '(01) 424-2222', -12.0463740, -77.0427810);

INSERT INTO POLICE_STATIONS (station_id, division_id, station_code, station_name, address, phone_number, latitude, longitude)
VALUES (102, 1, 'COM-SAN-ANDRES', 'Comisaria San Andres', 'Jr. Junin 842, Cercado de Lima', '(01) 428-1144', -12.0491200, -77.0223400);

INSERT INTO POLICE_STATIONS (station_id, division_id, station_code, station_name, address, phone_number, latitude, longitude)
VALUES (103, 2, 'COM-SOL-ORO', 'Comisaria Sol de Oro', 'Av. Angelica Gamarra 450, Los Olivos', '(01) 533-3390', -11.9961200, -77.0708400);

INSERT INTO POLICE_STATIONS (station_id, division_id, station_code, station_name, address, phone_number, latitude, longitude)
VALUES (104, 3, 'COM-CANTO-REY', 'Comisaria Canto Rey', 'Av. Canto Grande 3200, San Juan de Lurigancho', '(01) 388-1212', -11.9723500, -76.9921400);

-- ----------------------------------------------------------------------------
-- 3. NEIGHBORHOOD SECTORS (CUADRANTES VECINALES)
-- ----------------------------------------------------------------------------
INSERT INTO NEIGHBORHOOD_SECTORS (sector_id, station_id, sector_code, sector_name, boundary_coordinates, centroid_latitude, centroid_longitude, risk_level)
VALUES (
    201, 101, 'SEC-AU-01', 'Sector Comercial Malvinas y Bellota',
    '{"type":"Polygon","coordinates":[[[-77.048,-12.043],[-77.041,-12.043],[-77.041,-12.048],[-77.048,-12.048],[-77.048,-12.043]]]}',
    -12.0455000, -77.0445000, 'CRITICAL'
);

INSERT INTO NEIGHBORHOOD_SECTORS (sector_id, station_id, sector_code, sector_name, boundary_coordinates, centroid_latitude, centroid_longitude, risk_level)
VALUES (
    202, 101, 'SEC-AU-02', 'Sector Residencial Breña Limite',
    '{"type":"Polygon","coordinates":[[[-77.051,-12.049],[-77.045,-12.049],[-77.045,-12.055],[-77.051,-12.055],[-77.051,-12.049]]]}',
    -12.0520000, -77.0480000, 'MEDIUM'
);

INSERT INTO NEIGHBORHOOD_SECTORS (sector_id, station_id, sector_code, sector_name, boundary_coordinates, centroid_latitude, centroid_longitude, risk_level)
VALUES (
    203, 102, 'SEC-SA-01', 'Sector Mesa Redonda y Mercado Central',
    '{"type":"Polygon","coordinates":[[[-77.025,-12.048],[-77.019,-12.048],[-77.019,-12.053],[-77.025,-12.053],[-77.025,-12.048]]]}',
    -12.0505000, -77.0220000, 'CRITICAL'
);

INSERT INTO NEIGHBORHOOD_SECTORS (sector_id, station_id, sector_code, sector_name, boundary_coordinates, centroid_latitude, centroid_longitude, risk_level)
VALUES (
    204, 103, 'SEC-SO-01', 'Sector Tomas Valle y Ovalo Habich',
    '{"type":"Polygon","coordinates":[[[-77.075,-11.993],[-77.068,-11.993],[-77.068,-12.001],[-77.075,-12.001],[-77.075,-11.993]]]}',
    -11.9970000, -77.0715000, 'HIGH'
);

INSERT INTO NEIGHBORHOOD_SECTORS (sector_id, station_id, sector_code, sector_name, boundary_coordinates, centroid_latitude, centroid_longitude, risk_level)
VALUES (
    205, 104, 'SEC-CR-01', 'Sector Paraderos Canto Rey y Santa Rosa',
    '{"type":"Polygon","coordinates":[[[-76.998,-11.968],[-76.988,-11.968],[-76.988,-11.978],[-76.998,-11.978],[-76.998,-11.968]]]}',
    -11.9730000, -76.9930000, 'CRITICAL'
);

PROMPT Loading Area 2: Community Network...

-- ----------------------------------------------------------------------------
-- 4. COMMUNITY WATCHES (JUNTAS VECINALES)
-- ----------------------------------------------------------------------------
INSERT INTO COMMUNITY_WATCHES (watch_id, sector_id, watch_name, communication_channel)
VALUES (301, 201, 'Junta Vecinal Emprendedores de Las Malvinas', 'WhatsApp Red Emergencia Malvinas - Grupo 1');

INSERT INTO COMMUNITY_WATCHES (watch_id, sector_id, watch_name, communication_channel)
VALUES (302, 203, 'Asociacion Comerciantes Unidos Mesa Redonda', 'Canal Radial VHF 146.520 MHz y Telegram');

INSERT INTO COMMUNITY_WATCHES (watch_id, sector_id, watch_name, communication_channel)
VALUES (303, 204, 'Junta Vecinal Segura Tomas Valle Los Olivos', 'WhatsApp Comisaria Sol de Oro Alerta');

INSERT INTO COMMUNITY_WATCHES (watch_id, sector_id, watch_name, communication_channel)
VALUES (304, 205, 'Red de Transportistas y Vecinos Canto Grande', 'Central Telefonica Vecinal y Grupo WhatsApp');

-- ----------------------------------------------------------------------------
-- 5. COMMUNITY COORDINATORS
-- ----------------------------------------------------------------------------
INSERT INTO COMMUNITY_COORDINATORS (coordinator_id, watch_id, first_name, last_name, id_card_number, phone_number, email, is_active)
VALUES (401, 301, 'Victor Raul', 'Quispe Huaman', '09876541', '+51 987654321', 'vquispe.malvinas@gmail.com', 'Y');

INSERT INTO COMMUNITY_COORDINATORS (coordinator_id, watch_id, first_name, last_name, id_card_number, phone_number, email, is_active)
VALUES (402, 302, 'Maria Elena', 'Zegarra Mendoza', '10293847', '+51 971234567', 'mzegarra.mesa@gmail.com', 'Y');

INSERT INTO COMMUNITY_COORDINATORS (coordinator_id, watch_id, first_name, last_name, id_card_number, phone_number, email, is_active)
VALUES (403, 303, 'Carlos Alberto', 'Rios Sandoval', '45829103', '+51 965432198', 'carlos.rios.olivos@gmail.com', 'Y');

INSERT INTO COMMUNITY_COORDINATORS (coordinator_id, watch_id, first_name, last_name, id_card_number, phone_number, email, is_active)
VALUES (404, 304, 'Dora Luz', 'Paredes Benitez', '25619384', '+51 954321876', 'dora.paredes@yahoo.com', 'Y');

PROMPT Loading Area 3: Police Personnel and Ranks...

-- ----------------------------------------------------------------------------
-- 6. POLICE RANKS
-- ----------------------------------------------------------------------------
INSERT INTO POLICE_RANKS (rank_id, rank_name, hierarchy_order, category)
VALUES (1, 'Suboficial de Tercera (SO3)', 1, 'Suboficiales de Armas');

INSERT INTO POLICE_RANKS (rank_id, rank_name, hierarchy_order, category)
VALUES (2, 'Suboficial de Segunda (SO2)', 2, 'Suboficiales de Armas');

INSERT INTO POLICE_RANKS (rank_id, rank_name, hierarchy_order, category)
VALUES (3, 'Suboficial Brigadier (SB)', 6, 'Suboficiales de Armas');

INSERT INTO POLICE_RANKS (rank_id, rank_name, hierarchy_order, category)
VALUES (4, 'Teniente (Tnte)', 7, 'Oficiales Subalternos');

INSERT INTO POLICE_RANKS (rank_id, rank_name, hierarchy_order, category)
VALUES (5, 'Capitan (Cap)', 8, 'Oficiales Subalternos');

INSERT INTO POLICE_RANKS (rank_id, rank_name, hierarchy_order, category)
VALUES (6, 'Mayor (My)', 9, 'Oficiales Superiores');

INSERT INTO POLICE_RANKS (rank_id, rank_name, hierarchy_order, category)
VALUES (7, 'Comandante (Cmdte)', 10, 'Oficiales Superiores');

-- ----------------------------------------------------------------------------
-- 7. POLICE OFFICERS (COMMAND STRUCTURE)
-- ----------------------------------------------------------------------------
-- Superior Officers / Station Commanders (No supervisor)
INSERT INTO POLICE_OFFICERS (officer_id, cip, first_name, last_name, rank_id, station_id, supervisor_officer_id, specialty, phone_number, email, badge_status)
VALUES (501, '31048291', 'Manuel Eduardo', 'Carranza Rojas', 7, 101, NULL, 'Comisario / Direccion Operativa', '+51 991100001', 'mcarranza@pnp.gob.pe', 'ACTIVE');

INSERT INTO POLICE_OFFICERS (officer_id, cip, first_name, last_name, rank_id, station_id, supervisor_officer_id, specialty, phone_number, email, badge_status)
VALUES (502, '31048292', 'Luis Fernando', 'Pacheco Silva', 6, 102, NULL, 'Comisario / Direccion Operativa', '+51 991100002', 'lpacheco@pnp.gob.pe', 'ACTIVE');

-- Department Heads / Captains (Supervised by Commanders)
INSERT INTO POLICE_OFFICERS (officer_id, cip, first_name, last_name, rank_id, station_id, supervisor_officer_id, specialty, phone_number, email, badge_status)
VALUES (503, '31084920', 'Hector Gustavo', 'Vilchez Morales', 5, 101, 501, 'Jefe de Investigaciones Criminales (DEPINCRI)', '+51 991100003', 'hvilchez@pnp.gob.pe', 'ACTIVE');

INSERT INTO POLICE_OFFICERS (officer_id, cip, first_name, last_name, rank_id, station_id, supervisor_officer_id, specialty, phone_number, email, badge_status)
VALUES (504, '31084921', 'Jorge David', 'Barrientos Alva', 5, 103, NULL, 'Jefe de Investigaciones Criminales', '+51 991100004', 'jbarrientos@pnp.gob.pe', 'ACTIVE');

-- Detective Investigators (Supervised by Captains)
INSERT INTO POLICE_OFFICERS (officer_id, cip, first_name, last_name, rank_id, station_id, supervisor_officer_id, specialty, phone_number, email, badge_status)
VALUES (505, '31293847', 'Ricardo Arturo', 'Montesinos Cueva', 4, 101, 503, 'Investigador Principal de Extorsiones', '+51 991100005', 'rmontesinos@pnp.gob.pe', 'ACTIVE');

INSERT INTO POLICE_OFFICERS (officer_id, cip, first_name, last_name, rank_id, station_id, supervisor_officer_id, specialty, phone_number, email, badge_status)
VALUES (506, '31293848', 'Cesar Augusto', 'Delgado Herrera', 4, 101, 503, 'Investigador Principal de Crimen Organizado', '+51 991100006', 'cdelgado@pnp.gob.pe', 'ACTIVE');

INSERT INTO POLICE_OFFICERS (officer_id, cip, first_name, last_name, rank_id, station_id, supervisor_officer_id, specialty, phone_number, email, badge_status)
VALUES (507, '31293849', 'Raul Javier', 'Chavez Salazar', 3, 102, 502, 'Investigador Principal de Extorsiones', '+51 991100007', 'rchavez@pnp.gob.pe', 'ACTIVE');

-- Field Officers and Patrol Agents
INSERT INTO POLICE_OFFICERS (officer_id, cip, first_name, last_name, rank_id, station_id, supervisor_officer_id, specialty, phone_number, email, badge_status)
VALUES (508, '31394850', 'Alonso Daniel', 'Guerra Tello', 2, 101, 505, 'Patrullaje Integrado y Operaciones Tacticas', '+51 991100008', 'aguerra@pnp.gob.pe', 'ACTIVE');

INSERT INTO POLICE_OFFICERS (officer_id, cip, first_name, last_name, rank_id, station_id, supervisor_officer_id, specialty, phone_number, email, badge_status)
VALUES (509, '31394851', 'Edgar Yampier', 'Reyes Medina', 1, 101, 505, 'Inteligencia Operativa y Vigilancia', '+51 991100009', 'ereyes@pnp.gob.pe', 'ACTIVE');

INSERT INTO POLICE_OFFICERS (officer_id, cip, first_name, last_name, rank_id, station_id, supervisor_officer_id, specialty, phone_number, email, badge_status)
VALUES (510, '31394852', 'Walter Hernan', 'Soto Palomino', 2, 103, 504, 'Patrullaje Motorizado', '+51 991100010', 'wsoto@pnp.gob.pe', 'ACTIVE');

-- ----------------------------------------------------------------------------
-- 8. SUPPORT TEAMS & MEMBERS
-- ----------------------------------------------------------------------------
INSERT INTO SUPPORT_TEAMS (team_id, station_id, team_code, team_name)
VALUES (601, 101, 'EQ-HALCON-1', 'Grupo TACTICO Halcon 1 - Alfonso Ugarte');

INSERT INTO SUPPORT_TEAMS (team_id, station_id, team_code, team_name)
VALUES (602, 101, 'EQ-INTEL-CENTRO', 'Peloton Especial de Inteligencia y Analisis Digital');

INSERT INTO SUPPORT_TEAMS (team_id, station_id, team_code, team_name)
VALUES (603, 103, 'EQ-COBRA-NORTE', 'Grupo de Respuesta Inmediata Cobra Los Olivos');

INSERT INTO SUPPORT_TEAM_MEMBERS (team_id, officer_id, role_in_team, joined_date)
VALUES (601, 508, 'Breacher / Intervencion Tactica', TO_DATE('2026-01-15', 'YYYY-MM-DD'));

INSERT INTO SUPPORT_TEAM_MEMBERS (team_id, officer_id, role_in_team, joined_date)
VALUES (601, 509, 'Agente de Reconocimiento y Dron', TO_DATE('2026-01-15', 'YYYY-MM-DD'));

INSERT INTO SUPPORT_TEAM_MEMBERS (team_id, officer_id, role_in_team, joined_date)
VALUES (602, 509, 'Perito Tecnologico y Enlace Digital', TO_DATE('2026-02-01', 'YYYY-MM-DD'));

INSERT INTO SUPPORT_TEAM_MEMBERS (team_id, officer_id, role_in_team, joined_date)
VALUES (603, 510, 'Piloto Táctico Motorizado', TO_DATE('2026-01-20', 'YYYY-MM-DD'));

PROMPT Loading Area 4: Currencies, Modalities and Establishments...

-- ----------------------------------------------------------------------------
-- 9. CURRENCIES (ISO 4217 - MULTI-CURRENCY REQUIREMENT)
-- ----------------------------------------------------------------------------
INSERT INTO CURRENCIES (currency_id, currency_code, currency_name, currency_symbol, is_active)
VALUES (1, 'PEN', 'Sol Peruano', 'S/', 'Y');

INSERT INTO CURRENCIES (currency_id, currency_code, currency_name, currency_symbol, is_active)
VALUES (2, 'USD', 'US Dollar', '$', 'Y');

INSERT INTO CURRENCIES (currency_id, currency_code, currency_name, currency_symbol, is_active)
VALUES (3, 'EUR', 'Euro', '€', 'Y');

-- ----------------------------------------------------------------------------
-- 10. EXTORTION MODALITIES
-- ----------------------------------------------------------------------------
INSERT INTO EXTORTION_MODALITIES (modality_id, modality_code, modality_name, description)
VALUES (1, 'COBRO_CUPOS', 'Cobro de Cupos a Negocios y Obras', 'Exigencia periodica de dinero a comerciantes formales e informales bajo amenaza de atentado.');

INSERT INTO EXTORTION_MODALITIES (modality_id, modality_code, modality_name, description)
VALUES (2, 'EXTORSION_TEL', 'Extorsion Telefonica y Mensajeria Chat', 'Llamadas intimidatorias, mensajes de WhatsApp con fotos de armas y audios exigiendo transferencias bancarias o Yape/Plin.');

INSERT INTO EXTORTION_MODALITIES (modality_id, modality_code, modality_name, description)
VALUES (3, 'GOTA_A_GOTA', 'Prestamos Extorsivos Gota a Gota', 'Creditos ilegales con intereses usurarios diarios y cobros violentos con retencion de bienes o amedrentamiento fisico.');

INSERT INTO EXTORTION_MODALITIES (modality_id, modality_code, modality_name, description)
VALUES (4, 'PARADERO_TRANS', 'Cobro de Cupos en Paraderos de Transporte', 'Exigencia extorsiva a choferes y cobradores de combis o buses por cada vuelta o parada en paraderos clave.');

INSERT INTO EXTORTION_MODALITIES (modality_id, modality_code, modality_name, description)
VALUES (5, 'ATENTADO_EXPLOSIVO', 'Ataque con Explosivos y Disparos', 'Detonacion de artefactos pirotecnicos/dinamita o disparos a la fachada del establecimiento como medida de presion.');

-- ----------------------------------------------------------------------------
-- 11. COMPLAINANTS (WITH ANONYMITY / IDENTITY PROTECTION TEST CASES)
-- ----------------------------------------------------------------------------
-- Citizen with Protected Identity / Anonymity
INSERT INTO COMPLAINANTS (complainant_id, first_name, last_name, id_card_number, phone_number, address, is_identity_protected)
VALUES (701, 'CLAVE_PROTEGIDA_01', 'RESERVA_LEGAL', 'DNI_ENCRYPTED_9941', '+51 980000001', 'Direccion protegida bajo custodia fiscal', 'Y');

-- Normal Citizens
INSERT INTO COMPLAINANTS (complainant_id, first_name, last_name, id_card_number, phone_number, address, is_identity_protected)
VALUES (702, 'Jorge Luis', 'Paredes Cardenas', '42918274', '+51 994829102', 'Jr. Guillermo Dansey 450 Int 12, Lima Cercado', 'N');

INSERT INTO COMPLAINANTS (complainant_id, first_name, last_name, id_card_number, phone_number, address, is_identity_protected)
VALUES (703, 'Rosa Angelica', 'Chumpitaz Vera', '08291039', '+51 984729103', 'Jr. Andahuaylas 980, Mesa Redonda, Cercado', 'N');

INSERT INTO COMPLAINANTS (complainant_id, first_name, last_name, id_card_number, phone_number, address, is_identity_protected)
VALUES (704, 'Manuel Antonio', 'Espinoza Farfan', '71928301', '+51 954829104', 'Av. Canto Grande 3400, San Juan de Lurigancho', 'N');

-- ----------------------------------------------------------------------------
-- 12. AFFECTED ESTABLISHMENTS
-- ----------------------------------------------------------------------------
INSERT INTO AFFECTED_ESTABLISHMENTS (establishment_id, sector_id, trade_name, establishment_type, address, latitude, longitude, owner_contact_name)
VALUES (801, 201, 'Galeria Ferretera Las Malvinas Stand 114', 'Hardware Store', 'Av. Argentina 320, Lima Cercado', -12.0451000, -77.0450000, 'Jorge Luis Paredes Cardenas');

INSERT INTO AFFECTED_ESTABLISHMENTS (establishment_id, sector_id, trade_name, establishment_type, address, latitude, longitude, owner_contact_name)
VALUES (802, 203, 'Importadora y Jugueteria El Sol de Mesa Redonda', 'Toy & Import Store', 'Jr. Cusco 680, Mesa Redonda', -12.0512000, -77.0231000, 'Rosa Angelica Chumpitaz Vera');

INSERT INTO AFFECTED_ESTABLISHMENTS (establishment_id, sector_id, trade_name, establishment_type, address, latitude, longitude, owner_contact_name)
VALUES (803, 204, 'Polleria y Restaurant Sabores Nortenos', 'Restaurant', 'Av. Tomas Valle 1205, Los Olivos', -11.9968000, -77.0721000, 'Marcos Huaman Perez');

INSERT INTO AFFECTED_ESTABLISHMENTS (establishment_id, sector_id, trade_name, establishment_type, address, latitude, longitude, owner_contact_name)
VALUES (804, 205, 'Paradero y Terminal de Combis La 50 Canto Rey', 'Transit Stop', 'Av. Canto Grande cruce con Sta Rosa', -11.9729000, -76.9928000, 'Asociacion Choferes Ruta 50');

-- ----------------------------------------------------------------------------
-- 13. CRIMINAL ORGANIZATIONS
-- ----------------------------------------------------------------------------
INSERT INTO CRIMINAL_ORGANIZATIONS (organization_id, organization_name, operating_territory, description, threat_level)
VALUES (901, 'Los Injertos del Cono Norte', 'Los Olivos, San Martin de Porres e Independencia', 'Banda delictiva dedicada a la extorsion de pequenos negocios, bodegas y farmacias mediante prestamos gota a gota y cobro semanal.', 'CRITICAL');

INSERT INTO CRIMINAL_ORGANIZATIONS (organization_id, organization_name, operating_territory, description, threat_level)
VALUES (902, 'Los Pulpos de Trujillo - Celula Lima Centro', 'Cercado de Lima, Mesa Redonda y Barrios Altos', 'Faccion extorsiva con antecedentes de artefactos explosivos y reglaje a comerciantes mayoristas.', 'CRITICAL');

INSERT INTO CRIMINAL_ORGANIZATIONS (organization_id, organization_name, operating_territory, description, threat_level)
VALUES (903, 'La Jauria de Canto Grande', 'San Juan de Lurigancho - Sector Canto Rey', 'Organizacion dedicada al cobro de cupos a empresas de transporte urbano y mototaxis.', 'HIGH');

PROMPT Loading Complaints, Digital Evidences and Suspects...

-- ----------------------------------------------------------------------------
-- 14. COMPLAINTS (MULTI-CURRENCY, GEOLOCATION & DETAILED EXTORTION INCIDENTS)
-- ----------------------------------------------------------------------------
-- Complaint 1: In Soles (PEN), Las Malvinas, under investigation
INSERT INTO COMPLAINTS (
    complaint_id, incident_number, incident_timestamp, registration_timestamp,
    sector_id, complainant_id, modality_id, establishment_id,
    demanded_amount, currency_id, payment_frequency,
    latitude, longitude, address_description,
    incident_narrative, current_status_code
) VALUES (
    1001, 'DEN-2026-000101',
    TO_TIMESTAMP('2026-10-15 09:30:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2026-10-15 11:20:00', 'YYYY-MM-DD HH24:MI:SS'),
    201, 702, 1, 801,
    500.00, 1, 'WEEKLY',
    -12.0451500, -77.0449500, 'Stand 114 Pasaje Comercial 3 - Frente a puerta principal',
    'Dos sujetos armados a bordo de una motocicleta lineal dejaron un sobre con una bala y una nota manuscrita exigiendo 500 soles semanales para no atentar contra el local.',
    'UNDER_INVESTIGATION'
);

-- Complaint 2: In US Dollars (USD), Mesa Redonda, with explosive attack
INSERT INTO COMPLAINTS (
    complaint_id, incident_number, incident_timestamp, registration_timestamp,
    sector_id, complainant_id, modality_id, establishment_id,
    demanded_amount, currency_id, payment_frequency,
    latitude, longitude, address_description,
    incident_narrative, current_status_code
) VALUES (
    1002, 'DEN-2026-000102',
    TO_TIMESTAMP('2026-10-18 22:45:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2026-10-19 08:15:00', 'YYYY-MM-DD HH24:MI:SS'),
    203, 703, 5, 802,
    5000.00, 2, 'ONCE',
    -12.0512800, -77.0230500, 'Puerta de metal de la importadora en Jr. Cusco 680',
    'Detonaron un artefacto explosivo artesanal de alta potencia en la puerta del local. Posteriormente enviaron videos por WhatsApp exigiendo $5,000 dolares para dejar trabajar.',
    'INTERVENTION_SCHEDULED'
);

-- Complaint 3: In Soles (PEN), Protected Identity, Gota a Gota in Los Olivos
INSERT INTO COMPLAINTS (
    complaint_id, incident_number, incident_timestamp, registration_timestamp,
    sector_id, complainant_id, modality_id, establishment_id,
    demanded_amount, currency_id, payment_frequency,
    latitude, longitude, address_description,
    incident_narrative, current_status_code
) VALUES (
    1003, 'DEN-2026-000103',
    TO_TIMESTAMP('2026-10-22 14:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2026-10-22 16:30:00', 'YYYY-MM-DD HH24:MI:SS'),
    204, 701, 3, 803,
    150.00, 1, 'DAILY',
    -11.9968200, -77.0720500, 'Av. Tomas Valle 1205 a una cuadra de Av. Universitaria',
    'Victima con identidad reservada solicito un prestamo de 2,000 soles y ahora le exigen 150 soles diarios por tiempo indefinido. Amenazan con quemar el local comercial.',
    'VALIDATED_STATION'
);

-- Complaint 4: In Soles (PEN), Transit stop SJL, newly registered
INSERT INTO COMPLAINTS (
    complaint_id, incident_number, incident_timestamp, registration_timestamp,
    sector_id, complainant_id, modality_id, establishment_id,
    demanded_amount, currency_id, payment_frequency,
    latitude, longitude, address_description,
    incident_narrative, current_status_code
) VALUES (
    1004, 'DEN-2026-000104',
    TO_TIMESTAMP('2026-10-28 06:10:00', 'YYYY-MM-DD HH24:MI:SS'),
    TO_TIMESTAMP('2026-10-28 07:05:00', 'YYYY-MM-DD HH24:MI:SS'),
    205, 704, 4, 804,
    10.00, 1, 'DAILY',
    -11.9729200, -76.9927500, 'Paradero final Ruta 50 - Av. Canto Grande cruce Santa Rosa',
    'Extorsionadores apostados en el paradero cobran 10 soles por vuelta a cada conductor de la linea. Quien se niega es agredido fisicamente o le rompen las lunas.',
    'REGISTERED'
);

-- ----------------------------------------------------------------------------
-- 15. COMPLAINT SUSPECTS & ALIASES
-- ----------------------------------------------------------------------------
INSERT INTO COMPLAINT_SUSPECTS (suspect_id, complaint_id, organization_id, alias_name, extortion_phone, suspect_description)
VALUES (1101, 1001, 902, 'El Chato Frank', '+51 912348571', 'Estatura aproximada 1.65m, tez triguena, tatuaje de calavera en antebrazo derecho, usa casaca negra y casco cerrado.');

INSERT INTO COMPLAINT_SUSPECTS (suspect_id, complaint_id, organization_id, alias_name, extortion_phone, suspect_description)
VALUES (1102, 1002, 902, 'El Monstruo de Barrios Altos', '+51 988472910', 'Sujeto de contextura gruesa, envia audios con voz distorsionada y acento del norte del pais.');

INSERT INTO COMPLAINT_SUSPECTS (suspect_id, complaint_id, organization_id, alias_name, extortion_phone, suspect_description)
VALUES (1103, 1003, 901, 'El Chamito Kevin', '+51 947291049', 'Acento extranjero, se desplaza en motocicleta roja placa 4521-7B, porta arma de fuego en mariconera.');

INSERT INTO COMPLAINT_SUSPECTS (suspect_id, complaint_id, organization_id, alias_name, extortion_phone, suspect_description)
VALUES (1104, 1004, 903, 'Cachorro de Canto Rey', '+51 977102948', 'Joven de 22 anos aprox, gorra con visera plana, bermudas, vigila la caseta del paradero con un cuaderno de cobros.');

-- ----------------------------------------------------------------------------
-- 16. DIGITAL FORENSIC EVIDENCES
-- ----------------------------------------------------------------------------
INSERT INTO DIGITAL_EVIDENCES (evidence_id, complaint_id, evidence_type, file_name, file_storage_uri, file_hash_sha256, mime_type, description)
VALUES (1201, 1001, 'EXTORTION_LETTER', 'carta_amenaza_stand114.jpg', '/secure_vault/evidences/2026/10/ev_1001_01.jpg', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', 'image/jpeg', 'Fotografia en alta resolucion de la nota extorsiva dejada con el proyectil 9mm.');

INSERT INTO DIGITAL_EVIDENCES (evidence_id, complaint_id, evidence_type, file_name, file_storage_uri, file_hash_sha256, mime_type, description)
VALUES (1202, 1002, 'SECURITY_VIDEO', 'camara_explosion_cusco680.mp4', '/secure_vault/evidences/2026/10/ev_1002_vid01.mp4', 'cca9cf445f354365f4b89c025470addbfa442d1ece9115f1ab9572b046b45a22', 'video/mp4', 'Grabacion de camara de seguridad municipal captando el momento de la deflagracion.');

INSERT INTO DIGITAL_EVIDENCES (evidence_id, complaint_id, evidence_type, file_name, file_storage_uri, file_hash_sha256, mime_type, description)
VALUES (1203, 1002, 'AUDIO_RECORDING', 'audio_amenaza_whatsapp.aac', '/secure_vault/evidences/2026/10/ev_1002_aud01.aac', '789569de0e61ec23528f8049fb551a31d0fdcf16fe4022a8435d8efefbe2e7bf', 'audio/aac', 'Audio remitido desde el telefono +51 988472910 exigiendo 5 mil dolares de cuota.');

INSERT INTO DIGITAL_EVIDENCES (evidence_id, complaint_id, evidence_type, file_name, file_storage_uri, file_hash_sha256, mime_type, description)
VALUES (1204, 1003, 'CHAT_SCREENSHOT', 'captura_chat_amenazas_gota.png', '/secure_vault/evidences/2026/10/ev_1003_chat.png', '2c26b46b68ffc68ff99b453c1d30413413422d706483bfa0f98a5e886266e7ae', 'image/png', 'Captura de pantalla de conversacion donde amenazan a los hijos de la victima.');

PROMPT Loading Area 5: Investigation Lifecycle and Status Histories...

-- ----------------------------------------------------------------------------
-- 17. COMPLAINT STATUSES (OFFICIAL SIX STAGES)
-- ----------------------------------------------------------------------------
INSERT INTO COMPLAINT_STATUSES (status_id, status_code, status_name, sequence_order, description)
VALUES (1, 'REGISTERED', 'Registrado en Sistema', 1, 'Ingreso inicial formal de la denuncia o alerta ciudadana.');

INSERT INTO COMPLAINT_STATUSES (status_id, status_code, status_name, sequence_order, description)
VALUES (2, 'VALIDATED_STATION', 'Validado por Comisaria', 2, 'Triaje inicial por el oficial de guardia y verificacion de competencia territorial.');

INSERT INTO COMPLAINT_STATUSES (status_id, status_code, status_name, sequence_order, description)
VALUES (3, 'UNDER_INVESTIGATION', 'En Investigacion Activa', 3, 'Expediente asignado formalmente a un detective principal y equipo de apoyo.');

INSERT INTO COMPLAINT_STATUSES (status_id, status_code, status_name, sequence_order, description)
VALUES (4, 'INTERVENTION_SCHEDULED', 'Intervencion Programada', 4, 'Planificacion de allanamiento, operativo de captura o patrullaje focalizado.');

INSERT INTO COMPLAINT_STATUSES (status_id, status_code, status_name, sequence_order, description)
VALUES (5, 'REFERRED_PROSECUTOR', 'Derivado a Fiscalia', 5, 'Paso a etapa procesal penal con informe pericial y acta de diligencias al Ministerio Publico.');

INSERT INTO COMPLAINT_STATUSES (status_id, status_code, status_name, sequence_order, description)
VALUES (6, 'ARCHIVED_RESOLVED', 'Archivado o Resuelto', 6, 'Cierre final del caso por captura de banda, sentencia judicial o sobreseimiento fundado.');

-- ----------------------------------------------------------------------------
-- 18. INVESTIGATION CASES (DETECTIVE CASELOAD TRACKING)
-- ----------------------------------------------------------------------------
-- Case 1 for Complaint 1001: Assigned to Officer 505 (Ricardo Montesinos)
INSERT INTO INVESTIGATION_CASES (
    case_id, complaint_id, lead_officer_id, support_team_id,
    assigned_by_officer_id, case_start_date, is_active, investigation_notes
) VALUES (
    1301, 1001, 505, 601,
    503, TO_DATE('2026-10-16', 'YYYY-MM-DD'), 'Y',
    'Se dispuso peritaje balistico del proyectil y geolocalizacion del numero extorsivo.'
);

-- Case 2 for Complaint 1002: Assigned to Officer 505 (Ricardo Montesinos) - Now has 2 active cases
INSERT INTO INVESTIGATION_CASES (
    case_id, complaint_id, lead_officer_id, support_team_id,
    assigned_by_officer_id, case_start_date, is_active, investigation_notes
) VALUES (
    1302, 1002, 505, 602,
    503, TO_DATE('2026-10-19', 'YYYY-MM-DD'), 'Y',
    'Caso de alta prioridad con intervencion de la UDEX y coordinacion con Fiscalia Contra el Crimen Organizado.'
);

-- ----------------------------------------------------------------------------
-- 19. COMPLAINT STATUS HISTORIES (FULL AUDIT TRAIL)
-- ----------------------------------------------------------------------------
-- Complaint 1001 Trail: 1 -> 2 -> 3
INSERT INTO COMPLAINT_STATUS_HISTORIES (history_id, complaint_id, from_status_id, to_status_id, authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes)
VALUES (1401, 1001, NULL, 1, 501, TO_TIMESTAMP('2026-10-15 11:20:00', 'YYYY-MM-DD HH24:MI:SS'), 'Registro inicial en mesa de partes virtual por comerciante afectado.', 'Se recepciono la nota y el proyectil bajo cadena de custodia.');

INSERT INTO COMPLAINT_STATUS_HISTORIES (history_id, complaint_id, from_status_id, to_status_id, authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes)
VALUES (1402, 1001, 1, 2, 503, TO_TIMESTAMP('2026-10-15 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Validacion de competencia funcional y evaluacion de riesgo critico.', 'Se califica como delito flagrante de extorsion agravada.');

INSERT INTO COMPLAINT_STATUS_HISTORIES (history_id, complaint_id, from_status_id, to_status_id, authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes)
VALUES (1403, 1001, 2, 3, 503, TO_TIMESTAMP('2026-10-16 08:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'Asignacion formal de detective principal mediante Memo N° 045-DEPINCRI.', 'Asignado al Tnte. Montesinos con apoyo del Grupo Halcon 1.');

-- Complaint 1002 Trail: 1 -> 2 -> 3 -> 4
INSERT INTO COMPLAINT_STATUS_HISTORIES (history_id, complaint_id, from_status_id, to_status_id, authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes)
VALUES (1404, 1002, NULL, 1, 502, TO_TIMESTAMP('2026-10-19 08:15:00', 'YYYY-MM-DD HH24:MI:SS'), 'Registro de urgencia por explosion en frontis comercial.', 'Acta de constatacion policial preliminar efectuada en el lugar.');

INSERT INTO COMPLAINT_STATUS_HISTORIES (history_id, complaint_id, from_status_id, to_status_id, authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes)
VALUES (1405, 1002, 1, 2, 503, TO_TIMESTAMP('2026-10-19 09:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'Triaje urgente aprobado por Comisario.', 'Derivado a unidad especializada de extorsiones.');

INSERT INTO COMPLAINT_STATUS_HISTORIES (history_id, complaint_id, from_status_id, to_status_id, authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes)
VALUES (1406, 1002, 2, 3, 503, TO_TIMESTAMP('2026-10-19 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Apertura de caso fiscal coordinado.', 'Asignado a detective Montesinos y equipo de analisis digital.');

INSERT INTO COMPLAINT_STATUS_HISTORIES (history_id, complaint_id, from_status_id, to_status_id, authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes)
VALUES (1407, 1002, 3, 4, 501, TO_TIMESTAMP('2026-10-23 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Plan de operaciones aprobado para captura en entrega pactada.', 'Se coordina operativo de seuelo con apoyo de la Fiscalia.');

-- Complaint 1003 Trail: 1 -> 2
INSERT INTO COMPLAINT_STATUS_HISTORIES (history_id, complaint_id, from_status_id, to_status_id, authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes)
VALUES (1408, 1003, NULL, 1, 504, TO_TIMESTAMP('2026-10-22 16:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'Registro bajo clave de proteccion de testigo.', 'Identidad resguardada de acuerdo a ley.');

INSERT INTO COMPLAINT_STATUS_HISTORIES (history_id, complaint_id, from_status_id, to_status_id, authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes)
VALUES (1409, 1003, 1, 2, 504, TO_TIMESTAMP('2026-10-23 10:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'Validacion de elementos de conviccion.', 'Verificado numero emisor de amenazas extorsivas.');

-- Complaint 1004 Trail: 1
INSERT INTO COMPLAINT_STATUS_HISTORIES (history_id, complaint_id, from_status_id, to_status_id, authorized_by_officer_id, change_timestamp, transition_reason, investigation_notes)
VALUES (1410, 1004, NULL, 1, 501, TO_TIMESTAMP('2026-10-28 07:05:00', 'YYYY-MM-DD HH24:MI:SS'), 'Recepcion en modulo de atencion al ciudadano.', 'A la espera de evaluacion por oficial de guardia.');

PROMPT Loading Area 6: Patrol Units and Field Interventions...

-- ----------------------------------------------------------------------------
-- 20. PATROL UNITS (VEHICLES & MOTORCYCLES)
-- ----------------------------------------------------------------------------
INSERT INTO PATROL_UNITS (patrol_id, station_id, unit_code, unit_type, is_available)
VALUES (1501, 101, 'PL-20412', 'Patrol Car Hilux 4x4', 'Y');

INSERT INTO PATROL_UNITS (patrol_id, station_id, unit_code, unit_type, is_available)
VALUES (1502, 101, 'MOTO-AU-05', 'Tactical Motorcycle 250cc', 'Y');

INSERT INTO PATROL_UNITS (patrol_id, station_id, unit_code, unit_type, is_available)
VALUES (1503, 102, 'PL-18930', 'Patrol Car Sedan', 'Y');

INSERT INTO PATROL_UNITS (patrol_id, station_id, unit_code, unit_type, is_available)
VALUES (1504, 103, 'MOTO-SO-12', 'Tactical Motorcycle 250cc', 'Y');

-- ----------------------------------------------------------------------------
-- 21. FIELD INTERVENTIONS (OPERATIONS IN CRIME HOTSPOTS)
-- ----------------------------------------------------------------------------
INSERT INTO FIELD_INTERVENTIONS (intervention_id, sector_id, patrol_id, intervention_timestamp, intervention_type, operational_result, summary_report)
VALUES (
    1601, 201, 1501,
    TO_TIMESTAMP('2026-10-20 17:30:00', 'YYYY-MM-DD HH24:MI:SS'),
    'TARGETED_PATROL', 'PATROL_COMPLETED',
    'Patrullaje disuasivo focalizado en el cuadrante comercial de Las Malvinas. Se realizaron 35 controles de identidad preventivos.'
);

INSERT INTO FIELD_INTERVENTIONS (intervention_id, sector_id, patrol_id, intervention_timestamp, intervention_type, operational_result, summary_report)
VALUES (
    1602, 203, 1503,
    TO_TIMESTAMP('2026-10-24 16:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    'RAID_STING_OPERATION', 'SUSPECT_DETAINED',
    'Operativo conjunto en flagrancia durante el cobro de cupo extorsivo. Se detuvo a un sujeto apodado Chato Frank con arma de fuego y dinero incautado.'
);

-- ----------------------------------------------------------------------------
-- 22. INTERVENTION COMPLAINTS (M:N LINKAGE)
-- ----------------------------------------------------------------------------
-- Intervention 1601 covered Complaint 1001
INSERT INTO INTERVENTION_COMPLAINTS (intervention_id, complaint_id)
VALUES (1601, 1001);

-- Intervention 1602 solved/impacted Complaint 1001 and Complaint 1002
INSERT INTO INTERVENTION_COMPLAINTS (intervention_id, complaint_id)
VALUES (1602, 1001);

INSERT INTO INTERVENTION_COMPLAINTS (intervention_id, complaint_id)
VALUES (1602, 1002);

-- ----------------------------------------------------------------------------
-- 23. INTERVENTION OFFICERS (DEPLOYED AGENTS)
-- ----------------------------------------------------------------------------
INSERT INTO INTERVENTION_OFFICERS (intervention_id, officer_id, tactical_role)
VALUES (1601, 508, 'Driver / Conductor de Patrullero');

INSERT INTO INTERVENTION_OFFICERS (intervention_id, officer_id, tactical_role)
VALUES (1601, 509, 'Operador de Seguridad Perimetral');

INSERT INTO INTERVENTION_OFFICERS (intervention_id, officer_id, tactical_role)
VALUES (1602, 505, 'Lider Operativo / Detective a Cargo');

INSERT INTO INTERVENTION_OFFICERS (intervention_id, officer_id, tactical_role)
VALUES (1602, 508, 'Agente de Reduccion y Esposamiento');

INSERT INTO INTERVENTION_OFFICERS (intervention_id, officer_id, tactical_role)
VALUES (1602, 509, 'Custodia de Evidencias e Incautacion');

COMMIT;

PROMPT ============================================================================
PROMPT Mock data loaded successfully! Verification summary:
PROMPT ============================================================================

SELECT 'POLICE_DIVISIONS' AS TABLE_NAME, COUNT(*) AS TOTAL_ROWS FROM POLICE_DIVISIONS
UNION ALL
SELECT 'POLICE_STATIONS', COUNT(*) FROM POLICE_STATIONS
UNION ALL
SELECT 'NEIGHBORHOOD_SECTORS', COUNT(*) FROM NEIGHBORHOOD_SECTORS
UNION ALL
SELECT 'COMMUNITY_WATCHES', COUNT(*) FROM COMMUNITY_WATCHES
UNION ALL
SELECT 'COMMUNITY_COORDINATORS', COUNT(*) FROM COMMUNITY_COORDINATORS
UNION ALL
SELECT 'POLICE_RANKS', COUNT(*) FROM POLICE_RANKS
UNION ALL
SELECT 'POLICE_OFFICERS', COUNT(*) FROM POLICE_OFFICERS
UNION ALL
SELECT 'SUPPORT_TEAMS', COUNT(*) FROM SUPPORT_TEAMS
UNION ALL
SELECT 'SUPPORT_TEAM_MEMBERS', COUNT(*) FROM SUPPORT_TEAM_MEMBERS
UNION ALL
SELECT 'CURRENCIES', COUNT(*) FROM CURRENCIES
UNION ALL
SELECT 'EXTORTION_MODALITIES', COUNT(*) FROM EXTORTION_MODALITIES
UNION ALL
SELECT 'COMPLAINANTS', COUNT(*) FROM COMPLAINANTS
UNION ALL
SELECT 'AFFECTED_ESTABLISHMENTS', COUNT(*) FROM AFFECTED_ESTABLISHMENTS
UNION ALL
SELECT 'CRIMINAL_ORGANIZATIONS', COUNT(*) FROM CRIMINAL_ORGANIZATIONS
UNION ALL
SELECT 'COMPLAINTS', COUNT(*) FROM COMPLAINTS
UNION ALL
SELECT 'COMPLAINT_SUSPECTS', COUNT(*) FROM COMPLAINT_SUSPECTS
UNION ALL
SELECT 'DIGITAL_EVIDENCES', COUNT(*) FROM DIGITAL_EVIDENCES
UNION ALL
SELECT 'COMPLAINT_STATUSES', COUNT(*) FROM COMPLAINT_STATUSES
UNION ALL
SELECT 'INVESTIGATION_CASES', COUNT(*) FROM INVESTIGATION_CASES
UNION ALL
SELECT 'COMPLAINT_STATUS_HISTORIES', COUNT(*) FROM COMPLAINT_STATUS_HISTORIES
UNION ALL
SELECT 'PATROL_UNITS', COUNT(*) FROM PATROL_UNITS
UNION ALL
SELECT 'FIELD_INTERVENTIONS', COUNT(*) FROM FIELD_INTERVENTIONS
UNION ALL
SELECT 'INTERVENTION_COMPLAINTS', COUNT(*) FROM INTERVENTION_COMPLAINTS
UNION ALL
SELECT 'INTERVENTION_OFFICERS', COUNT(*) FROM INTERVENTION_OFFICERS;
