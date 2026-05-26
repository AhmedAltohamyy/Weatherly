import 'package:equatable/equatable.dart';

sealed class WeatherState extends Equatable {
  const WeatherState();
  
  @override
  List<Object> get props => [];
}

final class WeatherInitial extends WeatherState {}

final class WeatherLoading extends WeatherState {}

final class WeatherError extends WeatherState {
  final String message; // تصحيح الإملاء
  const WeatherError(this.message);

  @override
  List<Object> get props => [message];
}

final class WeatherSuccess extends WeatherState {
  final Map weatherData;
  final String cityName;
  
  const WeatherSuccess(this.weatherData, this.cityName);

  @override
  List<Object> get props => [weatherData, cityName];
}