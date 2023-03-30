package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class MapNamePanel extends MovieClip{
		private var mapPanel:MapNamePanel; //the movieclip is stored here
		private var mapString:String; //the text displayed on the panel (name of the map)
		
		public function MapNamePanel(fileList, panelNumber, preGameScreen):void{
			mapPanel = this; //the movieclip is stored
			mapPanel.x = -275; //the x and y positions are set
			mapPanel.y = -10 + (panelNumber * 105); //see above
			mapString = fileList[panelNumber].name; //the map string is set
			if(Main.selectedMap == mapString){ //if the map on this panel is selected
				mapPanel.selectedMap.visible = true; //then a check mark is shown on it
			}else{ //otherwise it is hidden
				mapPanel.selectedMap.visible = false; //see above
			}
			mapPanel.mapName.text = mapString; //the text on the panel is set to the map string
			preGameScreen.changeMap.mapPanelScreen.addChild(mapPanel); //the movieclip is added to the display list as a child of mapPanelScreen
			
			mapPanel.addEventListener(Event.ENTER_FRAME, updateInfo); //appropiate event listeners are added
			mapPanel.addEventListener(MouseEvent.MOUSE_OVER, hoverOver); //see above
			mapPanel.addEventListener(MouseEvent.MOUSE_OUT, hoverOut); //see above
			mapPanel.addEventListener(MouseEvent.CLICK, clicked); //see above
		}
		
		private function updateInfo(e:Event):void{ //the text of the panel is set to map string in case the frame changes
			mapPanel.mapName.text = mapString; //see above
		}
		
		private function hoverOver(e:MouseEvent):void{ //indicates that the panel is being hovered over
			mapPanel.gotoAndStop(2); //see above
		}

		private function hoverOut(e:MouseEvent):void{ //reverses the effect of hovering
			mapPanel.gotoAndStop(1); //see above
		}
		
		private function clicked(e:MouseEvent):void{ 
			for(var i:Number = 0; i < Main.mapList.length; i++){ //hides all other check marks on other panels
				Main.mapList[i].selectedMap.visible = false;
			}
			mapPanel.selectedMap.visible = true; //shows the check mark on this panel to indicate it is selected
			Main.selectedMap = mapString; //the selected map is changed to the map string of this panel
		}
		
		public function kill():void{ //gets rid of the panel if needed
			mapPanel.parent.removeChild(mapPanel); //removes it from the display list
			Main.mapList.removeAt(Main.mapList.indexOf(mapPanel)); //removes it from the array
		}

	}
	
}
