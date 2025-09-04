# Flutter Thermal Printer App

This project demonstrates a Flutter application that communicates with a thermal printer via Bluetooth using Android native code (Kotlin) and Flutter platform channels.

## Features

*   Connect to a Bluetooth thermal printer.
*   Send text data to the printer.
*   Close the printer connection.

## Prerequisites

Before you begin, ensure you have the following installed:

*   Flutter SDK: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
*   Android Studio (for Android SDK and platform tools)
*   A physical Android device with Bluetooth capabilities and a compatible thermal printer (e.g., Sunmi, iMini, or any ESC/POS compatible Bluetooth printer).

## Project Structure

*   `lib/main.dart`: Contains the Flutter UI and the platform channel communication logic.
*   `android/app/src/main/kotlin/com/example/flutter_printer_app/MainActivity.kt`: The main Android activity that handles method calls from Flutter and initializes the `PrinterService`.
*   `android/app/src/main/kotlin/com/example/flutter_printer_app/PrinterService.kt`: Contains the Android native code for Bluetooth printer communication (connecting, printing, and closing connection).
*   `android/app/src/main/AndroidManifest.xml`: Defines necessary Bluetooth permissions for the Android application.

## Setup and Run

1.  **Clone the repository (or create the project if you followed the steps):**

    ```bash
    # If you are cloning
    git clone <repository_url>
    cd flutter_printer_app
    ```

    If you created the project by following the steps, you should already be in the `flutter_printer_app` directory.

2.  **Get Flutter dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Open the Android project in Android Studio:**

    Navigate to the `android` folder within your `flutter_printer_app` directory and open it with Android Studio. This will allow Android Studio to download necessary Gradle dependencies and set up the Android project.

4.  **Connect your Android device:**

    Ensure your Android device is connected to your development machine via USB and USB debugging is enabled.

5.  **Pair your Bluetooth printer with your Android device:**

    Go to your Android device's Bluetooth settings and pair it with your thermal printer. Make a note of the printer's Bluetooth MAC address (e.g., `00:11:22:33:44:55`). You might find this in the printer's documentation or by checking the paired devices list on your Android phone.

6.  **Run the Flutter application:**

    ```bash
    flutter run
    ```

    Alternatively, you can run the app directly from Android Studio by selecting your connected device and clicking the 'Run' button.