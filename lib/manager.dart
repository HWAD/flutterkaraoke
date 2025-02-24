import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutterkaraoke/model_song.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

import './model_song.dart';
import './songs_search.dart';
import './songs_album.dart';
import './songs_row.dart';
import './recorder_control.dart';
import './player.dart';
import './recorder.dart';
import './feed.dart';
import './login.dart';

class Manager extends StatefulWidget {
  final String startingMenu;

  Manager({this.startingMenu = 'Default Value'});

  @override
  State<StatefulWidget> createState() {
    return _Manager();
  }
}

class _Manager extends State<Manager> {
  List<ModelSong> _allSongs = [];
  List<ModelSong> _allVideos = [];
  FlutterSound _flutterSound = new FlutterSound();
  ModelSong _selectedSong = new ModelSong(
      title: "none",
      artist: "none",
      downloadURL: "none",
      imageURL: "none",
      lyrics: "[00:00:00]Lyrics",
      score: 0,
      isFavorite: false);
  String _currentLyric = "Lyrics Come Here!!";
  bool _isCategory = false;
  bool _isSongs = false;
  bool _isRecorder = false;
  bool _isPlayer = false;
  bool _isFeed = false;
  bool _isLogin = false;
  bool _isTimer = false;
  String _selectedCategory = "All";
  List<int> _decibels = [];
  String _username = "";
  String _timerForSong = "";
  String filePathToPlay;

  @override
  void initState() {
    super.initState();
    _isLogin = true;
    _getAllVideos();
    _getAllSongs();
  }

  Future<void> _getAllSongs() async {
    const url = 'https://flutterkaraoke.firebaseio.com/songs.json';
    http.get(url).then(
      (response) {
        Map<String, dynamic> mappedBody = json.decode(response.body);
        List<dynamic> dynamicList = mappedBody.values.toList();
        List<dynamic> dynamicKeys = mappedBody.keys.toList();
        List<ModelSong> modelSongList = [];
        for (int i = 0; i < dynamicList.length; i++) {
          modelSongList.add(ModelSong(
              id: dynamicKeys[i],
              title: dynamicList[i]["title"],
              artist: dynamicList[i]["artist"],
              downloadURL: dynamicList[i]["downloadURL"],
              imageURL: dynamicList[i]["imageURL"],
              length: dynamicList[i]["length"],
              category: dynamicList[i]["category"],
              score: dynamicList[i]["score"],
              lyrics: dynamicList[i]["lyrics"],
              isFavorite: dynamicList[i]["isFavorite"]));
        }
        setState(
          () {
            _allSongs = modelSongList;
          },
        );
      },
    );
  }

  Future<void> _getAllVideos() async {
    const url = 'https://flutterkaraoke.firebaseio.com/videos.json';
    http.get(url).then(
      (response) {
        Map<String, dynamic> mappedBody = json.decode(response.body);
        List<dynamic> dynamicList = mappedBody.values.toList();
        List<dynamic> dynamicKeys = mappedBody.keys.toList();
        List<ModelSong> modelVideoList = [];
        for (int i = dynamicList.length - 1; i >= 0; i--) {
          modelVideoList.add(ModelSong(
              id: dynamicKeys[i],
              title: dynamicList[i]["title"],
              artist: dynamicList[i]["artist"],
              downloadURL: dynamicList[i]["downloadURL"],
              imageURL: dynamicList[i]["imageURL"],
              length: dynamicList[i]["length"],
              category: dynamicList[i]["category"],
              score: dynamicList[i]["score"],
              isFavorite: dynamicList[i]["isFavorite"]));
        }
        setState(
          () {
            _allVideos = modelVideoList;
          },
        );
      },
    );
  }

  void _setUsername(String username) {
    setState(
      () {
        _username = username;
      },
    );
  }

  void _changeSongs(bool isSongs) {
    setState(
      () {
        _isSongs = isSongs;
      },
    );
  }

  void _changeRecorder(bool isRecorder) {
    setState(
      () {
        _isRecorder = isRecorder;
      },
    );
  }

  void _changeCategory(bool isCategory) {
    setState(
      () {
        _isCategory = isCategory;
      },
    );
  }

  void _changePlayer(bool isPlayer) {
    setState(
      () {
        _isPlayer = isPlayer;
      },
    );
  }

  void _setSelectedSong(ModelSong song) {
    setState(
      () {
        _selectedSong = song;
      },
    );
  }

  void _setCategory(String category) {
    setState(
      () {
        _selectedCategory = category;
        _changeSongs(true);
      },
    );
  }

  void _setCurrentLyric(String line) {
    setState(
      () {
        _currentLyric = line;
      },
    );
  }

  void _setFilePathToPlay(String text) {
    setState(
      () {
        filePathToPlay = text;
      },
    );
  }

  void _setDecibels(int decibel) {
    setState(
      () {
        _decibels.add(decibel);
      },
    );
  }

  void _changeFeed(bool isFeed) {
    setState(
      () {
        _isFeed = isFeed;
      },
    );
  }

  void _setLogin(bool isLogin) {
    setState(
      () {
        _isLogin = isLogin;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          visible: _isLogin,
          child: Column(
            children: [
              Login(_setLogin, _changeFeed, _setUsername),
            ],
          ),
        ),
        Visibility(
          visible: _isFeed,
          child: Column(
            children: [
              Feed(_allVideos, _changeCategory, _changeFeed, _setFilePathToPlay,
                  _changePlayer, _getAllVideos, _changeSongs, _username),
            ],
          ),
        ),
        Visibility(
          visible: _isCategory,
          child: Column(
            children: [
              SongSearch(_setCategory, _changeCategory, _changeFeed),
            ],
          ),
        ),
        Visibility(
          visible: _isSongs,
          child: Column(
            children: [
              SongRow(_setCategory, _changeSongs, _changeCategory, _changeFeed,
                  _changeRecorder, _setSelectedSong, _allSongs),
              SongAlbum(_changeSongs, _changeRecorder, _allSongs,
                  _setSelectedSong, _selectedCategory),
            ],
          ),
        ),
        Visibility(
          visible: _isRecorder,
          child: Column(
            children: [
              Container(
                child: RecorderControl(
                  _changeRecorder,
                  _changePlayer,
                  _changeSongs,
                  _changeFeed,
                ),
              ),
              Recorder(
                setFilePathToPlay: _setFilePathToPlay,
                currentLyric: _currentLyric,
                flutterSound: _flutterSound,
                selectedSong: _selectedSong,
                setCurrentLyric: _setCurrentLyric,
                changeRecorder: _changeRecorder,
                changePlayer: _changePlayer,
                changeSongs: _changeSongs,
                username: _username,
                timerForSong: _timerForSong,
                isTimer: _isTimer,
              ),
            ],
          ),
        ),
        Visibility(
          visible: _isPlayer,
          child: Column(
            children: [
              Player(
                filePathToPlay: filePathToPlay,
                changeSongs: _changeSongs,
                changeRecorder: _changeRecorder,
                changePlayer: _changePlayer,
                changeFeed: _changeFeed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
