// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weatherly/bloc/weather_state.dart';
import 'package:weatherly/utils/weather_helper.dart';

Widget hourlyForecast(WeatherSuccess state) {
    final hourlyData = state.weatherData['hourly'];
    if (hourlyData == null) return const SizedBox.shrink();

    final List<dynamic> times = hourlyData['time'] ?? [];
    final List<dynamic> temps = hourlyData['temperature_2m'] ?? [];
    final List<dynamic> codes = hourlyData['weather_code'] ?? [];

    // سنعرض أول 24 ساعة فقط (أو يمكنك تعديلها لعرض الساعات القادمة فقط)
    final int itemCount = times.length > 24 ? 24 : times.length;

    return SizedBox(
      height: 120, // تحديد طول الشريط
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // جعل التصفح أفقياً
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // تحويل صيغة الوقت القادمة من الـ API (مثل 2026-05-29T14:00) إلى صيغة مقروءة (مثل 2 PM)
          final String timeStr = times[index].toString();
          final DateTime dateTime = DateTime.parse(timeStr);
          final String hourFormatted = DateFormat('ha').format(dateTime); // تحتاج لتأكيد وجود حزمة intl المجلوبة في ملفك فعلياً

          final dynamic temp = temps[index];
          final int code = codes.isNotEmpty ? (codes[index] as num).toInt() : 0;

          return Container(
            width: 75,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08), // خلفية شبه شفافة تناسب التصميم الداكن
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  hourFormatted,
                  style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Image.asset(
                  getWeatherImagePath(code), // استخدام دالة المساعدة المضافة لديك مسبقاً لجلب الأيقونة المناسبة
                  width: 32,
                  height: 32,
                ),
                Text(
                  "${temp.toString()}°C",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          );
        },
      ),
    );
  }