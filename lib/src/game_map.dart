library Map;

import 'package:dart_rpg/src/character.dart';
import 'package:dart_rpg/src/tile.dart';

class GameMap {
  String name;
  List<List<List<Tile>>> tiles = [];
  List<Character> characters = [];
  
  GameMap(this.name, [this.tiles, this.characters]);
}