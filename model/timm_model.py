
# - Equipo Victoria

class TimmClassificationModel:
    def __init__(self, *args, **kwargs):
        pass

    def __call__(self, *args, **kwargs):
        # Devuelve una predicción falsa para que el sistema no se rompa
        return {"neoplastic_lesion_likelihood": 0.0}
