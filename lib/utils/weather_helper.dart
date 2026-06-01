/// Maps WMO weather codes to appropriate asset image paths based on day/night conditions
/// WMO Weather Interpretation Codes: https://www.open-meteo.com/en/docs
/// 
/// [code]: WMO weather code (0-99)
/// [isDay]: 1 for daytime, 0 for nighttime
/// Returns the path to the corresponding weather icon asset
String getWeatherImagePath(int code, int isDay) {
  // Code 0: Clear sky
  if (code == 0) return isDay == 1 ? 'assets/images/6.png' : 'assets/images/moon.png';
  
  // Codes 1-3: Mainly clear, partly cloudy, overcast
  if ([1, 2, 3].contains(code)) return isDay == 1 ? 'assets/images/7.png' : 'assets/images/cloudy_night.png';
  
  // Codes 45, 48: Foggy
  if ([45, 48].contains(code)) return 'assets/images/5.png';
  
  // Codes 51-57: Drizzle
  if ([51, 53, 55, 56, 57].contains(code)) return 'assets/images/4.png';
  
  // Codes 61-67: Rain
  if ([61, 63, 65, 66, 67].contains(code)) return 'assets/images/2.png';
  
  // Codes 80-82: Rain showers
  if ([80, 81, 82].contains(code)) return 'assets/images/3.png';
  
  // Codes 95-99: Thunderstorm
  if ([95, 96, 99].contains(code)) return 'assets/images/1.png';

  // Default to sunny icon if code is not recognized
  return 'assets/images/6.png';
}