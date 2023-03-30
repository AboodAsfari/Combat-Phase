package  {
	import flash.display.Stage;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import troops.*;
	import com.greensock.TweenMax;
	import flash.net.URLLoaderDataFormat;
	import flash.display.Loader;

	public class Main{
		public static var _stage:Stage; //a reference for the stage
		public static var uiScreen:MovieClip; //a movieclip that contains all ui related objects
		public static var mainGame:MovieClip; //a movieclip that contains all game related objects

		public static var selectedMap:String; //the name of the selected map
		public static var playerOneCommander; //the selected commander of each player
		public static var playerTwoCommander; //see above
		
		public static var sceneTransition:Boolean = false; //indicates if a transitional continuation should play
		
		public static var tileList:Array; //an array to store all the tiles in the game
		public static var tileCoords:Array; //an array which stores the coordinates of the tiles
		public static var mapList:Array = []; //a list of all available maps
		
		public static var playerOneList:Array; //an array to store player one's troops
		public static var playerOneGold:Number; //stores player one's gold
		public static var playerOneDiscount:Number; //stores the discount player one gets
		public static var playerOneEnlisted:Number; //used for end of game summary
		public static var playerOneSpent:Number; //see above
		public static var playerOneGained:Number; //see above
		
		public static var playerTwoList:Array; //see above, identical variables but for player two
		public static var playerTwoGold:Number; //see above
		public static var playerTwoDiscount:Number; //see above
		public static var playerTwoEnlisted:Number; //see above
		public static var playerTwoSpent:Number; //see above
		public static var playerTwoGained:Number; //see above
		
		static var troopBuy:Array; //an array of the objects you can buy 
		static var troopCatalog:Array = [BlobKnight]; //an array of all troops available for purchase
		public static var goldAllowance:Number = 10; //the amount of gold players get at the start of their turn
		
		public static var turn:Number; //the overall turn of the game
		public static var playersTurn:Number; //indicates who's turn it is
		public static var gameEnd:Boolean; //indicates if the game is over or not

		private static var tileData:Object; //the data of all tiles in the game, to be read from a json file
		private static var mapData:Array; //the data of the current map
		private static var mapMiddleX:Number; //the x and y to center the map
		private static var mapMiddleY:Number; //see above
		static var navMode:Boolean; //indicates if the map is being moved or not
		public static var teamColoredClips:Array; //a list of the clips that are going to change colors depending on the players turn
		
		public static var selectedTroop:Object; //the currently selected troop
		public static var generalAction:String; //the name of the general action being taken. e.g move, hit
		public static var activeAction:Function; //the function of the current action
		static var selectedTile:Number; //the id of the selected tile
		
		public static function setup(stageR, mainGameR, uiScreenR):void{			
			_stage = stageR; //sets the three main variables to the provided paramaters
			uiScreen = uiScreenR; //see above
			mainGame = mainGameR; //see above
			teamColoredClips = [uiScreen.endTurnButton, uiScreen.recruitPanelUI.recruitPanel, uiScreen.infoBar, uiScreen, uiScreen.troopUI.selectedTroopBar, uiScreen.troopUI.tooltipPanel, uiScreen.troopUI.attackIcon, uiScreen.troopUI.utilityIcon, uiScreen.troopUI.moveIcon];
			
			if(sceneTransition){ //checks if the game is starting from a transition
				_stage.addEventListener(Event.ENTER_FRAME, fadeChecker); //adds a listener to check when the transition animation is over
				uiScreen.gameFade.visible = true; //shows the transition screen
				uiScreen.gameFade.gotoAndPlay(17); //starts the continuation animation
				function fadeChecker(e:Event):void{
					sceneTransition = false; //sets sceneTransition to false
					if(uiScreen.gameFade.currentFrame == 44){ //checks if the animation is over
						uiScreen.gameFade.visible = false; //hides the transition screen
						_stage.removeEventListener(Event.ENTER_FRAME, fadeChecker); //removes the event listener
					}
				}
			}else{ //if the game is not starting from a transition then the transition screen is hidden
				uiScreen.gameFade.visible = false; //see above
			}
			
			var loader:URLLoader = new URLLoader(); //sets up a loader and request to get tile data
			var request:URLRequest = new URLRequest(); //see above
			request.url = "tiles.json"; //see above
			loader.addEventListener(Event.COMPLETE, onLoaderComplete); //adds a listener for when the data loads from the json 
			loader.load(request); //loads the data		
			
			function onLoaderComplete(e:Event):void {
				var loader:URLLoader = URLLoader(e.target);
				tileData = JSON.parse(loader.data); //puts the data in a variable
				newMap(selectedMap); //generates the selected map
			
				_stage.addEventListener(Event.ENTER_FRAME, updateGame); //adds the main game listeners
				_stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown); //see above
				_stage.addEventListener(KeyboardEvent.KEY_UP, keyUp); //see above
			}
				
			tileList = []; //clears all the game variables in case it is loading up from a previous game
			tileCoords = []; //see above
			selectedTroop = null; //see above
			generalAction = "none"; //see above
			activeAction = null; //see above
			navMode = false; //see above
			playerOneList = []; //see above
			playerTwoList = []; //see above
			troopBuy = []; //see above
			selectedTile = 0; //see above
			turn = 1; //see above
			playersTurn = 1; //see above
			playerOneGold = goldAllowance; //see above
			playerTwoGold = 0; //see above
			playerOneDiscount = 0; //see above
			playerTwoDiscount = 0; //see above
			playerOneEnlisted = 0; //see above
			playerOneSpent = 0; //see above
			playerOneGained = goldAllowance; //see above
			playerTwoEnlisted = 0; //see above
			playerTwoSpent = 0; //see above
			playerTwoGained = 0; //see above
			gameEnd = false; //see above
			
			for(var i:Number = 0; i < teamColoredClips.length; i++){ //colors clips to blue as to show it is player ones turn
				TweenMax.to(Main.teamColoredClips[i].colorChange, 0, {tint:0x3870c9}); //see above
			}
			
			uiScreen.goldGain.visible = false; //hides all additional ui elements
			uiScreen.troopUI.visible = false; //see above
			uiScreen.recruitPanelUI.visible = false; //see above 
			uiScreen.gameEndScreen.visible = false; //see above
			uiScreen.cannotUseAnimation.visible = false; //see above
		}
		
		private static function newMap(mapName):void{ //generates a new map
			var loader:URLLoader = new URLLoader(); //loads the map layour from a csv file
			loader.addEventListener(Event.COMPLETE, dataLoaded); //see above
			var request:URLRequest = new URLRequest("maps/" + mapName + "/map.csv"); //see above
			loader.load(request); //see above
			
			function dataLoaded(e:Event):void {
				mapData = loader.data.split(","); //formats the csv file into an array
				var realCounter:Number = 0; //a counter used in the loop to show tile IDs (as to not count empty tiles)
				var row:Number = 1; //the row and column of the tile
				var column:Number = 0; //see above
				for(var i:Number = 0; i < mapData.length; i++){
					if(mapData[i] == 1){ //if the id provided is 1, then a new row is made
						row++;
						column = 0;
					}else if(mapData[i] == 2){ //if the id provided is 2, then an empty tile is placed
						column++;
					}else{ //otherwise an actual tile is made 
						realCounter ++; 
						column++;
						for(var b:Number = 1; b<=tileData.tiles.length;b++){ //loops through all tile data to find the data of the specified tile
							if(tileData.tiles[b-1].tile_id == mapData[i]){ //when the loop finds the data
								var tileInfo:Object = tileData.tiles[b-1]; //an object is made storing the info for the specific tile
								tileList.push(new NewTile(column, row, tileInfo, realCounter)); //the position, info, and unique id of the tile are provided to the new tile made
								tileCoords.push([column, row]); //the coordinates are added in an array to the tileCoords array
								break; //the loop is stopped
							}
						}
					}
					
					if(i == mapData.length-1){ //if the loop is over, then the map layout is generated and the second phase of map generation begins												
						var loaderTwo:URLLoader = new URLLoader(); //the second map info file is loaded
						var request:URLRequest = new URLRequest(); //see above
						request.url = "maps/" + mapName + "/mapInfo.json"; //see above
						loaderTwo.addEventListener(Event.COMPLETE, dataLoadedTwo); //see above
						loaderTwo.load(request); //see above
						
						function dataLoadedTwo(e:Event):void {
							var loaderTwo:URLLoader = URLLoader(e.target); 
							var mapInfo = JSON.parse(loaderTwo.data); //the info is stored in a variable
							mainGame.x = (762.5 - (mapInfo.centerRowLength/2 * (tileList[0].tile.width - 2))) //the map is centered
							mainGame.y = (407.5 - ((mapInfo.centerColumnLength/2 * tileList[0].tile.height) - (mapInfo.centerColumnLength/2 * 33))) //see above
							mapMiddleX = mainGame.x; //the centered x and y coordinates are saved
							mapMiddleY = mainGame.y; //see above
							
							playerOneList.push(new playerOneCommander(mapInfo.player_one_info.commander_x, mapInfo.player_one_info.commander_y, 1, true)); //commanders are spawned using the coordinated from the file
							playerTwoList.push(new playerTwoCommander(mapInfo.player_two_info.commander_x, mapInfo.player_two_info.commander_y, 2, true)); //see above
														
							for(var i:Number = 0; i < mapInfo.player_one_info.normal_troops.length; i++){ //spawns the normal troops in the specific locations from the map file
								var troopClass = playerOneCommander.tribeMinion; //see above
								playerOneList.push(new troopClass(mapInfo.player_one_info.normal_troops[i].troop_x, mapInfo.player_one_info.normal_troops[i].troop_y, 1, false)); //see above
							}
							for(var b:Number = 0; b < mapInfo.player_two_info.normal_troops.length; b++){ //see above
								var troopClassTwo = playerTwoCommander.tribeMinion; //see above
								playerTwoList.push(new troopClassTwo(mapInfo.player_two_info.normal_troops[b].troop_x, mapInfo.player_two_info.normal_troops[b].troop_y, 2, false)); //see above
							}
						}
					}
				}
			}
		}
		
		private static function updateGame(e:Event):void{ //updates the text on the ui
			uiScreen.turnText.text = "TURN " + turn; //updates what turn it is
			uiScreen.playerTurnText.text = "PLAYER " + playersTurn + "'s TURN"; //updates who's turn it is
			if(playersTurn == 1){ //displays the gold of the current player
				uiScreen.playerGoldText.text = playerOneGold + " GOLD"; //see above
			}else{ 
				uiScreen.playerGoldText.text = playerTwoGold + " GOLD"; //see above
			}
		}
		
		private static function keyDown(e:KeyboardEvent):void{ //detects when a key is down
			if(e.keyCode == 17 && !gameEnd){ //if ctrl is held down and the game is not over
				navMode = true; //then navigation mode is indicated as true
				var startingMouseX:Number = _stage.mouseX; //the original coordinates of the mouse and game are recorded
				var startingMouseY:Number = _stage.mouseY; //see above
				var startingGameX:Number = mainGame.x; //see above
				var startingGameY:Number = mainGame.y; //see above
				_stage.addEventListener(Event.ENTER_FRAME, navMap);
				function navMap(e:Event):void{
					mainGame.x = startingGameX + (_stage.mouseX - startingMouseX) //the coordinates are set to the original game coordinates plus Δmouse position
					mainGame.y = startingGameY + (_stage.mouseY - startingMouseY) //see above
					if(!navMode || gameEnd){ //if the game is over or navigation mode is false
						_stage.removeEventListener(Event.ENTER_FRAME, navMap); //the map location stops updates
					}
				}
			}else if(e.keyCode == 67 && !gameEnd){ //if c is pressed then the map is centered
				mainGame.x = mapMiddleX; //see above
				mainGame.y = mapMiddleY; //see above
			}
		}		
		
		private static function keyUp(e:KeyboardEvent):void{ 
			if(e.keyCode == 17){ //if ctrl is released then navigation mode is set to false
				navMode = false; //see above
			}
		}
	
		public static function checkTiles(maxMoves:int, pointX:int, pointY:int, trueMax:int, troop, foundFunction):void{ //pathfinding system
			var possibleMovements:Array = [[0,-1], [-1,-1], [1,0], [-1,0], [0,1], [1,1]]; //all 6 possible directions a troop can move
			
			Main.tileCoords.forEach(checkTile) //loops through each tile and runs checkTile
			
			function checkTile(element, index, array):void{
				if(Main.tileList[index].tileInfo.can_move){ //if the tile can be moved on
					if(troop.tileBlacklist.length > 0){ //if the tile blacklist exists (prevents tiles from being found twice)
						var blacklistChecker:Boolean = false; //a boolean variable is made 
						for(var b:Number = 1; b <= troop.tileBlacklist.length; b++){ //the blacklist is checked
							if(troop.tileBlacklist[b-1][0] == element[0] && troop.tileBlacklist[b-1][1] == element[1]){ //if the tile is already in the blacklist it has been found 
								if(troop.tileBlacklist[b-1][2] < maxMoves){ //if the previously found path is longer than the current one then it is updates
									for(var d:Number = 1; d <= possibleMovements.length; d++){ //if it is possible to move onto the tile
										if(element[0] == pointX + possibleMovements[d-1][0] && element[1] == pointY + possibleMovements[d-1][1]){ //see above
											if(maxMoves > 1){ //if there any moves left 
												if(Main.tileList[index].moveDistance > trueMax - maxMoves + 1){ //distance from tile is updated
													Main.tileList[index].moveDistance = trueMax - maxMoves + 1; //see above
												}
												if(Main.tileList[index].reCheck){ //checks the surroundings of the tile again
													checkTiles(maxMoves - 1, element[0], element[1], trueMax, troop, foundFunction); //see above 
												}
											}
										}
									}									
								}
								blacklistChecker = true; //the variable is set to true, meaning the tile has been already found
							}else if(b == troop.tileBlacklist.length && !blacklistChecker){ //if the loop is over and the tile has not been found
								for(var i:Number = 1; i <= possibleMovements.length; i++){ //the loop checks if it is possible to move onto the tile
									if(element[0] == pointX + possibleMovements[i-1][0] && element[1] == pointY + possibleMovements[i-1][1]){ //see above
										foundFunction(maxMoves, trueMax, troop, foundFunction, element, index); //the function provided runs when the tile is found
									}
								}
							}
						}
					}else{ //if the blacklist is empty
						for(var k:Number = 1; k <= possibleMovements.length; k++){ //the loop checks if it is possible to move onto the tile
							if(element[0] == pointX + possibleMovements[k-1][0] && element[1] == pointY + possibleMovements[k-1][1]){ //see above
								foundFunction(maxMoves, trueMax, troop, foundFunction, element, index); //the function provided runs when the tile is found
							}
						}
					}
				}
			}
		}
		
	}
}
