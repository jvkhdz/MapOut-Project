# MapOut 📍

A feature-rich iOS planning app built with SwiftUI and SwiftData.

## Features

### Core
- Create plans with 6 categories: Personal, Work, Friends, Trip, Health, Other
- Category-specific fields (Trip: airline, hotel, packing list | Work: priority, notes | Friends: attendees, location | Health: type, goal, frequency)
- Edit and delete plans
- Mark plans as complete with confetti animation
- Auto-delete plans 3 days after completion
- Search and filter plans by category

### Views
- **Plans** — grouped by category with live countdown to next upcoming plan
- **Calendar** — see all plans laid out by date with weather forecast
- **Stats** — completion rate, streaks, plans per category chart
- **Memories** — visual diary of all completed plans with photos

### Smart Features
- Weather forecast integration (Open-Meteo API) for plans with a location
- Push notifications before plan start time
- Countdown timer on upcoming plans
- Photo log — add multiple photos to any plan as a journal
- Cover image per plan
- Share plan as a beautiful image card
- Plan templates + save your own custom templates

### Polish
- Onboarding flow for new users
- Dark mode support
- Custom app icon
- Home screen widget (upcoming plans)
- Progress bar on plan cards

## Tech Stack

- **SwiftUI** — UI framework
- **SwiftData** — persistence layer
- **WidgetKit** — home screen widget
- **UserNotifications** — local push notifications
- **PhotosUI** — photo picker
- **CoreLocation** — location geocoding for weather
- **Open-Meteo API** — free weather forecasts
- **ConfettiSwiftUI** — confetti animation on plan completion
- **Charts** — stats dashboard visualizations

## Requirements

- iOS 17+
- Xcode 15+

## Installation

1. Clone the repo
```bash
   git clone https://github.com/yourusername/MapOut.git
```
2. Open `MapOut.xcodeproj` in Xcode
3. Set your development team in Signing & Capabilities
4. Build and run on your device or simulator

## Screenshots

*Coming soon*

## Author

Mate Javakhadze

## License

This project is for personal and portfolio use.
