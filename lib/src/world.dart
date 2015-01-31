library World;

import 'dart:math' as math;

import 'package:dart_rpg/src/animation_game_event.dart';
import 'package:dart_rpg/src/character.dart';
import 'package:dart_rpg/src/choice_game_event.dart';
import 'package:dart_rpg/src/interactable_tile.dart';
import 'package:dart_rpg/src/main.dart';
import 'package:dart_rpg/src/sign.dart';
import 'package:dart_rpg/src/sprite.dart';
import 'package:dart_rpg/src/text_game_event.dart';
import 'package:dart_rpg/src/tile.dart';
import 'package:dart_rpg/src/warp_tile.dart';

class World {
  static final int
    LAYER_GROUND = 0,
    LAYER_BELOW = 1,
    LAYER_PLAYER = 2,
    LAYER_ABOVE = 3;
  
  static final List<int> layers = [
    LAYER_GROUND,
    LAYER_BELOW,
    LAYER_PLAYER,
    LAYER_ABOVE
  ];
  
  List<List<List<Tile>>> map = [];
  List<Character> characters = [];
  
  final int
    viewXSize = (Main.canvasWidth/(Sprite.pixelsPerSprite*Sprite.spriteScale)).round(),
    viewYSize = (Main.canvasHeight/(Sprite.pixelsPerSprite*Sprite.spriteScale)).round();
  
  World() {
    int xSize = 50;
    int ySize = 50;
    
    for(int y=0; y<ySize; y++) {
      map.add([]);
      for(int x=0; x<xSize; x++) {
        map[y].add([]);
        for(int i=0; i<layers.length; i++) {
          map[y][x].add(null);
        }
      }
    }
    
    for(int y=0; y<viewYSize; y++) {
      for(int x=0; x<viewXSize; x++) {
        if(y == 0 || y == 15 || x == 0 || x == 19) {
          map[y][x][LAYER_GROUND] = new Tile(
            true,
            new Sprite.int(Tile.WALL, x, y)
          );
        } else {
          map[y][x][LAYER_GROUND] = new Tile(
            false,
            new Sprite.int(Tile.GROUND, x, y)
          );
        }
      }
    }
    
    // Top half of the house, which you can walk behind
    addObject(
      Tile.HOUSE,
      10, 6, LAYER_ABOVE,
      6, 2,
      false
    );
    
    // Bottom half of the house
    addObject(
      Tile.HOUSE + 64,
      10, 8, LAYER_BELOW,
      6, 3,
      true
    );
    
    for(int y=25; y<=32; y++) {
      for(int x=0; x<=8; x++) {
        if(x == 0 || x == 8 || y == 25 || y == 32) {
          map[y][x][LAYER_GROUND] = new Tile(
            true,
            new Sprite.int(Tile.WALL, x, y)
          );
        } else {
          map[y][x][LAYER_GROUND] = new Tile(
            false,
            new Sprite.int(Tile.WOOD_FLOOR, x, y)
          );
        }
      }
    }
    
    // Outside door warp
    addWarp(
      Tile.HOUSE + 128 + 1,
      11, 10, // Pos
      4, 32 // Dest
    );
    
    // Inside door warp
     addWarp(
       Tile.HOUSE + 128 + 1,
       4, 32, // Pos
       11, 10 // Dest
     );
    
    // Sign
    addSign(
      Tile.SIGN,
      235,
      9, 10, LAYER_BELOW,
      1, 1,
      true,
      "This is only a test. This is a sign that has way too much text. " +
        "We'll see how the sign handles having this much text on it. " +
        "It really takes a lot of text to fill them up!"
    );
    
    // Sign
    addSign(
      Tile.SIGN,
      235,
      8, 10, LAYER_BELOW,
      1, 1,
      true,
      "This is a second sign."
    );
    
    // Character
    Character character = addCharacter(
      //Tile.PLAYER - 64,
      Tile.PLAYER,
      238,
      4, 6, LAYER_BELOW,
      1, 2,
      true
    );
    
    character.direction = Character.RIGHT;
    
    // TODO: handle multi-tier choices?
    character.setGameEvents([
      new TextGameEvent(238, "I'm like a kid, right?"),
      new AnimationGameEvent((callback) {
        chainCharacterMovement(
          character,
          [Character.LEFT, Character.LEFT, Character.LEFT,
            Character.RIGHT, Character.RIGHT, Character.RIGHT],
          callback
        );
      }),
      new TextGameEvent.choice(238, "See?",
        new ChoiceGameEvent(["Yes", "No"], [
          new TextGameEvent(232, "That's fine."),
          new TextGameEvent(232, "I hate you.")
        ])
      )
    ]);
  }
  
  void chainCharacterMovement(Character character, List<int> directions, Function callback) {
    if(directions.length == 0) {
      callback();
    } else {
      int direction = directions.removeAt(0);
      character.move(direction);
      character.motionCallback = () {
        chainCharacterMovement(character, directions, callback);
      };
    }
  }
  
  Character addCharacter(
      int spriteId, int pictureId,
      int posX, int posY, int layer, int sizeX, int sizeY, bool solid) {
    Character character = new Character(
      spriteId, pictureId, posX, posY, layer, sizeX, sizeY, solid
    );
    characters.add(character);
    return character;
  }
  
  void addWarp(int spriteId, int posX, int posY, int destX, int destY) {
    map[posY][posX][LAYER_GROUND] = new WarpTile(
      true,
      new Sprite.int(spriteId, posX, posY),
      destX, destY
    );
  }
  
  void addSign(
      int spriteId, int pictureId,
      int posX, int posY, int layer, int sizeX, int sizeY, bool solid,
      String text) {
    for(int y=posY; y<posY+sizeY; y++) {
      for(int x=posX; x<posX+sizeX; x++) {
        map[y][x][layer] = new Sign(
          solid,
          new Sprite.int(spriteId, x, y),
          pictureId,
          text
        );
      }
    }
  }
  
  void addInteractableObject(
      int spriteId, int posX, int posY, int layer, int sizeX, int sizeY, bool solid,
      void handler(List<int> keyCodes)) {
    for(var y=0; y<sizeY; y++) {
      for(var x=0; x<sizeX; x++) {
        map[posY+y][posX+x][layer] = new InteractableTile(
          solid,
          new Sprite.int(
            spriteId + x + (y*Sprite.spriteSheetSize),
            posX+x, posY+y
          ),
          handler
        );
      }
    }
  }
  
  void addObject(
      int spriteId,
      int posX, int posY, int layer, int sizeX, int sizeY, bool solid) {
    for(var y=0; y<sizeY; y++) {
      for(var x=0; x<sizeX; x++) {
        map[posY+y][posX+x][layer] = new Tile(
          solid,
          new Sprite.int(
            spriteId + x + (y*Sprite.spriteSheetSize),
            posX+x, posY+y
          )
        );
      }
    }
  }
  
  bool isSolid(int x, int y) {
    for(int layer in layers) {
      if(map[y][x][layer] is Tile && map[y][x][layer].solid) {
        return true;
      }
    }
    
    for(Character character in characters) {
      if(character.mapX == x && character.mapY == y) {
        return true;
      }
    }
    
    return false;
  }
  
  bool isInteractable(int x, int y) {
    for(int layer in layers) {
      if(map[y][x][layer] is InteractableTile) {
        return true;
      }
    }
    
    for(Character character in characters) {
      if(character.mapX == x && character.mapY == y) {
        return true;
      }
    }
    
    return false;
  }
  
  void interact(int x, int y) {
    for(int layer in layers) {
      if(map[y][x][layer] is InteractableTile) {
        InteractableTile tile = map[y][x][layer] as InteractableTile;
        tile.interact();
        return;
      }
    }
    
    for(Character character in characters) {
      if(character.mapX == x && character.mapY == y) {
        character.interact();
        return;
      }
    }
  }

  void render(List<List<Tile>> renderList) {
    for(
        var y=math.max(Main.player.mapY-(viewYSize/2+1).round(), 0);
        y<Main.player.mapY+(viewYSize/2+1).round() && y<map.length;
        y++) {
      for(
          var x=math.max(Main.player.mapX-(viewXSize/2).round(), 0);
          x<Main.player.mapX+(viewXSize/2+2).round() && x<map[y].length;
          x++) {
        for(int layer in layers) {
          if(map[y][x][layer] is Tile) {
            renderList[layer].add(
              map[y][x][layer]
            );
          }
        }
      }
    }
  }
}