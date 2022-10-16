import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

class History extends Equatable {
  final String image;
  final String disease;
  final double probability;
  final DateTime createdAt;
  History({
    required this.image,
    required this.disease,
    required this.probability,
    required this.createdAt,
  });

  History copyWith({
    String? image,
    String? disease,
    double? probability,
    DateTime? createdAt,
  }) {
    return History(
      image: image ?? this.image,
      disease: disease ?? this.disease,
      probability: probability ?? this.probability,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'disease': disease,
      'probability': probability,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory History.fromMap(Map<String, dynamic> map) {
    return History(
      image: map['image'] ?? '',
      disease: map['disease'] ?? '',
      probability: map['probability']?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory History.fromJson(String source) => History.fromMap(json.decode(source));

  @override
  String toString() {
    return 'History(image: $image, disease: $disease, probability: $probability, createdAt: $createdAt)';
  }

  @override
  List<Object> get props => [image, disease, probability, createdAt];
}

extension DateFormatter on DateTime {
  String toHumanClockTime() => DateFormat('dd MMMM yyyy, hh:mm').format(this);
  String toHumanDate() => DateFormat('dd MMMM yyyy').format(this);
  String time() => DateFormat('hh:mm').format(this);
}

class GroupedHistory extends Equatable {
  final String dateISO;
  final List<History> histories;
  GroupedHistory({
    required this.dateISO,
    required this.histories,
  });

  GroupedHistory copyWith({
    String? dateISO,
    List<History>? histories,
  }) {
    return GroupedHistory(
      dateISO: dateISO ?? this.dateISO,
      histories: histories ?? this.histories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date_i_s_o': dateISO,
      'histories': histories.map((x) => x.toMap()).toList(),
    };
  }

  factory GroupedHistory.fromMap(Map<String, dynamic> map) {
    return GroupedHistory(
      dateISO: map['date_i_s_o'] ?? '',
      histories: List<History>.from(map['histories']?.map((x) => History.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory GroupedHistory.fromJson(String source) => GroupedHistory.fromMap(json.decode(source));

  DateTime get date => DateTime.parse(dateISO);

  @override
  String toString() => 'GroupedHistory(dateISO: $dateISO, histories: $histories)';

  @override
  List<Object> get props => [dateISO, histories];
}
