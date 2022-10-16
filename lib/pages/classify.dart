import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cnn/history.dart';
import 'package:cnn/styles/colors.dart';
import 'package:cnn/values.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClassifyPage extends StatefulWidget {
  const ClassifyPage({Key? key}) : super(key: key);

  @override
  State<ClassifyPage> createState() => _ClassifyPageState();
}

class _ClassifyPageState extends State<ClassifyPage> {
  File? _image;
  bool _processing = false;
  String _status = '';
  String? _output;
  double? _prob;
  Dio dio = Dio();
  final picker = ImagePicker();

  pickImage() async {
    //this function to grab the image from camera
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });
  }

  pickGalleryImage() async {
    //this function to grab the image from gallery
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
      print(_image!.path);
    });
  }

  classify() async {
    setState(() {
      _processing = true;
    });
    _status = '0% Processing Image';
    var path = _image!.path;
    var fileName = (path.split('/').last);
    var formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        path,
        filename: fileName,
      )
    });

    setState(() {
      _status = '12% Identifying Image';
    });

    // TODO: Uncomment this section
    // var host = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
    // var response = await dio.post('http://$host:5000/predict', data: formData);

    // setState(() {
    //   _output = response.data['output'][0];
    //   _prob = response.data['probability'][0];
    //   _status = '66% Image has been identified';
    // });
    // recordData();

    // TODO: Remove this section later

    await Future.delayed(
      Duration(seconds: 3),
      () {
        setState(() {
          _output = 'Playground';
          _prob = random(10, 100).toDouble();
          _status = '66% Image has been identified';
        });
        recordData();
      },
    );
    ///////
  }

  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  recordData() async {
    var uri = await sendImage();

    var newData = History(
      image: uri,
      disease: _output!,
      probability: _prob!,
      createdAt: DateTime.now(),
    );

    setState(() {
      _status = '90% Storing identification in database';
    });
    final _ff = FirebaseFirestore.instance.collection(F_HISTORY_KEY);
    await _ff.add(newData.toMap());

    saveToLocal(newData);
    reset();
  }

  Future<String> sendImage() async {
    setState(() {
      _status = '75% Storing identification in database';
    });
    final _storage =
        FirebaseStorage.instance.ref().child(FS_HISTORY).child(DateTime.now().millisecondsSinceEpoch.toString());

    var uploadTask = _storage.putFile(_image!);
    return (await uploadTask).ref.getDownloadURL();
  }

  reset() {
    setState(() {
      _processing = false;
      _status = '';
    });
  }

  saveToLocal(History data) async {
    SharedPreferences _pr = await SharedPreferences.getInstance();
    var rawDatas = _pr.getStringList(F_HISTORY_KEY);
    if (rawDatas == null) {
      rawDatas = [];
    }
    List<History> datas = rawDatas.map((e) => History.fromJson(e)).toList();
    datas.add(data);

    await _pr.setStringList(F_HISTORY_KEY, datas.map((e) => e.toJson()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Stack(
        children: [
          if (!_processing) ...[
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('close'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColor.gray,
                  ),
                ),
              ),
            ),
          ],
          if (_image == null) ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/upload.jpg',
                    height: MediaQuery.of(context).size.width * 0.5,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'You can choose x-ray image from gallery\nwith format png, jpg, jpeg',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColor.black),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: pickGalleryImage,
                    child: Text('Choose Image'),
                  ),
                ],
              ),
            ),
          ],
          if (_image != null) ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.file(
                    _image!,
                    height: MediaQuery.of(context).size.width * 0.5,
                  ),
                  SizedBox(height: 24),
                  if (_output == null) ...[
                    if (_processing) ...[
                      LinearProgressIndicator(
                        color: AppColor.primary,
                        backgroundColor: AppColor.blueAccent,
                      ),
                      SizedBox(height: 16),
                      Text(_status),
                      SizedBox(height: 8),
                      Text(
                        "Please don't close this page\nuntil this process ends",
                        style: TextStyle(color: Colors.redAccent),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      Text(
                        'Make sure the image you upload is an x-ray',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColor.black),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: pickGalleryImage,
                            child: Text('Choose Image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.blueAccent,
                              foregroundColor: AppColor.black,
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: classify,
                            child: Text('Process'),
                          ),
                        ],
                      ),
                    ]
                  ] else ...[
                    SizedBox(height: 16),
                    RichText(
                      text: TextSpan(
                        text: 'this image identified',
                        style: GoogleFonts.poppins(
                          color: AppColor.black,
                        ),
                        children: [
                          TextSpan(
                            text: ' $_prob%',
                            style: TextStyle(
                              color: _prob! > 90 ? AppColor.primary : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: ' $_output',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "You can close this page",
                      style: TextStyle(color: AppColor.primary),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
