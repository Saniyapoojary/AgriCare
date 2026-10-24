#  AgriCare – AI-Based Arecanut Disease Diagnosis & Workforce Management

AgriCare is an AI-powered agricultural mobile application designed to help arecanut farmers identify crop diseases, understand disease severity, access treatment guidance, and connect with agricultural workers. The application combines machine learning with digital workforce management to support smarter farming decisions.

## 🎯 Project Objectives

- Enable early identification of arecanut diseases using crop images.
- Help farmers understand disease severity and appropriate treatment options.
- Simplify agricultural workforce discovery and job management.
- Provide a user-friendly mobile platform for farmers and agricultural workers.

## Key Features

### AI-Based Disease Detection
- Analyze arecanut crop images using a TensorFlow Lite machine learning model.
- Support disease identification for Healthy crops, Koleroga, Bud Rot, Yellow Leaf Disease, Fruit Rot, and Anthracnose.
- Classify disease severity into Mild, Moderate, and Severe categories where supported by the implemented workflow.
- Provide disease-related guidance to help farmers make informed decisions.

###  Farmer Dashboard
- Access crop scanning and disease reports.
- View relevant farming information.
- Create agricultural job requests.
- Track job details and request status.

### Agricultural Workforce Management
- Browse available agricultural jobs.
- View and manage assigned jobs.
- Support worker matching and reliability scoring through application logic.
- Manage worker profiles and job-related information.

### Mobile Application
- Built with Flutter for a cross-platform application experience.
- Organized screens for farmers and agricultural workers.
- Reusable widgets and structured application components.
- Local machine learning model integration for crop disease analysis.

##  Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile application |
| Dart | Application programming language |
| TensorFlow Lite | On-device machine learning inference |
| Machine Learning | Crop disease identification |
| Git & GitHub | Version control and source management |

##  Project Structure

```text
AgriCare/
├── android/                  # Android platform configuration
├── ios/                      # iOS platform configuration
├── web/                      # Flutter web configuration
├── windows/                  # Windows platform configuration
├── assets/
│   └── models/
│       ├── arecanut_model.tflite
│       ├── plant_labels.txt
│       └── MODEL_ATTRIBUTION.md
├── lib/
│   ├── main.dart             # Application entry point
│   ├── models/               # Application data models
│   ├── screens/              # Farmer and worker interfaces
│   ├── services/             # Diagnosis and matching logic
│   ├── state/                # Application state management
│   ├── theme/                # Application theme
│   ├── utils/                # Utility functions
│   └── widgets/              # Reusable UI components
├── test/                     # Application tests
├── pubspec.yaml              # Flutter dependencies
└── README.md
```

## Getting Started

### Prerequisites

Install the following tools before running the application:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Android Studio](https://developer.android.com/studio) or VS Code
- Git

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/YOUR-USERNAME/AgriCare-AI-Mobile.git
```

Replace `YOUR-USERNAME` with your GitHub username.

**2. Navigate to the Flutter project directory**

```bash
cd AgriCare-AI-Mobile/AgriCare-main
```

If you upload the Flutter project files directly into the repository root, use `cd AgriCare-AI-Mobile` instead.

**3. Install dependencies**

```bash
flutter pub get
```

**4. Check your development environment**

```bash
flutter doctor
```

**5. Run the application**

Connect an Android device or start an emulator, then execute:

```bash
flutter run
```

##  Testing

Run the available Flutter tests using:

```bash
flutter test
```

The repository includes widget and login-related test files. Actual test results depend on the project configuration and environment.

##  Machine Learning Model

The application includes a TensorFlow Lite model at `assets/models/arecanut_model.tflite`, along with a label file used by the application.

The model is intended to support arecanut disease identification. Its accuracy and reliability should be evaluated using a representative, independently labelled dataset before using predictions for agricultural decisions.

##  Future Enhancements

- Integrate a fully connected backend and persistent database.
- Expand disease-detection accuracy through additional field-image validation.
- Improve treatment recommendations with verified agricultural guidance.
- Add regional-language support for farmers.
- Enhance worker matching using location, availability, and reliability information.
- Provide notifications and detailed analytics for farmers and workers.

##  Contributions

AgriCare is a collaborative agricultural technology project. Contributions, suggestions, and improvements are welcome, subject to the project's ownership and licensing terms.

If you are contributing to the project, document your changes clearly and acknowledge the work of other team members.

## ⚠️ Disclaimer

Disease predictions are intended as decision-support information and should not replace professional agricultural diagnosis. Treatment decisions should be made using verified agricultural recommendations.

## 📄License

Check the project's existing license and model attribution requirements before redistributing the source code or machine learning model. Add a license file only when the project owners have agreed on the applicable terms.

---

**AgriCare — Supporting healthier arecanut crops through AI and digital agriculture.** 🌱
