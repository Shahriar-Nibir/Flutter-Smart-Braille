import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'package:pdf_text/pdf_text.dart';

void main() {
  runApp(FrontPage2());
}

//////////////////////////////
// pdf to text
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PDFDoc? _pdfDoc;
  String _text = "";

  bool _buttonsEnabled = true;

  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start().then((x) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Smart Braille : PDF Upload'),
          ),
          body: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: ListView(
              children: <Widget>[
                TextButton(
                  child: Text(
                    "Pick PDF document",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(10, 80, 10, 80),
                      backgroundColor: Colors.blueAccent),
                  onPressed: _pickPDFText,
                ),
                // TextButton(
                //   child: Text(
                //     "Read random page",
                //     style: TextStyle(color: Colors.white),
                //   ),
                //   style: TextButton.styleFrom(
                //       padding: EdgeInsets.all(5),
                //       backgroundColor: Colors.blueAccent),
                //   onPressed: _buttonsEnabled ? _readRandomPage : () {},
                // ),
                TextButton(
                  child: Text(
                    "Read document",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.fromLTRB(10, 80, 10, 80),
                      // margin: const EdgeInsets.only(top: 25),
                      backgroundColor: Colors.blueAccent),
                  onPressed: _buttonsEnabled ? _readWholeDoc : () {},
                ),
                Padding(
                  child: Text(
                    _pdfDoc == null
                        ? "Pick a new PDF document and wait for it to load..."
                        : "PDF document loaded, ${_pdfDoc!.length} pages\n",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.all(15),
                ),
                Padding(
                  child: Text(
                    _text == "" ? "" : "Text:",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.all(15),
                ),
                Text(_text),
              ],
            ),
          )),
    );
  }

  /// Picks a new PDF document from the device
  Future _pickPDFText() async {
    var filePickerResult = await FilePicker.platform.pickFiles();
    if (filePickerResult != null) {
      _pdfDoc = await PDFDoc.fromPath(filePickerResult.files.single.path!);
      setState(() {});
    }
  }

  /// Reads a random page of the document
  Future _readRandomPage() async {
    if (_pdfDoc == null) {
      return;
    }
    setState(() {
      _buttonsEnabled = false;
    });

    String text =
        await _pdfDoc!.pageAt(Random().nextInt(_pdfDoc!.length) + 1).text;

    setState(() {
      _text = text;
      _buttonsEnabled = true;
    });
  }

  /// Reads the whole document
  Future _readWholeDoc() async {
    if (_pdfDoc == null) {
      return;
    }
    setState(() {
      _buttonsEnabled = false;
    });

    String text = await _pdfDoc!.text;

    setState(() {
      _text = text;
      _buttonsEnabled = true;
    });
  }
}

///////////////////////////////
// OCR app

class MyApp1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Braille',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Smart Braille : OCR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<OcrText> text = [];
  int _counter = 0;
  List _text = [];
  bool isInitialized = false;
  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start().then((value) {
      isInitialized = true;
    });
  }

  Future _startScan() async {
    try {
      List<OcrText> text = await FlutterMobileVision.read(
          waitTap: true, fps: 5.0, multiple: true);

      setState(() {
        for (OcrText t in text) {
          _text.add(t.value);
        }
        print(_text);
      });
    } on Exception {
      text.add(new OcrText('Failed to recognize text.'));
    }
  }

  void _incrementCounter() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child:
            // ListView.builder(
            //   itemCount: text.length,
            //   itemBuilder: (BuildContext context, int index) {
            //     return Container(
            //       height: 50,
            //       color: Colors.black,
            //       child: Center(child: Text('${_text[index]}')),
            //     );
            //   }),
            TextButton(
          child: Text(
            "Start Scan",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.black,
            ),
          ),
          style: TextButton.styleFrom(
              padding: EdgeInsets.fromLTRB(130, 360, 130, 360),
              backgroundColor: Colors.blue[100]),
          onPressed: _startScan,
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _startScan,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}

////////////////////////////////
// home page
class FrontPage2 extends StatelessWidget {
  const FrontPage2({Key? key}) : super(key: key);

  static const String _title = 'Smart Braille';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const Center(
          child: MyStatefulWidget(),
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  double sideLength = 350;
  double upLength = 700;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: upLength,
      width: sideLength,
      duration: const Duration(seconds: 2),
      curve: Curves.easeIn,
      child: Material(
        color: Colors.blue[100],
        child: InkWell(
          child: Center(
            child: Text(
              'Tap Once To Read Text From Image,Tap Twice To Upload PDF',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp1()),
            );
          },
          onDoubleTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyApp()),
            );
          },
        ),
      ),
    );
  }
}
