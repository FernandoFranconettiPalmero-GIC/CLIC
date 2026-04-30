#!/bin/bash

# --- Genera en hex con herramientas POSIX, el identificador del contenedor ---
CONTAINER_HEX=$(printf '%s' "{\"containerName\":\"/${CONTAINER_SHELL}\"}" \
  | od -An -tx1 \
  | tr -d ' \n')

# --- Comprueba si el contenedor esta levantado ---
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_SHELL}$"; then

  # --- Abre una instancia de VS Code y bloquea el script hasta que se cierre ---
  code --wait --new-window --folder-uri "vscode-remote://attached-container+${CONTAINER_HEX}/workdir"

  # --- Hace un compose down ---
  docker compose -p "${COMPOSE_NAME}" down

fi

# --- Elimina cualquier plantilla con datos sensibles de la ruta de ejecucion ---
find . -maxdepth 1 -type f -delete

# --- Sale del script ---
exit