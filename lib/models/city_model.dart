class CityModel {
  final String name;
  final String landmark;
  final String landmarkName;
  final String? freeIconSource;

  CityModel({
    required this.name,
    required this.landmark,
    required this.landmarkName,
    this.freeIconSource,
  });

  // Get the image asset path for this city
  String get imagePath => 'assets/images/${name.toLowerCase().replaceAll(' ', '_')}.png';
}

// Comprehensive city-to-landmark mapping
class CityLandmarks {
  static final Map<String, CityModel> cities = {
    'Amsterdam': CityModel(
      name: 'Amsterdam',
      landmark: 'Canal Houses',
      landmarkName: 'Amsterdam Canal Houses',
      freeIconSource: 'https://thenounproject.com/search/?q=amsterdam+canal&i=icon',
    ),
    'Athens': CityModel(
      name: 'Athens',
      landmark: 'Parthenon',
      landmarkName: 'Parthenon',
      freeIconSource: 'https://thenounproject.com/search/?q=parthenon&i=icon',
    ),
    'Auckland': CityModel(
      name: 'Auckland',
      landmark: 'Sky Tower',
      landmarkName: 'Auckland Sky Tower',
      freeIconSource: 'https://thenounproject.com/search/?q=auckland+sky+tower&i=icon',
    ),
    'Bangkok': CityModel(
      name: 'Bangkok',
      landmark: 'Grand Palace',
      landmarkName: 'Grand Palace',
      freeIconSource: 'https://thenounproject.com/search/?q=grand+palace+bangkok&i=icon',
    ),
    'Barcelona': CityModel(
      name: 'Barcelona',
      landmark: 'Sagrada Familia',
      landmarkName: 'Sagrada Familia',
      freeIconSource: 'https://thenounproject.com/search/?q=sagrada+familia&i=icon',
    ),
    'Beijing': CityModel(
      name: 'Beijing',
      landmark: 'Forbidden City',
      landmarkName: 'Forbidden City',
      freeIconSource: 'https://thenounproject.com/search/?q=forbidden+city&i=icon',
    ),
    'Berlin': CityModel(
      name: 'Berlin',
      landmark: 'Brandenburg Gate',
      landmarkName: 'Brandenburg Gate',
      freeIconSource: 'https://thenounproject.com/search/?q=brandenburg+gate&i=icon',
    ),
    'Bogotá': CityModel(
      name: 'Bogotá',
      landmark: 'Monserrate',
      landmarkName: 'Monserrate',
      freeIconSource: 'https://thenounproject.com/search/?q=monserrate&i=icon',
    ),
    'Buenos Aires': CityModel(
      name: 'Buenos Aires',
      landmark: 'Obelisco',
      landmarkName: 'Obelisco',
      freeIconSource: 'https://thenounproject.com/search/?q=obelisco&i=icon',
    ),
    'Cairo': CityModel(
      name: 'Cairo',
      landmark: 'Pyramids of Giza',
      landmarkName: 'Pyramids of Giza',
      freeIconSource: 'https://thenounproject.com/search/?q=pyramids&i=icon',
    ),
    'Cape Town': CityModel(
      name: 'Cape Town',
      landmark: 'Table Mountain',
      landmarkName: 'Table Mountain',
      freeIconSource: 'https://thenounproject.com/search/?q=table+mountain&i=icon',
    ),
    'Chicago': CityModel(
      name: 'Chicago',
      landmark: 'Willis Tower',
      landmarkName: 'Willis Tower (Sears Tower)',
      freeIconSource: 'https://thenounproject.com/search/?q=chicago+skyline&i=icon',
    ),
    'Copenhagen': CityModel(
      name: 'Copenhagen',
      landmark: 'Little Mermaid',
      landmarkName: 'The Little Mermaid',
      freeIconSource: 'https://thenounproject.com/search/?q=little+mermaid&i=icon',
    ),
    'Delhi': CityModel(
      name: 'Delhi',
      landmark: 'India Gate',
      landmarkName: 'India Gate',
      freeIconSource: 'https://thenounproject.com/search/?q=india+gate&i=icon',
    ),
    'Denpasar': CityModel(
      name: 'Denpasar',
      landmark: 'Bajra Sandhi',
      landmarkName: 'Bajra Sandhi Monument',
      freeIconSource: 'https://thenounproject.com/search/?q=bajra+sandhi&i=icon',
    ),
    'Dubai': CityModel(
      name: 'Dubai',
      landmark: 'Burj Khalifa',
      landmarkName: 'Burj Khalifa',
      freeIconSource: 'https://thenounproject.com/search/?q=burj+khalifa&i=icon',
    ),
    'Dublin': CityModel(
      name: 'Dublin',
      landmark: 'Spire',
      landmarkName: 'Spire of Dublin',
      freeIconSource: 'https://thenounproject.com/search/?q=spire+dublin&i=icon',
    ),
    'Edinburgh': CityModel(
      name: 'Edinburgh',
      landmark: 'Edinburgh Castle',
      landmarkName: 'Edinburgh Castle',
      freeIconSource: 'https://thenounproject.com/search/?q=edinburgh+castle&i=icon',
    ),
    'Florence': CityModel(
      name: 'Florence',
      landmark: 'Duomo',
      landmarkName: 'Cathedral of Santa Maria del Fiore',
      freeIconSource: 'https://thenounproject.com/search/?q=florence+duomo&i=icon',
    ),
    'Helsinki': CityModel(
      name: 'Helsinki',
      landmark: 'Senate Square',
      landmarkName: 'Senate Square',
      freeIconSource: 'https://thenounproject.com/search/?q=senate+square&i=icon',
    ),
    'Ho Chi Minh City': CityModel(
      name: 'Ho Chi Minh City',
      landmark: 'Bitexco Tower',
      landmarkName: 'Bitexco Financial Tower',
      freeIconSource: 'https://thenounproject.com/search/?q=bitexco+tower&i=icon',
    ),
    'Hong Kong': CityModel(
      name: 'Hong Kong',
      landmark: 'Victoria Harbour',
      landmarkName: 'Victoria Harbour Skyline',
      freeIconSource: 'https://thenounproject.com/search/?q=hong+kong+skyline&i=icon',
    ),
    'Istanbul': CityModel(
      name: 'Istanbul',
      landmark: 'Hagia Sophia',
      landmarkName: 'Hagia Sophia',
      freeIconSource: 'https://thenounproject.com/search/?q=hagia+sophia&i=icon',
    ),
    'Jakarta': CityModel(
      name: 'Jakarta',
      landmark: 'Monas',
      landmarkName: 'National Monument (Monas)',
      freeIconSource: 'https://thenounproject.com/search/?q=monas&i=icon',
    ),
    'Kuala Lumpur': CityModel(
      name: 'Kuala Lumpur',
      landmark: 'Petronas Towers',
      landmarkName: 'Petronas Twin Towers',
      freeIconSource: 'https://thenounproject.com/search/?q=petronas+towers&i=icon',
    ),
    'Lima': CityModel(
      name: 'Lima',
      landmark: 'Huaca Pucllana',
      landmarkName: 'Huaca Pucllana',
      freeIconSource: 'https://thenounproject.com/search/?q=huaca+pucllana&i=icon',
    ),
    'Lisbon': CityModel(
      name: 'Lisbon',
      landmark: 'Belém Tower',
      landmarkName: 'Belém Tower',
      freeIconSource: 'https://thenounproject.com/search/?q=belem+tower&i=icon',
    ),
    'London': CityModel(
      name: 'London',
      landmark: 'Big Ben',
      landmarkName: 'Big Ben / Elizabeth Tower',
      freeIconSource: 'https://thenounproject.com/search/?q=big+ben&i=icon',
    ),
    'Los Angeles': CityModel(
      name: 'Los Angeles',
      landmark: 'Hollywood Sign',
      landmarkName: 'Hollywood Sign',
      freeIconSource: 'https://thenounproject.com/search/?q=hollywood+sign&i=icon',
    ),
    'Madrid': CityModel(
      name: 'Madrid',
      landmark: 'Prado Museum',
      landmarkName: 'Prado Museum',
      freeIconSource: 'https://thenounproject.com/search/?q=prado+museum&i=icon',
    ),
    'Manila': CityModel(
      name: 'Manila',
      landmark: 'Rizal Park',
      landmarkName: 'Rizal Park',
      freeIconSource: 'https://thenounproject.com/search/?q=rizal+park&i=icon',
    ),
    'Melbourne': CityModel(
      name: 'Melbourne',
      landmark: 'Flinders Street',
      landmarkName: 'Flinders Street Station',
      freeIconSource: 'https://thenounproject.com/search/?q=flinders+street&i=icon',
    ),
    'Mexico City': CityModel(
      name: 'Mexico City',
      landmark: 'Angel of Independence',
      landmarkName: 'Angel of Independence',
      freeIconSource: 'https://thenounproject.com/search/?q=angel+independence&i=icon',
    ),
    'Milan': CityModel(
      name: 'Milan',
      landmark: 'Duomo di Milano',
      landmarkName: 'Milan Cathedral',
      freeIconSource: 'https://thenounproject.com/search/?q=duomo+milano&i=icon',
    ),
    'Moscow': CityModel(
      name: 'Moscow',
      landmark: 'St. Basil\'s Cathedral',
      landmarkName: 'St. Basil\'s Cathedral',
      freeIconSource: 'https://thenounproject.com/search/?q=st+basil&i=icon',
    ),
    'Mumbai': CityModel(
      name: 'Mumbai',
      landmark: 'Gateway of India',
      landmarkName: 'Gateway of India',
      freeIconSource: 'https://thenounproject.com/search/?q=gateway+india&i=icon',
    ),
    'New York': CityModel(
      name: 'New York',
      landmark: 'Statue of Liberty',
      landmarkName: 'Statue of Liberty',
      freeIconSource: 'https://thenounproject.com/search/?q=statue+of+liberty&i=icon',
    ),
    'Oslo': CityModel(
      name: 'Oslo',
      landmark: 'Opera House',
      landmarkName: 'Oslo Opera House',
      freeIconSource: 'https://thenounproject.com/search/?q=oslo+opera&i=icon',
    ),
    'Paris': CityModel(
      name: 'Paris',
      landmark: 'Eiffel Tower',
      landmarkName: 'Eiffel Tower',
      freeIconSource: 'https://thenounproject.com/search/?q=eiffel+tower&i=icon',
    ),
    'Prague': CityModel(
      name: 'Prague',
      landmark: 'Charles Bridge',
      landmarkName: 'Charles Bridge',
      freeIconSource: 'https://thenounproject.com/search/?q=charles+bridge&i=icon',
    ),
    'Reykjavik': CityModel(
      name: 'Reykjavik',
      landmark: 'Hallgrímskirkja',
      landmarkName: 'Hallgrímskirkja',
      freeIconSource: 'https://thenounproject.com/search/?q=hallgrimskirkja&i=icon',
    ),
    'Rio de Janeiro': CityModel(
      name: 'Rio de Janeiro',
      landmark: 'Christ the Redeemer',
      landmarkName: 'Christ the Redeemer',
      freeIconSource: 'https://thenounproject.com/search/?q=christ+redeemer&i=icon',
    ),
    'Rome': CityModel(
      name: 'Rome',
      landmark: 'Colosseum',
      landmarkName: 'Colosseum',
      freeIconSource: 'https://thenounproject.com/search/?q=colosseum&i=icon',
    ),
    'San Francisco': CityModel(
      name: 'San Francisco',
      landmark: 'Golden Gate Bridge',
      landmarkName: 'Golden Gate Bridge',
      freeIconSource: 'https://thenounproject.com/search/?q=golden+gate+bridge&i=icon',
    ),
    'Santiago': CityModel(
      name: 'Santiago',
      landmark: 'San Cristóbal Hill',
      landmarkName: 'San Cristóbal Hill',
      freeIconSource: 'https://thenounproject.com/search/?q=san+cristobal&i=icon',
    ),
    'Seoul': CityModel(
      name: 'Seoul',
      landmark: 'N Seoul Tower',
      landmarkName: 'N Seoul Tower',
      freeIconSource: 'https://thenounproject.com/search/?q=n+seoul+tower&i=icon',
    ),
    'Shanghai': CityModel(
      name: 'Shanghai',
      landmark: 'Oriental Pearl Tower',
      landmarkName: 'Oriental Pearl Tower',
      freeIconSource: 'https://thenounproject.com/search/?q=oriental+pearl+tower&i=icon',
    ),
    'Singapore': CityModel(
      name: 'Singapore',
      landmark: 'Marina Bay Sands',
      landmarkName: 'Marina Bay Sands',
      freeIconSource: 'https://thenounproject.com/search/?q=marina+bay+sands&i=icon',
    ),
    'Stockholm': CityModel(
      name: 'Stockholm',
      landmark: 'Gamla Stan',
      landmarkName: 'Gamla Stan (Old Town)',
      freeIconSource: 'https://thenounproject.com/search/?q=gamla+stan&i=icon',
    ),
    'Sydney': CityModel(
      name: 'Sydney',
      landmark: 'Sydney Opera House',
      landmarkName: 'Sydney Opera House',
      freeIconSource: 'https://thenounproject.com/search/?q=sydney+opera+house&i=icon',
    ),
    'Tokyo': CityModel(
      name: 'Tokyo',
      landmark: 'Tokyo Tower',
      landmarkName: 'Tokyo Tower',
      freeIconSource: 'https://thenounproject.com/search/?q=tokyo+tower&i=icon',
    ),
    'Toronto': CityModel(
      name: 'Toronto',
      landmark: 'CN Tower',
      landmarkName: 'CN Tower',
      freeIconSource: 'https://thenounproject.com/search/?q=cn+tower&i=icon',
    ),
    'Vancouver': CityModel(
      name: 'Vancouver',
      landmark: 'Canada Place',
      landmarkName: 'Canada Place',
      freeIconSource: 'https://thenounproject.com/search/?q=canada+place&i=icon',
    ),
    'Venice': CityModel(
      name: 'Venice',
      landmark: 'St. Mark\'s Basilica',
      landmarkName: 'St. Mark\'s Basilica',
      freeIconSource: 'https://thenounproject.com/search/?q=st+mark+basilica&i=icon',
    ),
    'Vienna': CityModel(
      name: 'Vienna',
      landmark: 'St. Stephen\'s Cathedral',
      landmarkName: 'St. Stephen\'s Cathedral',
      freeIconSource: 'https://thenounproject.com/search/?q=st+stephen+cathedral&i=icon',
    ),
    'Warsaw': CityModel(
      name: 'Warsaw',
      landmark: 'Palace of Culture',
      landmarkName: 'Palace of Culture and Science',
      freeIconSource: 'https://thenounproject.com/search/?q=palace+culture&i=icon',
    ),
    'Budapest': CityModel(
      name: 'Budapest',
      landmark: 'Parliament Building',
      landmarkName: 'Hungarian Parliament Building',
      freeIconSource: 'https://thenounproject.com/search/?q=budapest+parliament&i=icon',
    ),
    'Zurich': CityModel(
      name: 'Zurich',
      landmark: 'Grossmünster',
      landmarkName: 'Grossmünster',
      freeIconSource: 'https://thenounproject.com/search/?q=grossmunster&i=icon',
    ),
  };

  static CityModel? getCityModel(String cityName) {
    // Try exact match first
    if (cities.containsKey(cityName)) {
      return cities[cityName];
    }
    
    // Try case-insensitive match
    for (var entry in cities.entries) {
      if (entry.key.toLowerCase() == cityName.toLowerCase()) {
        return entry.value;
      }
    }
    
    // Try partial match
    for (var entry in cities.entries) {
      if (entry.key.toLowerCase().contains(cityName.toLowerCase()) ||
          cityName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    return null;
  }
}
