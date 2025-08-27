import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String?> pickAndUploadFile() async {
  final result = await FilePicker.platform.pickFiles();
  if (result != null && result.files.single.path != null) {
    File file = File(result.files.single.path!);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:3900/upload'),
    );
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var respStr = await response.stream.bytesToString();
      var data = jsonDecode(respStr);
      return data['url'];
    }
  }
  return null;
}
