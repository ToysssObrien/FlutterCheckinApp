import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'PreviewcameraPage.dart';
import 'Utility/user_model.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({
    Key? key,
    required this.cameras,
    required this.user,
  }) : super(key: key);

  final List<CameraDescription>? cameras;
  final User user;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  bool _isRearCameraSelected = true;
  bool _isLoading = false;
  late String token;

  @override
  void initState() {
    token = widget.user.showapi();
    super.initState();
    initCamera(widget.cameras![1]);
  }

  Future<Position?> fetchPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  Future<void> _takePictureAndNavigate(Position? position, context) async {
    if (!_cameraController.value.isInitialized) {
      return;
    }
    try {
      await _cameraController.setFlashMode(FlashMode.off);
      XFile picture = await _cameraController.takePicture();
      if (position != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewPage(
              user: widget.user,
              picture: picture,
              geo: '${position.latitude},${position.longitude}',
            ),
          ),
        );
      }
    } on CameraException catch (e) {
      debugPrint('Error occurred while taking picture: $e');
    }
  }

  Future<void> initCamera(CameraDescription cameraDescription) async {
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);
    try {
      await _cameraController.initialize();
      if (mounted) {
        setState(() {});
      }
    } on CameraException catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _cameraController.value.isInitialized
                ? CameraPreview(_cameraController)
                : Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.20,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  color: Colors.black,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 30,
                        icon: Icon(
                          _isRearCameraSelected
                            ? Icons.switch_camera
                            : Icons.switch_camera_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          setState(() {
                            _isRearCameraSelected = !_isRearCameraSelected;
                          });
                          await initCamera(
                            widget.cameras![_isRearCameraSelected ? 1 : 0]
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<Position?>(
                        future: fetchPosition(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return const Center(
                              child: Text('Error fetching position'),
                            );
                          } else {
                            return IconButton(
                              onPressed: () async {
                                if (snapshot.data != null && !_isLoading) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await _takePictureAndNavigate(
                                    snapshot.data,
                                    context,
                                  );
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                              iconSize: 50,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: _isLoading
                                ? const CircularProgressIndicator()
                                : const Icon(
                                    Icons.circle,
                                    color: Colors.white,
                                  ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
