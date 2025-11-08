from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
import torch
import uvicorn

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
MODEL_PATH = "./slm-recipe-summary"   # path to fine-tuned T5 model directory
DEVICE = torch.device("cpu")  # safe for macOS (can switch to cuda)

# ------------------------------------------------------------
# Load model and tokenizer
# ------------------------------------------------------------
print("🚀 Loading model from:", MODEL_PATH)
tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
model = AutoModelForSeq2SeqLM.from_pretrained(MODEL_PATH)
model.to(DEVICE)
model.eval()
print("✅ Model loaded successfully on", DEVICE)

# ------------------------------------------------------------
# FastAPI setup
# ------------------------------------------------------------
app = FastAPI(
    title="Small Language Model (SLM) API",
    description="Summarizes nutritional information into health insights.",
    version="1.0.0",
)

# ------------------------------------------------------------
# Request/Response Models
# ------------------------------------------------------------
class NutritionInput(BaseModel):
    calories: float
    protein: float
    fat: float
    carbs: float
    fiber: float = 0.0
    sugar: float = 0.0
    sodium: float = 0.0
    extra_context: str = None  # optional (e.g. "Goal: weight loss")


class SummaryResponse(BaseModel):
    summary: str
    input_text: str


# ------------------------------------------------------------
# Helper: Format nutrition data into model prompt
# ------------------------------------------------------------
def format_prompt(data: NutritionInput) -> str:
    base = (
        f"Calories: {data.calories}, Protein: {data.protein}g, Fat: {data.fat}g, "
        f"Carbs: {data.carbs}g, Fiber: {data.fiber}g, Sugar: {data.sugar}g, Sodium: {data.sodium}mg"
    )
    if data.extra_context:
        return f"Summarize nutrition insights for: {base}. Context: {data.extra_context}"
    else:
        return f"Summarize nutrition insights for: {base}"


# ------------------------------------------------------------
# API Endpoints
# ------------------------------------------------------------

@app.get("/health")
def health():
    """Health check"""
    return {"status": "ok", "device": str(DEVICE), "model": MODEL_PATH}


@app.post("/summarize", response_model=SummaryResponse)
def summarize(data: NutritionInput):
    """Generate nutrition/recipe summary from macro data"""
    try:
        prompt = format_prompt(data)
        inputs = tokenizer(prompt, return_tensors="pt", truncation=True).to(DEVICE)

        # Generate summary
        with torch.no_grad():
            outputs = model.generate(**inputs, max_new_tokens=80, temperature=0.8, top_p=0.9)

        summary = tokenizer.decode(outputs[0], skip_special_tokens=True)
        return SummaryResponse(summary=summary, input_text=prompt)

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating summary: {e}")


# ------------------------------------------------------------
# Run
# ------------------------------------------------------------
if __name__ == "__main__":
    uvicorn.run("server:app", host="0.0.0.0", port=8000, reload=False)
