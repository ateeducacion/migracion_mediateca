# Migración de Mediateca WordPress a Omeka S

Este repositorio documenta el procedimiento de migración de una mediateca educativa basada en WordPress hacia una nueva infraestructura con **Omeka S**. El objetivo principal es trasladar de forma segura los recursos digitales (archivos, vídeos, documentos, etc.) y sus metadatos, integrándolos en **ItemSets** e **Items** de Omeka S, manteniendo su estructura y accesibilidad.

## Contenidos del repositorio

Incluye todos los recursos necesarios para realizar la migración completa:

- **Archivos XSLT** para transformar el XML exportado desde WordPress:
  - `xsl/xsl_omeka_itemset.xsl`: para generar colecciones (ItemSets).
  - `xsl/xsl_item_preprocessor.xsl`: para procesar entradas, ítems y archivos adjuntos.
  
- **Mapeos XML (Mappers)** para el módulo `Bulk Import` de Omeka S:
  - `Mapping/mapper_wp_xml_itemsets.xml`: categorías de WordPress → ItemSets.
  - `Mapping/mapper_wp_post_omeka_items.xml`: entradas → Items.
  - `Mapping/mapper_wp_post_omeka_media.xml`: adjuntos → Media.

- **Plantillas JSON de recursos**:
  - `Assets/Templates/autor.json`
  - `Assets/Templates/categoria.json`

- **Scripts auxiliares** y comandos para preparar el entorno (como configuración de MIME types o ajustes de ImageMagick para EPS).

# Requisitos previos
Antes de iniciar la fase final de migración, deben estar disponibles:

- Exportación XML de WordPress validada.
- Acceso y permisos de administrador en Omeka S.
- Instalación de módulos requeridos (Bulk Import, Advanced Resource Template, etc.).
- Acceso SSH al servidor para subir archivos, revisar logs o ajustar configuraciones.
- Aplicaciones necesarias como `ffmpeg` o editores de políticas como `sed`.

## Plan de migración

El plan de migración se estructura en seis fases:

1. **Pre-migración y planificación** 
2. **Migración en entorno local de pruebas** 
3. **Migración en servidor de desarrollo** 
4. **Migración final en producción** 
5. **Aseguramiento de calidad post-migración**
6. **Puesta en marcha y seguimiento post-lanzamiento**

## Plan de migración resumido
Plan simplificado para su uso por parte del equipo técnico que realiza la migración

## Glosario básico

- **Item**: unidad básica en Omeka S (recurso con metadatos y media).
- **ItemSet**: conjunto o colección de Items (equivalente a categorías en WordPress).
- **Media**: archivo digital asociado a un Item.
- **Resource Template**: estructura de metadatos aplicada a Items o ItemSets.
- **Mapper**: archivo XML que define la correspondencia entre los datos de entrada y los campos de Omeka S.

## Destinatarios
Este material está dirigido al equipo técnico encargado de ejecutar la migración (CAUCE), y sirve como referencia principal para reproducir en producción los pasos ya probados en desarrollo.

---

Para más detalles, consulta el documento `Planning.md` incluido en este repositorio.

