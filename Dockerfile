# 1. Usamos la base de PyTorch
FROM pytorch/pytorch:latest

# 2. Establecemos nuestro lugar de trabajo
WORKDIR /opt/app

# 3. Copiamos TODO lo que hay en GitHub a la "caja"
# Esto lo hacemos como (root) para que no haya problemas de permisos al copiar
COPY . .

# 4. Instalamos las librerías necesarias
RUN pip install -r requirements.txt

# 5. Creamos un conductor designado sin tantos privilegios
RUN groupadd -r user && useradd -m --no-log-init -r -g user user

# 6. Le damos al conductor la propiedad del coche
RUN chown -R user:user /opt/app

# 7. 
USER user

# 8. 
CMD ["python", "-u", "inference.py"]
