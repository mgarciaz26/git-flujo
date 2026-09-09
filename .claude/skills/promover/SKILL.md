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