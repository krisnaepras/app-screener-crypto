# Screener Micin App (Flutter)

Flutter mobile application untuk monitoring cryptocurrency real-time dengan notifikasi otomatis.

## Features

-   **Real-time WebSocket Stream**: Koneksi ke backend Golang di Heroku untuk data real-time
-   **Push Notifications**: Notifikasi otomatis ketika ada coin dengan status TRIGGER (score ≥ 70)
-   **Technical Indicators**: Menampilkan RSI, EMA, Bollinger Bands, ATR, VWAP
-   **Multi-Strategy Screening**: Analisis berdasarkan berbagai strategi trading
-   **Search & Filter**: Cari coin berdasarkan symbol
-   **Detail View**: Informasi lengkap untuk setiap coin

## Architecture

```
lib/
├── main.dart                      # Entry point
├── models/                        # Data models
│   └── coin_data.dart
├── services/                      # Services layer
│   ├── api_service.dart          # WebSocket connection
│   ├── notification_service.dart # Push notifications
│   └── background_service.dart   # Background tasks
├── logic/                         # Business logic
│   └── screener_logic.dart       # Notification monitoring
├── ui/                           # UI screens
│   ├── home_screen.dart
│   ├── coin_detail_screen.dart
│   └── main_navigation.dart
├── scoring/                      # Scoring algorithms
└── indicators/                   # Technical indicators
```

## Backend Integration

### WebSocket URL

-   **Production**: `wss://screener-micin-eu-040b62987c7f.herokuapp.com/ws`
-   **Local Dev**: `ws://localhost:8080/ws` (atau `ws://10.0.2.2:8080/ws` untuk Android emulator)

### Data Format

Backend mengirim array JSON dengan struktur:

```json
[
  {
    "symbol": "BTCUSDT",
    "price": 98765.43,
    "score": 85.5,
    "status": "TRIGGER",
    "priceChangePercent": 2.5,
    "fundingRate": 0.0001,
    "features": { ... }
  }
]
```

## Notifications

### Trigger Conditions

Notifikasi akan dikirim ketika:

-   `status == "TRIGGER"`
-   `score >= 70`
-   Coin belum di-notify dalam 5 menit terakhir

### Notification Content

```
Title: 🚀 BTC TRIGGER
Body: Score: 85 | Price: $98765.43 | Change: 2.5%
```

### Implementation

Monitoring dilakukan di [screener_logic.dart](lib/logic/screener_logic.dart):

-   Subscribe ke WebSocket stream
-   Check setiap update untuk coin dengan TRIGGER status
-   Kirim notifikasi via `NotificationService`
-   Cooldown 5 menit per coin untuk menghindari spam

## Getting Started

### Prerequisites

-   Flutter SDK ≥ 3.0.0
-   Android Studio / Xcode (untuk development mobile)

### Installation

```bash
# Clone repository
cd screener-micin-app

# Install dependencies
flutter pub get

# Run app
flutter run
```

### Permissions

App memerlukan permission untuk:

-   **Internet**: Koneksi ke backend WebSocket
-   **Notifications**: Push notifications untuk alerts

### Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# iOS
flutter build ios --release
```

## Configuration

### Switch Backend URL

Edit [api_service.dart](lib/services/api_service.dart):

```dart
// Use local backend
static const bool useLocal = true;

// Or use Heroku (default)
static const bool useLocal = false;
```

### Build with Local Backend

```bash
flutter run --dart-define=USE_LOCAL=true
```

## Troubleshooting

### Tidak Terima Notifikasi

1. **Check Permissions**: Pastikan notification permission sudah granted
2. **Check Backend**: Pastikan websocket terkoneksi (lihat console log)
3. **Check Status**: Notifikasi hanya untuk coins dengan `status: "TRIGGER"` dan `score >= 70`
4. **Check Cooldown**: Ada cooldown 5 menit per coin

### WebSocket Connection Failed

1. **Heroku**: Cek apakah backend Heroku masih running
2. **Local**: Pastikan backend local jalan di port 8080
3. **Emulator**: Gunakan `10.0.2.2` untuk Android emulator
4. **Network**: Cek koneksi internet

### App Crashes

1. Check console logs untuk error details
2. Pastikan semua dependencies terinstall dengan benar
3. Try `flutter clean && flutter pub get`

## Technical Details

### Indicators Displayed

-   **RSI (14)**: Relative Strength Index
-   **EMA (20/50)**: Exponential Moving Average
-   **Bollinger Bands**: Upper/Lower bands
-   **ATR (14)**: Average True Range
-   **VWAP**: Volume Weighted Average Price

### Status Values

-   **TRIGGER**: Strong signal (score 70-100) - Notifikasi aktif
-   **SETUP**: Potential setup (score 50-69)
-   **WATCH**: Monitor (score < 50)

## Future Improvements

-   [ ] Historical data charts
-   [ ] Custom notification settings (threshold, cooldown)
-   [ ] Favorites/Watchlist
-   [ ] Dark/Light theme toggle
-   [ ] Price alerts (custom price targets)
-   [ ] Multiple timeframe views

## License

Proprietary - Internal use only

## Author

Krisna Epras - December 2025
