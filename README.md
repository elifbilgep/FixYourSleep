# FixYourSleep
<img src="https://github.com/user-attachments/assets/c100e551-ea30-4471-890a-0e7dac46b908" alt="IMG_5777" width="300">
<img src="https://github.com/user-attachments/assets/39073760-b093-4dbd-a2d5-654ec4fa2b1c" alt="IMG_5776" width="300">
<img src="https://github.com/user-attachments/assets/1b7fde83-c317-4e58-9700-c9346d5996bc" alt="IMG_5775" width="300">
<img src="https://github.com/user-attachments/assets/7ea0e84d-70e6-4764-adfe-7ece924dbddf" alt="IMG_5772" width="300">
<img src="https://github.com/user-attachments/assets/1e2af791-20df-435a-912d-660ca7764a3b" alt="IMG_5768" width="300">
<img src="https://github.com/user-attachments/assets/b8feff60-67c1-4601-9b09-69fc999c1184" alt="IMG_5770" width="300">



## Overview
**FixYourSleep** is an iOS application designed to help users establish healthy sleep habits by setting ideal bedtime and wake-up routines. The app integrates notifications, Firebase services, and intuitive navigation to provide a seamless user experience. It encourages better sleep practices through reminders and actionable insights.

## Features
- **Onboarding Process**: A guided step-by-step introduction to help users define their sleep routines.
- **Sleep Goals**: Set and track bedtime and wake-up goals to improve sleep quality.
- **Notification Integration**: Smart notifications to remind users of their sleep schedules.
- **Firebase Integration**:
  - User authentication (Sign In, Sign Up) with **Apple Sign-In** and **Google Sign-In**.
  - Firestore for storing user data.
  - Analytics for tracking user interactions.
- **Dynamic Navigation**: Navigate through different app flows using a `RouterManager`.
- **Motion Manager**: Tracks and analyzes device motion to enhance sleep insights and user interaction.
- **Dark Mode Support**: Clean and optimized dark mode UI.

## Architecture
The app follows a **MVVM (Model-View-ViewModel)** architecture, ensuring modularity and scalability. Dependency injection is used via `ViewModelFactory` to streamline the creation of view models. The app also incorporates **Protocol-Oriented Abstraction** to enhance code modularity and testing by abstracting core functionalities through protocols.

### Key Components
- **`RouterManager`**: Handles dynamic navigation between views.
- **`FirebaseService`**: Abstracts Firestore database interactions.
- **`NotificationManager`**: Manages notifications and permission requests.
- **`MotionManager`**: Provides motion tracking capabilities for user engagement.
- **`ViewModelFactory`**: Provides centralized creation of view models.
- **Protocol-Oriented Abstractions**:
  - Abstracts services (e.g., `NotificationServiceProtocol`, `FirebaseServiceProtocol`) for better testability and flexibility.

## Technologies Used
- **SwiftUI**: For building the user interface.
- **Firebase**: For backend services (Authentication, Firestore, Analytics).
- **Apple Sign-In and Google Sign-In**: For seamless and secure user authentication.
- **MVVM Architecture**: For separating business logic and UI.
- **Dependency Injection**: For managing dependencies in a clean, testable manner.
- **Core Motion**: For motion data tracking.
- **Protocol-Oriented Abstraction**: For ensuring modular and testable service interactions.

## Installation
### Prerequisites
- Xcode 15.0 or later
- iOS 16.0 or later
- A Firebase project configured with Firestore and Authentication enabled

### Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/FixYourSleep.git
   ```
2. Open the project in Xcode:
   ```bash
   cd FixYourSleep
   open FixYourSleep.xcodeproj
   ```
3. Add your `GoogleService-Info.plist` file to the project root.
4. Build and run the app on a simulator or device:
   ```bash
   Cmd + R
   ```

## Usage
1. Launch the app.
2. Follow the onboarding process to set your sleep goals.
3. Use the home screen to view and adjust your sleep routines.
4. Enable notifications to receive reminders for your bedtime and wake-up schedules.


