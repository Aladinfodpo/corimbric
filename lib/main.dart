import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'imbric.dart';
import 'user.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  User().loadFromData(prefs);
  runApp(const MyApp());
}

var routePages = {
      '/' : (BuildContext context) => MyHomePage(title: 'Coratech Imbric'),
      SettingsPage.routeName: (BuildContext context) => SettingsPage(),
    };

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coratech Imbric',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: routePages,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Piece> pieces = [Piece(1, 1, true, 1, isMeter: User().isMeter, others: 1)];
  Camion camion = Camion();
  double _currentScale = 1.0;

  static int currentId = 1;
  bool fullscreen = false;

  final TransformationController _controller = TransformationController();

  void calculate(){
    camion = Camion();
    List<Piece> palettes = [];

    for (var piece in pieces){
      for(var i = 0; i < piece.others; i++){
        palettes.add(Piece(piece.dx, piece.dy, piece.isTransposable, piece.id, isMeter: piece.isMeter, others: piece.others));
      }
    }
    if(!Imbric.bestFit(camion, palettes) || camion.longueur == 0){
      _controller.value = Matrix4.identity()
    ..translate(100.0, 20.0)
    ..scale(1.0);
    }
  }

  @override
  void initState(){
    super.initState();

    calculate();
    _controller.value = Matrix4.identity()
    ..translate(100.0, 20.0)
    ..scale(_currentScale);

    _controller.addListener(() {
      final scale = _controller.value.getMaxScaleOnAxis();
      setState(() {
        _currentScale = scale;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center( child: 
        OrientationBuilder(
          builder: (context, orientation) {
            return Flex( 
            direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
            children: [ Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: fullscreen ? 0 : 270,
                width: fullscreen ? 0 : null,
                child: Card(
                      child: 
                      Padding(
                        padding: EdgeInsets.all(0.0),
                        child :
                          SingleChildScrollView(
                          child:
                          DataTable(
                            columnSpacing: 8.0,
                            columns: [
                              DataColumn(label: Center(child: Text('Largeur'), )),
                              DataColumn(label: Center(child: Text('Longueur'))),
                              DataColumn(label: Center(child: Text('    '))),
                              DataColumn(label: Center(child: Text('Nombre'))),
                              DataColumn(label: Center(child: Text('Id'))),
                              DataColumn(label: Center(child: Text('Tournable'))),
                              DataColumn(label: Center(child: IconButton(onPressed: (){setState(() {
                                pieces.add(Piece(1, 1, true, ++currentId, isMeter: User().isMeter, others: 1));
                              });}, icon: Icon(Icons.add)))),
                            ],
                            rows: List.generate(pieces.length, (index) => DataRow(
                              cells: [
                                DataCell(Center(child: TextFormField(initialValue: pieces[index].dx.toString(), onChanged: (value) => pieces[index].dx = double.tryParse(value) ?? 0, textAlign: TextAlign.center,))),
                                DataCell(Center(child: TextFormField(initialValue: pieces[index].dy.toString(), onChanged: (value) => pieces[index].dy = double.tryParse(value) ?? 0, textAlign: TextAlign.center,))),
                                DataCell(Center(child: DropdownButton<String>(items: ["m", "\""].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(value: value, child: Text(value));
                                }).toList(), value: ["m", "\""][pieces[index].isMeter ? 0 : 1], onChanged: (String? value){setState((){pieces[index].isMeter = value! == "m";});}))),
                                DataCell(Center(child: TextFormField(initialValue: pieces[index].others.toString(), onChanged: (value) => pieces[index].others = int.tryParse(value) ?? 1, textAlign: TextAlign.center,))),
                                DataCell(Center(child: Text(pieces[index].id.toString()))),
                                DataCell(Center(child: Checkbox(value: pieces[index].isTransposable, onChanged:(value) => setState(() {
                                  pieces[index].isTransposable = value!;
                                }),))),
                                DataCell(Center(child: IconButton(icon: Icon(Icons.delete), onPressed:() => setState(() {
                                  pieces.removeAt(index);
                                }),))),
                              ],
                            )
                            ),
                          )
                        )
                      )
                  )
                ),
                ],
                ),
                Expanded(child:
                Column(children: [
                  SizedBox(
                  width: 300,
                  height: 60,
                  child: Card(
                      margin: EdgeInsets.all(0),
                      child: 
                      Column(children:[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: [
                          Text(camion.longueur == double.infinity ? "" : "Efficacité: ${camion.calculEfficiency().toStringAsFixed(0)}%"),
                          Text(camion.longueur == double.infinity ? "" : "Longueur: ${camion.getOutString(camion.longueur, precision: 1)}"),
                        ]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 20,
                          children: [
                          ElevatedButton(
                            onPressed: (){setState(() {
                            calculate();
                          });}, child: const Text("Calculer")),
                          IconButton(onPressed: (){setState(() {
                            fullscreen = !fullscreen;
                          });}, icon: Icon(Icons.fullscreen)),
                          IconButton(onPressed: (){Navigator.pushNamed(context, SettingsPage.routeName, ).then((res) {if(res != null && res as bool) {setState(calculate);}});}, icon: Icon(Icons.settings)),
                        ],
                      ),
                      ])
                    )
                  ),  
                Expanded(
                  child:
                Padding(
                  padding: EdgeInsets.all(4.0),
                  child:
                  InteractiveViewer(
                    transformationController: _controller,
                    boundaryMargin: EdgeInsets.only(left: 20 + camion.dx*50, right: 50, top: 25, bottom: camion.longueur == double.infinity ? 0 : camion.longueur * 100),
                    minScale: 0.01,
                    maxScale: 5.0,
                    child: 
                    CustomPaint(
                        size: Size.infinite,
                        painter: MyPainter(camion, _currentScale),
                    )
                  )
                )
                ),
                ])
                )
              ],
            );
            } )
          ),
    );
  }
}

class MyPainter extends CustomPainter {
  final Camion camion;
  final double scale;

  MyPainter(this.camion, this.scale);

  @override
  void paint(Canvas canvas, Size size) {
    camion.draw(canvas, scale);
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    return oldDelegate.camion != camion || oldDelegate.scale != scale;
  }
}
