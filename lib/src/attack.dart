library Attack;

import 'package:dart_rpg/src/battler.dart';
import 'package:dart_rpg/src/text_game_event.dart';

class Attack {
  final String name;
  final int power;
  
  TextGameEvent textGameEvent;
  
  Attack(this.name, this.power) {
    
  }
  
  void use(Battler attacker, Battler receiver, bool enemy, Function callback) {
    String text = "${attacker.name} attacked ${receiver.name} with ${this.name}!";
    if(enemy) {
      text = "Enemy ${text}";
    }
    textGameEvent = new TextGameEvent(241, text);
    textGameEvent.callback = () {
      receiver.health -= power;
      callback();
    };
    textGameEvent.trigger();
  }
}