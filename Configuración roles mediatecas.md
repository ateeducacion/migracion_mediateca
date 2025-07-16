# Configuración de Roles y Permisos en Omeka S para canales de mediateca
Este documento describe la configuración recomendada de roles y permisos recomendados para instalación de Omeka S con múltiples sitios, cada uno correspondiente a un centro educativo o canal de mediateca con una finalidad específica. 

## 1. Estructura de Sitios

- Cada centro educativo puede solicitar su canal de mediateca y esté será configurado como un sitio independiente dentro de la instancia de Omeka S.
- Los usuarios serán asignan a los sitios según su centro de trabajo o pertenencia institucional.

## 2. Roles y Permisos

### 2.1. Directores o Personas Autorizadas de un Centro Educativo
- **Rol en Omeka S:** Revisor (`Reviewer`)
- **Permisos en sitio:** Viewer (visualizador) de su propio sitio del centro educativo.
- **Sitio por defecto:** Se asignará como sitio por defecto en su usuario, el sitio correspondiente a su centro educativo.
- **Restricción de visualización:** Mediante el plugin IsolatedSites, se limitará el panel de administración para que no puedan ver ítems de otros centros educativos o canales de mediateca.
- **Acceso a contenidos:** Los directores o personas autorizadas pueden editar y gestionar los contenidos de su sitio, asociado al centro educativo, pero no tienen permisos sobre otros sitios. Además, pueden visualizar los items públicos y privados del resto de sitios de Omeka-S
- **Configuración inicial del usuario:** Manual por parte del administrador de Omeka-S.

### 2.2. Docentes y Usuarios Autorizados a visualizar contenido privado

- **Rol en Omeka S:** Guest Private (proporcionado por el módulo Guest Private)
- **Permisos en sitio:** No se dan permisos específicos en ningún sitio de Omeka-S. 
- **Acceso a contenidos:** Los docentes y otros usuarios autorizados pueden visualizar los items públicos y privados de todos los sitios de Omeka-S, pero no pueden editar contenidos. No tienen acceso al panel de administración.
- **Asignación de permisos/configuración de usuario:** Automática mediante el método de registro CAS (Single Sign-On).

## 3. Consideraciones Técnicas

- **Diferencia entre roles y permisos:**  
    - Los roles en Omeka S (Admin, Editor, Author, Researcher, Reviewer, Guest, etc.) definen capacidades generales sobre los objetos de Omeka-S.
    - **Módulo Guest Private:**   
        - Añade un nuevo rol llamado `guest_private` que permite visualizar los ítems marcados como privados, asegurando así que solo usuarios autorizados accedan a recursos privados. .
        - Este rol es necesario porque habrá sitios de Omeka S que serán accesibles únicamente a profesores o personas autorizadas.
        - A través de CAS se le asignará el rol `guest_private` automáticamente a los usuarios con credenciales.

## 4. Procedimiento de Asignación

1. **Gestores:**  
     - Crear usuario en Omeka S.
     - Asignar rol `Reviewer`.
     - Añadir como Viewer al sitio correspondiente.

2. **Docentes y Autorizados:**  
     - Registro automático vía CAS.
     - Se le asignará el rol `Guest private`
     - Acceso privado gestionado por el módulo y configuración del sitio.

---