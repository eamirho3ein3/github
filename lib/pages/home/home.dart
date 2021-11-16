import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github/global-variable.dart';
import 'package:github/models/repo.dart';
import 'package:github/pages/home/home-bloc.dart';
import 'package:github/pages/home/home-repository.dart';
import 'package:github/pages/home/widgets/repo-item.dart';
import 'package:oauth2_client/github_oauth2_client.dart';

import 'package:graphql_flutter/graphql_flutter.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GitHubOAuth2Client _githubClient = GitHubOAuth2Client(
      redirectUri: 'simplegithub://callback', customUriScheme: 'simplegithub');
  List<Repo> _repose = [];
  ScrollController _listController = ScrollController();
  HomeBloc _homeBloc;
  var _after;

  @override
  void initState() {
    super.initState();

    _listController.addListener(_onListviewChange);
  }

  @override
  void dispose() {
    _listController.removeListener(_onListviewChange);
    _listController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (context) =>
          HomeBloc(HomeRepository(githubClient: _githubClient)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('GitHub'),
        ),
        body: _manageState(),
      ),
    );
  }

  _manageState() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        _homeBloc = context.read<HomeBloc>();
        _after = GlobVariable().getNextFetchCursor();
        if (state is HomeUninitialized) {
          // initial the screen
          context
              .read<HomeBloc>()
              .add(CheckAccessToken('accessToken', context));
        } else if (state is HomeLoading) {
          // show loading
          return _buildRegularLoading();
        } else if (state is FetchLoading) {
          return _buildRepoView(context);
        } else if (state is NoAccessToken) {
          // show Login view
          return _buildLoginView(context);
        } else if (state is HaveAccessToken) {
          // get repos
          context.read<HomeBloc>().add(GetRepos(10, _client()));
        } else if (state is ReposReady) {
          // data are ready
          _repose.addAll(state.getResult);
          _homeBloc.isLoading = false;

          return _buildRepoView(context);
        } else if (state is GetError) {
          // get error
          return _buildCenterMessage("oops :(");
        }
        return Container();
      },
    );
  }

  _buildLoginView(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: Text('login'),
        onPressed: () async {
          context.read<HomeBloc>().add(GetAccessToken('accessToken', context));
        },
      ),
    );
  }

  _buildRepoView(BuildContext context) {
    return _repose.isEmpty
        ? _buildCenterMessage('No reposity founded')
        : ListView.separated(
            controller: _listController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemBuilder: (context, index) {
              return RipoItem(_repose[index]);
            },
            separatorBuilder: (context, _) {
              return SizedBox(
                height: 12,
              );
            },
            itemCount: _repose.length);
  }

  _buildRegularLoading() {
    return Center(
      child: CircularProgressIndicator(
        valueColor:
            AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        backgroundColor: Colors.black,
      ),
    );
  }

  _buildCenterMessage(String message) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }

  GraphQLClient _client() {
    final HttpLink _httpLink = HttpLink(
      'https://api.github.com/graphql',
    );

    final AuthLink _authLink = AuthLink(
      getToken: () => 'Bearer ${GlobVariable().accessToken}',
    );

    final Link _link = _authLink.concat(_httpLink);

    return GraphQLClient(
      cache: GraphQLCache(
        store: HiveStore(),
      ),
      link: _link,
    );
  }

  void _onListviewChange() {
    if ((_listController.offset >=
            (_listController.position.maxScrollExtent * 0.8)) &&
        !_homeBloc.isLoading &&
        _after != null) {
      _homeBloc.add(GetRepos(10, _client()));
      _homeBloc.isLoading = true;
    }
  }
}
