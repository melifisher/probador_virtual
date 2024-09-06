/* import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';

class VirtualFittingRoom extends StatefulWidget {
  const VirtualFittingRoom({super.key});

  @override
  _VirtualFittingRoomState createState() => _VirtualFittingRoomState();
}

class _VirtualFittingRoomState extends State<VirtualFittingRoom> {
  ArCoreController? arCoreController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Probador Virtual')),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    // Aquí añadirías la lógica para cargar y mostrar el modelo 3D
  }

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }
}
 */