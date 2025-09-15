import torch
from torchvision import models, transforms
from PIL import Image
import numpy as np
import json
import os
import glob
import openslide # ¡La herramienta del cerrajero!

INPUT_DIR = "/input/"
OUTPUT_PATH = "/output/stacked-neoplastic-lesion-likelihoods.json"

class RARE25Algorithm:
    def __init__(self):
        self.model = models.efficientnet_b0(weights=None)
        num_ftrs = self.model.classifier[1].in_features
        self.model.classifier = torch.nn.Sequential(
            torch.nn.Dropout(p=0.4, inplace=True),
            torch.nn.Linear(num_ftrs, 2)
        )
        
        model_path = "/opt/app/RARE25_best_model.pth" 
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        
        self.model.load_state_dict(torch.load(model_path, map_location=self.device))
        self.model.to(self.device)
        self.model.eval()

        self.transform = transforms.Compose([
            transforms.Resize((224, 224)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
        ])

    def predict(self, image: Image.Image) -> float:
        image = image.convert("RGB")
        image_tensor = self.transform(image).unsqueeze(0).to(self.device)
        
        with torch.no_grad():
            outputs = self.model(image_tensor)
            probabilities = torch.nn.functional.softmax(outputs, dim=1)
        
        cancer_probability = probabilities[0][1].item()
        return cancer_probability

    def save_output(self, probability: float):
        output_data = [
            {
                "value": probability
            }
        ]
        
        os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
        with open(OUTPUT_PATH, 'w') as f:
            json.dump(output_data, f)
        
        print(f"Resultado guardado en {OUTPUT_PATH}")

def run_inference():
    # 1. Buscamos  .dzi en la carpeta de entrada
    dzi_files = glob.glob(os.path.join(INPUT_DIR, "*.dzi"))
    if not dzi_files:
        raise FileNotFoundError(f"No se encontró un archivo .dzi en {INPUT_DIR}")

    dzi_path = dzi_files[0]
    print(f"Abriendo la caja fuerte: {dzi_path}")

    # 2. 
    slide = openslide.OpenSlide(dzi_path)
    
    # 3. Leemos la imagen completa y la convertimos
    image = slide.read_region((0,0), 0, slide.level_dimensions[0]).convert("RGB")
    slide.close()
    
    print("¡Imagen extraída con éxito! Pasando al chef...")

    # 4. Creamos el algoritmo y procesamos la imagen
    algorithm = RARE25Algorithm()
    result_prob = algorithm.predict(image)
    algorithm.save_output(result_prob)
    print("¡Proceso completado con éxito!")

if __name__ == "__main__":
    run_inference()