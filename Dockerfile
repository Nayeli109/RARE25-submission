# We use an official PyTorch image as the base
FROM pytorch/pytorch:latest

# Set the working directory inside the container
WORKDIR /opt/app

# --- Start as "Boss" (root) to prepare everything ---

# 1. Copy ALL required files and folders from GitHub into the "box"
COPY requirements.txt /opt/app/
COPY model /opt/app/model/
COPY resources /opt/app/resources/
COPY inference.py /opt/app/

# 2. Install the Python libraries
RUN python -m pip install --no-cache-dir --requirement /opt/app/requirements.txt

# --- Now, prepare the user for security ---

# 3. Create a non-privileged user
RUN groupadd -r user && useradd -m --no-log-init -r -g user user

# 4. Give ownership of our entire application to the new user
RUN chown -R user:user /opt/app

# 5. Switch to that user's "uniform"
USER user

# By default, when starting, run our inference script
CMD ["python", "-u", "inference.py"]
