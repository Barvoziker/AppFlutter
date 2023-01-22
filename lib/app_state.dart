import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;

/// `MyAppState` is a class that extends `ChangeNotifier` and has a `String` property called `title`
class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var history = <WordPair>[];

  GlobalKey? historyListKey;

  /// Get the next token from the input stream.
  void getNext() {
    history.insert(0, current);
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>{};

  /// If the pair is null, then the function will toggle the favorite status of the current pair. If the
  /// pair is not null, then the function will toggle the favorite status of the pair that was passed in
  ///
  /// Args:
  ///   pair (WordPair): The WordPair to be added or removed from the favorites list.
  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
    notifyListeners();
  }

  /// If the pair is in the list of favorites, remove it
  ///
  /// Args:
  ///   pair (WordPair): The word pair to remove from the list of favorites.
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  String _email = '';
  String _bearer = '';

  /// It fetches the user from the database.
  fetchUser(String mail, String password) async {
    _bearer = await generateToken(mail, password);
    var response = await http.get(Uri.parse('http://127.0.0.1:8000/api/users'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_bearer"
        });

    print(response.body);
  }

  /// It creates a user in the database.
  createUser(String mail, String password) async {
    //send the request with json body
    await http.post(Uri.parse('http://127.0.0.1:8000/api/users'),
        headers: {"Content-Type": "application/json"},
        body: '{"email": "$mail", "password": "$password"}');

    _email = mail;
    notifyListeners();

    generateToken(mail, password);
    fetchUser(mail, password);
  }

  String get email => _email;

  /// It generates a token for the user.
  ///
  /// Args:
  ///   mail: The email address of the user.
  ///   password: The password of the user
  generateToken(mail, password) async {
    var response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/login_check'),
        headers: {"Content-Type": "application/json"},
        body: '{"username": "$mail", "password": "$password"}');
    print(response.body);

    var bearer = jsonDecode(response.body)["token"];
    return bearer;
  }
}
