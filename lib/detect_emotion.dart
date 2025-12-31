import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'recommend_music_page.dart';

class DetectResultPage extends StatefulWidget {
  final File imageFile;
  final String detectedEmotion;
  final Future<File?> Function() onRetake;

  const DetectResultPage({
    super.key,
    required this.imageFile,
    required this.detectedEmotion,
    required this.onRetake,
  });

  @override
  State<DetectResultPage> createState() => _DetectResultPageState();
}

class _DetectResultPageState extends State<DetectResultPage> {
  File? _currentImage;
  late String _currentEmotion;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _currentImage = widget.imageFile;
    _currentEmotion = widget.detectedEmotion;
  }

  Future<void> _handleRetake() async {
    setState(() {
      _loading = true;
    });

    File? newImage = await widget.onRetake();
    if (!mounted) return;

    setState(() {
      if (newImage != null) _currentImage = newImage;
      _loading = false;
    });
  }

  void _handleExit() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    double boxWidth = 300;
    double photoSize = boxWidth;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _handleExit,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87),
            onPressed: _handleExit,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Cloud.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.lightBlue.withOpacity(0.08)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: boxWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      Text(
                        "Detection Result",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playpenSans(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _loading
                          ? SizedBox(
                              width: photoSize,
                              height: photoSize,
                              child: const Center(child: CircularProgressIndicator()),
                            )
                          : _currentImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _currentImage!,
                                    width: photoSize,
                                    height: photoSize,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : SizedBox(width: photoSize, height: photoSize),
                      const SizedBox(height: 16),
                      
                      Text(
                        _loading
                            ? "Detecting..."
                            : "Detected Emotion: $_currentEmotion",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playpenSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _handleRetake,
                                icon: const Icon(Icons.camera_alt),
                                label: Center(
                                  child: Text(
                                    "Retake",
                                    style: GoogleFonts.playpenSans(fontSize: 16),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          RecommendMusicPage(emotion: _currentEmotion),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.music_note),
                                label: Center(
                                  child: Text(
                                    "Recommend Music",
                                    style: GoogleFonts.playpenSans(fontSize: 16),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
