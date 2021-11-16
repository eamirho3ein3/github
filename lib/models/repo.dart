import 'package:flutter/material.dart';
import 'package:github/global-variable.dart';

class Repo {
  final String id;
  final String name;
  final bool isPrivate;
  final String createdAt;

  Repo({
    @required this.id,
    @required this.name,
    @required this.isPrivate,
    @required this.createdAt,
  });

  static List<Repo> fromJson(Map<String, dynamic> json) {
    List<Repo> results = [];
    var repositories = json['viewer']['repositories'];
    final List<dynamic> dataResults = repositories['nodes'] as List<dynamic>;
    var pageInfo = repositories['pageInfo'];
    var _after;
    if (pageInfo['hasNextPage'] as bool) {
      _after = pageInfo['endCursor'];
    }
    GlobVariable().setNextFetchCursor(_after);
    for (var item in dataResults) {
      results.add(Repo(
        id: item["id"] as String,
        name: item["name"] as String,
        isPrivate: item["isPrivate"] as bool,
        createdAt: item["createdAt"] as String,
      ));
    }

    return results;
  }
}
