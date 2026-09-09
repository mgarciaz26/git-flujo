# PROMPTS CONSTRUCTORES DE LOS 5 SKILLS

Cada prompt genera desde cero el SKILL.md correspondiente. Copialo, pegalo a
cualquier IA y responde SOLO con el contenido del archivo.

## CONTEXTO COMPARTIDO (pegar al inicio de cada prompt)

Trabajamos un ERP en C# (Visual Studio) con GitHub y Claude (modelo Sonnet).
Ramas: main (produccion, solo Gestores/Aprobadores), develop (integracion,
cualquier desarrollador fusiona), qa (pruebas, solo el equipo QA),
feature/<ID>-<descripcion> (requerimientos) y fix/<ID>-<descripcion>
(soportes). Todo viaja por Pull Request; nadie pushea directo a main ni a qa.
TRAZABILIDAD POR CODIGO: cada tarea tiene su documento de pase con un codigo
correlativo TGE-PROD-YYYYMMDD-NNNNNN (generado por el aplicativo de
documentacion ANTES del commit); el titulo de cada commit ES ese codigo, y
sobre ese commit se crea un tag LOCAL con el mismo codigo (lo pushea el skill
que publica la rama). El tag viaja con el commit al fusionarlo a develop, qa
y main: en cualquier rama, git show <codigo> y git checkout <codigo> devuelven
los archivos de ese pase. El cuerpo del commit lleva Tipo (requerimiento o
soporte), Ticket (ERP-...) y descripcion generada por IA.
REGLA DE ORO: antes de cada accion irreversible el skill muestra la ruta
"desde <origen> -> hacia <destino>" y pregunta literalmente
"¿Estas seguro de ...? (si / no)", esperando confirmacion explicita
(si/ok/adelante). Si responde no, se detiene sin ejecutar nada.

---

## PROMPT 1 - SKILL nueva-tarea

[CONTEXTO COMPARTIDO]

Genera un archivo SKILL.md con este frontmatter exacto:
- name: nueva-tarea
- description: explica que crea la rama de trabajo desde develop, detecta
  requerimiento (feature/) o soporte (fix/), pide ID y descripcion, y SIEMPRE
  pide confirmacion mostrando la ruta. Incluye los gatillos: "nueva tarea",
  "crear rama", "empezar requerimiento", "empezar soporte", "nuevo ticket",
  "ERP-123".
- allowed-tools: Bash(git:*), Bash(gh:*)

El cuerpo debe tener: reglas de nombres (minusculas, sin acentos, guiones;
feature/<ID>-<desc> y fix/<ID>-<desc> con 1 ejemplo de cada uno) y pasos
numerados: 1) determinar tipo (preguntar si es ambiguo), 2) pedir ID del
ticket (formato ERP-<numero>; si no hay, generar ERP-YYYYMMDD-N),
 3) pedir descripcion corta de 2-4 palabras y el formulario si aplica,
 4) verificar arbol limpio con git status --porcelain (si esta limpio,
 seguir; si hay cambios porque modifico sin crear la rama, ofrecer 3
 salidas: a) guardar a un lado con git stash -u, crear la rama y devolver
 con git stash pop —recomendado, con confirmacion por sub-paso—,
 b) deshacer mostrando la lista exacta y advirtiendo que es irreversible
 (git restore . + git clean -fd), c) detenerse sin tocar nada),
 5) git checkout develop + git pull origin develop,
 6) mostrar la ruta y pedir confirmacion obligatoria,
 7) crear y publicar solo tras confirmar (git checkout -b + git push -u),
 8) resumen final: recordatorio de trabajar en esa rama en Visual Studio y de
 armar el documento en el aplicativo para obtener el codigo TGE-PROD antes de
 commitear (escribir-commit lo pedira obligatoriamente).
Responde SOLO con el contenido del archivo.

---

## PROMPT 2 - SKILL escribir-commit

[CONTEXTO COMPARTIDO]

Genera un archivo SKILL.md con este frontmatter exacto:
- name: escribir-commit
- description: explica que el TITULO de cada commit ES el codigo del
  documento de pase (tag TGE-PROD-YYYYMMDD-NNNNNN, obligatorio); si el
  usuario aun no lo tiene, le muestra la lista de archivos para que arme el
  documento y vuelva con el correlativo. Arma un cuerpo con Tipo, Ticket,
  descripcion generada por IA y lista de archivos, pide confirmacion y tras
  commitear crea el tag LOCAL con ese codigo (el push del tag lo hace despues
  el skill promover). Incluye los gatillos: "commit", "hacer commit",
  "commitea", "commitea estos cambios", "tengo el codigo TGE-PROD".
- allowed-tools: Bash(git:*)

El cuerpo debe tener: formato de titulo = codigo, cuerpo con Tipo (de la
rama: feature->requerimiento, fix->soporte), Ticket (de la rama), descripcion
IA de 2-5 lineas y Archivos modificados (de git diff --name-only HEAD),
pasos: 1) git status, git branch --show-current (debe ser feature/fix),
git diff (normal y --cached), 2) pedir el codigo (obligatorio; si no lo tiene,
mostrar la lista de archivos y mandarlo al aplicativo; verificar formato y que
no exista como tag local ni en origin), 3) obtener Tipo y Ticket de la rama,
4) generar descripcion con IA, 5) proponer titulo+cuerpo+archivos+ruta y pedir
confirmacion obligatoria literal, 6) git add + git commit -m "<codigo>" -m
"<cuerpo>" solo de lo confirmado, 7) crear el tag local con confirmacion
(git tag <codigo>; el tag se queda en local), 8) verificar con
git log --oneline -3 y git tag --points-at HEAD. Reglas: nunca push (ni rama
ni tag), nunca commit -am a ciegas, nunca sin las dos confirmaciones
(commit y tag), el titulo es SIEMPRE el codigo, no renombrar commits ya
publicados. Responde SOLO con el contenido del archivo.

---

## PROMPT 3 - SKILL promover

[CONTEXTO COMPARTIDO]

Genera un archivo SKILL.md con este frontmatter exacto:
- name: promover
- description: explica que publica la rama feature/fix junto con su tag de
  pase (TGE-PROD-YYYYMMDD-NNNNNN creado por escribir-commit) y crea el PR
  hacia develop (entrega) o qa (pruebas) con titulo con el codigo visible y
  descripcion autogenerada (pase, tipo, ticket, commits, archivos), muestra
  la ruta y pide confirmacion antes del push y antes del PR. Incluye los gatillos:
  "promover", "promueve", "crear PR", "pasar a develop", "subir a develop",
  "entregar", "pasar a qa", "mandar a pruebas".
- allowed-tools: Bash(git:*), Bash(gh:*)

El cuerpo debe tener pasos: 1) verificar rama feature/fix con
git branch --show-current, 2) detectar el codigo del pase con
git tag --points-at HEAD (si no hay tag, detenerse y mandar a
escribir-commit con el codigo del documento),
3) exigir arbol limpio, 4) listar commits con
git log origin/<destino>..HEAD --oneline (si vacia, nada que promover),
5) destino develop (defecto) o qa (preguntar si no se dice),
6) actualizar rama con develop si esta detras (si el merge mueve la punta y
el tag aun no fue pusheado, moverlo con git tag -f; si ya fue pusheado, NO
moverlo y anotarlo en el PR), 7) extraer ID y tipo,
8) confirmacion obligatoria del push mostrando la ruta (git push -u origin
<rama> + git push origin <codigo>), 9) titulo
"[<ID>] <descripcion> (<requerimiento|soporte>) · <codigo>", 10) plantilla de
descripcion del PR (pase, tipo, ticket, descripcion, commits, archivos,
pruebas), 11) confirmacion obligatoria del PR y creacion con gh pr create
mostrando la URL, 12) no fusionar: indicar quien fusiona segun destino y
recordar que el tag viaja con el commit. Responde SOLO con
el contenido del archivo.

---

## PROMPT 4 - SKILL release

[CONTEXTO COMPARTIDO]

Genera un archivo SKILL.md con este frontmatter exacto:
- name: release
- description: explica que crea el PR de develop hacia main AGRUPANDO los
  pases ya numerados (cada cambio trae su propio tag TGE-PROD-YYYYMMDD-NNNNNN
  creado en su rama; NO crea ningun codigo nuevo), lista los codigos incluidos,
  clasifica requerimientos y soportes, y pide confirmacion mostrando la ruta.
  Incluye los gatillos: "release",
  "hacer release", "publicar a main", "subir a main", "pasar a produccion",
  "crear version". ACLARA que es solo para el Gestor.
- allowed-tools: Bash(git:*), Bash(gh:*)

El cuerpo debe tener pasos: 1) confirmar rol de Gestor/Aprobador (Wilmer
Moscol, Marlon Garcia, Jorge Salas, Victor Roldan) y detenerse si no lo es,
2) git checkout develop + git pull, 3) git log origin/main..origin/develop
--oneline (si vacio, nada que publicar), 4) clasificar leyendo el cuerpo del
mensaje (lineas Tipo: y Ticket:), 5) listar los codigos de pase incluidos con
git tag --merged origin/develop menos los ya presentes en origin/main (son los
del release; NO inventar ninguno; si no hay nuevos, terminar),
6) titulo "Release <fecha> (<N> pases)", 7) plantilla de descripcion
(pases incluidos con su ticket y tipo, requerimientos, soportes, resumen,
archivos, checklist de qa, compilacion y publicador),
8) confirmacion obligatoria mostrando la ruta,
9) crear con gh pr create y mostrar URL, 10) tras el merge VERIFICAR que todos
los tags del release quedaron en main (git tag --merged main; sin crear
codigo nuevo; si falta alguno, detenerse), 11) avisar a Pase Produccion para
que descargue cada codigo en orden de correlativo. Responde SOLO con el
contenido del archivo.

---

## PROMPT 5 - SKILL publicar

[CONTEXTO COMPARTIDO]

Genera un archivo SKILL.md con este frontmatter exacto:
- name: publicar
- description: explica que lista a Pase Produccion los pases pendientes y
  descarga por codigo del documento (tag TGE-PROD-YYYYMMDD-NNNNNN generado en
  la tarea): muestra commits, clasifica requerimientos/soportes y archivos de
  ESE codigo, pide confirmacion y
  solo entonces lo descarga exacto. ACLARA que no compila ni despliega y
  que es solo para Pase Produccion. Incluye los gatillos: "que hay nuevo
  en main", "que pases hay pendientes", "descarga la TGE-PROD-20260907-000004",
  "revisar release", "descargar release", "bajar a produccion", "publicar".
- allowed-tools: Bash(git:*)

El cuerpo debe tener pasos: 1) confirmar rol de Pase Produccion,
2) git checkout main + git fetch origin --tags (sin descargar),
3) listar pases pendientes (codigo local con git describe --tags y
codigos de GitHub con git ls-remote --tags origin; si no hay, avisar
que ya esta al dia y terminar), 4) pedir el codigo del documento de pase
(usarlo directo si ya lo dijo; con 2+ pases recordar el orden de menor a
mayor codigo; verificar que el tag exista o detenerse),
5) mostrar el contenido de ESE codigo (git log y git diff entre el codigo
actual y el tag, clasificar por lineas Tipo: requerimiento/soporte),
6) confirmacion obligatoria mostrando la ruta
"desde origin/main (<tag>) -> descargar hacia tu carpeta",
7) descargar exacto con git fetch origin tag <tag> + git checkout <tag>
solo tras confirmar, 8) verificar con git describe --tags que sea IGUAL
al codigo del documento (si no, NO publicar y avisar al Gestor),
9) recordar compilar y publicar desde la carpeta.
Reglas: nunca descargar sin confirmacion, nunca un codigo distinto al del
documento, nunca compilar ni desplegar, si el tag no coincide detenerse y
avisar. Responde SOLO con el contenido del archivo.
