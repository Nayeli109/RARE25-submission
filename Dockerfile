# Use an official PyTorch runtime as a parent image
FROM pytorch/pytorch:latest

# Set the working directory in the container
WORKDIR /opt/app

# --- PRIMERO, PREPARAMOS TODO COMO "JEFE" (root) ---

# 1. Creamos las carpetas vacías que el baseline espera
RUN mkdir resources
RUN mkdir model

# 2. Copiamos la lista de la compra
COPY requirements.txt /opt/app/

# 3. Copiamos nuestra carpeta 'model' (que ahora sí está en GitHub)
COPY model /opt/app/model

# 4. Copiamos nuestra receta de inferencia
COPY inference.py /opt/app/

# 5. Instalamos las librerías
RUN python -m pip install --no-cache-dir --no-color --requirement /opt/app/requirements.txt

# --- AHORA, LE DAMOS TODO AL "USER" ---

# 6. Creamos al usuario y le damos la propiedad de todo
RUN groupadd -r user && useradd -m --no-log-init -r -g user user
RUN chown -R user:user /opt/app

# 7. ¡Y AHORA SÍ, NOS PONEMOS EL UNIFORME!
USER user

# By default, run the inference script
CMD ["python", "-u", "inference.py"]
