import 'package:flutter/material.dart';
import 'package:flutter_app/contact_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'test'),
    );
  }
}

//定义一个组件（如果有必要，你可以把它写在另外一个文件中引入进来)，你可以理解为时Vue的Component
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  //定义组件的属性值，类似于props
  final String title;

  /**
   * 如果你的组件中的内容，需要响应式变更，
   * 那么久需要重写createState方法，
   * 所以说，大多数情况下，一个State类和一个Widget类会同时出现
   * 除非组件是不需要响应变化的静态组件
   */

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: new ContactPage() // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
