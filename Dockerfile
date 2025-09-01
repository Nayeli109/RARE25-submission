# 1. Usamos la base de PyTorch
FROM pytorch/pytorch:latest

# 2. Establecemos nuestro lugar de trabajo
WORKDIR /opt/app

# 3. ¡EL COMANDO MÁGICO! Copiamos TODO lo que hay en GitHub a la "caja"
COPY . .

# 4. Instalamos las librerías necesarias
RUN pip install -r requirements.txt

# 5. Ejecutamos nuestro script
CMD ["python", "-u", "inference.py"]
