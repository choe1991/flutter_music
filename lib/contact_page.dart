import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
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
  var channel = IOWebSocketChannel.connect("ws://86qweqweqwe.com");

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

  Future<int> playByMusic(int id) async {
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
      return 0;
    }else{
      int play_result = await audioPlayer.play(result);
      setState(() {
        playedId = id;
        PlayStatu = play_result;
      });
      return id;
    }
  }

  void sendMusicToServer(data){
    print("sendMusicToServer"+data.toString());
    if(data!=0){
      print(123123);
      channel.sink.add(data.toString());
    }else{
      print(321321321);
    }

  }

  void onButtonTap(id) {
    channel.sink.add("有人点击播放了"+id.toString());
    playByMusic(id).then((data) =>sendMusicToServer(data));
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
    channel.stream.listen((message) {
      try {
        playByMusic(int.parse(message));
        print('转数字成功:' + message);
      } on FormatException {
        print('received from socket server:' + message);
      }


    });
    channel.sink.add("someone connected!");
//    manager = SocketIOManager();
//    socketIn();
  }

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
                          onTap: () => {onButtonTap(songs[index].songid)},
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
