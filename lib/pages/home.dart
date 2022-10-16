import 'package:cnn/pages/about.dart';
import 'package:cnn/pages/classify.dart';
import 'package:cnn/pages/history.dart';
import 'package:cnn/styles/colors.dart';
import 'package:cnn/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  checkGuest() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    final bool? action = _pref.getBool(SP_SKIP_TUTORIAL_KEY);
    if (action != null && !action) {
      showTutorial();
    }
    if (action == null) {
      showTutorial();
    }
  }

  skipTutorial() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    await _pref.setBool(SP_SKIP_TUTORIAL_KEY, true);
  }

  @override
  void initState() {
    createTutorial();
    checkGuest();

    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
  }

  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HistoryPage(),
    SizedBox(),
    AboutPage(),
  ];

  void _onItemTapped(int index) {
    if (index != 1) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      openClassify();
    }
  }

  openClassify() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.75,
          child: ClassifyPage(),
        );
      },
    );
  }

  late TutorialCoachMark tutorialCoachMark, tutorialCoachMarkSkip;
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(
      TargetFocus(
        identify: "Scan",
        keyTarget: keyButton2,
        color: AppColor.black,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Image Lung Disease Detection",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 8),
                      child: Text(
                        "Detecting lung diseases based on images, there are 3 types of diseases that can be classified by the application (Pneumonia, Tuberculosis, Covid-19) and Normal",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        controller.next();
                      },
                      child: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              );
            },
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 5,
      ),
    );

    targets.add(
      TargetFocus(
        identify: "Target 1",
        keyTarget: keyButton1,
        color: AppColor.black,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Scan History",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 8),
                      child: Text(
                        "Images that have been classified will be entered into the detection history",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            controller.previous();
                          },
                          child: Icon(Icons.chevron_left),
                        ),
                        SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: () {
                            controller.next();
                            skipTutorial();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: Icon(Icons.check),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 5,
      ),
    );

    return targets;
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      onFinish: skipTutorial,
      paddingFocus: 10,
      hideSkip: true,
    );
    tutorialCoachMarkSkip = TutorialCoachMark(
      targets: _createTargets(),
      paddingFocus: 10,
    );
  }

  void showTutorial({bool hideSkip = true}) {
    if (!hideSkip) {
      tutorialCoachMarkSkip.show(context: context);
    } else {
      tutorialCoachMark.show(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Lung Disease Detection',
          style: TextStyle(
            color: AppColor.black,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.6,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              showTutorial(hideSkip: false);
            },
            icon: Icon(FlutterRemix.question_fill),
            color: AppColor.black,
          )
        ],
      ),
      // body: Container(
      //   color: Colors.white,
      //   padding: EdgeInsets.all(24),
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Container(
      //         child: Center(
      //           child: Container(
      //             child: Column(
      //               children: [
      //                 if (_image != null)
      //                   Container(
      //                     height: 250,
      //                     width: 250,
      //                     child: ClipRRect(
      //                       borderRadius: BorderRadius.circular(30),
      //                       child: Image.file(
      //                         _image,
      //                         fit: BoxFit.fill,
      //                       ),
      //                     ),
      //                   ),
      //                 // Divider(
      //                 //   height: 25,
      //                 //   thickness: 1,
      //                 // ),
      //                 _output != null
      //                     ? Text(
      //                         'Terdeteksi: $_prob% $_output!',
      //                         style: TextStyle(
      //                           color: Colors.white,
      //                           fontSize: 18,
      //                           fontWeight: FontWeight.w400,
      //                         ),
      //                       )
      //                     : Container(),
      //                 // Divider(
      //                 //   height: 25,
      //                 //   thickness: 1,
      //                 // ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //       GestureDetector(
      //         onTap: pickGalleryImage,
      //         child: Container(
      //           width: MediaQuery.of(context).size.width - 200,
      //           alignment: Alignment.center,
      //           padding: EdgeInsets.symmetric(horizontal: 24, vertical: 17),
      //           decoration: BoxDecoration(
      //             color: Colors.blueGrey[600],
      //             borderRadius: BorderRadius.circular(15),
      //           ),
      //           child: Text(
      //             'Ambil dari galeri',
      //             style: TextStyle(color: Colors.white, fontSize: 16),
      //           ),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                FlutterRemix.history_fill,
                key: keyButton1,
              ),
              label: 'Scan History',
            ),
            BottomNavigationBarItem(
              icon: Container(
                key: keyButton2,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColor.blueAccent,
                ),
                child: Icon(
                  FlutterRemix.lungs_fill,
                  color: AppColor.primary,
                  size: 18,
                ),
              ),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(FlutterRemix.user_smile_fill),
              label: 'About',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppColor.primary,
          unselectedItemColor: AppColor.gray2,
          onTap: _onItemTapped,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 20,
        ),
      ),
    );
  }
}
