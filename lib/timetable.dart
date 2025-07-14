import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  File? _image;
  String? _result;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = null;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;
    setState(() => _loading = true);

    final uri = Uri.parse('https://your-render-url/extract');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', _image!.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    setState(() {
      _loading = false;
      if (response.statusCode == 200) {
        _result = respStr;
      } else {
        _result = 'Error: ${response.statusCode}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable Scanner')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_image != null) Image.file(_image!, height: 200),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Timetable Image'),
            ),
            if (_image != null)
              ElevatedButton(
                onPressed: _uploadImage,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Upload & Extract'),
              ),
            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _result ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
