import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:gallery_saver/gallery_saver.dart';
import 'package:universal_html/html.dart' as html;
import '../../services/video_processing_service.dart';
import 'video_player_widget.dart';

class VideoProcessingScreen extends StatefulWidget {
  final String garmentUrl;
  const VideoProcessingScreen({Key? key, required this.garmentUrl})
      : super(key: key);
  @override
  _VideoProcessingScreenState createState() => _VideoProcessingScreenState();
}

class _VideoProcessingScreenState extends State<VideoProcessingScreen> {
  File? _videoFile;
  File? _processedVideo;
  final VideoProcessingService _service = VideoProcessingService();

  Future<void> _pickVideo() async {
    final pickedFile =
        await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _videoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _processVideo() async {
    if (_videoFile == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Selecciona video')));
      return;
    }

    try {
      final processed = await _service.processVideo(
          videoFile: _videoFile!, garmentFilePath: widget.garmentUrl);

      setState(() {
        _processedVideo = processed;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _saveOrDownloadVideo() async {
    if (kIsWeb) {
      // Web platform - Download file
      final bytes = await _processedVideo!.readAsBytes();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement()
        ..href = url
        ..download = 'processed_video.mp4'
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile platform - Save to gallery
      await GallerySaver.saveVideo(_processedVideo!.path);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text(kIsWeb ? 'Video descargado' : 'Video guardado en galería')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Probador Virtual'),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instrucciones
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 30, color: Colors.blue),
                    SizedBox(height: 10),
                    Text(
                      'Prueba cómo te queda esta prenda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Selecciona un video tuyo para ver cómo te quedaría esta prenda',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón de selección de video
            ElevatedButton.icon(
              onPressed: _pickVideo,
              icon: const Icon(Icons.video_library),
              label: Text(
                  _videoFile == null ? 'Seleccionar Video' : 'Cambiar Video'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Botón de procesar
            ElevatedButton.icon(
              onPressed: _videoFile == null ? null : _processVideo,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Procesar Video'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Video procesado y botón de descarga
            if (_processedVideo != null) ...[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: VideoPlayerWidget(videoFile: _processedVideo!),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: _saveOrDownloadVideo,
                icon: Icon(kIsWeb ? Icons.download : Icons.save_alt),
                label: Text(kIsWeb ? 'Descargar Video' : 'Guardar en Galería'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],

            // Indicador de carga mientras se procesa
            if (_videoFile != null && _processedVideo == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
