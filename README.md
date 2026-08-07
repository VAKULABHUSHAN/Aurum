# Aurum

Aurum is a lightweight, premium Flutter application designed to monitor the live Indian 24K gold price. Built with a clean, minimal, Apple Finance/Google Wallet-inspired aesthetic, Aurum seamlessly provides live market updates and robust offline capabilities.

## Features

- **Live Gold Price Tracking:** Connects to the GoldPrice.dev API to fetch and display the current 24K gold price in INR.
- **Offline-First Architecture:** Instantly loads and displays the latest locally cached price upon launch, preventing loading screens or disruptions while fresh data is retrieved in the background.
- **Premium Material 3 Design:** A sleek, minimal UI using customized typography, harmonious spacing, and a carefully curated gold/white color palette.
- **Robust Local Storage:** Employs strictly typed Hive adapters to securely cache historical price records without duplication.
- **Debug Logging:** Integrated structured network request and response logging that disables automatically in Release mode.

## Tech Stack

- **Framework:** Flutter (Latest Stable)
- **State Management:** GetX
- **Networking:** Dio
- **Local Storage:** Hive & Hive Flutter (with Hive Generator for TypeAdapters)
- **Utilities:** Intl (Currency & Date Formatting), Logger

## Architecture

The project maintains a simple yet effective feature-based structure inside `lib/`:

- `core/`: Application-wide constants (colors, spacing, radius), theme data, shared services (API, Storage), and formatting utilities.
- `data/`: Strictly typed data models (`GoldPriceModel`, `GoldHistoryModel`) natively integrated with Hive TypeAdapters.
- `features/`: The application's main screens and business logic components (e.g., `HomeController`, `HomeScreen`).
- `routes/`: Centralized GetX routing configurations.

## Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/VAKULABHUSHAN/Aurum.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Generate Hive Adapters:**
   If you ever modify the models, re-generate the TypeAdapters:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Run the app:**
   ```bash
   flutter run
   ```
