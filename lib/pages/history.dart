import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cnn/history.dart';
import 'package:cnn/styles/colors.dart';
import 'package:cnn/values.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with TickerProviderStateMixin {
  // List<History> rawHistories = [
  //   History(
  //     image: 'https://www.alomedika.com/wp-content/uploads/2020/05/shutterstock_107915651-min.jpg',
  //     disease: 'Tuberkulosis',
  //     probability: 98.88,
  //     createdAt: DateTime(2022, 1, 12, 19, 30),
  //   ),
  //   History(
  //     image: 'https://www.alomedika.com/wp-content/uploads/2020/05/shutterstock_107915651-min.jpg',
  //     disease: 'Covid',
  //     probability: 98.88,
  //     createdAt: DateTime(2022, 1, 12, 12, 34),
  //   ),
  //   History(
  //     image: 'https://www.alomedika.com/wp-content/uploads/2020/05/shutterstock_107915651-min.jpg',
  //     disease: 'Normal',
  //     probability: 68.88,
  //     createdAt: DateTime(2022, 1, 12, 17, 30),
  //   ),
  //   History(
  //     image: 'https://www.alomedika.com/wp-content/uploads/2020/05/shutterstock_107915651-min.jpg',
  //     disease: 'Tuberkulosis',
  //     probability: 98.88,
  //     createdAt: DateTime(2022, 1, 10, 17, 30),
  //   ),
  //   History(
  //     image: 'https://www.alomedika.com/wp-content/uploads/2020/05/shutterstock_107915651-min.jpg',
  //     disease: 'Covid',
  //     probability: 98.88,
  //     createdAt: DateTime(2022, 1, 10, 10, 10),
  //   ),
  // ];

  List<GroupedHistory> groupedHistory = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    // TODO: Change this code after reviewer accept
    // SharedPreferences _pr = await SharedPreferences.getInstance();
    // var rawDatas = _pr.getStringList(F_HISTORY_KEY);

    //  if (rawDatas != null) {
    //   List<History> datas = rawDatas.map((e) => History.fromJson(e)).toList();
    //   var groupByDate = groupBy<History, String>(datas, (obj) => obj.createdAt.toIso8601String().substring(0, 10));
    //   groupByDate.forEach((date, list) {
    //     list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    //     setState(() {
    //       groupedHistory.add(GroupedHistory(dateISO: date, histories: list));
    //     });
    //   });
    // }

    final _fs = FirebaseFirestore.instance.collection(F_HISTORY_KEY);
    var rawDatas = await _fs.get();
    if (rawDatas.docs.isNotEmpty) {
      List<History> datas = rawDatas.docs.map((e) => History.fromMap(e.data())).toList();
      var groupByDate = groupBy<History, String>(datas, (obj) => obj.createdAt.toIso8601String().substring(0, 10));
      groupByDate.forEach((date, list) {
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() {
          groupedHistory.add(GroupedHistory(dateISO: date, histories: list));
        });
      });
    }
  }

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    groupedHistory.clear();
    await getData();
    await Future.delayed(Duration(milliseconds: 200));
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      header: WaterDropMaterialHeader(),
      child: groupedHistory.isNotEmpty
          ? ListView.builder(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              itemCount: groupedHistory.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupedHistory[index].date.toHumanDate(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      ...List.generate(groupedHistory[index].histories.length, (j) {
                        var history = groupedHistory[index].histories[j];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColor.blueAccent.withOpacity(0.5),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 1,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: CachedNetworkImage(
                                      imageUrl: history.image,
                                      height: 30,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(history.disease),
                                      Text(
                                        'Checked At : ' + history.createdAt.time(),
                                        style: TextStyle(fontSize: 12, color: AppColor.gray),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                history.probability.toString() + '%',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: history.probability > 90 ? AppColor.primary : Colors.redAccent),
                              ),
                            ],
                          ),
                        );
                      })
                    ],
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/empty.jpg',
                    height: MediaQuery.of(context).size.width * 0.5,
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Let's try to identify lung disease\non the lung icon menu",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColor.black),
                  ),
                ],
              ),
            ),
    );
  }
}
