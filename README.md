# Fundit 💰
**A Premium 3D Mobile Goal Tracker & Financial Progress Application**

Fundit helps users visualize their financial goals and provides actionable savings plans to reach them. Built with a focus on clean UI/UX, cinematic lighting in assets, and robust local data management.

## ✨ Features
* **Goal Management**: Create and track multiple financial goals with custom names, prices, and descriptions.
* **Smart Savings Plan**: Automatically calculates Daily, Weekly, and Monthly savings requirements based on a target "Estimated Date."
* **Visual Progress**: High-fidelity progress bars and percentage tracking for every goal.
* **Priority System**: Categorize goals by High, Medium, or Low priority with dynamic color-coding.
* **Transaction History**: Add or withdraw savings directly from the goal detail page with real-time database updates.
* **Local Persistence**: Powered by SQLite for fast, offline-first data reliability.

## 🛠️ Tech Stack
* **Framework**: [Flutter](https://flutter.dev/) (Channel Stable)
* **Language**: [Dart](https://dart.dev/)
* **Database**: `sqflite` (SQLite for Flutter)
* **Formatting**: `intl` for Philippine Peso (PHP) currency formatting.
* **Assets**: Custom 3D-rendered icons and cinematic imagery.

## 🚀 Getting Started

### Prerequisites
* Flutter SDK: `^3.0.0`
* Dart SDK: `^3.0.0`
* Android Studio / Xcode (for mobile simulation)

### Installation
1.  **Clone the repository**:
    ```bash
    git clone [https://github.com/yourusername/fundit.git](https://github.com/yourusername/fundit.git)
    cd fundit
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the app**:
    ```bash
    flutter run
    ```

## 📁 Project Structure
```text
lib/
├── db/             # SQLite Database helpers (DBHelper)
├── models/         # Data models (GoalModel)
├── screens/        # UI Screens (Homescreen, GoalDetailPage)
└── widgets/        # Reusable UI components
