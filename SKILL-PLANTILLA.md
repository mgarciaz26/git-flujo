---
name: mi-skill
description: Qué hace este skill y cuándo debe usarse. Incluir las palabras gatillo que dirá el usuario, por ejemplo: crear, ejemplo, frase gatillo, ERP-123.
allowed-tools: Bash(git:*), Bash(gh:*)
---

# Mi skill

Qué logra este skill, en 1 o 2 líneas.

## Reglas

- Regla 1 (qué nunca debe hacer).
- Regla 2 (qué siempre debe hacer).

## Pasos

1. Primer paso con su comando exacto:
   - `comando exacto --con-sus-flags`
2. Segundo paso:
   - `otro comando exacto`
3. Mostrar el resultado al usuario.

## Formato

Formato exacto de lo que genera (mensaje, ruta, plantilla):

```
<tipo>: [<ID>] <descripcion>
```

## Confirmacion (obligatorio)

- Antes de cada acción irreversible, mostrar la ruta:
  `desde <origen> -> hacia <destino>`
- Preguntar de forma literal:
  "¿Estas seguro de ...? (si / no)"
- Esperar la confirmacion explicita del usuario (si/ok/adelante).
- Si responde no, detenerse sin ejecutar nada.

## Casos especiales

- Si falta un dato, pedirlo antes de continuar (no inventarlo).
- Si no hay nada que hacer, avisarlo y terminar.
- Si hay un error, detenerse y explicarlo en simple.
