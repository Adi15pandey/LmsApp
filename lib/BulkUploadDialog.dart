import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class BulkUploadDialog extends StatefulWidget {
  final Function(File) onFileUploaded;

  BulkUploadDialog({required this.onFileUploaded});

  @override
  _BulkUploadDialogState createState() => _BulkUploadDialogState();
}

class _BulkUploadDialogState extends State<BulkUploadDialog> {
  File? selectedFile;

  void _handleFileUpload(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        if (file.path.endsWith('.zip')) {
          setState(() {
            selectedFile = file;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File selected: ${file.path}',))
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid file type. Only .zip files allowed.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<bool> _uploadFileToServer(File file) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://lms.recqarz.com/api/econciliation/upload'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Key expected by the API
          file.path,
        ),
      );

      request.headers.addAll({
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjhiYWY0ZjJlNGUyNWI5ZTRmZThiN2YiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzkwNTg0NiwiZXhwIjoxNzM0NTEwNjQ2fQ.YIoKP6gZm5oYdzYMKc46fsKYAqTTM-gfnLE0YN9Egzk',
        'Content-Type': 'multipart/form-data',
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        String responseBody = await response.stream.bytesToString();
        print('Failed with status code: ${response.statusCode}');
        print('Response: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error uploading file: $e');
      return false;
    }
  }

  void _importData(BuildContext context) async {
    if (selectedFile != null) {
      bool isUploaded = await _uploadFileToServer(selectedFile!);
      if (isUploaded) {
        widget.onFileUploaded(selectedFile!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data imported successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data import failed!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected for import.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Bulk Upload File!"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Upload Excel File"),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Text(
                  "Drop Files Here To Upload, Please use .zip files only",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _handleFileUpload(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: Text('Choose File'),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            _importData(context);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: Text("Import Data"),
        ),
      ],
    );
  }
}
