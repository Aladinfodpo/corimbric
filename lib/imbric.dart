import 'dart:math';
//import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'user.dart';


const eps = 0.0001;

class Piece{
    double x = 0, y = 0, dx, dy;
    int id;
    bool isTransposable;
    bool isMeter = true;
    int others = 0;

    Piece(this.dx, this.dy, this.isTransposable, this.id, {this.isMeter = true, this.others = 0});
    double getArea() { return dx * dy; }

    double getOut(double dim) { return isMeter ? dim : dim * 39.37; }
    String getOutString(double dim) { return "${getOut(dim)} ${isMeter ? "m" : "\""}"; }

    void transpose(){
      final buff = dx;
      dx = dy;
      dy = buff;
    }

    void draw(Canvas canvas){
      canvas.drawRect(Rect.fromLTWH(x, y, dx, dy), Paint());
      final textPainter = TextPainter(
        text: TextSpan(
          text: id.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas,Offset((x + dx * 0.5) - textPainter.width*0.5, (y + dy * 0.5) - textPainter.height*0.5));
    }
}

class Box{
    double x, y, dx, dy;

    Box(this.x, this.y, this.dx, this.dy);

    bool hasRoomFor(double inDx, double inDy){
      return dx + eps >= inDx && dy + eps >= inDy;
    }

    bool isFitting(Piece p){
      if(!hasRoomFor(p.dx, p.dy)){
        if(p.isTransposable && hasRoomFor(p.dy, p.dx)){
            p.transpose();
        }else{
            return false;
        }
      }

      return true;
    }

    void draw(Canvas canvas){
      canvas.drawRect(Rect.fromLTWH(x, y, dx, dy), Paint());
    }
}

class Camion{
    double dx, dy;
    double longueur = 0;
    List<Box> boxes = [];
    List<Box> boxesVides = [];
    List<Piece> pieces = [];

    double getOut(double dim) { return User().isMeter ? dim : dim * 39.37; }
    String getOutString(double dim) { return "${getOut(dim)} ${User().isMeter ? "m" : "\""}"; }

    Camion({this.dx = 0, this.dy = 0}){
      dx = (dx == 0) ? User().largeur : dx;
      dy = (dy == 0) ? User().longueur : dy;
      boxes.add(Box(0, 0, dx, dy));
    }

    double addPiece(Piece p){
      pieces.add(p);
      longueur = max(p.y + p.dy, longueur);
      return longueur;
    }

    double calculEfficiency(){
      double sumArea = 0;
      for (var piece in pieces){ sumArea += piece.getArea(); }
      return sumArea / (dx * longueur) * 100;
    }

    void sortPieces(List<Piece> inOutPieces, {int forceTransposePieceI = -1}){
      inOutPieces.sort((Piece a, Piece b) {return a.getArea().compareTo(b.getArea()); });

      int indexP = 0;

      for (var piece in inOutPieces) {
          var remainX = dx / piece.dx;
          var remainY = dy / piece.dy;
          remainX = remainX - remainX.floor();
          remainY = remainY - remainY.floor();

          if (piece.isTransposable && (indexP++ != forceTransposePieceI && (remainY < remainX && piece.dy * piece.others >= 0.6 * dx))){ piece.transpose();}
      }
    }

    void draw(Canvas canvas){
      final redPainter = Paint();
      redPainter.color = Colors.red;
      canvas.drawRect(Rect.fromLTWH(0, 0, dx, dy), redPainter);

      for (var p in pieces){ p.draw(canvas); }
    }
}

class Imbric{
    static bool fit(Camion c, List<Piece> inPieces, {int forceTransposePieceI = -1}){
      c.sortPieces(inPieces, forceTransposePieceI: forceTransposePieceI);

      //Tant qu'il reste des pièces a poser
      while(inPieces.isNotEmpty){

          //Si il n'y a plus de place
          if(c.boxes.isEmpty){ return false; }

          final index = inPieces.indexWhere((Piece p){return c.boxes[0].isFitting(p);});
          

          if(index >= 0){
              final itPiece = inPieces[index];

              //On place la piece en haut a gauche
              itPiece.x = c.boxes[0].x;
              itPiece.y = c.boxes[0].y;
              c.addPiece(itPiece);

              //On ajoute les boites
              final ddx = c.boxes[0].dx - itPiece.dx;
              final ddy = c.boxes[0].dy - itPiece.dy;

              if(ddy > 0){
                  c.boxes.insert(1, Box(c.boxes[0].x, c.boxes[0].y + itPiece.dy, c.boxes[0].dx, ddy));
              }
              if (ddx > 0) {
                  final newBox = Box(c.boxes[0].x + itPiece.dx, c.boxes[0].y, ddx, itPiece.dy);

                  //On cherche si il existe une box vide en dessous
                  final indexE = c.boxesVides.indexWhere((Box b){return (newBox.x - b.x).abs() <= eps && (newBox.dx - b.dx).abs() <= eps && (newBox.y - (b.y + b.dy)).abs() <= eps; });
                  if (indexE >= 0) {
                      final itBox = c.boxesVides[indexE];
                      newBox.y = itBox.y;
                      newBox.dy += itBox.dy;
                      c.boxesVides.removeAt(indexE);
                  }

                  c.boxes.insert(1, newBox);
              }

              //On enlève la pièce traitée
              inPieces.removeAt(index);
          }
          else{
              c.boxesVides.add(c.boxes[0]);
          }

          c.boxes.removeAt(0);
      }

      return true;
    }

    static bool bestFit(Camion c, List<Piece> inPieces){
      Camion bestC = c;
      bool res = Imbric.fit(bestC, inPieces);

      for (int iPiece = 0; iPiece <= inPieces.length && res && User().deepFit; iPiece++) {
          Camion c2 = c;
          Imbric.fit(c2, inPieces, forceTransposePieceI: iPiece);
          if (c2.longueur < bestC.longueur){ bestC = c2; }
      }

      c = bestC;
      return res;
    }
}