# ============================================================
# CREADOR DE SKILLS - Flujo Git del ERP (Claude)
# ------------------------------------------------------------
# USO: copia TODO este contenido y pegalo en una terminal
# PowerShell ubicada en la RAIZ del repo del ERP.
# Crea .claude/skills/<skill>/SKILL.md con los 5 skills listos
# y .claude/settings.json con los permisos de git y gh.
# Requisito para los PRs: GitHub CLI instalado (gh auth login).
# ============================================================

$ErrorActionPreference = "Stop"

$base = Join-Path (Get-Location) ".claude\skills"

$skills = @{
  "nueva-tarea" = @'
---
name: nueva-tarea
description: Crea la rama de trabajo para una tarea nueva partiendo de develop. Detecta si es requerimiento (ramas feature/) o soporte (ramas fix/), pide el ID del ticket y una descripcion corta, crea la rama con el formato <tipo>/<ID>-<descripcion> y la publica en GitHub. SIEMPRE pide confirmacion al usuario mostrando la ruta desde develop hacia la rama nueva. Usar cuando el usuario dice "nueva tarea", "crear rama", "empezar requerimiento", "empezar soporte", "nuevo ticket", "nuevo soporte" o menciona un ID tipo ERP-123.
allowed-tools: Bash(git:*), Bash(gh:*)
---

# Nueva tarea (requerimiento o soporte)

Crea la rama de trabajo correcta partiendo de `develop`. Cada cambio va a su propia rama; jamas se trabaja directo en develop, qa o main.

## Reglas de nombres

- Requerimiento -> `feature/<ID>-<descripcion>`  (ej: `feature/erp-123-alta-de-clientes`)
- Soporte -> `fix/<ID>-<descripcion>`           (ej: `fix/erp-089-error-al-emitir-factura`)
- Minusculas, sin acentos, espacios reemplazados por guiones.

## Pasos

1. Determina el tipo de tarea:
   - **Requerimiento** -> rama `feature/` (nueva funcionalidad, mejora, modulo).
   - **Soporte** -> rama `fix/` (correccion de un error, incidencia, soporte diario).
   - Si el usuario no lo dice, preguntale antes de continuar.

2. Pide el **ID del ticket**. Formato recomendado: `ERP-<numero>`.
   - Si el usuario no tiene uno, genera un ID con la fecha: `ERP-20260909-1` y avisale para que lo reemplace por el real.

3. Pide una **descripcion corta** de 2 a 4 palabras (ej: "ruc en pedido de venta", "arqueo de caja chica"). Menciona el formulario involucrado si lo hay (ej: `frmPedidoVenta`, `frmCajaChica`).

4. Verifica que no haya cambios sin commitear en la rama actual:
   - `git status --porcelain`
   - Si el arbol esta limpio, continua al paso 5.
   - Si hay cambios (el usuario modifico sin crear la rama primero),
     NO avances y ofrece estas 3 salidas; el usuario elige una:
     a) **Guardar a un lado y continuar (recomendado):** explica que es
        como un "bloc de notas" (`git stash -u` guarda todo, incluyendo
        archivos nuevos). Si acepta: ejecuta el stash, continua con el
        paso 5 para crear la rama, y al final devuelve los cambios sobre
        la rama nueva con `git stash pop`. Pide confirmacion antes de
        cada sub-paso (stash, crear rama, pop).
     b) **Deshacer los cambios y continuar:** MUESTRA la lista exacta de
        archivos que se perderan y advierte que es irreversible. Pide
        confirmacion literal. Solo entonces: `git restore .` para lo
        modificado y `git clean -fd` para lo nuevo sin seguimiento, y
        continua con el paso 5.
     c) **Detenerse:** no toca nada y termina; el usuario lo resuelve
        a mano.

5. Pasa a `develop` y actualizala:
   - `git checkout develop`
   - `git pull origin develop`

6. **Muestra la ruta y pide confirmacion (obligatorio):**
   - Comunica claro el recorrido, por ejemplo:
     `desde develop -> crear y publicar: origin/feature/erp-101-ruc-pedido-venta`
     o `desde develop -> crear y publicar: origin/fix/erp-102-arqueo-caja-chica`
   - Pregunta de forma literal: **"¿Estas seguro de crear y publicar esta rama? (si / no)"**
   - Espera la confirmacion explicita del usuario (si/ok/si, adelante). Si responde no, detente.

7. Solo despues de la confirmacion, crea y publica:
   - `git checkout -b feature/erp-101-ruc-pedido-venta`
   - `git push -u origin feature/erp-101-ruc-pedido-venta`

8. Confirma al usuario con un resumen claro:
   - Nombre de la rama creada y publicada (de develop hacia origin/<rama>).
   - Recordatorio: trabaje con esa rama activa en Visual Studio.
   - Recordatorio: cuando termine los cambios, arme el documento en el
     aplicativo de documentacion para obtener el codigo TGE-PROD del pase;
     luego use el skill `escribir-commit` (se lo pedira obligatoriamente
     como titulo del commit).
'@

  "escribir-commit" = @'
---
name: escribir-commit
description: Crea commits cuyo TITULO ES el codigo del documento de pase (tag TGE-PROD-YYYYMMDD-NNNNNN, obligatorio). Si el usuario aun no tiene el codigo, le muestra la lista de archivos para que arme el documento en su aplicativo y vuelva con el correlativo. Arma un cuerpo con Tipo, Ticket, descripcion generada por IA y lista de archivos, pide confirmacion y tras commitear crea el tag LOCAL con ese codigo (el push del tag lo hace despues el skill promover). Usar cuando el usuario dice "commit", "hacer commit", "commitea", "commitea estos cambios", "subir mis cambios a local", "tengo el codigo TGE-PROD".
allowed-tools: Bash(git:*)
---

# Escribir commits con codigo de pase (titulo = TGE-PROD-...)

El titulo de cada commit **es si o si** el codigo del documento de pase
(tag con formato `TGE-PROD-YYYYMMDD-NNNNNN`,
ej: `TGE-PROD-20260907-000004`). Una tarea = un documento = un commit =
un tag. El cuerpo lo genera la IA con los archivos y la descripcion.
**Este skill solo commitea en local y crea el tag local; el push del tag
y de la rama lo hace despues el skill `promover`.**

## Formato del mensaje

```
TGE-PROD-20260907-000004
```

Cuerpo (generado por IA):

```
Tipo: requerimiento
Ticket: ERP-101

RUC del cliente visible en el pedido de venta (frmPedidoVenta):
se agrega la columna y se valida el formato de 11 digitos.

Archivos modificados:
- src/Pedidos/frmPedidoVenta.cs
- src/Pedidos/PedidoVentaService.cs
```

- El `Tipo` y el `Ticket` se derivan de la rama actual:
  `feature/erp-101-...` -> Tipo: requerimiento, Ticket: ERP-101.
  `fix/erp-102-...` -> Tipo: soporte, Ticket: ERP-102.
- La descripcion (2 a 5 lineas) la generas a partir del diff real:
  que hace el cambio y que formularios/secciones toca.
- Los `Archivos modificados` son la lista real de `git diff --name-only
  HEAD` (ignora bin/ obj/ y .vs/ si aparecen).

## Pasos

1. Revisa el estado y el diff:
   - `git status`
   - `git branch --show-current` (debe ser `feature/...` o `fix/...`;
     si no lo es, explica que los commits de pase van en ramas de
     trabajo y detente).
   - `git diff --stat` y `git diff` (cambios sin commitear)
   - `git diff --cached --stat` y `git diff --cached` (cambios en stage)

2. Pide el **codigo del documento de pase** (obligatorio):
   - Si el usuario ya lo dijo ("tengo el codigo TGE-PROD-20260907-000004"),
     usalo directo.
   - Si aun NO lo tiene, NO inventes uno: muestra la lista de archivos
     con `git diff --name-only HEAD` y dile: "armen el documento en el
     aplicativo con estos archivos, y vuelvan con el codigo que les
     genere (formato TGE-PROD-YYYYMMDD-NNNNNN)".
   - Verifica el formato `TGE-PROD-YYYYMMDD-NNNNNN` y que aun no exista:
     `git tag -l <codigo>` (local) y `git ls-remote --tags origin` (remoto).
     Si ya existe, detente: el documento podria estar duplicado, avisa y
     pide otro codigo.

3. Obtiene el **Tipo y el Ticket** de la rama (feature -> requerimiento,
   fix -> soporte; ticket tipo `ERP-123` del nombre de la rama). Si no
   hay ticket en la rama, pregunta al usuario.

4. Genera la descripcion con IA a partir del diff: que hace el cambio y
   que formularios o secciones toca (2 a 5 lineas, en espanol).

5. **Propone y pide confirmacion del commit (obligatorio):**
   - Muestra el titulo exacto (el codigo), el cuerpo completo y los
     archivos que entraran.
   - Comunica la ruta: `cambios en tu carpeta -> commit local en la rama
     feature/erp-101-... (sin push)`.
   - Pregunta de forma literal: **"¿Estas seguro de hacer este commit con el codigo TGE-PROD-20260907-000004 en la rama <rama-actual>? (si / no)"**
   - Espera la confirmacion explicita del usuario. Si responde no, ajusta
     o detente.

6. Ejecuta, solo con el/los archivos confirmados:
   - `git add <archivos>`
   - `git commit -m "<codigo>" -m "<Tipo: ... / Ticket: ... / descripcion / Archivos modificados: ...>"`

7. **Crea el tag local con el mismo codigo (obligatorio, es la trazabilidad):**
   - Pregunta de forma literal: **"¿Estas seguro de crear el tag local TGE-PROD-20260907-000004 sobre este commit? (si / no)"**
   - Solo despues de la confirmacion: `git tag <codigo>`
   - Explica que el tag se queda en local y que el skill `promover` lo
     pusheara a GitHub junto con la rama.

8. Confirma el resultado con `git log --oneline -3` y
   `git tag --points-at HEAD`.

## Reglas

- Nunca hagas `push` de nada desde este skill (ni rama ni tag): eso lo
  hace el skill `promover`.
- Nunca uses `git commit -am` a ciegas: siempre muestra que archivos entran.
- Nunca ejecutes el commit ni crees el tag sin la confirmacion explicita
  del usuario (dos confirmaciones: una para el commit, otra para el tag).
- El titulo del commit es SIEMPRE el codigo del documento; nunca lo
  reemplaces por un texto libre.
- Si no hay cambios para commitear, avisalo y termina.
- Si el commit ya tiene otro codigo como titulo (reescribir), detente:
  no se renombran commits; los commits ya publicados son inmutables.
- Si hay conflictos o errores, detente y explicale el problema al usuario
  en simple.
'@

  "promover" = @'
---
name: promover
description: Publica la rama actual (feature/ o fix/) junto con su tag de pase (TGE-PROD-YYYYMMDD-NNNNNN creado por el skill escribir-commit) y crea un Pull Request hacia develop (entrega normal) o hacia qa (para pruebas). Genera automaticamente el titulo con el codigo del pase y la descripcion del PR con la lista del conjunto de commits, el tipo (requerimiento o soporte) y los archivos modificados. SIEMPRE muestra la ruta "desde <rama> hacia <destino>" y pide confirmacion antes de pushear y antes de crear el PR. Usar cuando el usuario dice "promover", "promueve", "crear PR", "pasar a develop", "subir a develop", "entregar", "pasar a qa", "mandar a pruebas".
allowed-tools: Bash(git:*), Bash(gh:*)
---

# Promover cambios (crear Pull Request)

Publica tu rama en GitHub junto con su tag de pase y crea un Pull Request hacia `develop` (entrega) o hacia `qa` (pruebas) con toda la descripcion lista.

## Pasos

1. Verifica la rama actual:
   - `git branch --show-current`
   - Debe ser `feature/...` o `fix/...`. Si no lo es, explica que este skill solo promueve ramas de trabajo y detente.

2. Detecta el codigo del pase (trazabilidad):
   - `git tag --points-at HEAD`: si la punta de la rama tiene un tag
     `TGE-PROD-YYYYMMDD-NNNNNN`, ese es el codigo del pase (lo creo el
     skill `escribir-commit`).
   - Si NO hay tag, detente y dile al usuario: "primero commitea con el
     skill `escribir-commit` usando el codigo TGE-PROD del documento;
     sin codigo no hay trazabilidad".

3. Confirma que no queden cambios sin commitear:
   - `git status --porcelain`
   - Si hay cambios sin commit, primero se commitean con `escribir-commit`.

4. Crea la lista de commits que trae tu rama respecto al destino:
   - `git fetch origin`
   - `git log origin/<destino>..HEAD --oneline`
   - Si la lista esta vacia, no hay nada que promover: avisale al usuario.

5. Decide el destino:
   - **Entrega normal** -> `develop` (lo fusiona cualquier desarrollador).
   - **Pasar a pruebas** -> `qa` (solo lo fusiona el equipo QA).
   - Si el usuario no lo dice, pregunta. Por defecto la entrega va a `develop`.

6. Actualiza la rama antes del PR (para evitar conflictos):
   - Revisa si estas detras del destino: `git rev-list --count HEAD..origin/develop`
   - Si el numero es mayor a 0, trae lo nuevo del destino a tu rama:
     - `git merge origin/develop` (resuelve conflictos si aparecen; pide confirmacion antes de cada paso conflictivo)
   - NOTA: despues de este merge la punta (HEAD) cambia; verifica de nuevo
     que el tag del pase siga apuntando al commit correcto con
     `git tag --points-at HEAD`. Si el merge movio la punta, el tag quedo
     en el commit anterior: muevelo con `git tag -f <codigo> HEAD` solo si
     el tag aun NO fue pusheado a origin. Si ya fue pusheado, NO lo muevas:
     crea el PR igual y anota en la descripcion que el pase incluye el
     merge de actualizacion.

7. Extrae el ID del ticket de la rama (p. ej. `ERP-123`) y el tipo (feature -> requerimiento, fix -> soporte).

8. **Muestra la ruta y pide confirmacion para el push (obligatorio):**
   - Comunica: `desde <rama-actual> + tag <codigo> -> hacia <destino>`.
   - Pregunta de forma literal: **"¿Estas seguro de pushear <rama-actual> y su tag <codigo>? (si / no)"**
   - Espera confirmacion explicita; solo entonces:
     - `git push -u origin <rama>`
     - `git push origin <codigo>`

9. Genera el titulo con el codigo del pase visible:
   - `[<ID>] <descripcion> (<requerimiento|soporte>) · <codigo>`
   - ej: `[ERP-101] RUC del cliente en pedido de venta (requerimiento) · TGE-PROD-20260907-000004`

10. Genera la descripcion del PR con esta estructura, usando la lista real de commits:

```
## Pase
- Codigo: TGE-PROD-20260907-000004

## Tipo de cambio
- [x] Requerimiento | Soporte

## Ticket
- ID: ERP-XXX
- Descripcion corta:

## Descripcion
(resumen de 2 a 5 lineas de que hace este cambio, para el revisor)

## Conjunto de commits
- <id> <mensaje>
- <id> <mensaje>

## Archivos modificados
- <ruta archivo>

## Pruebas realizadas
- [ ] Compila en Visual Studio
- [ ] (lo que el usuario haya probado)
```

11. **Muestra la ruta y pide confirmacion para el PR (obligatorio):**
    - Comunica: `desde <rama-actual> -> crear PR hacia <destino>`.
    - Pregunta de forma literal: **"¿Estas seguro de crear el PR de <rama-actual> hacia <destino>? (si / no)"**
    - Espera confirmacion explicita; solo entonces: `gh pr create --base <destino> --head <rama-actual> --title "<titulo>" --body "<descripcion>"`
    - Muestra la URL del PR resultante.

12. No fusionar automaticamente:
    - Si el destino es `develop`: recuerda que cualquier desarrollador puede aprobar el merge.
    - Si el destino es `qa`: solo el equipo QA lo fusiona.
    - Avisale al usuario quien debe fusionar y que el propio skill `release` se usa para pasarlo luego a `main`.
    - Recuerda que el tag del pase viaja con el commit al fusionarlo: en el destino el codigo seguira resolviendo a los mismos archivos (`git show <codigo>`).
'@

  "release" = @'
---
name: release
description: Crea el Pull Request de develop hacia main agrupando los pases ya numerados (cada cambio trae su propio tag TGE-PROD-YYYYMMDD-NNNNNN creado en su rama). Genera el resumen del release para que el Aprobador/Gestor de desarrollo lo revise y lo fusione: lista los codigos de pase incluidos, clasifica requerimientos y soportes, y usa la plantilla de release. NO crea ningun codigo nuevo: el codigo nace en la tarea. SIEMPRE muestra la ruta "desde develop hacia main" y pide confirmacion antes de crear el PR. Usar cuando el usuario (gestor de desarrollo) dice "release", "hacer release", "publicar a main", "subir a main", "pasar a produccion", "crear version", "subir a produccion".
allowed-tools: Bash(git:*), Bash(gh:*)
---

# Release de develop a main

Prepara el Pull Request de `develop` -> `main` para publicacion. **Este skill es para el Aprobador / Gestor de desarrollo.** No fusiona automaticamente ni despliega: solo crea el PR listo para revisar y fusionar.

## Pasos

1. Confirma el rol. Verifica con el usuario que sea el Aprobador/Gestor de desarrollo (Wilmer Moscol, Marlon Garcia, Jorge Salas o Victor Roldan) antes de continuar (los desarrolladores no pueden tocar `main`).

2. Situate en `develop` y actualizala:
   - `git checkout develop`
   - `git pull origin develop`

3. Revisa la diferencia contra `main`:
   - `git fetch origin`
   - `git log origin/main..origin/develop --oneline`
   - Si no hay commits, avisa que no hay nada que publicar y termina.

4. Clasifica los commits leyendo el cuerpo del mensaje (lineas `Tipo:` y
   `Ticket:` que dejo el skill `escribir-commit`) y la rama de origen:
   - Tipo: requerimiento -> **requerimientos**
   - Tipo: soporte -> **soportes**

5. Lista los codigos de pase que incluye este release (NO inventes ninguno):
   - `git fetch origin --tags`
   - `git tag --merged origin/develop`: codigos ya publicados en develop.
   - `git tag --merged origin/main`: codigos ya publicados en main.
   - Los pases de este release son los que estan en develop y aun no
     estan en main (de menor a mayor: el correlativo ya da el orden).
   - Si no hay pases nuevos, avisa que no hay nada que publicar y termina.

6. Genera el titulo:
   - `Release <fecha> (<N> pases)` (ej: `Release 2026-09-07 (2 pases)`)

7. Genera la descripcion del PR con esta estructura, usando la lista real de commits:

```
## Release <fecha> (<N> pases)

### Pases incluidos
- TGE-PROD-20260907-000004 (ERP-101, requerimiento)
- TGE-PROD-20260907-000005 (ERP-102, soporte)

### Requerimientos
- TGE-PROD-20260907-000004: RUC del cliente en pedido de venta

### Soportes
- TGE-PROD-20260907-000005: Corrige calculo de arqueo en caja chica

## Resumen
- X requerimientos nuevos
- Y soportes corregidos
- Z archivos modificados

## Archivos modificados
- <ruta archivo>

## Checklist antes de fusionar
- [ ] Se probo el conjunto en qa y paso las pruebas
- [ ] Compila en Visual Studio (Release)
- [ ] Pase Produccion esta disponible para publicar
```

8. **Muestra la ruta y pide confirmacion (obligatorio):**
   - Comunica: `desde develop -> crear PR hacia main` (Release <fecha> con los pases: <codigos>).
   - Pregunta de forma literal: **"¿Estas seguro de crear este PR de release de develop hacia main? (si / no)"**
   - Espera confirmacion explicita del usuario. Si responde no, detente.

9. Solo despues de la confirmacion, crea el PR:
   - `gh pr create --base main --head develop --title "Release <fecha> (<N> pases)" --body "<descripcion>"`
   - Muestra la URL del PR.

10. Despues del merge, verifica que los codigos del pase quedaron en
    `main` (obligatorio; NO se crea ningun codigo nuevo, ya nacieron en
    las tareas):
    - `git checkout main`
    - `git pull origin main`
    - `git fetch origin --tags`
    - `git tag --merged main`: debe incluir TODOS los codigos del release.
      Si falta alguno, avisa al equipo y detente (ese pase no debe
      publicarse aun).

11. Recuerda al usuario:
    - Revisar el PR, asegurarse de que QA ya paso las pruebas, y
      fusionarlo (solo el gestor puede) ANTES de verificar los tags.
    - **Pase Produccion** descargara cada codigo con el skill `publicar`
      en orden de correlativo (de menor a mayor) y publicara desde ahi.
'@

  "publicar" = @'
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
'@
}

foreach ($nombre in ($skills.Keys | Sort-Object)) {
  $carpeta = Join-Path $base $nombre
  New-Item -ItemType Directory -Path $carpeta -Force | Out-Null
  Set-Content -LiteralPath (Join-Path $carpeta "SKILL.md") -Value $skills[$nombre] -Encoding UTF8
}

$ajustes = @'
{
  "permissions": {
    "allow": [
      "Bash(git:*)",
      "Bash(gh:*)"
    ]
  }
}
'@

$carpetaClaude = Join-Path (Get-Location) ".claude"
New-Item -ItemType Directory -Path $carpetaClaude -Force | Out-Null
Set-Content -LiteralPath (Join-Path $carpetaClaude "settings.json") -Value $ajustes -Encoding UTF8

Write-Output ""
Write-Output "Skills creados correctamente:"
Write-Output ("  - " + (Join-Path $carpetaClaude "settings.json"))
Get-ChildItem -Recurse -File -LiteralPath $base | ForEach-Object { Write-Output ("  - " + $_.FullName) }
Write-Output ""
Write-Output "Reinicia Claude para que los detecte."
