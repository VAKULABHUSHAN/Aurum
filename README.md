# Aurum

Aurum is a lightweight, premium Flutter application specifically designed to monitor live Indian Gold Rates based on official IBJA (Indian Bullion and Jewellers Association) benchmarks. Built with a clean, minimal, Apple Finance-inspired aesthetic, Aurum seamlessly provides live market updates, an interactive local price history chart, a native Android Home Screen widget, and robust offline capabilities.

## ✨ Features

- **Indicative IBJA Benchmark Tracking:** Fetches live Indian retail reference prices for 24K, 22K, and 18K gold directly derived from IBJA AM/PM sessions, removing reliance on inaccurate international spot rates.
- **Offline-First Architecture:** Instantly loads and displays the latest locally cached price upon launch using Hive, ensuring zero loading screens or disruptions while fresh data is retrieved in the background.
- **Native Android Home Screen Widget:** Monitor the current 24K and 22K prices directly from your Android home screen. The widget runs natively and is updated via background syncs.
- **Interactive Price History Chart:** An elegant 7D and 30D line chart (built with `fl_chart`) that is rendered exclusively from locally accumulated data points.
- **Background Syncing:** Periodically fetches new gold prices in the background (using `workmanager`), caches them, updates the home screen widget, and appends a canonical daily record to your local chart history.
- **Premium Material 3 Design:** A sleek, minimal UI using customized typography (Outfit/Inter), harmonious spacing, dynamic price movement indicators, and a carefully curated gold/dark palette.

## 🛠 Tech Stack

- **Framework:** Flutter
- **State Management:** GetX
- **Networking:** Dio (hitting `ibja-api.vercel.app/latest`)
- **Local Storage:** Hive & Hive Flutter (with Hive Generator for `IndianGoldRateModel` TypeAdapters)
- **Background Tasks:** Workmanager
- **Charts:** fl_chart
- **Widgets:** home_widget (for native Android widget integration)
- **Utilities:** Intl (Currency & Date Formatting), Logger

## 🏗 Architecture & Data Flow

The project is structured efficiently under `lib/` using feature-based architecture:

1. **`core/`**: Application-wide constants (colors, fonts), theme data, and shared services:
   - `GoldApiService`: Handles network requests to the IBJA API.
   - `StorageService`: Manages Hive boxes (`indian_gold_latest_live_price` and `indian_gold_market_history`). Ensures data deduplication (keeping only one canonical chart point per market day).
   - `BackgroundService`: Configures Workmanager for periodic background syncs.
   - `WidgetService`: Bridges Flutter and native Android code to update the Home Screen widget XML.
2. **`data/`**: Strictly typed data models (`IndianGoldRateModel`, `PriceMovement`, `ChartRange`) natively integrated with Hive TypeAdapters.
3. **`features/`**: The main screens and UI components.
   - `HomeController`: The central GetX controller orchestrating initial load, API fetches, chart history computation, and price movement calculations.
   - `HomeScreen`: The master UI dashboard.
4. **`routes/`**: Centralized GetX routing configurations.

### 🔄 How Historical Charting Works
The IBJA API provides current live rates rather than extensive historical endpoints. To build the chart, Aurum relies on **Local Accumulation**:
- Every time the app fetches a new price (either manually or in the background), the record is appended to the `indian_gold_market_history` Hive box.
- The `HomeController` deduplicates these records by grouping them strictly by `rateDate`. If you fetch 5 times on the same day, the latest pull (e.g. PM session) overrides earlier pulls for that day.
- The chart begins plotting only when it has locally collected at least 2 distinct days of data. Until then, it displays an intentional "Building price history..." state.

## 🚀 Getting Started

1. **Clone the repository:**
   ```bash
   git clone https://github.com/VAKULABHUSHAN/Aurum.git
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Generate Hive Adapters:**
   If you ever modify the `IndianGoldRateModel`, you must re-generate the TypeAdapters:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Run the app:**
   ```bash
   flutter run
   ```

## 🧪 Testing

Aurum includes comprehensive unit and widget tests to ensure deduplication, price movement mathematics, and UI rendering remain flawless.

To run the test suite:
```bash
flutter test
```
