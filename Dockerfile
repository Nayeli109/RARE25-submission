# Use an official PyTorch runtime as a parent image
FROM pytorch/pytorch:latest

# Set up a new user "user"
RUN groupadd -r user && useradd -m --no-log-init -r -g user user

# Set the working directory in the container
WORKDIR /opt/app

# --- ¡AQUÍ ESTÁ LA MAGIA! ---
# Creamos las carpetas vacías que el baseline espera encontrar
RUN mkdir resources
RUN mkdir model

# Change to the new user
USER user

# Copiamos nuestros archivos
COPY --chown=user:user requirements.txt /opt/app/
COPY --chown=user:user model /opt/app/model # Esta línea la dejamos por si acaso
COPY --chown=user:user inference.py /opt/app/

# Instalamos las librerías
RUN python -m pip install --user --no-cache-dir --no-color --requirement /opt/app/requirements.txt

# By default, run the inference script
CMD ["python", "-u", "inference.py"]
