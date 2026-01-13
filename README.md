# 🗑️ Eco Snap: Smart Waste Sorter
An intelligent, cross-platform mobile application that simplifies accurate waste sorting using cutting-edge Vision AI and gamified tracking. Help the planet one snap at a time!

# 🌟 Project Overview
Eco Snap is designed to eliminate the confusion of waste separation. Developed with Flutter, it provides a seamless user experience while leveraging powerful Large Vision Models (LVMs) to instantly categorize waste, turning a daily chore into an impactful, trackable action.

[![Demo Application](https://img.youtube.com/vi/YwNOcrpJMGc/0.jpg)](https://www.youtube.com/watch?v=YwNOcrpJMGc)

# ✨ Key Features
| Icon | Feature                    | Description                                                            |
| ---- | -------------------------- | ---------------------------------------------------------------------- |
| 📸   | **AI-Powered Recognition** | Analyze images using Ollama + Qwen 2.5-VL to classify waste instantly. |
| 📊   | **Impact Tracking**        | Dashboard showing personal stats and environmental contributions.      |
| 📚   | **Educational Hub**        | Learn correct waste-sorting rules and recycling tips.                  |
| 🕹️  | **Gamified Learning**      | Mini-games to make waste sorting fun and interactive.                  |
| 📱   | **Cross-Platform**         | Smooth experience on both **iOS** and **Android** (Flutter).           |
| ☁️   | **Cloud Backend**          | Firebase for Auth, Firestore, and Storage.                             |

# ⚙️ Technology Stack
| Category     | Technology           | Purpose                                       |
| ------------ | -------------------- | --------------------------------------------- |
| **Frontend** | Flutter (Dart)       | Cross-platform UI                             |
| **AI / ML**  | Ollama + Qwen 2.5-VL | Local inference for LVM-based image detection |
| **Backend**  | Firebase             | Authentication, Database, Storage             |


# 🚀 Getting Started
Follow these steps to set up the project locally:

# 1. Prerequisites
Flutter SDK installed.
A Firebase project configured (authentication, Firestore).
Ollama installed on your machine (required for running the local AI model).

# 2. Clone the Repository
```
git clone https://github.com/YourUsername/eco-snap.git
cd eco-snap
```
# 3. Ollama Setup (AI Model)
The application requires an active Vision Language Model running via Ollama.
Download the Model: Pull the required model (e.g., Qwen 2.5-VL) using the terminal:
```
ollama pull qwen2.5vl:lastest
```
Start the Ollama Server: Run the Ollama server in a separate terminal window. The application communicates with this API.
```
ollama serve
```
# 4. Install Flutter Dependencies
```
flutter pub get
```
# 5. Configure Firebase
Place your google-services.json (Android) or GoogleService-Info.plist (iOS) in the correct directories.
Update Firebase configuration in the code if necessary.

# 6. Run the Application
Ensure the Ollama server (ollama serve) is running before executing the Flutter app.
```
flutter run
```
