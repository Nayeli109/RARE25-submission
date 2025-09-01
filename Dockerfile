# Use an official PyTorch runtime as a parent image
FROM pytorch/pytorch:latest

# Set up a new user "user"
RUN groupadd -r user && useradd -m --no-log-init -r -g user user

# Set the working directory in the container
WORKDIR /opt/app

# Change to the new user
USER user

# --- ESTA ES LA PARTE IMPORTANTE ---
# Copiamos todos nuestros archivos a la "caja"

# 1. Copiamos la lista de la compra
COPY --chown=user:user requirements.txt /opt/app/

# 2. Copiamos la carpeta 'model' que nos faltaba
COPY --chown=user:user model /opt/app/model

# 3. Instalamos las librerías
RUN python -m pip install --user --no-cache-dir --no-color --requirement /opt/app/requirements.txt

# 4. Copiamos nuestra receta de inferencia
COPY --chown=user:user inference.py /opt/app/

# --- ¡LISTO! ---

# By default, run the inference script
CMD ["python", "-u", "inference.py"]
