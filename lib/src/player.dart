library Player;

import 'dart:html';

import 'package:dart_rpg/src/character.dart';
import 'package:dart_rpg/src/choice_game_event.dart';
import 'package:dart_rpg/src/game_event.dart';
import 'package:dart_rpg/src/input_handler.dart';
import 'package:dart_rpg/src/main.dart';
import 'package:dart_rpg/src/tile.dart';
import 'package:dart_rpg/src/world.dart';

class Player extends Character implements InputHandler {
  bool inputEnabled = true;
  
  Player(int posX, int posY) : super(Tile.PLAYER + 17, 238, posX, posY, World.LAYER_PLAYER, 1, 2, true);
  
  void handleKeys(List<int> keyCodes) {
    if(!inputEnabled)
      return;
    
    if(keyCodes.contains(KeyCode.X))
      interact();
    
    if(keyCodes.contains(KeyCode.ENTER)) {
      // show start menu
      GameEvent empty = new GameEvent( (Function a) { Main.focusObject = this; } );
      new ChoiceGameEvent.custom(
          this,
          {
            "Stats": [empty],
            "Powers": [empty],
            "Items": [empty],
            "Save": [empty],
            "Exit": [empty]
          },
          15, 0,
          5, 6
        ).trigger();
    }
    
    for(int key in keyCodes) {
      if(keyCodes.contains(KeyCode.Z))
        curSpeed = runSpeed;
      else
        curSpeed = walkSpeed;
      
      if(keyCodes.contains(KeyCode.LEFT)) {
        move(Character.LEFT);
        return;
      }
      if(keyCodes.contains(KeyCode.RIGHT)) {
        move(Character.RIGHT);
        return;
      }
      if(keyCodes.contains(KeyCode.UP)) {
        move(Character.UP);
        return;
      }
      if(keyCodes.contains(KeyCode.DOWN)) {
        move(Character.DOWN);
        return;
      }
    }
  }
  
  void interact() {
    if(direction == Character.LEFT && Main.world.isInteractable(mapX-1, mapY)) {
      Main.world.interact(mapX-1, mapY);
    } else if(direction == Character.RIGHT && Main.world.isInteractable(mapX+1, mapY)) {
      Main.world.interact(mapX+1, mapY);
    } else if(direction == Character.UP && Main.world.isInteractable(mapX, mapY-1)) {
      Main.world.interact(mapX, mapY-1);
    } else if(direction == Character.DOWN && Main.world.isInteractable(mapX, mapY+1)) {
      Main.world.interact(mapX, mapY+1);
    }
  }
}