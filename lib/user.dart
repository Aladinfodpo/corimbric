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
    pref.setDouble("largeur", largeur);
    pref.setDouble("longueur", longueur);
    pref.setBool("isMeter", isMeter);
    pref.setBool("deepFit", deepFit);
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.onCancel});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
  final Function? onCancel;
}

class _SettingsPageState extends State<SettingsPage> {
  final largeurController = TextEditingController(text: User().largeur.toString());
  final longueurController = TextEditingController(text: User().longueur.toString());

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
    Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Text("Largeur :"),
                Expanded(child:
                Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: 
                TextField(
                  controller: longueurController,
                ),)
                ),
              ]
            ),
            Row(
              children: <Widget>[
                const Text("Longueur :"),
                Expanded(child:
                Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: 
                TextField(
                  controller: longueurController,
                ),)
                ),
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
                    setState(() { isSaving = true; }); 
                    await User().save();
                    setState(() { isSaving = false; }); 
                  }
                },
                child: isSaving ? CircularProgressIndicator() : const Text("Sauvegarder") ,
              ),
              Spacer(),
              ElevatedButton(
                onPressed: (){
                    widget.onCancel?.call();
                },
                child: const Text("Annuler"),
              ),
              ]),
            )
          ],
        )
    );
  }
}