library dart_rpg.interactable;

import 'package:dart_rpg/src/main.dart';

import 'package:dart_rpg/src/game_event/game_event.dart';
import 'package:dart_rpg/src/game_event/choice_game_event.dart';
import 'package:dart_rpg/src/game_event/text_game_event.dart';

class Interactable {
  String _gameEventChain;
  int _gameEventChainOffset;
  
  static GameEvent chainGameEvents(Interactable interactable, List<GameEvent> gameEvents) {
    if(gameEvents == null || gameEvents.length == 0)
      return null;
    
    // Set each event to call the next event and update the character's
     // attached game event so they can handle input
     for(int i=1; i<gameEvents.length; i++) {
       if(gameEvents[i-1] is TextGameEvent && gameEvents[i] is ChoiceGameEvent) {
         (gameEvents[i-1] as TextGameEvent).choiceGameEvent = (gameEvents[i] as ChoiceGameEvent);
       } else {
         gameEvents[i-1].callback = () {
           //interactable.gameEvent = gameEvents[i];
           gameEvents[i].trigger(interactable);
         };
       }
     }
     
     // The last event should return focus to the player
     // and re-attach the first event to the character
     gameEvents.last.callback = () {
       Main.focusObject = Main.player;
     };
     
     return gameEvents[0];
  }
  
  void setGameEventChain(String gameEventChain, int gameEventChainOffset) {
    _gameEventChain = gameEventChain;
    _gameEventChainOffset = gameEventChainOffset;
  }
  
  String getGameEventChain() {
    return _gameEventChain;
  }
  
  int getGameEventChainOffset() {
    return _gameEventChainOffset;
  }
}