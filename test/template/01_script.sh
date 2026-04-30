#!/bin/bash

# --- Comprueba si workdir existe y sino lo crea  ---
mkdir -p workdir

# --- Hace un compose y reconstruye la imagen por si existen cambios ---
docker compose -p "${COMPOSE_NAME}" up --build -d

# --- Sale del script ---
exit