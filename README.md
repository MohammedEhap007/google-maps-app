# 🗺️ Google Maps App

A comprehensive Flutter application demonstrating advanced Google Maps integration with real-time location tracking, place search, route planning, and custom map styling.

## ✨ Features

### 🧭 Core Map Features

- **Interactive Google Maps** with custom styling support
- **Real-time location tracking** with permission handling
- **Custom map markers** with SVG/PNG support
- **Night mode map styling** with JSON customization
- **Camera controls** with smooth animations

### 🔍 Search & Places

- **Google Places API integration** for location search
- **Auto-complete predictions** with debounced input
- **Place details** with comprehensive information

### 📍 Location Services

- **Current location detection** with high accuracy
- **Location permission management** with user-friendly dialogs
- **Location service status** monitoring and error handling

### 🛣️ Route Planning

- **Route calculation** between multiple points
- **Turn-by-turn directions** integration
- **Distance and duration** estimation
## 📸 Screenshots
  <img width="5340" height="2400" alt="Group 1" src="https://github.com/user-attachments/assets/8173a8fe-b46f-4e30-9845-846b05472023" />
  <img width="6408" height="2400" alt="Group 2" src="https://github.com/user-attachments/assets/dd9df0e4-dd69-40be-8551-d1889251c050" />
  
  ---
  
## 🏗️ Project Structure

```
lib/
├── main.dart                     # App entry point
├── route_tracker_module/         # Main module for route tracking
│   ├── views/                    # UI screens
│   │   └── route_tracker_view.dart
│   ├── services/                 # Business logic services
│   │   ├── location_service.dart
│   │   └── google_maps_places_api_service.dart
│   ├── models/                   # Data models
│   │   └── place_autocomplete_model/
│   ├── helpers/                  # Utility functions
│   │   ├── navigate_to_current_location.dart
│   │   └── show_error_dialog.dart
│   ├── errors/                   # Custom exceptions
│   │   └── exception.dart
│   └── widgets/                  # Reusable widgets
├── basics_module/                # Basic map features
└── live_location_tracker_module/ # Live tracking features
```

## 🔧 Configuration

### Google Maps API Setup

1. **Enable required APIs** in Google Cloud Console:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API
   - Routes API

2. **Set up API key restrictions** for security:
   - Android: Add your app's SHA-1 fingerprint
   - iOS: Add your app's bundle identifier

### Environment Variables

The app uses environment variables for sensitive configuration:

```env
GOOGLE_MAPS_API_KEY=your_api_key_here
```

## 🛠️ Dependencies

### Core Dependencies

- **google_maps_flutter**: ^2.12.3 - Google Maps integration
- **location**: ^8.0.1 - Location services
- **http**: ^1.5.0 - HTTP requests
- **flutter_dotenv**: ^6.0.0 - Environment variables

### Platform-Specific

- **google_maps_flutter_android**: ^2.18.2 - Android optimizations
- **google_maps_flutter_platform_interface**: ^2.14.0 - Platform interface

### Utilities

- **flutter_polyline_points**: ^3.0.1 - Route polylines
- **uuid**: ^4.5.1 - Unique identifiers

## 🔍 API Services

### Location Service

Handles all location-related operations:

- Current location detection
- Permission management
- Location updates

### Google Maps Places API Service

Manages place search functionality:

- Auto-complete predictions
- Place details
- Nearby search

## 🎨 Customization

### Map Styling

Custom map styles are stored in `assets/map_styles/`:

- `night_map_style.json` - Dark theme for the map

---

**Note**: Please keep your API keys secure and never commit them to version control. Use environment variables or secure key management services in production.
