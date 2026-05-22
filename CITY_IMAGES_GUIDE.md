# City Landmark Images Guide

This guide explains how to add hallmark/landmark images for cities in the Weatherboo app.

## Overview

The app now includes a comprehensive mapping of 50+ popular cities to their iconic landmarks. The landmark information is displayed in the weather card when viewing weather for supported cities.

## Supported Cities

The following cities have landmark information configured:

- **New York** - Statue of Liberty
- **London** - Big Ben / Elizabeth Tower
- **Paris** - Eiffel Tower
- **Tokyo** - Tokyo Tower
- **Sydney** - Sydney Opera House
- **Dubai** - Burj Khalifa
- **Rome** - Colosseum
- **Barcelona** - Sagrada Familia
- **Amsterdam** - Amsterdam Canal Houses
- **San Francisco** - Golden Gate Bridge
- **Los Angeles** - Hollywood Sign
- **Chicago** - Willis Tower (Sears Tower)
- **Moscow** - St. Basil's Cathedral
- **Beijing** - Forbidden City
- **Shanghai** - Oriental Pearl Tower
- **Hong Kong** - Victoria Harbour Skyline
- **Singapore** - Marina Bay Sands
- **Bangkok** - Grand Palace
- **Istanbul** - Hagia Sophia
- **Cairo** - Pyramids of Giza
- **Rio de Janeiro** - Christ the Redeemer
- **Berlin** - Brandenburg Gate
- **Athens** - Parthenon
- **Vienna** - St. Stephen's Cathedral
- **Prague** - Charles Bridge
- **Venice** - St. Mark's Basilica
- **Florence** - Cathedral of Santa Maria del Fiore
- **Edinburgh** - Edinburgh Castle
- **Toronto** - CN Tower
- **Vancouver** - Canada Place
- **Mexico City** - Angel of Independence
- **Buenos Aires** - Obelisco
- **Santiago** - San Cristóbal Hill
- **Lima** - Huaca Pucllana
- **Bogotá** - Monserrate
- **Cape Town** - Table Mountain
- **Mumbai** - Gateway of India
- **Delhi** - India Gate
- **Seoul** - N Seoul Tower
- **Jakarta** - National Monument (Monas)
- **Manila** - Rizal Park
- **Ho Chi Minh City** - Bitexco Financial Tower
- **Kuala Lumpur** - Petronas Twin Towers
- **Warsaw** - Palace of Culture and Science
- **Budapest** - Hungarian Parliament Building
- **Lisbon** - Belém Tower
- **Madrid** - Prado Museum
- **Milan** - Milan Cathedral
- **Zurich** - Grossmünster
- **Stockholm** - Gamla Stan (Old Town)
- **Oslo** - Oslo Opera House
- **Helsinki** - Senate Square
- **Copenhagen** - The Little Mermaid
- **Dublin** - Spire of Dublin
- **Reykjavik** - Hallgrímskirkja
- **Auckland** - Auckland Sky Tower
- **Melbourne** - Flinders Street Station

## Adding Images

### Option 1: Use Free Icon Sources

Each city in `lib/models/city_model.dart` includes a `freeIconSource` URL that points to free icon resources from The Noun Project. You can:

1. Visit the URL provided in the city model
2. Download a free icon for the landmark
3. Save it to `assets/images/` with the format: `city_name.png` (e.g., `new_york.png`)

### Option 2: Use Your Own Images

You can use any landmark images you prefer:

1. Find or create landmark images for each city
2. Save them to `assets/images/` with the format: `city_name.png` (e.g., `london.png`)
3. Recommended size: 64x64 to 128x128 pixels
4. Recommended format: PNG with transparency support

### File Naming Convention

Images should be named using the lowercase version of the city name with spaces replaced by underscores:

- New York → `new_york.png`
- San Francisco → `san_francisco.png`
- Ho Chi Minh City → `ho_chi_minh_city.png`

## Current Implementation

Currently, the app displays:
- City name
- Landmark name (if available in the database)
- A landmark icon emoji (🏛️)

Once you add actual image files to `assets/images/`, you can update the `_buildCityLandmark()` method in `lib/widgets/weather_card.dart` to display the actual image instead of just the text.

## Example: Updating to Display Images

To display actual landmark images instead of text, modify the `_buildCityLandmark()` method in `weather_card.dart`:

```dart
Widget _buildCityLandmark() {
  final cityModel = CityLandmarks.getCityModel(weather.cityName);
  
  if (cityModel != null) {
    return Image.asset(
      cityModel.imagePath,
      width: 32,
      height: 32,
      errorBuilder: (context, error, stackTrace) {
        return Row(
          children: [
            Text('🏛️', style: TextStyle(fontSize: 16)),
            SizedBox(width: 4),
            Text(
              cityModel.landmarkName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontFamily: AppFonts.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }
  
  return const SizedBox.shrink();
}
```

## Adding New Cities

To add a new city to the landmark database:

1. Open `lib/models/city_model.dart`
2. Add a new entry to the `cities` map in the `CityLandmarks` class:

```dart
'Your City': CityModel(
  name: 'Your City',
  landmark: 'Landmark Name',
  landmarkName: 'Full Landmark Name',
  freeIconSource: 'https://thenounproject.com/search/?q=landmark+name&i=icon',
),
```

## Resources

- **The Noun Project**: https://thenounproject.com - Free icons for landmarks
- **Flaticon**: https://www.flaticon.com - Free vector icons
- **Vecteezy**: https://www.vecteezy.com - Free vector art

## Notes

- All images should be royalty-free or properly licensed
- Consider using consistent styling across all landmark images
- Test the app after adding images to ensure they display correctly
- The app gracefully handles missing images by falling back to text display
