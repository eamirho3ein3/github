import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github/models/repo.dart';
import 'package:github/pages/home/home-repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckAccessToken extends HomeEvent {
  final String key;
  final BuildContext context;
  CheckAccessToken(this.key, this.context);

  @override
  List<Object> get props => [key, context];
}

class GetAccessToken extends HomeEvent {
  final String key;
  final BuildContext context;
  GetAccessToken(this.key, this.context);

  @override
  List<Object> get props => [key, context];
}

class GetRepos extends HomeEvent {
  final int numOfReposToLoad;
  final GraphQLClient client;
  GetRepos(this.numOfReposToLoad, this.client);

  @override
  List<Object> get props => [numOfReposToLoad, client];
}

class Reset extends HomeEvent {}

class HomeState extends Equatable {
  @override
  List<Object> get props => [];
}

class HomeUninitialized extends HomeState {}

class HomeLoading extends HomeState {}

class FetchLoading extends HomeState {}

class SearchStatusUpdate extends HomeState {}

class NoAccessToken extends HomeState {}

class HaveAccessToken extends HomeState {}

class ReposReady extends HomeState {
  final List<Repo> _result;
  ReposReady(this._result);
  List<Repo> get getResult => _result;

  @override
  List<Object> get props => throw [_result];
}

class GetError extends HomeState {}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  bool isLoading = false;
  final HomeRepository homeRepository;
  HomeBloc(this.homeRepository) : super(HomeUninitialized());

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is CheckAccessToken) {
      yield HomeLoading();

      try {
        var result = await homeRepository.checkAccessToken(event.key);
        if (result != null) {
          // have access token
          yield HaveAccessToken();
        } else {
          // no access token & shoul Loggin
          yield NoAccessToken();
        }
      } catch (error) {
        print("error read from database : $error");

        yield GetError();
      }
    } else if (event is GetAccessToken) {
      yield HomeLoading();

      try {
        await homeRepository.login(event.key);
        yield HaveAccessToken();
      } catch (error) {
        print("error read from database : $error");

        yield GetError();
      }
    } else if (event is GetRepos) {
      if (isLoading) {
        // means we are fetching
        yield FetchLoading();
      } else {
        yield HomeLoading();
      }

      try {
        final queryResults = await homeRepository.getRepositories(
            event.numOfReposToLoad, event.client);

        if (queryResults.hasException) {
          print('repo error : ${queryResults.exception.toString()}');
          yield GetError();
        } else {
          final List<Repo> listOfRepos = Repo.fromJson(queryResults.data);
          yield ReposReady(listOfRepos);
        }
      } catch (error) {
        print("error read from database : $error");

        yield GetError();
      }
    } else if (event is Reset) {
      yield HomeUninitialized();
    }
  }
}
