### Plan de migración de la Mediateca Wordpress a Omeka S

### Migración de mediateca de ATE a Servidor de Desarrollo (Referencia)
Para realizar la migración se ha usado un playbook de ansite con un container docker. El playbook está disponible en el directorio omeka-s del repositorio https://github.com/ateeducacion/ansible_playbooks.git 
1.  **Pasos previos a la carga de archivos XML**
    *   **Añadir extensiones a la configuración de OMEKA-S**:
        *   Para permitir la subida de nuevos tipos de archivo, navegue en la interfaz de administración de Omeka S a `Global Settings > Security`. En el campo "Allowed File Extensions" (Extensiones de archivo permitidas), añada las siguientes extensiones (separadas por comas): `eps`, `vtt`, `zip`.
        *   A continuación, vaya a `Global Settings > Security`. Asegúrese de que los siguientes tipos MIME estén presentes o añádalos:
            *   `application/postscript` (para .eps)
            *   `image/x-eps` (alternativo para .eps)
            *   `text/vtt` (para .vtt)
            *   `application/zip` o `application/x-zip-compressed` (para .zip)
    *   **Modificación de archivo policy.xml de ImageMagik:**    
        Permitir procesar medios EPS y no procesar archivos ZIP:
    ```bash
    sed -i 's|<policy domain="coder" rights="none" pattern="EPS" />|<!-- <policy domain="coder" rights="none" pattern="EPS" /> -->|' /etc/ImageMagick-6/policy.xml;
    sed -i '/<\/policymap>/ i \  <policy domain="coder" rights="none" pattern="ZIP" />' /etc/ImageMagick-6/policy.xml
    ```
    *   **Importación de plantillas de recursos**:
        *   Estas plantillas definen la estructura de metadatos para tipos específicos de recursos en Omeka S. Se trata de archivos JSON que se importan a través de la interfaz de Omeka.
            *   **Requisito previo:** Antes de importar las plantillas siguientes asegúrese de que el módulo [`Advanced Resource Template`](https://omeka.org/s/modules/AdvancedResourceTemplate) está instalado y habilitado.
            *   **Plantilla autores**: En `Resources > Resource Templates`. Haga clic en el botón "Import" y seleccione el archivo `Assets/Templates/autor.json`. Confirme la importación. Esta plantilla se usará para los items que representan autores.
            *   **Plantilla Categoría**: Repita el proceso anterior. Navegue a `Resources > Resource Templates`. Haga clic en "Import" y seleccione el archivo `Assets/Templates/categoria.json`. Confirme la importación. Esta plantilla podría usarse para los ItemSets si se requiere una estructura específica más allá de los campos básicos.
    *   **Descarga de fichero de exportación de mediateca de wordpress y preprocesado**
        *   En el administrador de Wordpress del canal de mediateca a migrar. Vaya a `Herramientas > Exportar`, seleccionar `Todo el contenido` y `Descargar el archivo de exportación`
        * El archivo exportado puede contener caracteres NULL. Hay que eliminarlos para evitar errores en la importación. Para ello ejecute:
        ```bash
        tr -d '\000' < archivo_descargado.xml > archivo_limpio.xml
        ```
2.  **Configuración Módulo `Bulk Import`**:
    *   Configurar importers en módulo Bulk Import. Vaya a `Modulos > Bulk Import > Configuration`.  Cree las siguientes configuraciones pulsando `Add new importer`:
        *   **0. WP XML-ItemSets (Importación de Colecciones/Categorías)**
            *   **Pestaña Importer**:
                *   **Etiqueta**: 0. XML - Itemset
                *   **Reader**: XML
                *   **Mapper**: `mapper_wp_xml_itemsets.xml`
                *   **Procesor**: Item Set
            *   **Pestaña Reader**
                *   **XSL Proc**: `xsl_omeka_itemset.xsl`
                *   **Params**: Sin parámetros
            *   **Pestaña Processor**
                ![Configuracion Processor item set](./img/Item_Sets.png)
        *   **1. WP XML- Items (Importación de Entradas/Items Principales)**
            *   **Pestaña Importer**:
                *   **Etiqueta**: 1. XML - Items
                *   **Reader**: XML
                *   **Mapper**: `mapper_wp_post_omeka_items.xml`
                *   **Procesor**: Items
            *   **Pestaña Reader**
                *   **XSL Proc**: `xsl_item_preprocessor.xsl`
                *   **Params**:
                    ```bash
                    postType=attachment
                    postParent=0
                    Media=0
                    ```
            *   **Pestaña Processor**
                ![Configuracion Processor item](./img/Items.png)
        *   **2. WP XML - Media (Importación de Medios Adjuntos a los Items)**
            *   **Pestaña Importer**:
                *   **Etiqueta**: 2. XML - Media
                *   **Reader**: XML
                *   **Mapper**: `mapper_wp_post_omeka_media.xml`
                *   **Procesor**: Media
            *   **Pestaña Reader**
                *   **XSL Proc**: `xsl_item_preprocessor.xsl`
                *   **Params**:
                    ```bash
                    postType=attachment
                    postParent=0
                    Media=1
                    ```
            *   **Pestaña Processor**
                ![Configuracion Processor item](./img/Media.png)
3.  **Importación de contenidos de la mediateca (Secuencia de ejecución con `Bulk Import`)**:
    Vaya a `Bulk Import > Import` y realice la siguiente secuencia de importación usando los importadores configurados en el paso anterior. El importador de medios puede llevar varias horas para procesarse. 
    *   **0.WP ML-ItemSets**
    *   **1.WP XML-Items**
    *   **2.WP XML-Media**



