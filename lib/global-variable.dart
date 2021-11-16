import 'package:graphql_flutter/graphql_flutter.dart';

class GlobVariable {
  static GlobVariable _instance;
  factory GlobVariable() => _instance ??= new GlobVariable._();
  GlobVariable._();

  String clientId = '53e4ee2e84f4729d00a9';
  String clientSecret = 'e35175ef99087a33647799a679aa71c4400853b4';
  String accessToken;
  String
      nextFetchCursor; // use to now the start point of next repository fetch, null means there is now repository left to fetch
  QueryResult lastRepositoryData;

  String getClientId() {
    return clientId;
  }

  String getClientSecret() {
    return clientSecret;
  }

  String getAccessToken() {
    return accessToken;
  }

  QueryResult getLastRepositoryData() {
    return lastRepositoryData;
  }

  String getNextFetchCursor() {
    return nextFetchCursor;
  }

  setAccessToken(String token) {
    this.accessToken = token;
  }

  setLastRepositoryData(QueryResult data) {
    this.lastRepositoryData = data;
  }

  setNextFetchCursor(String data) {
    this.nextFetchCursor = data;
  }
}
