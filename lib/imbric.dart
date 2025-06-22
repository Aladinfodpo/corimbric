import 'dart:math';
//import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'user.dart';


const eps = 0.0001;
const zoom = 100.0;

class Piece{
    double x = 0, y = 0, dx, dy;
    int id;
    bool isTransposable;
    bool isMeter = true;
    int others = 0;

    Piece(double inDx, double inDy, this.isTransposable, this.id, {this.isMeter = true, this.others = 0}): dx = isTransposable ? max(inDx, inDy) : inDx, dy = isTransposable ? min(inDx, inDy) : inDy;
    double getArea() { return dx * dy; }

    double getOut(double dim) { return isMeter ? dim : dim * 39.37; }
    String getOutString(double dim) { return "${getOut(dim)} ${isMeter ? "m" : "\""}"; }

    Piece clone(){
      return Piece(dx, dy, isTransposable, id, isMeter: isMeter, others: others);
    }

    void transpose(){
      final buff = dx;
      dx = dy;
      dy = buff;
    }

    void draw(Canvas canvas, double scale){
      Paint darkPainter = Paint();
      darkPainter.style = PaintingStyle.stroke;
      darkPainter.strokeWidth = 3.0;
      canvas.drawRect(Rect.fromLTWH(x*zoom, y*zoom, dx*zoom, dy*zoom), darkPainter);
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

      textPainter.paint(canvas,Offset((x + dx * 0.5)*zoom - textPainter.width*0.5, (y + dy * 0.5)*zoom - textPainter.height*0.5));

      if(dx * zoom * scale > 100 && dy * zoom * scale > 100){
        final textDx = TextPainter(
        text: TextSpan(
          text: dx.toStringAsFixed(2),
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textDx.paint(canvas, Offset((x + dx * 0.5) * zoom - textDx.width * 0.5, y * zoom + textDx.height * 0.1));

      final textDy = TextPainter(
        text: TextSpan(
          text: dy.toStringAsFixed(2),
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      
      Offset offset = Offset((x + dx) * zoom -10, (y + dy * 0.5) * zoom);
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(pi/2);
      final textOffset = Offset(-textDy.width / 2, -textDy.height / 2);
      textDy.paint(canvas,textOffset); 
      canvas.restore();
      }
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

    void draw(Canvas canvas, double scale){
      canvas.drawRect(Rect.fromLTWH(x*zoom, y*zoom, dx*zoom, dy*zoom), Paint());
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
      return longueur > 0 ? sumArea / (dx * longueur) * 100 : 100;
    }

    void sortPieces(List<Piece> inOutPieces, {int forceTransposePieceI = -1}){
      inOutPieces.sort((Piece a, Piece b) {return -a.getArea().compareTo(b.getArea()); });

      int indexP = 0;

      for (var piece in inOutPieces) {
          var remainX = dx / piece.dx;
          var remainY = dx / piece.dy;
          remainX = remainX - remainX.floor();
          remainY = remainY - remainY.floor();

          if (piece.isTransposable && (indexP++ != forceTransposePieceI && (remainY < remainX && piece.dy * piece.others >= 0.6 * dx))){ piece.transpose();}
      }
    }

    void draw(Canvas canvas, double scale){
      final redPainter = Paint();
      redPainter.style = PaintingStyle.stroke;
      redPainter.strokeWidth = 3.0;
      redPainter.color = Colors.red;

      if(longueur == 0 || longueur == double.infinity){
        final textPainter = TextPainter(
        text: TextSpan(
          text: longueur == 0 ? "Ajouter des palettes pour calculer" : "Impossible de faire tout rentrer",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(canvas,Offset(20, 200));        
      }else{
        canvas.drawRect(Rect.fromLTWH(0, 0, dx*zoom, longueur*zoom), redPainter);

        for (var p in pieces){ p.draw(canvas, scale); }

        final textPainter = TextPainter(
          text: TextSpan(
            text: "$dx m",
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
            textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas,Offset(dx * 0.5 * zoom - textPainter.width * 0.5, -textPainter.height * 1.2)); 

        final textPainterDy = TextPainter(
          text: TextSpan(
            text: "$longueur m",
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
            textDirection: TextDirection.ltr,
        )..layout();
        Offset offset = Offset(10.0 + dx * zoom + textPainterDy.height*0.1, longueur * zoom * 0.5 );
        canvas.save();
        canvas.translate(offset.dx, offset.dy);
        canvas.rotate(pi/2);
        final textOffset = Offset(-textPainter.width / 2, -textPainter.height / 2);
        textPainterDy.paint(canvas,textOffset); 
        canvas.restore();
      }
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
      Camion bestC = Camion(dx: c.dx, dy: c.dy);
      bestC.longueur = double.infinity;
      bool res = false;
 
      for (int iPiece = -1; iPiece <= inPieces.length && (iPiece < 0 || User().deepFit); iPiece++) {
          Camion c2 = Camion(dx: c.dx, dy: c.dy);
          if (Imbric.fit(c2, inPieces.map((Piece p) => p.clone()).toList(), forceTransposePieceI: iPiece) && c2.longueur < bestC.longueur){ 
            bestC = c2; 
            res = true;
          }
      }

      c.pieces = bestC.pieces;
      c.longueur = bestC.longueur;
      c.boxesVides = bestC.boxesVides;
      c.boxes = bestC.boxes;

      return res;
    }
}