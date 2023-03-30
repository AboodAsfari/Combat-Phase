package{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.events.MouseEvent;
	import fl.motion.easing.Back;
	
	public class NewTile{
		public var tile:MovieClip; //where the tile movieclip is stored 
		public var tileInfo:Object; //the info for the tile type
		private var specificID:Number; //the unique id for this tile
		private var frameMultiplier:Number; //used to change the default art for a tile (e.g player 1's spawner looks different to player 2's spawner)
		
		public var occupied:Boolean; //indicates if the tile is currently occupied
		public var occupiedTroop:Object; //a reference to the troop occupying the tile
		
		public var moveDistance:Number; //the distance of this tile to the selected tile, not active if at zero
		public var reCheck:Boolean; //indicates if this tile is able to check surrounding tiles again in the pathfinding system
		
		public var row:Number; //the row and column of the tile
		public var column:Number; //see above
		
		public function NewTile(columnR, rowR, tileInfoR, specificIDR):void{
			tileInfo = tileInfoR; //sets the tile info
			var selectedClass = getDefinitionByName(tileInfo.class_name); //fetches the class of the tile
			tile = new selectedClass(); //makes the tile
			
			occupied = false; //resets variables 
			moveDistance = 0 //see above
			reCheck = false; //see above
			specificID = specificIDR; //sets the unique id of the tile
			row = rowR; //sets the row and column
			column = columnR; //see above
			
			frameMultiplier = 0; //disabled frame multiplayer
			if(tileInfo.team == 2){ //if the tile is exclusive to player 2 then frameMultiplier is activated
				frameMultiplier = tile.totalFrames/2; //see above
				tile.gotoAndStop(1 + frameMultiplier) //see above
			}
			
			tile.x = (column * (tile.width - 2)) - (row * tile.width/2) //sets the x and y of the tile
			tile.y = (row * tile.height) - (row * 33); //see above
			
			Main.mainGame.addChild(tile); //adds the tile to the display list
			
			tile.addEventListener(Event.ENTER_FRAME, checkHover); //adds event listeners
			tile.addEventListener(MouseEvent.MOUSE_DOWN, click); //see above
			if(tileInfo.specialBehavior != "none"){	tile.addEventListener(MouseEvent.MOUSE_DOWN, this[tileInfo.specialBehavior]); } //adds special event listeners to a tile if it has any special behavior
		}
		
		private function checkHover(e:Event):void{ //a hover system i made as the event flash provides ran into problems with my tiles 
			if(tile.mainTile.hitTestPoint(Main._stage.mouseX, Main._stage.mouseY, true) && !Main.navMode){ //if not navigating the map and the mouse is on a coordinate of the tile
				var hoverChecker:Boolean = false; //see below
				for(var i:int = 0; i<Main.uiScreen.numChildren; i++){ //checks if theres any ui between the mouse and tile
					if(Main.uiScreen.getChildAt(i).hitTestPoint(Main._stage.mouseX, Main._stage.mouseY, true) && Main.uiScreen.getChildAt(i).visible){ //see above
						hoverChecker = true; //see above
					}else if(!hoverChecker && i + 1 == Main.uiScreen.numChildren){ //when the loop is over and no ui is overlapping
						if(tile.currentFrame != 5){ //if the current tile is not in the "unselectable" frame
							if(Main.generalAction != "none" && moveDistance > 0){ tile.gotoAndStop(4 + frameMultiplier); } //then it is being hovered over 
							else{ tile.gotoAndStop(2 + frameMultiplier); } //see above
						}
						
						Main.selectedTile = specificID; //the tile is set as selected
						Main.uiScreen.selectedTileText.text = tileInfo.tile_name //the top left tile info tile displays info about the tile and shows it's icon
						Main.uiScreen.infoBar.tileIcon.gotoAndStop(tileInfo.tile_icon + 1); //see above
						
						if(occupied){ //if the tile is occupied then the tile info panel shows info about the tile as well
							var troopType = getDefinitionByName(getQualifiedClassName(occupiedTroop)); 
							Main.uiScreen.troopInfoText.troopNameText.text = troopType.troopName; //see above
							Main.uiScreen.troopInfoText.troopHealthText.text = occupiedTroop.HP + "/" + troopType.maxHP; //see above
							Main.uiScreen.troopInfoText.movesLeftText.text = occupiedTroop.moves; //see above
						}else{ //if the tile is not occupied then question marks are placed in the troop info
							Main.uiScreen.troopInfoText.troopNameText.text = "???"; //see above
							Main.uiScreen.troopInfoText.troopHealthText..text = "??/??"; //see above
							Main.uiScreen.troopInfoText.movesLeftText.text = "?"; //see above
						}
					}
				}
			}else{ //if not hovering
				if(Main.selectedTile == specificID){ //if the tile is the selected tile that means it has been hovered off of
					Main.selectedTile = 0; //the selected tile is reset
					Main.uiScreen.selectedTileText.text = "None"; //see above
					Main.uiScreen.infoBar.tileIcon.gotoAndStop(1); //see above
					
					Main.uiScreen.troopInfoText.troopNameText.text = "???"; //see above
					Main.uiScreen.troopInfoText.troopHealthText.text = "??/??"; //see above
					Main.uiScreen.troopInfoText.movesLeftText.text = "?"; //see above
				}
				if(tile.currentFrame != 5){ //resets the frame of the tile
					if(Main.generalAction != "none" && moveDistance > 0){ tile.gotoAndStop(3 + frameMultiplier); } //see above
					else{ tile.gotoAndStop(1 + frameMultiplier); } //see above
				}
			}
		}
		
		private function click(e:MouseEvent):void{
			if(occupied && occupiedTroop.team == Main.playersTurn && (tile.currentFrame != 4 || tileInfo.specialBehavior != "none")){ //if it is possible to select a troop on this tile
				resetSelections(); //tile selections are reset
					
				Main.selectedTroop = occupiedTroop; //the troop is set to the selected troop
				if((Main.uiScreen.troopUI.visible && Main.uiScreen.troopUI.currentFrame < 7) || !Main.uiScreen.troopUI.visible){ //fades in the troop ui
					Main.uiScreen.troopUI.visible = true; //see above
					Main.uiScreen.troopUI.gotoAndPlay(1); //see above
				}else{ //see above
					Main.uiScreen.troopUI.gotoAndStop(7); //see above
				}
				
				if(Main.playersTurn == 1){ //changes the color of the move icon based on the players turn
					Main.uiScreen.troopUI.moveIcon.gotoAndStop(2); //see above
				}else{ //see above
					Main.uiScreen.troopUI.moveIcon.gotoAndStop(1); //see above
				}
				Main.uiScreen.troopUI.attackIcon.gotoAndStop(getDefinitionByName(getQualifiedClassName(occupiedTroop)).attackIcon);	//ability icons are set based on the troops abilities	
				Main.uiScreen.troopUI.utilityIcon.gotoAndStop(getDefinitionByName(getQualifiedClassName(occupiedTroop)).utilityIcon); //see above
				
				if(occupiedTroop.commander){ //sets the text of the name of the troop
					Main.uiScreen.troopUI.selectedTroopBar.troopName.text = "COMMANDER " + getDefinitionByName(getQualifiedClassName(occupiedTroop)).troopName; //see above
				}else{ //see above
					Main.uiScreen.troopUI.selectedTroopBar.troopName.text = getDefinitionByName(getQualifiedClassName(occupiedTroop)).troopName; //see above
				} 
				Main.uiScreen.troopUI.tooltipPanel.tooltipHeader.text = getDefinitionByName(getQualifiedClassName(occupiedTroop)).troopName; //tooltip text is set
				Main.uiScreen.troopUI.tooltipPanel.tooltipText.text = getDefinitionByName(getQualifiedClassName(occupiedTroop)).troopDesc; //see above			
			}else if(tile.currentFrame == 4 && tileInfo.specialBehavior == "none" ){ //if you are able to confirm selection on the tile
				Main.activeAction(column, row); //then the troop performs the action
				if(Main.activeAction == Main.selectedTroop.occupyTile){ //if the troop is moving
					occupiedTroop.moves -= moveDistance; //moves of the troop are decreased
				}
				
				Main.activeAction = null; //current action is reset
				Main.generalAction = "none"; //see above
				Main.tileList.forEach(defaultTile); //see above 
			}else if((Main.uiScreen.troopUI.selectedTroopBar.visible ||  Main.uiScreen.recruitPanelUI.recruitPanel.visible) && !occupied){ //if clicking out of a selection it is reset
				resetSelections(); //see above
			}
		}
		
		public static function resetSelections():void{	
			if(Main.uiScreen.troopUI.currentFrame < 8 && Main.uiScreen.troopUI.visible){ //fades troop ui out
				Main.uiScreen.troopUI.gotoAndPlay(7); //see above
			}
			if(Main.uiScreen.recruitPanelUI.currentFrame < 8 && Main.uiScreen.recruitPanelUI.visible){ //fades recruit panel out
				Main.uiScreen.recruitPanelUI.gotoAndPlay(7); //see above
			}
			
			var listLength = Main.troopBuy.length-1; //gets rid of all panels in the recruit panel
			for(var i:Number = 0; i <= listLength; i++){ //see above
				Main.troopBuy[listLength - i].kill(); //see above
			}
				
			Main.tileList.forEach(defaultTile); //resets current action and tiles
			Main.activeAction = null; //see above
			Main.selectedTroop = null; //see above
			Main.generalAction = "none"; //see above
		}
		
		public static function defaultTile(element, index, array):void{ //resets the state of the current tile
			Main.tileList[index].tile.gotoAndStop(1 + Main.tileList[index].frameMultiplier); //see above
			Main.tileList[index].moveDistance = 0; //see above
			Main.tileList[index].reCheck = false; //see above
		}
		
		private function spawnerBehavior(e:MouseEvent):void{ //special behavior for spawners
			if(!occupied && tileInfo.specialBehavior == "spawnerBehavior" && tileInfo.team == Main.playersTurn){ //when clicking on the spawner
				if((Main.uiScreen.recruitPanelUI.visible && Main.uiScreen.recruitPanelUI.currentFrame < 7) || !Main.uiScreen.recruitPanelUI.visible){ //fades the recruit ui in
					Main.uiScreen.recruitPanelUI.visible = true; //see above
					Main.uiScreen.recruitPanelUI.gotoAndPlay(1); //see above
				}else{ //see above
					Main.uiScreen.recruitPanelUI.gotoAndStop(7); //see above
				}
				for(var i:Number = 0; i <= Main.troopCatalog.length-1; i++){ //makes panels for troops you can buy
					Main.troopBuy.push(new RecruitInfoPanel(Main.troopCatalog[i], i, specificID)); //see above
				}
			}
		}		
		
		public function kill():void{ //gets rid of the tile
			tile.removeEventListener(Event.ENTER_FRAME, checkHover); //removes all event listeners added to the tile
			tile.removeEventListener(MouseEvent.MOUSE_DOWN, click); //see above
			if(tileInfo.specialBehavior != "none"){	tile.removeEventListener(MouseEvent.MOUSE_DOWN, this[tileInfo.specialBehavior]); } //see above
			Main.mainGame.removeChild(tile); //removes the tile from the display list
			Main.tileList.removeAt(Main.tileList.indexOf(tile)); //removes the tile from the tileList array
		}
		
	}
}
