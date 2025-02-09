// ignore_for_file: camel_case_types

import 'dart:convert';
import 'api.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> weatherFuture = Future.value({}); 
  @override
  void initState() {
    super.initState();
    getWeather();

    weatherFuture = getWeather();
  }
  
  String city = "Mumbai";
  String apiKey = api;
  Future<Map<String, dynamic>> getWeather() async {
    try{
      final res = await http.get(
      Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=$city,in&APPID=$api"
        ),
      );
         if(res.statusCode == '200'){
          final data = jsonDecode(res.body);
          print(data);
            setState(() {
            weatherFuture = Future.value(data);
        });
        print(weatherFuture);
        return data;
        } else{
          throw 'Connection Error';
        }
        
    }
    catch(e){
      throw e.toString();
    }
    
  }
  @override
  /// A screen that displays a simple weather app.
  ///
  /// Includes a heading with the app name and a refresh button, a main card
  /// that displays the current temperature and weather condition, a row of cards
  /// that display the forecast for the next few hours, and a row of cards that
  /// display additional information such as humidity.
  ///
  /// All of the cards are horizontally scrollable.
  ///
  /// This is the main screen of the app.
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Weather App', style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            getWeather();
          }, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder(
          future: weatherFuture,
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if(snapshot.hasError){
              return AlertDialog(
                content: Text("Snapshot error Occured"),
              );
            }

            
            final data = snapshot.data!;
            final currentWeatherData = data["list"][0];

            final temperature = currentWeatherData[0]["main"]["temp"];
            final currentSky = currentWeatherData["weather"][0]["main"];

            final pressure = currentWeatherData["main"]["pressure"];
            final humidity = currentWeatherData["main"]["humidity"];
            final windSpeed = currentWeatherData["wind"]["speed"];
            
            return Column(
            children: [
              //main card
              weatherCard(currentSky, currentSky == "Clouds" || currentSky == "Rain"? Icons.cloud : Icons.sunny, temperature),
              const SizedBox(height: 20,),  
              Container(
                alignment: Alignment.centerLeft,
                child: const Text("Weather Forecast", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  TimeCard(time: "09:00",temperature: 300,weather: Icons.water,),
                  TimeCard(time: "10:00",temperature: 320,weather: Icons.sunny,),
                  TimeCard(time: "11:00",temperature: 310,weather: Icons.snowing,),
                  TimeCard(time: "12:00",temperature: 330,weather: Icons.air,),
                  TimeCard(time: "1:00",temperature: 310,weather: Icons.flutter_dash,),
                  TimeCard(time: "2:00",temperature: 320,weather: Icons.man,),
          
                ],),
              ),
              const SizedBox(height: 20,), const SizedBox(height: 20,),
              Container(
                alignment: Alignment.centerLeft,
                child: const Text("Additional Information", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),)),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                child: Row(children: [
                  additionalCard(name: "Humidity", value: humidity, info: Icons.water),
                  additionalCard(name: "Wind Speed", value: windSpeed, info: Icons.air),
                  additionalCard(name: "Pressure", value: pressure, info: Icons.umbrella),
                  
                ],),
              ),// additional information
              const SizedBox(height: 20,),
          
              
            ],
          );
          },
        ),
      ),
    );
  }

  Card weatherCard(String a, IconData icon, double temp) {
    return Card(
            child: SizedBox(
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text("${temp}K", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),),
                        Icon(icon, size: 64),
                        Text(a, style: TextStyle(fontSize: 16),),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

class TimeCard extends StatelessWidget {
  final IconData weather;
  final double temperature;
  final String time;

  @override
   const TimeCard({
    super.key,
    required this.temperature,
    required this.weather,
    required this.time,
    
  });


  @override
  Widget build(BuildContext context) {
    return Row(
      children: [ 
        SizedBox(
          width: 100,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(time, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  Icon(weather, size: 32),
                  Text("${temperature}K", style: TextStyle(fontSize: 16),),
                ],
              ),
          )),
        ),
      ],
    );
  }
}
class additionalCard extends StatelessWidget {
  final IconData info;
  final double value;
  final String name; 
  const additionalCard({
    super.key,
    required this.info,
    required this.value,
    required this.name,
});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [ 
        Container(
          alignment: Alignment.center,
          width: 105,
          child: Card(
            elevation: 0,
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(0.0),
              child: Column(
                children: [
                  Icon(info, size: 32),

                  Text(name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                  Text("$value", style: TextStyle(fontSize: 16),),
                ],
              ),
          )),
        ),
      ],
    );
  }
}