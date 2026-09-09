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