import torch
from torchvision import models, transforms
from PIL import Image
import numpy as np
import json
import os

# Define la ruta de salida que Grand Challenge espera
OUTPUT_PATH = "/output/stacked-neoplastic-lesion-likelihoods.json"

class RARE25Algorithm:
    def __init__(self):
        self.model = models.efficientnet_b0(weights=None)
        num_ftrs = self.model.classifier[1].in_features
        self.model.classifier = torch.nn.Sequential(
            torch.nn.Dropout(p=0.4, inplace=True),
            torch.nn.Linear(num_ftrs, 2)
        )
        
        # --- ¡ESTA ES LA DIRECCIÓN CORRECTA! ---
        # Le decimos que busque el cerebro en la misma carpeta donde está él.
        model_path = "RARE25_best_model.pth" 
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

def process_image(image_path: str):
    algorithm = RARE25Algorithm()
    image = Image.open(image_path)
    result_prob = algorithm.predict(image)
    algorithm.save_output(result_prob)

if __name__ == "__main__":
    pass
