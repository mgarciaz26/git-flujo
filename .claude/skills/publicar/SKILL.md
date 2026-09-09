---
name: publicar
description: Lista a Pase Produccion los pases pendientes y descarga por codigo del documento (tag TGE-PROD-YYYYMMDD-NNNNNN): muestra commits, clasifica requerimientos/soportes y archivos de ESE codigo, pide confirmacion y solo entonces lo descarga exacto. No compila ni despliega. Usar cuando el publicador dice "que hay nuevo en main", "que pases hay pendientes", "descarga la TGE-PROD-20260907-000004", "revisar release", "descargar release", "bajar a produccion" o "publicar".
allowed-tools: Bash(git:*)
---

# Publicar (revisar y descargar por codigo)

Descarga exactamente el codigo del documento de pase (tag con formato
`TGE-PROD-YYYYMMDD-NNNNNN`, ej: `TGE-PROD-20260907-000004`) generado en la
tarea por el aplicativo de documentacion. Si hay 2 o mas pases pendientes,
se descargan de menor a mayor codigo (el correlativo ya da el orden).
**Este skill es para Pase Produccion.** No compila ni despliega: deja tu
carpeta con el codigo exacto para que publiques desde ahi.

## Pasos

1. Confirma el rol. Verifica con el usuario que sea Pase Produccion antes
   de continuar.

2. Situate en `main` y trae las referencias sin descargar nada:
   - `git checkout main`
   - `git fetch origin --tags`

3. Lista los pases pendientes de descargar:
   - Tu codigo actual: `git describe --tags` (si falla, aun no tienes
     ninguna version descargada).
   - Codigos publicados en GitHub: `git ls-remote --tags origin`
     (se ordenan solos: fecha + correlativo con ceros).
   - Muestra: "Tu carpeta esta en TGE-PROD-20260907-000003. Pases
     pendientes: TGE-PROD-20260907-000004, TGE-PROD-20260907-000005."
   - Si no hay nada pendiente, avisale "ya estas al dia con origin/main"
     y termina.

4. Pide el **codigo del documento de pase** (ej:
   `TGE-PROD-20260907-000004`).
   - Si el usuario ya lo dijo ("descarga la TGE-PROD-20260907-000004"),
     usalo directo.
   - Si hay 2 o mas pases pendientes, recuerda descargar en el orden del
     documento (primero el menor codigo) y confirma cual toca ahora.
   - Verifica que el tag exista en origin. Si no existe, avisale que los
     desarrolladores aun no lo publican y detente sin descargar nada.

5. Muestra el contenido de ESE codigo:
   - Commits desde tu codigo hasta el tag:
     `git log <tu-codigo>..<tag> --oneline`
   - Archivos que trae: `git diff --name-only <tu-codigo>..<tag>`
   - Clasifica leyendo el cuerpo del mensaje (lineas `Tipo:` y `Ticket:`
     que dejo el skill `escribir-commit`): Tipo: requerimiento ->
     **requerimientos**, Tipo: soporte -> **soportes**.

6. **Muestra la ruta y pide confirmacion (obligatorio):**
   - Comunica: `desde origin/main (<tag>) -> descargar hacia tu carpeta`.
   - Pregunta de forma literal: **"¿Estas seguro de descargar <tag> de origin/main a tu carpeta? (si / no)"**
   - Espera la confirmacion explicita del usuario. Si responde no, detente
     sin descargar nada.

7. Solo despues de la confirmacion, descarga exactamente ese codigo:
   - `git fetch origin tag <tag>`
   - `git checkout <tag>`

8. Verifica el resultado:
   - `git describe --tags`
   - El resultado debe ser IGUAL al codigo del documento de pase.
     Si no coincide, NO publicar y avisar al Gestor.

9. Recuerda al usuario: compilar y publicar el ERP desde esta carpeta.

## Reglas

- Nunca descargar sin la confirmacion explicita del usuario.
- Nunca descargar un codigo distinto al del documento de pase.
- Nunca compilar ni desplegar desde este skill (eso lo hace el publicador
  a mano despues de verificar).
- Si el tag descargado no coincide con el codigo del documento, detenerse,
  no publicar y avisar al Gestor.
- Si hay conflictos o errores, detenerse y explicar el problema en simple.
