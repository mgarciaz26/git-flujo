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
