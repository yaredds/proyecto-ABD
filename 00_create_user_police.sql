-- ============================================================================
-- SCRIPT: 00_create_user_police.sql (CORREGIDO PARA ORACLE MULTITENANT EN DOCKER)
-- RUN THIS SCRIPT CONNECTED AS SYSTEM IN SQL DEVELOPER
-- ============================================================================

-- Permite crear usuarios locales sin el prefijo C## en la arquitectura Multitenant
ALTER SESSION SET "_ORACLE_SCRIPT"=true;

-- 1. Crear el usuario administrador del aplicativo
CREATE USER POLICE_ADMIN IDENTIFIED BY "Police2026#Secure"
DEFAULT TABLESPACE USERS
TEMPORARY TABLESPACE TEMP
QUOTA UNLIMITED ON USERS;

-- 2. Asignar roles y privilegios necesarios
GRANT CONNECT, RESOURCE TO POLICE_ADMIN;
GRANT CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE, CREATE TRIGGER TO POLICE_ADMIN;

PROMPT ============================================================================
PROMPT Usuario POLICE_ADMIN creado exitosamente!
PROMPT Ahora crea una nueva conexion en SQL Developer con:
PROMPT   Usuario: POLICE_ADMIN
PROMPT   Contrasena: Police2026#Secure
PROMPT ============================================================================
