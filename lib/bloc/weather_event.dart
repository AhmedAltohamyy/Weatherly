import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

/// Base class for all weather bloc events
sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered to fetch weather data for a specific location
/// [position]: The geographic coordinates to fetch weather for
/// [update]: If true, forces a fresh API call; if false, cached data is used if available
class FetchWeather extends WeatherEvent {
  final Position position;
  final bool update;
  const FetchWeather({required this.position, this.update = false});

  @override
  List<Object> get props => [position, update];
}