## Plan de Migración: Mediateca WordPress a Omeka S

**Objetivo:** Migrar de forma segura los recursos digitales educativos y sus metadatos de la Mediateca de WordPress a Omeka S, estableciéndolos como ítems de omeka dentro de colecciones digitales (ItemSets).

Este documento sirve como guía principal para el equipo de CAUCE en la ejecución de la migración final al entorno de producción. Detalla los prerrequisitos, los pasos de migración, las verificaciones de calidad y las tareas post-lanzamiento. Las fases previas (1-3) describen el trabajo de desarrollo y pruebas ya realizado, y sirven de referencia técnica para los procedimientos aquí detallados.

**Fases de la migración**
    Para realizar la migración de los canales de la Mediateca se han planteado las siguientes fases, que se desarrollarán con más detalle posteriormente en este informe:
*   Fase 1: Pre-Migración y Planificación (Referencia)
*   Fase 2: Migración y Pruebas en el entorno de pruebas local (Iterativo) (Referencia)
*   Fase 3: Migración total de la mediateca de ATE en Servidor de Desarrollo (Referencia)
*   Fase 4: Migración Final en Producción (Ejecución por CAUCE)
*   Fase 5: Post-Migración y Aseguramiento de la Calidad (Valorar por CAUCE y acción coordinada)
*   Fase 6: Puesta en Marcha y Post-Lanzamiento (Coordinado)


**Estado actual de la migración**
    Actualmente se han finalizado las fases 1 y 2 y se estima tener finalizada la fase 3 en la primerna semana de Junio 2025. Una vez finalizada la fase 3, mientras se realiza la migración a los entornos de producción nos centraríamos en el desarrollo de la vista pública de los sitios principales que se migrarán, esto es, la mediateca de ATE y la web de recursos educativos.
    Por otro lado, para la web de recursos educativos se prevee la necesidad de desarrollar un plugin para visualizar desde el propio sitio los recursos educativos, permitiendo navegar el contenido del zip que contiene cada recurso.

## Prerrequisitos: Herramientas, Archivos y Acceso Necesarios

Antes de iniciar la Fase 4 (Migración Final en Producción), CAUCE debe verificar la disponibilidad y acceso a los siguientes elementos:

*   **1. Fichero de Exportación XML de WordPress:** El archivo XML final validado, resultado de la exportación de WordPress.
*   **2. Acceso al Entorno de Producción Omeka S:**
    *   URL de la instancia de Omeka S en producción.
    *   Credenciales de administrador para la instancia de Omeka S.
*   **3. Archivos de Transformación y Mapeo (parte del paquete de migración):**
    *   **Archivos XSL Personalizados:**
        *   `xsl/xsl_omeka_itemset.xsl` (para extraer categorías/ItemSets)
        *   `xsl/xsl_item_preprocessor.xsl` (para extraer metadatos de entradas/Items y medios)
    *   **Archivos Mapper de Omeka S:**
        *   `Mapping/mapper_wp_xml_itemsets.xml`
        *   `Mapping/mapper_wp_post_omeka_items.xml`
        *   `Mapping/mapper_wp_post_omeka_media.xml`
    *   **Plantillas de Recurso JSON:**
        *   `Assets/Templates/autor.json`
        *   `Assets/Templates/categoria.json`
*   **4. Módulos de Omeka S (versiones específicas):** La siguiente lista de módulos debe estar disponible para su instalación en el Omeka S de producción, coincidiendo con las versiones probadas:
    *   Common - 3.4.66
    *   Log - 3.4.27
    *   Advanced Resource Template - 3.4.39
    *   Bulk Export - 3.4.36
    *   Bulk Import - 3.4.58
    *   CSV Import - 2.6.2
    *   Custom Vocab - 2.0.2
    *   Disk Quota - 1.0.1
    *   Easy Admin - 3.4.29
    *   Faceted Browse - 1.7.0
    *   Hierarchy - 1.1.2
    *   IsolatedSites - 1.0.0
    *   ThreeDViewer - 1.0.4
*   **5. Credenciales de Acceso al Servidor de Producción:**
    *   Acceso SSH o equivalente al servidor donde reside Omeka S producción, con permisos suficientes para:
        *   Gestionar archivos (copiar los XSL, Mappers, etc.).
        *   Ejecutar comandos del sistema (ej. `sed` si es necesario para la política de ImageMagick).
        *   Acceder a logs del servidor web y de PHP.
*   **6. Documentación de Referencia:**
    *   Este mismo documento (`Planning.md`).
    *   Cualquier otra documentación técnica entregada por el equipo de desarrollo.
*   **7. Aplicaciones y librerias en servidor**
    *   ffmpeg: para procesado de video
    *   

## Terminología Clave

*   **Item:** En Omeka S, un "Item" es la unidad básica de contenido. Representa un recurso digital individual (ej. una fotografía, un documento, un vídeo, una entrada de blog migrada). Cada ítem tiene metadatos asociados.
*   **Item Set:** Un "Item Set" es una colección o agrupación de Items. En esta migración, las categorías de WordPress se convierten en Item Sets en Omeka S. Los Item Sets ayudan a organizar y navegar el contenido.
*   **Media:** En Omeka S, "Media" se refiere a los archivos digitales asociados a un Item (ej. el archivo JPG de una imagen, el archivo PDF de un documento). Un Item puede tener múltiples archivos Media.
*   **Plantilla de Recurso (Resource Template):** Una estructura predefinida de campos de metadatos que se puede aplicar a Items, Item Sets u otros recursos en Omeka S. Ayuda a estandarizar la descripción de los recursos. (ej. `autor.json`, `categoria.json`).
*   **Mapper:** En el contexto del módulo `Bulk Import` de Omeka S, un Mapper es un archivo XML (ej. `mapper_wp_post_omeka_items.xml`) que define cómo los datos de una fuente externa (procesados por un XSLT) se asignan a los campos de metadatos de un Item, Item Set o Media en Omeka S.


### Fase 1: Pre-Migración y Planificación (Referencia)

1.  **Definir Alcance y Requisitos:**
    *   **Mapeo de Metadatos:** Ten un mapa claro y documentado de cómo cada campo de metadatos de WordPress (incluidos los campos personalizados) se asignará a los elementos de Dublin Core de Omeka S o a los vocabularios personalizados que hayas definido.
        - Mapeo de colecciones de wordpress a item sets de Omeka:
            | WordPress Term Field | Omeka S Field | Datatype | Notes |
            |---------------------|---------------|----------|-------|
            | `wp:term/term_name` | `dcterms:title` | literal | Item Set title |
            | `wp:term/term_id` | `dcterms:identifier` | literal | WordPress term ID |
            | `wp:term/term_slug` | `dcterms:identifier` | literal | WordPress term slug |
            | `wp:term/term_parent` | `dcterms:isPartOf` | literal | Parent term reference |
            | (hardcoded) | `resource_name` | raw="o:Item_set" | Resource type specification |

        - Mapeo de entradas mediateca a items:
            | WordPress Field | Omeka S Field | Datatype | Notes |
            |----------------|---------------|----------|-------|
            | `title` | `dcterms:title` | (default) | Post title |
            | `wp:post_id` | `dcterms:identifier` | (default) | WordPress post ID |
            | `dc:creator` | `dcterms:creator` | (default) | Original author |
            | `description` | `dcterms:description` | (default) | Post description |
            | `wp:post_name` | `dcterms:replaces` | (default) | WordPress slug |
            | `wp:post_date` | `dcterms:date` | literal | Publication date |
            | `category[@domain='media-tag']` | `dcterms:relation` | literal | Media tags |
            | `wp:postmeta[meta_key='meta_author']` | `dcterms:contributor` | literal | Custom author metadata |
            | `wp:postmeta[meta_key='meta_copyright']` | `dcterms:rights` | literal | Copyright information |
            | `wp:postmeta[meta_key='meta_language']` | `dcterms:language` | literal | Language metadata |
            | `category[@domain='media-category']` | `o:item_set` | literal | Collection/Item Set assignment |
            | (hardcoded) | `resource_name` | raw="o:Item" | Resource type specification |


        - Mapeo de entradas mediateca a items media:
            Una vez introducidos los metadatos de las entradas en items se realiza la carga de los medios asociados a cada item

            | WordPress Field | Omeka S Field | Datatype | Notes |
            |----------------|---------------|----------|-------|
            | `title` | `dcterms:title` | (default) | Media title |
            | `wp:post_id` | `o:item` | literal | Links media to parent item |
            | `dc:creator` | `dcterms:creator` | (default) | Original author |
            | `description` | `dcterms:description` | (default) | Media description |
            | `wp:post_name` | `dcterms:replaces` | (default) | WordPress slug |
            | `wp:post_date` | `dcterms:date` | literal | Publication date |
            | `content:encoded` | `html` | (default) | HTML content |
            | `wp:attachment_url` | `url` | uri | Media file URL |
            | `wp:postmeta[meta_key='meta_author']` | `dcterms:contributor` | literal | Custom author metadata |
            | `wp:postmeta[meta_key='meta_copyright']` | `dcterms:rights` | literal | Copyright information |
            | (hardcoded) | `resource_name` | raw="o:Media" | Resource type specification |

    *   **Colecciones/Relaciones:**
        En la mediateca de wordpress las entradas están catalogadas por categorías que siguen una estructura de árbol, pudiendo cada entrada pertenecer a una o varias categorías. En Omeka, cada categoría será un ItemSet y para realizar la estructura de árbol se ha usado el módulo `Hierarchy`.
        Por otro lado, cada entrada puede tener una o varias etiquetas (media-tag) que se han añadido a campo `dcterms:relation` de la ontología Dublin Core en OmekaS. Se puede usar el módulo `Fields as Tags` para usar las etiquetas en la navegación.

    *   **Manejo de Archivos:** ¿Los archivos están incrustados en el XML o vinculados? Tus scripts deben encargarse de descargar/cargar lateralmente estos archivos en Omeka S. Asegúrate de que las rutas de los archivos sean correctas.

    *   **Estructura de Sitios Omeka S:** Planifica los **Sitios** de Omeka S donde residirán estas colecciones. ¿Habrá un sitio principal o varios sitios educativos? ¿Cómo se organizarán los conjuntos de ítems dentro de ellos?
        Dentro de la estructura de sitios de Omeka, se prevee un sitio por cada canal de mediateca y por cada repositorio digital dentro de la DGOEII. Como opción adicional, que puede resultar interesante para acciones puntuales, se pueden crear sitios específicos para exhibiciones de colecciones digitales concretas (día de Canarias, patrimonio, REF, etc).

        - **Sitios previstos**
            - **Mediateca ATE** (https://www3.gobiernodecanarias.org/medusa/mediateca/ecoescuela/?media-tag=ate)
            - **Recursos Educativos** (https://www3.gobiernodecanarias.org/medusa/ecoescuela/recursosdigitales/)
            - **Canales de mediateca de centros educativos**

2.  **Configuración del Entorno Omeka S:**
    *   **Entorno Dedicado de Desarrollo:**
        Se ha configurado un servidor local Omeka S para realizar pruebas y desarrollar los ficheros que automatizan la migración
    *   **Instalar y Configurar Omeka S:**
    *   **Instalar Módulos Necesarios:**
        *   **Bulk Import (Esencial):** Asegúrate de que esté instalado y habilitado.


### Fase 2: Migración y Pruebas en el entorno de pruebas local (Iterativo) (Referencia)

0.  **Desarrollo y Refinar Scripts XSL y mappers:**

    Se han desarrollado los ficheros XSL para preprocesado del fichero de exportación de wordpress así como los mappers de forma iterativa, corriendo errores y refinando para mejorar rendimiento, seguridad, logging y manejo de errores.

1.  **Importación de Prueba con Lote Pequeño:**
    *   **Seleccionamos una muestra representativa:** Elegimos un pequeño número de ítems (p. ej., 5-20) que representen varios tipos de contenido, complejidad de metadatos y tipos de archivos de tu exportación de WordPress. Se incluyen ítems con caracteres especiales, datos faltantes, múltiples archivos, etc. Convertimos este pequeño lote XML al formato de `Bulk Import` de Omeka S en XML.
    *   **Realizamos la Importación Masiva:** Utiliza el módulo `Bulk Import` de Omeka S para importar este pequeño lote en tu instancia de Omeka S.
    *   **Verificación Exhaustiva:**
        *   **Precisión de Metadatos:**
        *   **Integridad de Archivos:**
        *   **Relaciones:**
        *   **Búsqueda y Navegación:**
        *   **Visualización Pública:**

2.  **Iterar y Refinar:**
    Con un lote pequeño de items se realizan las modificaciones necesarias para refinar el proceso de migración (errores, seguridad, rendimiento, ...)

3.  **Pruebas con Lote Mediano**

4.  **Simulacro de lotes mayores de datos:**
    Se ha realizado la prueba de migrar un año entero (~1800 items)

5. **Resolver particularidades de la mediateca**
    *   Créditos en algunos items (logos por ser contenido financiado por alguna entidad (FEDER, ...)): Se valora añadirlos mediante CSS.
    *   Añadir extensiones a la configuración de OMEKA-S:
        - En tipo MIME: `application/postscript`, `image/x-eps`, `text/vtt`, `application/x-zip-compressed`
        - En extensiones permitidas: `eps`, `vtt`
    *   Procesado de medios EPS: ejecutar en servidor:
    ```bash
    sed -i 's|<policy domain="coder" rights="none" pattern="EPS" />|<!-- <policy domain="coder" rights="none" pattern="EPS" /> -->|' /etc/ImageMagick-6/policy.xml
    ```

### Fase 3: Migración total de la mediateca de ATE en Servidor de Desarrollo (Referencia)

1.  **Pasos previos a la carga de archivos XML**
    *   **Añadir extensiones a la configuración de OMEKA-S**:
        *   Para permitir la subida de nuevos tipos de archivo, navegue en la interfaz de administración de Omeka S a `Global Settings > Security` (o la ruta equivalente en su versión, como `Admin > Settings > Security`). En el campo "Allowed File Extensions" (Extensiones de archivo permitidas), añada las siguientes extensiones (separadas por comas si ya existen otras): `eps`, `vtt`, `zip`.
        *   A continuación, vaya a `Admin > Vocabularies > MIME Types` (o `Admin > Settings > Media Types` o similar, dependiendo de la versión de Omeka S y los módulos activados). Asegúrese de que los siguientes tipos MIME estén presentes o añádalos:
            *   `application/postscript` (para .eps)
            *   `image/x-eps` (alternativo para .eps)
            *   `text/vtt` (para .vtt)
            *   `application/zip` o `application/x-zip-compressed` (para .zip)
    *   Procesado de medios EPS: ejecutar en servidor:
    ```bash
    sed -i 's|<policy domain="coder" rights="none" pattern="EPS" />|<!-- <policy domain="coder" rights="none" pattern="EPS" /> -->|' /etc/ImageMagick-6/policy.xml
    ```
    *   **Importación de plantillas de recursos**:
        *   Estas plantillas definen la estructura de metadatos para tipos específicos de recursos en Omeka S. Se trata de archivos JSON que se importan a través de la interfaz de Omeka.
        *   **Plantilla autores**: Navegue a `Admin > Templates`. Haga clic en el botón "Import" y seleccione el archivo `Assets/Templates/autor.json`. Confirme la importación. Esta plantilla se usará para los items que representan autores.
        *   **Plantilla Categoría**: Repita el proceso anterior. Navegue a `Admin > Templates`. Haga clic en "Import" y seleccione el archivo `Assets/Templates/categoria.json`. Confirme la importación. Esta plantilla podría usarse para los ItemSets si se requiere una estructura específica más allá de los campos básicos.
    *   **Realizar la migración de los autores `<wp:authors>`**:
        *   Usar el fichero **autores_csv.csv**
        *   **Bulk import => Importación de items CSV (Módulo `CSV Import`)**: Utilizar el módulo `CSV Import` de Omeka S para importar los autores como items individuales.
            *   **1ra pasada: Creación de recursos**:
                *   **Plantilla de Recurso**: Utilizar la plantilla "autores" importada previamente.
                *   **Mapeo**: Mapear las columnas del CSV a los campos correspondientes de la plantilla "autores" (e.g., `author_display_name` a `dcterms:title`, `author_id` a `dcterms:identifier`).
                *   **Acción**: Seleccionar "Create new items".
                *   **Identificador único**: Especificar la columna del CSV `author_id`.
            *   **2da pasada: Append data to resources**:
                *   **Identificador**: Usar el campo mapeado a `dcterms:identifier` (`author_id` de WP).
                *   **Acción**: Seleccionar "Append to existing items", "Replace in existing items" o "Update existing items".
2.  **Configuración Módulo `Bulk Import`**:
    *   Las siguientes configuraciones son para el módulo `Bulk Import`. Usar rutas `Mapping/` y `xsl/`.
    *   **0. WP XML-ItemSets (Importación de Colecciones/Categorías)**
        *   **Mapper**: `Mapping/mapper_wp_xml_itemsets.xml`
        *   **XSL Proc**: `xsl/xsl_omeka_itemset.xsl`
        *   **Params**: (Según se definan en la interfaz del módulo `Bulk Import` si el XSL los requiere).
    *   **1. WP XML- Items (Importación de Entradas/Items Principales)**
        *   **Mapper**: `Mapping/mapper_wp_post_omeka_items.xml`
        *   **XSL Proc**: `xsl/xsl_item_preprocessor.xsl`
        *   **Params**:
            ```bash
            postType=attachement
            postParent=0
            Media=0
            ```
    *   **2. WP XML - Media (Importación de Medios Adjuntos a los Items)**
        *   **Mapper**: `Mapping/mapper_wp_post_omeka_media.xml`
        *   **XSL Proc**: `xsl/xsl_item_preprocessor.xsl`
        *   **Params**:
            ```bash
            postType=attachement
            postParent=0
            Media=1
            ```
3.  **Importación de colecciones (Secuencia de ejecución con `Bulk Import`)**:
    *   0.WP ML-ItemSets**
    *   1.WP XML-Items**
    *   2.WP XML-Media**

- Realizar documentación paso a paso desde una instalación de Omeka básica del proceso de migración para facilitar trabajo a CAUCE.
- Realizar el desarrollo del site donde se visualizarán los recursos digitales para facilitar su diseño posteriormente en producción.


### Fase 4: Migración Final en Producción (Ejecución por CAUCE)

Esta fase es responsabilidad de CAUCE y consiste en replicar el proceso de migración realizado en el servidor de desarrollo (Fase 3) en el entorno de producción final. Se requiere una planificación cuidadosa y la ejecución de los pasos con supervisión.

**A. Preparación del Entorno de Producción (Pre-Flight Checks):**

* **A1. Compatibilidad de Omeka S:** Verificar que la versión de Omeka S instalada en el servidor de producción sea idéntica a la utilizada durante el desarrollo y pruebas (consultar Prerrequisitos y Fase 3).
* **A2. Instalación y Configuración de Módulos Omeka S:** Instalar y activar todas las versiones de los módulos necesarios (ver lista en Prerrequisitos), asegurándose de que coincidan con las versiones probadas.
* **A3. Requisitos del Servidor:** Confirmar que el entorno de producción cumple con todos los requisitos:
  * Versión de PHP y extensiones PHP necesarias.
  * Acceso y credenciales correctas a la base de datos.
  * Permisos adecuados en el servidor para la carga de archivos (directorio `files` de Omeka S) y para la ejecución de comandos del sistema si fuera necesario (ej. `sed`).
* **A4. Acceso al XML de WordPress:** Asegurar la disponibilidad y acceso al fichero final y validado de exportación XML de WordPress (ver Prerrequisitos).
* **A5. Copia de Seguridad Previa:** Realizar una copia de seguridad completa de la base de datos de la instancia de Omeka S en producción ANTES de iniciar cualquier proceso de importación.
* **A6. Política de ImageMagick:** Verificar que la política de ImageMagick para el procesamiento de archivos EPS esté configurada. Si se usa `sed` (ver Fase 2, Punto 5):

    ```bash
        sed -i 's|<policy domain="coder" rights="none" pattern="EPS" />|<!-- <policy domain="coder" rights="none" pattern="EPS" /> -->|' /etc/ImageMagick-6/policy.xml

    ```
Confirmar la ruta correcta de `policy.xml` en producción.

**B. Ejecución de la Migración en Producción:**
    *   Esta sección replica los pasos detallados en Fase 3, adaptados para producción.
    *   **B1. Pasos previos a la carga de archivos XML (Producción):**
        *   **Añadir extensiones y tipos MIME a OMEKA-S (Producción):** Seguir Fase 3 -> 1.
        *   **Importación de plantillas de recursos (Producción):** Importar `Assets/Templates/autor.json` y `Assets/Templates/categoria.json` (ver Fase 3 -> 1).
        *   **Realizar la migración de los autores `<wp:authors>` (Producción):** Crear CSV e importar (ver Fase 3 -> 1).
    *   **B2. Configuración y Ejecución del Módulo `Bulk Import` (Producción):**
        *   Utilizar los Mappers (`Mapping/`) y XSL (`xsl/`) definidos en Prerrequisitos.
        *   Ejecutar los trabajos en orden (ver Fase 3 -> 3):
            *   **0. WP XML-ItemSets (Producción)**
            *   **1. WP XML- Items (Producción)**
            *   **2. WP XML - Media (Producción)**
        *   **Revisión de Logs:** Después de cada trabajo de `Bulk Import`, revisar logs.
    *   **B3. Configuración de Sitios Omeka S (Producción):**
        *   Navegar a `Admin > Sites`. Para cada sitio:
            *   Seleccionar y configurar el tema visual (`Theme`).
            *   Configurar páginas, Item Sets, navegación y módulos específicos del sitio (`Faceted Browse`, `Hierarchy`).

**C. Verificación Post-Migración Inmediata (Producción):**
    *   **C1. Conteo de Elementos:** Confirmar totales de ítems, media, e ItemSets.
    *   **C2. Control Aleatorio de Ítems:** Muestreo de ítems para verificar metadatos, media y relaciones.
    *   **C3. Accesibilidad de Sitios:** Comprobar carga de URLs públicas y navegación básica.

Una vez completados estos pasos, CAUCE procederá con las verificaciones exhaustivas detalladas en "Fase 5".

### Fase 5: Post-Migración y Aseguramiento de la Calidad (Valorar por parte de CAUCE y hacer las comprobaciones de forma coordinada con ATE)

**D. Auditoría Post-Migración Exhaustiva y Aseguramiento de Calidad:**
    Tras la verificación inmediata en producción, CAUCE realizará una auditoría más profunda.
    *   **D1. Precisión del Contenido y Metadatos:**
        *   **Cómo:** Revisión de muestra representativa (ej. 10-20%).
        *   **Qué:** Exactitud e integridad de metadatos, caracteres especiales, HTML, idiomas.
        *   **Herramientas:** Checklists manuales, scripts de comparación si es posible.
    *   **D2. Integridad de Archivos y Medios:**
        *   **Cómo:** Probar archivos multimedia para la muestra de D1.
        *   **Qué:** Enlaces rotos, renderizado (imágenes, PDF, video, EPS, VTT), visores, tipos MIME.
    *   **D3. Funcionalidad de Omeka S:**
        *   **Búsqueda y Filtros** Pruebas de palabras clave y facetas.
        *   **Navegación:** Por Item Sets, etiquetas, creador, jerarquía (`Hierarchy`).
        *   **Vistas Públicas y de Administración:** Correcta visualización.
        *   **Acceso y Permisos:** Pruebas de roles de usuario si aplica.
    *   **D4. Pruebas de Rendimiento (Básicas):**
        *   **Cómo:** Navegación manual sistemática.
        *   **Qué:** Tiempos de carga, lentitud notable, cuellos de botella.
    *   **D5. Pruebas de Aceptación del Usuario (Coordinación):**
        *   **Qué:** "Coordinar con el equipo responsable para la realización de Pruebas de Aceptación del Usuario (UAT) con un grupo designado de usuarios finales en el entorno de producción." (Responsabilidad principal del equipo de proyecto).
    *   **D6. Comprobación de Requisitos de Aspecto y Accesibilidad:**
        *   **Cómo:** Revisión manual contra guías de estilo y WCAG 2.1 AA.
        *   **Qué:** Logo, colores, fuentes, navegación por teclado, alt text, contraste. Uso de herramientas.

**E. Configuración de Redirecciones:**
    Es crucial redirigir las antiguas URLs de WordPress para preservar el SEO y la experiencia del usuario.
    *   **E1. Implementación de Redirecciones 301:**

**F. Limpieza Final y Mantenimiento Inicial:**
    Pasos finales para asegurar que el entorno de producción esté limpio y optimizado.
    *   **F1. Eliminación de Archivos Temporales:**
        *   **Qué:** Eliminar archivos de migración innecesarios (XML de prueba, logs revisados).
    *   **F2. Optimización de Omeka S y Servidor:**
        *   **Qué:** Revisar configuración de Omeka S (`Admin > Settings`, modo debug desactivado), considerar caché (Omeka S, servidor web, OPcache), asegurar funcionamiento de `jobs`.
    *   **F3. Configuración de Copias de Seguridad (Producción):**
        *   **Qué:** Verificar y asegurar copias de seguridad automáticas y periódicas (BBDD y directorio `files`).
        *   **Definir:** Frecuencia, política de retención, almacenamiento seguro externo.
### Fase 6: Puesta en Marcha y Post-Lanzamiento (Coordinado)

Esta fase se centra en el anuncio formal del nuevo sitio y el monitoreo continuo después del lanzamiento.
*   **Comunicación del Lanzamiento:** Coordinar con los responsables para anunciar la disponibilidad del nuevo sitio Omeka S.
*   **Monitoreo Inicial:** Supervisar rendimiento del servidor y logs de errores (Omeka S, servidor web) de forma intensiva.
*   **Soporte al Usuario:** Establecer un canal para reportes de problemas o consultas.
*   **Revisión Post-Implementación:** Después de un período prudencial (ej. un mes), revisar el proceso, identificar lecciones aprendidas y documentar ajustes.
