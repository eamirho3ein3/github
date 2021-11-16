import 'package:flutter/material.dart';
import 'package:github/global-variable.dart';
import 'package:github/services/shared-preference/shared-preference-helper.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:oauth2_client/github_oauth2_client.dart';
import 'package:github/services/graphql/queries.dart' as queries;

class HomeRepository {
  final GitHubOAuth2Client githubClient;

  HomeRepository({@required this.githubClient}) : assert(githubClient != null);

  Future<void> login(String key) async {
    var resp = await githubClient.getTokenWithAuthCodeFlow(
        clientId: GlobVariable().clientId,
        clientSecret: GlobVariable().clientSecret,
        scopes: [
          "user",
          "repo",
          "public_repo",
        ]);
    print("body: $resp");
    await SharedPreferenceHelper().addStringToSF(key, resp.accessToken);
    GlobVariable().setAccessToken(resp.accessToken);
  }

  Future<String> checkAccessToken(String key) async {
    var result = await SharedPreferenceHelper().getStringValuesSF(key);
    GlobVariable().setAccessToken(result);
    return result;
  }

  Future<QueryResult> getRepositories(
      int numOfRepositories, GraphQLClient client) async {
    var _after = GlobVariable().getNextFetchCursor();
    final WatchQueryOptions _options = WatchQueryOptions(
      document: gql(queries.readRepositories),
      variables: <String, dynamic>{
        'nRepositories': numOfRepositories,
        'after': _after,
      },
      fetchResults: true,
    );
    var result = await client.query(_options);
    return result;
  }
}
