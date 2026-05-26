// مسار الملف: lib/utils/weather_helper.dart

String getWeatherImagePath(int code) {
  if (code == 0) return 'assets/images/6.png'; // Clear sky
  if ([1, 2, 3].contains(code)) return 'assets/images/7.png'; // Mainly clear, partly cloudy, overcast
  if ([45, 48].contains(code)) return 'assets/images/5.png'; // Fog
  if ([51, 53, 55, 56, 57].contains(code)) return 'assets/images/4.png'; // Drizzle / Freezing Drizzle
  if ([61, 63, 65, 66, 67].contains(code)) return 'assets/images/2.png'; // Rain / Freezing Rain
  // if ([71, 73, 75, 77, 85, 86].contains(code)) return 'assets/images/snow.png'; // Snow fall / Snow showers
  if ([80, 81, 82].contains(code)) return 'assets/images/3.png'; // Rain showers
  if ([95, 96, 99].contains(code)) return 'assets/images/1.png'; // Thunderstorm
  
  return 'assets/images/6.png'; 
}