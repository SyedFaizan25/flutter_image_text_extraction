import 'dart:io';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  const ImageToTextApp()
    );
  }
}




class ImageToTextApp extends StatefulWidget {
  const ImageToTextApp({super.key});

  @override
  _ImageToTextAppState createState() => _ImageToTextAppState();
}

class _ImageToTextAppState extends State<ImageToTextApp> {
  File? _image;
  final picker = ImagePicker();
  RecognizedText? _recognizedText; // Define _recognizedText here

  Future getImageFromGallery() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future getImageFromCamera() async {
    final pickedFile =
    await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(_recognizedText?.blocks ?? []);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to Text'),
      ),
      body: Center(
        child: _image == null
            ? const Text('No image selected.')
        //     : Column(
        //   children: [
        //     Image.file(
        //       _image!,
        //       height: MediaQuery.of(context).size.height * 0.6,
        //     ),
        //     ElevatedButton(
        //       onPressed: () async {
        //        await readTextFromImage(context);
        //       },
        //       child: const Text("Get Text"),
        //     )
        //   ],
        // ),
        :Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: CustomPaint(
                painter: TextOverlayPainter(_recognizedText?.blocks ?? []),
                child: Image.file(
                  _image!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await readTextFromImage(context);
              },
              child: const Text("Get Text"),
            )
          ],
        ),

      ),

      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: getImageFromGallery,
            tooltip: 'Select Image',
            child: const Icon(Icons.image),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: getImageFromCamera,
            tooltip: 'Take a Picture',
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }

  // Future<void> readTextFromImage() async {
  //   final inputImage = InputImage.fromFile(_image!);
  //   final textRecognizer =
  //   TextRecognizer(script: TextRecognitionScript.latin);
  //   final RecognizedText recognizedText =
  //   await textRecognizer.processImage(inputImage);
  //
  //   // Print each block and its lines
  //   for (int i = 0; i < recognizedText.blocks.length; i++) {
  //     final block = recognizedText.blocks[i];
  //     debugPrint("Block ${i + 1} Text: ${block.text}");
  //     debugPrint("Block ${i + 1} boundingBox: ${block.boundingBox}");
  //     for(int i=0;i<block.cornerPoints.length;i++) {
  //       debugPrint("Block ${i + 1} cornerPoints x: ${block.cornerPoints[i].x}");
  //       debugPrint("Block ${i + 1} cornerPoints y: ${block.cornerPoints[i].y}");
  //       debugPrint("Block ${i + 1} cornerPoints magnitude: ${block.cornerPoints[i]..magnitude}");
  //     }
  //     for(int i=0;i<block.recognizedLanguages.length;i++) {
  //       debugPrint("Block ${i + 1} recognizedLanguages x: ${block.recognizedLanguages[i]}");
  //     }
  //     for (int j = 0; j < block.lines.length; j++) {
  //       final line = block.lines[j];
  //       debugPrint("  Line ${j + 1} Text: ${line.text}");
  //       for (int j = 0; j < line.elements.length; j++) {
  //         debugPrint("  Line ${j + 1} angle: ${line.elements[j].angle}");
  //         debugPrint("  Line ${j + 1} confidence: ${line.elements[j].confidence}");
  //         debugPrint("  Line ${j + 1} text: ${line.elements[j].text}");
  //       }
  //
  //     }
  //   }
  //
  //   String text = recognizedText.text;
  //   debugPrint("Text Box Length is ${recognizedText.blocks.length}");
  //
  //
  //   textRecognizer.close();
  //
  //   // Process the extracted text as required (e.g., display in a dialog).
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Extracted Text'),
  //         content: Text(text),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> readTextFromImage(BuildContext context) async {
    final inputImage = InputImage.fromFile(_image!);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _recognizedText = recognizedText;
    });

    // Extracted text from recognized blocks
    String text = recognizedText.text;

    // Show dialog with extracted text
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Extracted Text'),
          content: SelectableText(
            text,
            onTap: () {
              // Copy tapped text to clipboard
              Clipboard.setData(ClipboardData(text: text));
              // Show snackbar to indicate that text has been copied
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied to clipboard: $text'),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog when "Close" button is pressed
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    // Close the text recognizer
    textRecognizer.close();
  }

// Future<void> readTextFromImage(BuildContext context) async {
  //   final inputImage = InputImage.fromFile(_image!);
  //   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  //   final RecognizedText recognizedText =
  //   await textRecognizer.processImage(inputImage);
  //   setState(() async {
  //     _recognizedText=  await textRecognizer.processImage(inputImage);
  //   });
  //
  //   // Extracted text from recognized blocks
  //   String text = recognizedText.text;
  //
  //   // Show dialog with extracted text
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Extracted Text'),
  //         content: SelectableText(
  //           text,
  //           onTap: () {
  //             // Copy tapped text to clipboard
  //             Clipboard.setData(ClipboardData(text: text));
  //             // Show snackbar to indicate that text has been copied
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(
  //                 content: Text('Copied to clipboard: $text'),
  //               ),
  //             );
  //           },
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               // Close the dialog when "Close" button is pressed
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //
  //   // Close the text recognizer
  //   textRecognizer.close();
  // }
}
  // Future<void> readTextFromImage() async {
  //   final inputImage = InputImage.fromFile(_image!);
  //   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  //   final RecognizedText recognizedText =
  //   await textRecognizer.processImage(inputImage);
  //
  //   // Extracted text from recognized blocks
  //   String text = recognizedText.text;
  //
  //   // Display dialog with extracted text
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Extracted Text'),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(text),
  //               SizedBox(height: 20),
  //               TextButton(
  //                 onPressed: () {
  //                   // Close dialog when "Close" button is pressed
  //                   Navigator.pop(context);
  //                 },
  //                 child: const Text('Close'),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  //
  //   // Select and copy specific text
  //   // For demonstration, let's say we want to copy the text of the first block
  //   String selectedText = recognizedText.blocks.first.text;
  //
  //   // Copy selected text to clipboard
  //   await Clipboard.setData(ClipboardData(text: selectedText));
  //
  //   // Show confirmation message
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text('Text copied to clipboard: $selectedText'),
  //     ),
  //   );
  //
  //   // Close the text recognizer
  //   textRecognizer.close();
  // }

  // Future<void> readTextFromImage() async {
  //   final inputImage = InputImage.fromFile(_image!);
  //   final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  //   final RecognizedText recognizedText =
  //   await textRecognizer.processImage(inputImage);
  //
  //   // Print each block and its lines
  //   for (int i = 0; i < recognizedText.blocks.length; i++) {
  //     final block = recognizedText.blocks[i];
  //     debugPrint("Block ${i + 1} Text: ${block.text}");
  //     debugPrint("Block ${i + 1} boundingBox: ${block.boundingBox}");
  //
  //     // Iterate through corner points
  //     for (int i = 0; i < block.cornerPoints.length; i++) {
  //       final cornerPoint = block.cornerPoints[i];
  //       debugPrint("Block ${i + 1} cornerPoints x: ${cornerPoint.x}");
  //       debugPrint("Block ${i + 1} cornerPoints y: ${cornerPoint.y}");
  //       debugPrint("Block ${i + 1} cornerPoints magnitude: ${cornerPoint.magnitude}");
  //     }
  //
  //     for (int i = 0; i < block.recognizedLanguages.length; i++) {
  //       debugPrint("Block ${i + 1} recognizedLanguages: ${block.recognizedLanguages[i]}");
  //     }
  //
  //     for (int j = 0; j < block.lines.length; j++) {
  //       final line = block.lines[j];
  //       debugPrint("  Line ${j + 1} Text: ${line.text}");
  //       for (int k = 0; k < line.elements.length; k++) {
  //         debugPrint("  Line ${j + 1} Element ${k + 1} angle: ${line.elements[k].angle}");
  //         debugPrint("  Line ${j + 1} Element ${k + 1} confidence: ${line.elements[k].confidence}");
  //         debugPrint("  Line ${j + 1} Element ${k + 1} text: ${line.elements[k].text}");
  //       }
  //     }
  //   }
  //
  //   String text = recognizedText.text;
  //   debugPrint("Text Box Length is ${recognizedText.blocks.length}");
  //
  //   textRecognizer.close();
  //
  //   // Process the extracted text as required (e.g., display in a dialog).
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Extracted Text'),
  //         content: Text(text),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: const Text('Close'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }












class TextOverlayPainter extends CustomPainter {
  final List<TextBlock> textBlocks;

  TextOverlayPainter(this.textBlocks);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var block in textBlocks) {
      final left = block.boundingBox.left.toDouble();
      final top = block.boundingBox.top.toDouble();
      final width = block.boundingBox.width.toDouble();
      final height = block.boundingBox.height.toDouble();

      canvas.drawRect(Rect.fromLTWH(left, top, width, height), paint);

      TextPainter(
        text: TextSpan(
          text: block.text,
          style: const TextStyle(color: Colors.yellow, fontSize: 20.0),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, Offset(left, top));

      if (kDebugMode) {
        print(block.text);
      }
    }
  }

  @override
  bool shouldRepaint(TextOverlayPainter oldDelegate) {
    return oldDelegate.textBlocks != textBlocks;
  }
}





