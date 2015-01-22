library Player;

import 'dart:html';

import 'package:dart_rpg/src/input_handler.dart';
import 'package:dart_rpg/src/main.dart';
import 'package:dart_rpg/src/sprite.dart';
import 'package:dart_rpg/src/tile.dart';
import 'package:dart_rpg/src/world.dart';

class Player implements InputHandler {
  static final int
    DOWN = 0,
    RIGHT = 1,
    UP = 2,
    LEFT = 3,
    walkSpeed = 4,
    runSpeed = 8,
    motionAmount = Sprite.pixelsPerSprite * Sprite.spriteScale,
    directionCooldownAmount = 4;
  
  static int 
    motionX = 0,
    motionY = 0,
    direction = DOWN,
    directionCooldown = 0,
    mapX = 8,
    mapY = 5,
    curSpeed = walkSpeed,
    x = mapX * motionAmount,
    y = mapY * motionAmount,
    motionStep = 1,
    motionSpriteOffset = 0;

  void render(List<List<Tile>> renderList) {
    renderList[World.LAYER_PLAYER].add(
      new Tile(
        true,
        new Sprite(
          Tile.PLAYER + direction + motionSpriteOffset,
          x/motionAmount, (y/motionAmount)-1
        )
      )
    );
    
    renderList[World.LAYER_PLAYER].add(
      new Tile(
        true,
        new Sprite(
          Tile.PLAYER + direction + motionSpriteOffset + Sprite.spriteSheetSize,
          x/motionAmount, y/motionAmount
        )
      )
    );
  }
  
  void handleKeys(List<int> keyCodes) {
    if(keyCodes.contains(KeyCode.X))
      interact();
    
    for(int key in keyCodes) {
      if(keyCodes.contains(KeyCode.LEFT)) {
        move(Player.LEFT);
        return;
      }
      if(keyCodes.contains(KeyCode.RIGHT)) {
        move(Player.RIGHT);
        return;
      }
      if(keyCodes.contains(KeyCode.UP)) {
        move(Player.UP);
        return;
      }
      if(keyCodes.contains(KeyCode.DOWN)) {
        move(Player.DOWN);
        return;
      }
    }
  }
  
  void interact() {
    if(direction == Player.LEFT && Main.world.isInteractable(mapX-1, mapY)) {
      Main.world.interact(mapX-1, mapY);
    } else if(direction == Player.RIGHT && Main.world.isInteractable(mapX+1, mapY)) {
      Main.world.interact(mapX+1, mapY);
    } else if(direction == Player.UP && Main.world.isInteractable(mapX, mapY-1)) {
      Main.world.interact(mapX, mapY-1);
    } else if(direction == Player.DOWN && Main.world.isInteractable(mapX, mapY+1)) {
      Main.world.interact(mapX, mapY+1);
    }
  }
  
  void move(motionDirection) {
    // only move if we're not already moving
    if(motionX == 0 && motionY == 0) {
      // allow the player to change directions without moving
      if(direction != motionDirection) {
        direction = motionDirection;
        directionCooldown = directionCooldownAmount;
        return;
      }
      
      // don't add motion until we've finished turning
      if(directionCooldown > 0)
        return;
      
      if(motionDirection == LEFT) {
        Main.world.map[mapY][mapX-1][World.LAYER_GROUND].enter();
        motionX = -motionAmount;
      } else if(motionDirection == RIGHT) {
        Main.world.map[mapY][mapX+1][World.LAYER_GROUND].enter();
        motionX = motionAmount;
      } else if(motionDirection == UP) {
        Main.world.map[mapY-1][mapX][World.LAYER_GROUND].enter();
        motionY = -motionAmount;
      } else if(motionDirection == DOWN) {
        Main.world.map[mapY+1][mapX][World.LAYER_GROUND].enter();
        motionY = motionAmount;
      }
    }
  }
  
  void tick() {
    if(directionCooldown > 0) {
      directionCooldown -= 1;
      
      // use walk cycle sprite when turning
      if(directionCooldown >= directionCooldownAmount/2) {
        motionSpriteOffset = motionStep + 3 + direction;
      } else if(directionCooldown == 0) {
        if(motionStep == 1)
          motionStep = 2;
        else if(motionStep == 2)
          motionStep = 1;
      }
      
      return;
    }
    
    // set walk cycle sprite for first half of motion
    if(
        (motionX != 0 && (motionX).abs() > motionAmount/2)
        || (motionY != 0 && (motionY).abs() > motionAmount/2)) {
      motionSpriteOffset = motionStep + 3 + direction;
    } else {
      motionSpriteOffset = 0;
    }
    
    if(motionX < 0) {
      motionX += curSpeed;
      if(!Main.world.isSolid(mapX-1, mapY)) {
        x -= curSpeed;
        
        if(motionX == 0)
          mapX -= 1;
      }
      
      // reverse walk cycle foot
      if(motionX == 0 && motionStep == 1)
        motionStep = 2;
      else if(motionX == 0 && motionStep == 2)
        motionStep = 1;
    } else if(motionX > 0) {
      motionX -= curSpeed;
      if(!Main.world.isSolid(mapX+1, mapY)) {
        x += curSpeed;
        
        if(motionX == 0)
          mapX += 1;
      }
      
      // reverse walk cycle foot
      if(motionX == 0 && motionStep == 1)
        motionStep = 2;
      else if(motionX == 0 && motionStep == 2)
        motionStep = 1;
    } else if(motionY < 0) {
      motionY += curSpeed;
      if(!Main.world.isSolid(mapX, mapY-1)) {
        y -= curSpeed;
        
        if(motionY == 0)
          mapY -= 1;
      }
      
      // reverse walk cycle foot
      if(motionY == 0 && motionStep == 1)
        motionStep = 2;
      else if(motionY == 0 && motionStep == 2)
        motionStep = 1;
    } else if(motionY > 0) {
      motionY -= curSpeed;
      if(!Main.world.isSolid(mapX, mapY+1)) {
        y += curSpeed;
        
        if(motionY == 0)
          mapY += 1;
      }
      
      // reverse walk cycle foot
      if(motionY == 0 && motionStep == 1)
        motionStep = 2;
      else if(motionY == 0 && motionStep == 2)
        motionStep = 1;
    }
  }
}