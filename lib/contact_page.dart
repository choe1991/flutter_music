//import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_app/Song.dart';

class ContactPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new PageState();
  }
}

class PageState extends State<ContactPage> {
  List songs;
  int PlayStatu = 0;
  int playedId = 0;
//  SocketIOManager manager;
//  SocketIO socket;
  AudioPlayer audioPlayer = new AudioPlayer();

  Future getSongs({String keyword: "你好"}) async {
    final String url = "http://music.86qweqweqwe.com/search?keywords=$keyword";
    Dio dio = new Dio();
    Response response = await dio.get(url);
    List result = response.data['result']['songs'];
    setState(() {
      songs = result.map((item) => Song.fromJson(item)).toList();
    });
  }

  void doit(int id) async {
    audioPlayer.stop();
    final String url = "http://music.86qweqweqwe.com/song/url?id=$id";
    Dio dio = new Dio();
    Response response = await dio.get(url);
    print(response);
    var result = response.data['data'][0]['url'];
    if (result == null) {
      showError('这首歌可能是没有版权哦！');
      setState(() {
        PlayStatu = 0;
      });
      return;
    }
    int play_result = await audioPlayer.play(result);
    setState(() {
      playedId = id;
      PlayStatu = play_result;
    });
  }

  void showError(String text) {
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('温馨提示'),
          content: new SingleChildScrollView(child: new Text(text)),
          actions: <Widget>[
            new FlatButton(
              child: new Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((val) {
      print(val);
    });
  }

  Future stopAll() async {
    if (PlayStatu == 1) {
      int play_result = await audioPlayer.pause();

      setState(() {
        PlayStatu = play_result == 1 ? 0 : 1;
      });
    } else {
      int play_result = await audioPlayer.resume();
      setState(() {
        PlayStatu = play_result;
      });
    }
  }

  void inputChanged(value) {
    setState(() {
      songs = null;
    });
    getSongs(keyword: value);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSongs();
//    manager = SocketIOManager();
//    socketIn();
  }

//  void socketIn() async {
//    print('initSockets');
//    socket = await manager.createInstance("http://86qweqweqwe.com",enableLogging: true);
//    socket.onConnect((data) {
//      socket.emit("GroupJoin",null);
//      print("connected...");
//    });
//    socket.on("top_events", (data) {
//      print("top_events");
//    });
//    socket.onDisconnect((data) {
//
//      print('disconnected from socket.io');
//    });
//    socket.onReconnect((data) {
//      print('reconnected to socket.io');
//    });
//    socket.connect();
//  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      floatingActionButton: new FloatingActionButton(
        onPressed: stopAll,
        tooltip: 'Increment',
        child: new Icon(PlayStatu == 1
            ? Icons.pause_circle_outline
            : Icons.play_circle_outline),
      ),
      body: songs == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
              child: new Column(
                children: [
                  new TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: '请输入歌曲名称',
                          prefixIcon: Icon(Icons.queue_music)),
                      onSubmitted: (value) => {inputChanged(value)}),
                  Flexible(
                      child: ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return new ListTile(
                          onTap: () => {doit(songs[index].songid)},
                          leading: new CircleAvatar(
                              child: new Text(songs[index].name[0])),
                          title: new Text(songs[index].name),
                          subtitle: new Text(songs[index].artistName),
                          trailing: (playedId == songs[index].songid)
                              ? new Icon(Icons.music_note, color: Colors.blue)
                              : null);
                    },
                  ))
                ],
              ),
            ),
    );
  }
}
