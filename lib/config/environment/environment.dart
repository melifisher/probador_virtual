import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    await dotenv.load(fileName: '.env');
  }

  static String apiUrl = kIsWeb
      ? dotenv.env['API_URL'] ?? 'No está configurado el API_URL'
      : 'http://192.168.0.14:3000'; //poner la api de tu computadora
}
