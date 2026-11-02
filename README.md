# Sistema de Gestión Geoespacial de Denuncias Ciudadanas, Alertas de Extorsión y Control Operativo Policial

**Universidad Nacional Mayor de San Marcos**  
*Facultad de Ingeniería de Sistemas e Informática (FISI)*  
*Escuela Profesional de Ingeniería de Sistemas (EPIS)*  
**Curso:** Administración de Base de Datos (Semestre 2026-2)  
**Entrega:** Entrega Parcial 2  

---

## 📌 1. Resumen Ejecutivo y Correcciones sobre el Entregable 1

Para la Entrega Parcial 2, se realizó una refactorización integral del diseño conceptual y lógico del Entregable 1 con el fin de alinearlo estrictamente a la rúbrica y los requerimientos del cliente:

1. **Cumplimiento de la Política Corporativa de Idioma (Inglés Técnico):**  
   Se tradujeron la totalidad de entidades, atributos, restricciones (`PK_`, `FK_`, `UQ_`, `CK_`), índices (`IDX_`), paquetes, procedimientos y comentarios al idioma inglés, tal como exige la especificación oficial del proyecto.
2. **Soporte Multimoneda:**  
   Se incorporó la entidad `CURRENCIES` (códigos ISO 4217: `PEN`, `USD`, `EUR`) para soportar de forma nativa exigencias extorsivas en distintas monedas.
3. **Modelado Geoespacial de Alta Precisión:**  
   Se definieron polígonos geoespaciales para los sectores vecinales (`boundary_coordinates` en formato GeoJSON/WKT) y coordenadas GPS de latitud y longitud con precisión sub-métrica para comisarías, comercios afectados e incidentes delictivos.
4. **Normalización de Equipos de Apoyo Policial:**  
   Se corrigió la relación de soporte táctico mediante la entidad asociativa `SUPPORT_TEAM_MEMBERS`, permitiendo registrar la participación de múltiples agentes bajo roles operativos específicos.
5. **Ciclo de Vida de 6 Estados con Auditoría Histórica:**  
   Se centralizó el seguimiento en `COMPLAINT_STATUS_HISTORIES`, asegurando la trazabilidad de las transacciones desde su ingreso (`REGISTERED`), triaje (`VALIDATED_STATION`), investigación (`UNDER_INVESTIGATION`), intervención (`INTERVENTION_SCHEDULED`), fiscalía (`REFERRED_PROSECUTOR`) hasta su resolución (`ARCHIVED_RESOLVED`).
6. **Trigger de Regla de Negocio Crítica (Carga Máxima de Casos):**  
   Se implementó un `COMPOUND TRIGGER` en Oracle para asegurar que ningún detective pueda liderar más de $N = 3$ casos activos simultáneos, evitando el error de mutación de tablas (`ORA-04091`).

---

## 🏗️ 2. Áreas de Información del Modelo de Datos

El modelo lógico y físico se encuentra normalizado (3FN) y estructurado en **6 Áreas de Dominio**:

* **Área 1: Territory & Jurisdiction:** `POLICE_DIVISIONS`, `POLICE_STATIONS`, `NEIGHBORHOOD_SECTORS`.
* **Área 2: Community Network:** `COMMUNITY_WATCHES`, `COMMUNITY_COORDINATORS`.
* **Área 3: Police Personnel & Hierarchy:** `POLICE_RANKS`, `POLICE_OFFICERS`, `SUPPORT_TEAMS`, `SUPPORT_TEAM_MEMBERS`.
* **Área 4: Extortion Intelligence & Complaints:** `CURRENCIES`, `EXTORTION_MODALITIES`, `COMPLAINANTS`, `AFFECTED_ESTABLISHMENTS`, `CRIMINAL_ORGANIZATIONS`, `COMPLAINTS`, `COMPLAINT_SUSPECTS`, `DIGITAL_EVIDENCES`.
* **Área 5: Investigation Lifecycle & Workflow:** `COMPLAINT_STATUSES`, `INVESTIGATION_CASES`, `COMPLAINT_STATUS_HISTORIES`.
* **Área 6: Field Operations & Patrols:** `PATROL_UNITS`, `FIELD_INTERVENTIONS`, `INTERVENTION_COMPLAINTS`, `INTERVENTION_OFFICERS`.

---

## 📁 3. Estructura de Scripts y Orden de Ejecución en Oracle

Todos los scripts deben ejecutarse en **Oracle Database (Docker / On-Premise)** utilizando **Oracle SQL Developer**:

| Script | Nombre del Archivo | Descripción | Usuario de Ejecución |
| :--- | :--- | :--- | :--- |
| **00** | `00_create_user_police.sql` | Crea el usuario/esquema `POLICE_ADMIN`, asigna cuotas y privilegios. | Conectado como `SYSTEM` |
| **01** | `01_create_schema_oracle.sql` | Genera las 24 tablas DDL, Primary Keys, Foreign Keys, Checks e Índices B-Tree. | Conectado como `POLICE_ADMIN` |
| **02** | `02_data_load.sql` | Carga masiva de datos realistas (Lima Metropolitana, casos en PEN y USD, audios, fotos y bandas). | Conectado como `POLICE_ADMIN` |
| **03** | `03_stored_procedures_packages.sql` | Secuencias, Packages (`PKG_COMPLAINT_MGMT`, `PKG_INVESTIGATION_OPS`) y Compound Trigger. | Conectado como `POLICE_ADMIN` |
| **04** | `04_test_cases.sql` | Suite automatizada de pruebas funcionales y validación del Trigger de casos máximos. | Conectado como `POLICE_ADMIN` |

---

## 🧪 4. Resumen de Pruebas Funcionales (`04_test_cases.sql`)

El script de pruebas es **idempotente** (puede re-ejecutarse indefinidamente) y valida:

1. **TEST 1 (Registro de Denuncia):** Inserción exitosa de denuncia extorsiva y generación automática del primer registro de auditoría en estado `REGISTERED`.
2. **TEST 2 (Triaje en Comisaría):** Validación por oficial de guardia y transición de estado a `VALIDATED_STATION`.
3. **TEST 3 (Asignación a Capacidad Límite):** Asignación del detective hasta completar su tope permitido ($N = 3$ casos activos).
4. **TEST 4 (Prueba de Fuego del Trigger):** Intento deliberado de asignar un 4to caso activo al detective. **El trigger intercepta la transacción y arroja la excepción esperada `-20001`**.
5. **TEST 5 (Liberación de Carga Laboral):** Cierre formal de un caso resuelto (`SP_CLOSE_CASE`). La carga laboral desciende a 2 y la asignación pendiente se completa exitosamente.
6. **TEST 6 (Analítica Geoespacial y Multimoneda):** Cálculo de agregaciones monetarias agrupadas por cuadrante vecinal en PEN y USD.

---

## 🖼️ 5. Diagramas Generados en PowerDesigner 16.5

En este repositorio se incluyen los diagramas generados mediante **Ingeniería Inversa** y exportados en alta definición:
* `Geospatial_Police_System_PDM - M Fisico.jpg`: Diagrama físico con tipos Oracle nativos (`NUMBER`, `VARCHAR2`, `TIMESTAMP`, `CLOB`), constraints e índices.
* `Geospatial_Police_System_PDM - M Logico.jpg`: Diagrama lógico estructurado por áreas de información.

---

## 👥 6. Guía para la Redacción del Informe Escrito (Para el Equipo)

Al redactar el documento Word de la **Entrega Parcial 2**, incluir:
1. **Sección: Modelo de Datos Lógico (Versión Corregida):**
   * Pegar la imagen `Geospatial_Police_System_PDM - M Logico.jpg`.
   * Describir la justificación de los cambios realizados respecto al Entregable 1 (Sección 1 de este README).
2. **Sección: Modelo de Datos Físico:**
   * Pegar la imagen `Geospatial_Police_System_PDM - M Fisico.jpg`.
   * Incluir el diccionario de datos físico (tablas, columnas, tipos de datos Oracle, longitudes y constraints).
3. **Sección: Esquema de Base de Datos en Oracle:**
   * Detallar el propósito de cada script (`00` al `04`).
   * Pegar capturas de pantalla de la salida exitosa en SQL Developer de la creación de tablas, la carga de datos y la salida del script de pruebas.
