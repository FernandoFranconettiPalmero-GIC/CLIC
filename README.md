# _**WSL-DevContainers**_

_**DISCLAIMER**_

- Este proyecto consta de un conjunto de scripts en varios lenguajes de scripting que consiguen una reproducibilidad consistente y cómoda para proyectos hechos en Docker.

- También soluciona varios problemas comunes de detección de cambios y lentitud de mounting points entre Docker Desktop (Windows) y contenedores Linux.

_**BENEFITS**_

- Facilidad de uso.

- Comodidad.

- Reproductibilidad.

_**PREREQUISITES**_

- _**Windows 10/11**_

- _**Docker Desktop**_

- _**Visual Studio Code**_

    - _**[WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)**_

    - _**[DevContainers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)**_

## _**¿CÓMO FUNCIONA?**_

1. El archivo `.vbs` inicia en oculto el script `hiddenStarter.ps1`.

2. `hiddenStarter.ps1` importa `envTools.psm1` y carga las variables definidas en `.env`.

3. Para evitar problemas de permisos, obtiene UID, GID y el nombre de usuario del usuario por defecto de WSL.

4. Ya con las variables importadas trata las plantillas de `.\template` y las deja montadas en `.\log\debug_templates`.

5. Copia la carpeta `.\log\debug_templates` a la home del usuario por defecto de `WSL` dentro de `.\compose`.

6. `hiddenStarter.ps1` ejecuta `visibleLifter.ps1`.

7. `visibleLifter.ps1` entra en el shell de `WSL` y corre el script `01-script.sh`.

8. `01-script.sh` monta docker-compose.yml.

9. `hiddenStarter.ps1` entra en el shell de `WSL` y corre el script `02-script.sh`.

10. `02-script.sh` incia VS Code dentro del contenedor gracias a DevContainers.

11. Una vez cerrada la ventana VS Code se bajan todos los contenedor. 

# _**STEP 1**_

**R**ealizamos el clonado del repositorio.

```powershell
git clone https://github.com/Adhoc-Analytics/WSL-DevContainers-AdHoc-Panel
```

Instalamos `WSL` y configuramos `Debian` como distribución base.

```powershell
wsl --install --no-distribution
wsl --update
wsl --install -d Debian
```

    SE RECOMIENDA REINICIAR EN ESTE PUNTO.

# _**STEP 2**_

**A**ctualizamos los repositorios, preparamos certificados e instalamos Git.

```bash
sudo apt-get update && sudo apt-get upgrade -y \
    && sudo apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        wget \
    && sudo rm -rf /var/lib/apt/lists/*
```

# _**STEP 3**_
**O**ptimizamos la integración entre Docker Desktop y WSL.

1. Dentro de `Docker Desktop` abrimos ajustes ( _Arriba a la derecha_ ).

    ![1](/public/img/1.png)

2. Entramos en `Resources`.

    ![2](/public/img/2.png)

3. Vamos hacia la pestaña de `WSL integration`. 

    ![3](/public/img/3.png)

4. Activamos la integración con `Debian`.

    ![4](/public/img/4.png)

# _**STEP 4**_
**U**tilizamos la extensión oficial de Microsoft para trabajar con `WSL` desde `VS Code`.


[**Microsoft WSL**](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)

Desde la nueva pestaña nos conectamos a `Debian` mediante la flecha.

![5](/public/img/5.png)

# _**STEP 5**_
**I**dentificamos `.env.example` y creamos nuestro `.env`.

    Cerramos las ventanas de los siguientes programas:  

    - PowerShell
    - Visual Studio Code

# _**STEP 6**_

**A**brimos la aplicación deseada ejecutando su archivo `.vbs`.

## _**FAQ**_

*¿Por qué Debian?* 

    - Estabilidad
    - Compatibilidad
    - Espacio

*¿Por qué no funciona **X** comando?* 

    A causa de limitaciones en las redes internas de Docker (Windows), se han creado alias para estos comandos:

    - bun-run-dev → npm/bun run dev -H 0.0.0.0   
    - uv-run-fastapi-dev → uv run fastapi dev --host 0.0.0.0

*¿Cómo funciona específicamente esto?* 

    Todos los scripts están comentados para que se entienda su funcionamiento.