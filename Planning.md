## Plan de Migración: Mediateca WordPress a Omeka S

**Objetivo:** Migrar de forma segura los recursos digitales educativos y sus metadatos de la Mediateca de WordPress a Omeka S, estableciéndolos como ítems de omeka dentro de colecciones digitales (ItemSets).

**Fases de la migración**
    Para realizar la migración de los canales de la Mediateca se han planteado las siguientes fases, que se desarrollarán con más detalle posteriormente en este informe:
*   Fase 1: Pre-Migración y Planificación
*   Fase 2: Migración y Pruebas en el entorno de pruebas local (Iterativo) (Iterativo)
*   Fase 3: Fase 3: Migración total de la mediateca de ATE en Servidor de Desarrollo
*   Fase 4: Migración Final en Producción
*   Fase 5: Post-Migración y Aseguramiento de la Calidad


**Estado actual de la migración**
    Actualmente se han finalizado las fases 1 y 2 y se estima tener finalizada la fase 3 en la primerna semana de Junio 2025. Una vez finalizada la fase 3, mientras se realiza la migración a los entornos de producción nos centraríamos en el desarrollo de la vista pública de los sitios principales que se migrarán, esto es, la mediateca de ATE y la web de recursos educativos.
    Por otro lado, para la web de recursos educativos se prevee la necesidad de desarrollar un plugin para visualizar desde el propio sitio los recursos educativos, permitiendo navegar el contenido del zip que contiene cada recurso.

**Herramientas y elementos necesarios:**
*   Fichero de exportación XML de WordPress
*   Omeka S
*   XSL personalizados
    * xsl_omeka_itemset.xsl : Para extrar las categorías de la mediateca wordpress
    * xsl_item_preprocessor.xsl : Para extrar los metadatos de las entradas de wordpress y extraer los medios
*   Mappers de Omeka
    * Adaptan ficheros de exportación de wordpress xml a los campos de las ontologías de Omeka. 
        - mapper_wp_post_omeka_items.xml
        - mapper_wp_post_omeka_media.xml
        - mapper_wp_xml_itemsets.xml
*   Modulos de Omeka S 
    - [Common - 3.4.66](https://omeka.org/s/modules/Common/)
    - [Log - 3.4.27](https://omeka.org/s/modules/Log/)
    - [Advanced Resource Template - 3.4.39](https://omeka.org/s/modules/AdvancedResourceTemplate/)
    - [Bulk Export - 3.4.36](https://omeka.org/s/modules/BulkExport/)
    - [Bulk Import - 3.4.58](https://omeka.org/s/modules/BulkImport/)
    - [CSV Import - 2.6.2](https://omeka.org/s/modules/CSVImport/)
    - [Custom Vocab - 2.0.2](https://omeka.org/s/modules/CustomVocab/)
    - [Disk Quota - 1.0.1](https://github.com/ateeducacion/omeka-s-DiskQuota)
    - [Easy Admin - 3.4.29](https://omeka.org/s/modules/EasyAdmin/)
    - [Faceted Browse - 1.7.0](https://omeka.org/s/modules/FacetedBrowse/)
    - [Hierarchy - 1.1.2](https://github.com/omeka-s-modules/Hierarchy)
    - [IsolatedSites - 1.0.0](https://github.com/ateeducacion/omeka-s-IsolatedSites)
    - [ThreeDViewer - 1.0.4](https://github.com/ateeducacion/omeka-s-ThreeDViewer)


### Fase 1: Pre-Migración y Planificación

1.  **Definir Alcance y Requisitos:**
    *   **Mapeo de Metadatos:** Ten un mapa claro y documentado de cómo cada campo de metadatos de WordPress (incluidos los campos personalizados) se asignará a los elementos de Dublin Core de Omeka S o a los vocabularios personalizados que hayas definido.
        - Mapeo de colecciones de wordpress a item sets de Omeka:
            | WordPress Term Field | Omeka S Field | Datatype | Notes |
            |---------------------|---------------|----------|-------|
            | wp:term/term_name | dcterms:title | literal | Item Set title |
            | wp:term/term_id | dcterms:identifier | literal | WordPress term ID |
            | wp:term/term_slug | dcterms:identifier | literal | WordPress term slug |
            | wp:term/term_parent | dcterms:isPartOf | literal | Parent term reference |
            | (hardcoded) | resource_name | raw="o:Item_set" | Resource type specification |

        - Mapeo de entradas mediateca a items:
            | WordPress Field | Omeka S Field | Datatype | Notes |
            |----------------|---------------|----------|-------|
            | title | dcterms:title | (default) | Post title |
            | wp:post_id | dcterms:identifier | (default) | WordPress post ID |
            | dc:creator | dcterms:creator | (default) | Original author |
            | description | dcterms:description | (default) | Post description |
            | wp:post_name | dcterms:replaces | (default) | WordPress slug |
            | wp:post_date | dcterms:date | literal | Publication date |
            | category[@domain='media-tag'] | dcterms:relation | literal | Media tags |
            | wp:postmeta[meta_key='meta_author'] | dcterms:contributor | literal | Custom author metadata |
            | wp:postmeta[meta_key='meta_copyright'] | dcterms:rights | literal | Copyright information |
            | wp:postmeta[meta_key='meta_language'] | dcterms:language | literal | Language metadata |
            | category[@domain='media-category'] | o:item_set | literal | Collection/Item Set assignment |
            | (hardcoded) | resource_name | raw="o:Item" | Resource type specification |


        - Mapeo de entradas mediateca a items media:
            Una vez introducidos los metadatos de las entradas en items se realiza la carga de los medios asociados a cada item

            | WordPress Field | Omeka S Field | Datatype | Notes |
            |----------------|---------------|----------|-------|
            | title | dcterms:title | (default) | Media title |
            | wp:post_id | o:item | literal | Links media to parent item |
            | dc:creator | dcterms:creator | (default) | Original author |
            | description | dcterms:description | (default) | Media description |
            | wp:post_name | dcterms:replaces | (default) | WordPress slug |
            | wp:post_date | dcterms:date | literal | Publication date |
            | content:encoded | html | (default) | HTML content |
            | wp:attachment_url | url | uri | Media file URL |
            | wp:postmeta[meta_key='meta_author'] | dcterms:contributor | literal | Custom author metadata |
            | wp:postmeta[meta_key='meta_copyright'] | dcterms:rights | literal | Copyright information |
            | (hardcoded) | resource_name | raw="o:Media" | Resource type specification |

    *   **Colecciones/Relaciones:** 
        En la mediateca de wordpress las entradas están catalogadas por categorías que siguen una estructura de árbol, pudiendo cada entrada pertenecer a una o varias categorías. En Omeka, cada categoría será un ItemSet y para realizar la estructura de árbol se ha usado el módulo Hierarchy.
        Por otro lado, cada entrada puede tener una o varias etiquetas (media-tag) que se han añadido a campo dcterms:relation de la ontología Dublin Core en OmekaS. Se puede usar el módulo Fields as Tags (https://omeka.org/s/modules/FieldsAsTags/) para usar las etiquetas en la navegación.

    *   **Manejo de Archivos:** ¿Los archivos están incrustados en el XML o vinculados? Tus scripts deben encargarse de descargar/cargar lateralmente estos archivos en Omeka S. Asegúrate de que las rutas de los archivos sean correctas.

    *   **Estructura de Sitios Omeka S:** Planifica los **Sitios** de Omeka S donde residirán estas colecciones. ¿Habrá un sitio principal o varios sitios educativos? ¿Cómo se organizarán los conjuntos de ítems dentro de ellos?
        Dentro de la estructura de sitios de Omeka, se prevee un sitio por cada canal de mediateca y por cada repositorio digital dentro de la DGOEII. Como opción adicional, que puede resultar interesante para acciones puntuales, se pueden crear sitios específicos para exhibiciones de colecciones digitales concretas (día de Canarias, patrimonio, REF, etc).

        - **Sitios previstos**
            - **Mediateca ATE** (https://www3.gobiernodecanarias.org/medusa/mediateca/ecoescuela/?media-tag=ate)
            - **Recursos Educativos** (https://www3.gobiernodecanarias.org/medusa/ecoescuela/recursosdigitales/)
            - ...
            - **Canales de mediateca de centros educativos**

2.  **Configuración del Entorno Omeka S:**
    *   **Entorno Dedicado de Desarrollo:**
        Se ha configurado un servidor local Omeka S para realizar pruebas y desarrollar los ficheros que automatizan la migración
    *   **Instalar y Configurar Omeka S:**
    *   **Instalar Módulos Necesarios:**
        *   **Bulk Import (Esencial):** Asegúrate de que esté instalado y habilitado.


### Fase 2: Migración y Pruebas en el entorno de pruebas local (Iterativo)

0.  **Desarrollo y Refinar Scripts XSL y mappers:**
    
    Se han desarrollado los ficheros XSL para preprocesado del fichero de exportación de wordpress así como los mappers de forma iterativa, corriendo errores y refinando para mejorar rendimiento, seguridad, logging y manejo de errores.

1.  **Importación de Prueba con Lote Pequeño:**
    *   **Seleccionamos una muestra representativa:** Elegimos un pequeño número de ítems (p. ej., 5-20) que representen varios tipos de contenido, complejidad de metadatos y tipos de archivos de tu exportación de WordPress. Se incluyen ítems con caracteres especiales, datos faltantes, múltiples archivos, etc. Convertimos este pequeño lote XML al formato de Bulk Import de Omeka S en XML.
    *   **Realizamos la Importación Masiva:** Utiliza el módulo Bulk Import de Omeka S para importar este pequeño lote en tu instancia de Omeka S.
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
    Se ha realizado la prueba de migrar un año entero (5200 items)

### Fase 3: Migración total de la mediateca de ATE en Servidor de Desarrollo

- Realizar documentación paso a paso desde una instalación de Omeka básica del proceso de migración para facilitar trabajo a CAUCE
- Realizar el desarrollo del site donde se visualizarán los recursos digitales para facilitar su diseño posteriormente en producción.

    

### Fase 4: Migración Final en Producción

Corresponde a CAUCE


### Fase 5: Post-Migración y Aseguramiento de la Calidad

1.  **Verificación Inmediata:**
    *   **Verificaciones Rápidas:** Confirmar el número total de ítems, archivos y conjuntos de ítems en Omeka S.
    *   **Control Aleatorio de Ítems:** Verificar algunos ítems para comprobar que la migración ha sido exitosa.
    *   **Verificar la Accesibilidad del Sitio:** Comprobar de que el sitio público se cargue y que la navegación/búsqueda funcione.

2.  **Auditoría Post-Migración Exhaustiva:**
    *   **Precisión del Contenido:** Realizar una revisión exhaustiva de los metadatos, archivos y relaciones. Considerar usar un script separado para comparar los datos entre la exportación original de WordPress y la base de datos de Omeka S.
    *   **Pruebas de Funcionalidad:**
        *   **Búsqueda y Filtros:** Probar todas las facetas y filtros de búsqueda.
        *   **Opciones de Navegación:** Verificar la navegación por conjunto de ítems, etiqueta, creador, etc.
        *   **Vistas Públicas y de Administración:** Comprobar de que ambas interfaces muestren los ítems correctamente.
        *   **Acceso a Archivos:** Probar las descargas y los visores de medios.
    *   **Pruebas de Rendimiento:** Verificar la velocidad de carga de las páginas, los resultados de búsqueda y los archivos multimedia.
    *   **Pruebas de Aceptación del Usuario:** Probar con un pequeño grupo de usuarios prueben el nuevo sistema para asegurar que satisfaga sus necesidades.
    *   **Comprobación de requisitos de aspecto y accesibilidad:** Comprobar de que el nuevo sitio Omeka S cumpla con los estándares fijados en cuanto a imagen institucional y en cuanto a accesibilidad.

3.  **Redirecciones:**
    *   **Redirecciones de URLs Antiguas:** Planificar redirecciones 301 desde tus antiguas URLs de WordPress a las nuevas URLs de Omeka S. 

4.  **Limpieza Final:**
    *   Eliminar cualquier archivo temporal generado durante el proceso de migración.
    *   Revisar y optimiza la configuración de Omeka S (p. ej., caché).
    *   Comprobar de que se configuren copias de seguridad adecuadas para la *nueva* instancia de producción de Omeka S.



### Fase 6: Puesta en Marcha y Post-Lanzamiento

