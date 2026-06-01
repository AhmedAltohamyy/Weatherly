import 'package:equatable/equatable.dart';

/// Base class for all weather bloc states
sealed class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object> get props => [];
}

/// Initial state before any weather data is fetched
final class WeatherInitial extends WeatherState {}

/// State emitted while weather data is being fetched from the API
final class WeatherLoading extends WeatherState {}

/// State emitted when an error occurs during fetching
final class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message);

  @override
  List<Object> get props => [message];
}

/// State emitted when weather data is successfully fetched
/// [weatherData]: Raw API response containing current, hourly, and daily weather data
/// [cityName]: City or region name obtained from reverse geocoding
final class WeatherSuccess extends WeatherState {
  final Map weatherData;
  final String cityName;
  
  const WeatherSuccess(this.weatherData, this.cityName);

  @override
  List<Object> get props => [weatherData, cityName];
}