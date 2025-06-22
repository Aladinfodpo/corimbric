import 'package:flutter/material.dart';

import 'imbric.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Coratech Imbric'),
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
  List<Piece> pieces = [Piece(1, 1, true, 1, others: 1)];
  Camion camion = Camion();
  double _currentScale = 1.0;

  static int currentId = 1;

  final TransformationController _controller = TransformationController();

  void calculate(){
    camion = Camion();
    List<Piece> palettes = [];

    for (var piece in pieces){
      for(var i = 0; i < piece.others; i++){
        palettes.add(Piece(piece.dx, piece.dy, piece.isTransposable, piece.id, isMeter: piece.isMeter, others: piece.others));
      }
    }
    Imbric.bestFit(camion, palettes);
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 300,
            child: Card(
                  child: 
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child :
                      SingleChildScrollView(
                      child:
                      DataTable(
                        columnSpacing: 18.0,
                        columns: [
                          DataColumn(label: Center(child: Text('Largeur'), )),
                          DataColumn(label: Center(child: Text('Longueur'))),
                          DataColumn(label: Center(child: Text('Nombre'))),
                          DataColumn(label: Center(child: Text('Id'))),
                          DataColumn(label: Center(child: Text('Tournable'))),
                          DataColumn(label: Center(child: IconButton(onPressed: (){setState(() {
                            pieces.add(Piece(1, 1, true, ++currentId, others: 1));
                          });}, icon: Icon(Icons.add)))),
                        ],
                        rows: List.generate(pieces.length, (index) => DataRow(
                          cells: [
                            DataCell(Center(child: TextFormField(initialValue: pieces[index].dx.toString(), onChanged: (value) => pieces[index].dx = double.tryParse(value) ?? 0,))),
                            DataCell(Center(child: TextFormField(initialValue: pieces[index].dy.toString(), onChanged: (value) => pieces[index].dy = double.tryParse(value) ?? 0,))),
                            DataCell(Center(child: TextFormField(initialValue: pieces[index].others.toString(), onChanged: (value) => pieces[index].others = int.tryParse(value) ?? 1,))),
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
            Card(child: 
              Row(
                spacing: 20,
                children: [
                  ElevatedButton(onPressed: (){setState(() {
                    calculate();
                  });}, child: const Text("Calculer")),
                  Text(camion.longueur == double.infinity ? "" : "Efficacité : ${camion.calculEfficiency().toStringAsFixed(0)}%"),
                  Text(camion.longueur == double.infinity ? "" : "Longueur : ${camion.longueur.toStringAsFixed(1)}m")
                ],
              ),
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
          ],
        ),
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
