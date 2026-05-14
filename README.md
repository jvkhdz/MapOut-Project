# MapOut 📍

A feature-rich iOS planning app built with SwiftUI and SwiftData. Plan your life, capture your moments, and relive your memories.

## Features

### Core
- Create plans with 6 categories: Personal, Work, Friends, Trip, Health, Other
- Category-specific fields (Trip: airline, hotel, packing list, budget | Work: priority, notes | Friends: attendees, location | Health: type, goal, frequency)
- Edit and delete plans
- Mark plans as complete with confetti animation
- Plans with photos are archived to Memories after 3 days — plans without photos are deleted
- Search and filter plans by category
- Date validation prevents illogical start/end dates

### Views
- **Plans** — grouped by category with live countdown to next upcoming plan
- **Calendar** — see all plans laid out by date with weather forecast
- **Stats** — completion rate, streaks, plans per category chart
- **Memories** — visual diary of all completed and archived plans with photos

### Smart Features
- 📸 **Moment Capture** — BeReal-style random daily notifications during active Trip and Friends plans, prompting you to take a photo that gets automatically logged
- 🌤 **Weather forecast** — live weather integration (Open-Meteo API) for plans with a location
- 🔔 Push notifications before plan start time
- ⏱ Live countdown timer on upcoming plans
- 📷 Photo log — add multiple photos to any plan as a journal
- 🖼 Cover image per plan
- 📤 Share plan as a beautiful image card
- 📋 Plan templates — use prebuilt templates or save your own

### Polish
- Onboarding flow for new users with first plan creation
- Dark mode support
- Custom app icon + launch screen
- Progress bar on plan cards showing time elapsed
- Confetti animation on plan completion

## Tech Stack

- **SwiftUI** — UI framework
- **SwiftData** — persistence layer
- **UserNotifications** — local push notifications + moment capture
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
   git clone https://github.com/jvkhdz/MapOut-Project.git
```
2. Open `MapOut.xcodeproj` in Xcode
3. Set your development team in **Signing & Capabilities**
4. Build and run on your device or simulator

## Screenshots

*Coming soon*

## Author

Mate Javakhadze

## License

This project is for personal and portfolio use.
