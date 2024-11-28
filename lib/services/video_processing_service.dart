import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VideoProcessingService {
  final http.Client client = http.Client();

  Future<File> processVideo(
      {required File videoFile, required String garmentFilePath}) async {
    // URL del servicio de Flask
    final url = Uri.parse('http://localhost:5000/process_video');

    // Crear solicitud multipart
    var request = http.MultipartRequest('POST', url);
    request.files
        .add(await http.MultipartFile.fromPath('video', videoFile.path));
    request.files
        .add(await http.MultipartFile.fromPath('garment', garmentFilePath));

    // Enviar solicitud
    final response = await request.send();

    if (response.statusCode == 200) {
      // Guardar archivo de respuesta
      final responseBytes = await response.stream.toBytes();
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/processed_video.mp4');
      await tempFile.writeAsBytes(responseBytes);

      return tempFile;
    } else {
      throw Exception('Error procesando el video');
    }
  }
}
