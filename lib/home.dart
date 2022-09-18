import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File _image;
  String _output;
  Dio dio = Dio();
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  pickImage() async {
    //this function to grab the image from camera
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

    classify(_image.path);
  }

  pickGalleryImage() async {
    //this function to grab the image from gallery
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

    classify(_image.path);
  }

  classify(String path) async {
    EasyLoading.show();
    var fileName = (path.split('/').last);
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        path,
        filename: fileName,
      )
    });

    var response = await dio.post('http://10.0.2.2:5000/predict', data: formData);

    setState(() {
      _output = response.data['value'];
    });

    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.9),
        centerTitle: true,
        title: Text(
          'Klasifikasi Paru',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w200, fontSize: 20, letterSpacing: 0.8),
        ),
      ),
      body: Container(
        color: Colors.black.withOpacity(0.9),
        padding: EdgeInsets.symmetric(horizontal: 35, vertical: 50),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Color(0xFF2A363B),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Center(
                  child: Container(
                    child: Column(
                      children: [
                        if (_image != null)
                          Container(
                            height: 250,
                            width: 250,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.file(
                                _image,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        Divider(
                          height: 25,
                          thickness: 1,
                        ),
                        _output != null
                            ? Text(
                                'Terdeteksi: $_output!',
                                // 'The object is: ${_output[0]['label']}!',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w400),
                              )
                            : Container(),
                        Divider(
                          height: 25,
                          thickness: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: pickGalleryImage,
                child: Container(
                  width: MediaQuery.of(context).size.width - 200,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                  decoration: BoxDecoration(color: Colors.blueGrey[600], borderRadius: BorderRadius.circular(15)),
                  child: Text(
                    'Ambil dari galeri',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
