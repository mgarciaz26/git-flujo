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