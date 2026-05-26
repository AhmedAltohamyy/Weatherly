import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';

sealed class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class FetchWeather extends WeatherEvent {
  final Position position;
  final bool update;
  const FetchWeather({required this.position, this.update = false});

  @override
  List<Object> get props => [position, update];
}