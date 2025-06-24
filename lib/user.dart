import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';


class User {
  double largeur = 2.4;
  double longueur = 100;
  bool isMeter = true;
  bool deepFit = true;

  static final User _singleton = User._internal();
  
  factory User() {
    return _singleton;
  }
  
  User._internal();
  
  void loadFromData(SharedPreferences pref){
    largeur =  pref.getDouble("largeur") ?? 2.4;
    longueur = pref.getDouble("longueur") ?? 100;
    isMeter =  pref.getBool("isMeter") ?? true;
    deepFit =  pref.getBool("deepFit") ?? true;
  }

  Future<void> save() async {
    final pref = await SharedPreferences.getInstance();
    largeur = isMeter ? largeur : largeur / 39.37;
    longueur = isMeter ? longueur : longueur / 39.37;
    pref.setDouble("largeur", largeur);
    pref.setDouble("longueur", longueur);
    pref.setBool("isMeter", isMeter);
    pref.setBool("deepFit", deepFit);
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const String routeName = "settings";

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final largeurController = TextEditingController(text: (User().isMeter ? User().largeur : User().largeur * 39.37).toString());
  final longueurController = TextEditingController(text: (User().isMeter ? User().longueur : User().longueur * 39.37).toString());
  bool isMeter = User().isMeter;

  bool isSaving = false;
  _SettingsPageState();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    largeurController.dispose();
    longueurController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return 
    Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Paramètres"),
      ),
      body:
      Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(width: 100, child:
                  const Text("Largeur :")),
                  SizedBox(width: 100, child:
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: 
                  TextField(
                    textAlign: TextAlign.center,
                    controller: largeurController,
                  ),)
                  ),
                  DropdownButton<String>(items: ["m", "\""].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(), value: ["m", "\""][isMeter ? 0 : 1], onChanged: (String? value){setState((){
                    isMeter = value! == "m";
                    if(isMeter){
                      largeurController.text = (double.parse(largeurController.text)/39.37).toStringAsFixed(2);
                      longueurController.text = (double.parse(longueurController.text)/39.37).toStringAsFixed(2);
                    }else{
                      largeurController.text = (double.parse(largeurController.text)*39.37).toStringAsFixed(2);
                      longueurController.text = (double.parse(longueurController.text)*39.37).toStringAsFixed(2);
                    }
                    });})
                ]
              ),
              Row(
                children: <Widget>[
                  SizedBox(width: 100, child:
                  const Text("Longueur :")),
                  SizedBox(width: 100, child:
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: 
                  TextField(
                    textAlign: TextAlign.center,
                    controller: longueurController,
                  ),)
                  ),
                  Text(["m", "\""][isMeter ? 0 : 1])
                ]
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 60.0, right: 60.0,),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                ElevatedButton(
                  onPressed: () async {
                    if(!isSaving){
                      User().largeur = double.parse(largeurController.text);
                      User().longueur = double.parse(longueurController.text);
                      User().isMeter = isMeter;
                      setState(() { isSaving = true; }); 
                      await User().save();
                      setState(() { isSaving = false; }); 

                       if (mounted && Navigator.canPop(context)){
                        Navigator.pop(context, true);
                       }
                    }
                  },
                  child: isSaving ? CircularProgressIndicator() : const Text("Sauvegarder") ,
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: (){
                      if (Navigator.canPop(context)){
                        Navigator.pop(context, false);
                      }
                  },
                  child: const Text("Annuler"),
                ),
                ]),
              )
            ],
          )
      )
    );
  }
}