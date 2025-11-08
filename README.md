# NutriSnap

NutriSnap is a comprehensive mobile application that helps users identify Indian food items and provides nutritional information using computer vision and machine learning technologies.

## Project Overview

The project consists of multiple components:

- **Mobile App**: A Flutter-based mobile application that allows users to capture or upload food images
- **Food Classification Model**: A MobileNetV2-based model trained to recognize Indian food items
- **API Server**: Python-based server handling food classification and nutrition information requests
- **Summary Generation**: A language model for generating detailed nutritional summaries

## Components

### 1. Mobile Application (Flutter)
Located in `/MobileApp`, this is the main user interface built with Flutter. Features include:
- Camera integration for food image capture
- Real-time food classification
- Nutritional information display
- Health summary generation

### 2. API Server
Located in `/APIServer`, handles:
- Summary generation using SLM

### 3. MobileNet Model
Located in `/MobileNetModel`:
- Custom-trained MobileNetV2 model for Indian food classification
- Model conversion notebooks for mobile deployment
- Training dataset management

### 4. Summary Language Model
Located in `/SummarySLM`:
- Specialized language model for generating nutritional summaries
- Jupyter notebooks for model training and testing

## Setup and Installation

### Prerequisites
- Flutter SDK
- Python 3.8+
- Required Python packages (see individual requirements.txt files)
- Android Studio / Xcode for mobile development

### Mobile App Setup
1. Navigate to the MobileApp directory:
   ```bash
   cd MobileApp
   ```
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Ensure assets are properly linked in `pubspec.yaml`

### API Server Setup
1. Navigate to the APIServer directory:
   ```bash
   cd APIServer
   ```
2. Install Python dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Start the server:
   ```bash
   ./start.sh
   ```

## Model Information

The food classification model is based on MobileNetV2 architecture, specifically trained on Indian food items. The model files are:
- `indianfood_mobilenetv2.pt`: Primary model file
- `indian_food_labels.txt`: Classification labels

## Usage

1. Launch the API server
2. Start the mobile application
3. Use the camera to capture food images
4. View classification results and nutritional information
5. Generate detailed health summaries as needed

## Contributing

Contributions to improve the model accuracy, expand the food database, or enhance the application features are welcome. Please refer to individual component directories for specific contribution guidelines.

## License

none

## Authors

- team techtitans
                YASWANTH BUDURU
                SREERAMADASU MUKUNDA RAMA CHARY
                A.SWARANJITH KUMAR GOUD
                B.BHARGAV VENKAT DORA


## Acknowledgments

- Thanks to contributors and data providers
- Reference to any external datasets or models used