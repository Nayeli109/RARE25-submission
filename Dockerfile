# 1. Usamos la base de PyTorch
FROM pytorch/pytorch:latest

# 2. ¡INSTALAMOS LAS HERRAMIENTAS!
RUN apt-get update && apt-get install -y libopenslide0

# 3. Establecemos nuestro lugar de trabajo
WORKDIR /opt/app

# 4. Copiamos TODO lo que hay en el repositorio 
COPY . .

# 5. Instalamos las librerías de Python 
RUN pip install -r requirements.txt

# 6. Ejecutamos nuestro script
CMD ["python", "-u", "inference.py"]