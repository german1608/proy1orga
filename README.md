# proy1orga
El proyecto 1 de CI3815

# Como contribuir

## Si es tu primera vez

1) Haz fork al repo (arriba a la derecha hay un boton que dice **fork**
2) Clona **TU REPO**, es decir, el fork que le hiciste.
3) Añade el remoto original (mi repo).
```bash
# Si usas SSH para clonar:
$ git remote add upstream git@github.com:german1608/proy1orga.git
# Si usas HTTPS:
$ git remote add upstream https://github.com/german1608/proy1orga.git
```

## Cuando comienza el día
```bash
git checkout master        # Cambiamos al master
git fetch upstream         # Bajamos los cambios del repo principal
git rebase upstream/master # Aplicamos los cambios del master del repo principal
git checkout tu-rama       # Cambias a tu rama donde estas trabajando
git rebase master          # Aplicas los cambios que se aplicaron en el master principal sobre tu rama
```

## Mientras trabajas

Es muy importante que **siempre escribas tu codigo en un branch aparte al master**.
Esto es para que nuestro master este bien limpio y ademas si cometes un error
pues no dañamos todo el proyecto.

Cuando empiezas a escribir codigo, crea una branch para que escribas codigo ahi:
```bash
git branch <nombre-de-branch>
git checkout <nombre-de-branch>
```

```bash
git add file-name
git commit -m 'Mensaje del commit'
```

## Subir el trabajo realizado al remoto

Antes de subir cambios, ejecuta lo de la parte **Cuando comienza el dia**
Cuando decides que tu codigo esta listo para que se monte en el remoto, ejecutas
```bash
$ git push -u origin <tu-rama>
```
y luego ejecutas un pull request en la interfaz de github. Vas a tu fork en github
y le das a pull request.

Es muy importante que para evitarnos dolores de cabeza, se revise bien que hace
nuestro codigo, es decir, analizar si el codigo no introduce bugs, si hace lo que
debe, etc.
