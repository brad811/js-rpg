library dart_rpg.map_editor_characters;

import 'dart:html';
import 'dart:js';

import 'package:dart_rpg/src/character.dart';
import 'package:dart_rpg/src/main.dart';
import 'package:dart_rpg/src/world.dart';

import 'package:dart_rpg/src/editor/editor.dart';
import 'package:dart_rpg/src/editor/map_editor/map_editor.dart';

import 'package:react/react.dart';

class MapEditorCharacters extends Component {
  void onInputChange(Event e) {
    Editor.enforceValueFormat(e);
    
    int i = -1;
    World.characters.forEach((String key, Character character) {
      i += 1;
      
      if(character.map != Main.world.curMap)
        return;
      
      try {
        character.mapX = Editor.getTextInputIntValue("#map_character_${i}_map_x", 0);
        character.mapY = Editor.getTextInputIntValue("#map_character_${i}_map_y", 0);
        character.layer = Editor.getSelectInputIntValue("#map_character_${i}_layer", 0);
        character.direction = Editor.getSelectInputIntValue("#map_character_${i}_direction", Character.DOWN);
        character.solid = Editor.getCheckboxInputBoolValue("#map_character_${i}_solid");
        
        character.x = character.mapX * character.motionAmount;
        character.y = character.mapY * character.motionAmount;
      } catch(e) {
        // could not update this character
        print("Error updating map character: " + e.toString());
      }
    });
    
    update();
  }

  void update() {
    setState({});
    MapEditor.updateMap();
    Editor.debounceExport();
  }

  Function goToEditCharacterFunction(int i) {
    return (MouseEvent e) {
      props['goToEditObject']('characters', i);
    };
  }

  @override
  render() {
    List<JsObject> tableRows = [
      tr({},
        td({}, "Num"),
        td({}, "Label"),
        td({}, "X"),
        td({}, "Y"),
        td({}), // move character button
        td({}, "Layer"),
        td({}, "Direction"),
        td({}, "Solid"),
        td({})
      )
    ];

    for(int i=0; i<World.characters.length; i++) {
      String key = World.characters.keys.elementAt(i);
      Character character = World.characters.values.elementAt(i);

      if(character.map != Main.world.curMap)
        continue;

      List<JsObject> layerOptions = [];
      for(int layer=0; layer<World.layers.length; layer++) {
        layerOptions.add(
          option({'value': layer}, World.layers[layer])
        );
      }

      List<String> directions = ["Down", "Right", "Up", "Left"];
      List<JsObject> directionOptions = [];
      for(int direction=0; direction<directions.length; direction++) {
        directionOptions.add(
          option({'value': direction}, directions[direction])
        );
      }

      tableRows.add(
        tr({},
          td({}, i),
          td({}, key),
          td({},
            Editor.generateInput({
              'id': 'map_character_${i}_map_x',
              'type': 'text',
              'className': 'number',
              'value': character.mapX,
              'onChange': onInputChange
            })
          ),
          td({},
            Editor.generateInput({
              'id': 'map_character_${i}_map_y',
              'type': 'text',
              'className': 'number',
              'value': character.mapY,
              'onChange': onInputChange
            })
          ),

          td({},
            // move character button
            button({
              'id': 'move_character_${i}',
              'onClick': (MouseEvent e) { props['moveInteractable'](character, '#move_character_${i}'); }
            }, span({'className': 'fa fa-crosshairs'}))
          ),

          td({},
            select({
              'id': 'map_character_${i}_layer',
              'value': character.layer,
              'onChange': onInputChange
            }, layerOptions)
          ),
          td({},
            select({
              'id': 'map_character_${i}_direction',
              'value': character.direction,
              'onChange': onInputChange
            }, directionOptions)
          ),
          td({},
            input({
              'id': 'map_character_${i}_solid',
              'type': 'checkbox',
              'checked': character.solid,
              'onChange': onInputChange
            })
          ),
          td({},
            button({'onClick': goToEditCharacterFunction(i)},
              span({'className': 'fa fa-pencil-square-o'}),
              " Edit Character"
            )
          )
        )
      );
    }

    return
      div({'id': 'map_characters_tab', 'className': 'tab'},
        div({'id': 'map_characters_container'},
          table({'className': 'editor_table'}, tbody({}, tableRows))
        )
      );
  }
}