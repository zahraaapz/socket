import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future pickAndUploadFile(FileType type) async {
  final result = await FilePicker.platform.pickFiles(
    type: type,
    allowedExtensions: type == FileType.custom ? typeDoc : [],
  );
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
      print(data.toString());
      return {
        'path': result.files.single.path,
        'name': result.files.single.name,
        'url': data['url'],
      };
    }
  }
  return null;
}

List<String> typeDoc = ['pdf', 'doc', 'docx'];
