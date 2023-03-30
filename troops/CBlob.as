package troops{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	import fl.motion.easing.Back;
	import flash.utils.setTimeout;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	import com.greensock.TweenMax;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	
	public class CBlob extends MovieClip{
		private var troop:MovieClip; //stores the movieclip
		private var occupiedTile; //stores the occupied tile
		public var commander:Boolean; //indicates if the troop is a commander or not
		public var tileBlacklist:Array; //stops tiles being found multiple times in pathfinding
		
		public static const troopName:String = "Blobulon"; //the info of the troop
		public static const troopDesc:String = "Leader of the Blobulous tribe, Commander Blobulon is a powerful troop that excels in training new troops for battle.";  //see above
		public static const maxMoves:Number = 3; //see above
		public static const maxHP:Number = 20; //see above
		public static const maxActions:Number = 1; //see above
		public var team:Number; //indicates what team the troop belongs to 
		public static const tribe:String = "BLOBULOUS"; //indicates what tribe the troop belongs to
		public static const tribeMinion:Class = BlobKnight; //since this troop is a commander, indicates what it's minion troop is
		
		public static const attackIcon:Number = 2; //info about the abilities of the troop
		public static const attackName:String = "Inspiring Kill"; //see above
		public static const attackDesc:String = "Deals 1 damage for each two troops you control to target enemy up to 2 tiles away from this troop. \n\n\n ACTION"; //see above
		public static const utilityIcon:Number = 2; //see above
		public static const utilityName:String = "Enlist"; //see above
		public static const utilityDesc:String = "The next troop you recruit this turn costs 10 less gold. \n\n\n\n [CLICK TROOP TO CONFIRM] \n ACTION"; //see above
		
		public var troopX:Number; //basic info about the specific troop
		public var troopY:Number; //see above
		public var HP:Number; //see above
		public var moves:Number; //see above
		public var actions:Number; //see above
		
		public var enlistedThisTurn:Boolean; //an ability-specific variable, checks if the enlist ability haz been used on the turn
			
		public function CBlob(column, row, teamR, commanderR):void{
			troop = this; //puts the movieclip in the variable
			troop.mouseEnabled = false; //stops the mouse from detecting the troop
			
			commander = commanderR; //sets information about the troop
			team = teamR //see above
			HP = maxHP; //see above
			moves = maxMoves; //see above
			actions = maxActions; //see above
			enlistedThisTurn = false; //see above
			
			occupyTile(column, row); //deploys the troop in the specified location
			
			troop.gotoAndStop(team); //changes the default look of the troop based on the team
			Main.mainGame.addChild(troop); //adds the troop to the display list
			Main._stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown); //adds the appropriate event listener
		}
		
		public function occupyTile(column, row):void{ //moves the troop 
			Main.tileCoords.forEach(findTile) //loops through all tiles and runs findTile()
			
			function findTile(element, index, array):void{ 
				if(element[0] == column && element[1] == row){ //if the tile is the one the main function is looking for 
					if(occupiedTile != null){ //if this tile is already occcupied
						occupiedTile.occupied = false; //the occupied variable of the previously occupied tile is set to false
					}
					occupiedTile = Main.tileList[index]; //the new occupied tile is set and variables are updates
					occupiedTile.occupied = true; //see above
					occupiedTile.occupiedTroop = troop; //see above
					
					troop.x = occupiedTile.tile.x + 52.4; //changes the x and y of the troop 
					troop.y = occupiedTile.tile.y + 12.1; //see above
					troopX = occupiedTile.column; //changes the coordinates of the troop
					troopY = occupiedTile.row; //see above
				}
			}
		}
		
		public function inspiredStrike(column, row):void{ //activates when the player is using this ability and select a target
			actions -=1; //decreases the actions of the troop
			Main.tileCoords.forEach(findTile); //finds the specified tile

			function findTile(element, index, array):void{
				if(element[0] == column && element[1] == row){ //when the tile is found
					var damage; //a damage variable is made
					if(team == 1){ //damage is set based on the amount of troops you control
						damage = Math.ceil(Main.playerOneList.length/2); //see above
					}else{ //see above
						damage = Math.ceil(Main.playerTwoList.length/2); //see above
					}
					
					if(damage > 0){ //if the damage is non-zero
						Main.tileList[index].occupiedTroop.takeDamage(team, damage); //the troop on the tile takes damage
					}
				}
			}
		}	

		public function enlist(column, row):void{ //activates when the player uses enlist and selects a target
			actions -=1; //decreases the actions of the troop
			enlistedThisTurn = true; //sets enlistedThisTurn to true
			
			if(team == 1){ //increases the discount for the player
				Main.playerOneDiscount += 10; //see above
			}else{ //see above
				Main.playerTwoDiscount += 10; //see above
			}
		}
		
		public function foundTileMovement(maxMoves, trueMax, troop, foundFunction, element, index):void{ //runs when the pathfinding action is set to this and a tile is found
			tileBlacklist.push([element[0], element[1], maxMoves]); //adds the tile to the blacklist
			if(element[0] != troop.troopX || element[1] != troop.troopY){ //if the tile isn't the original tile
				Main.tileList[index].moveDistance = trueMax - maxMoves + 1; //the move distance is updated
				Main.tileList[index].tile.gotoAndStop(3); //the tile frame is set as selectable
				Main.tileList[index].reCheck = true; //the ability to check tiles surrounding this is set to true if it is not occupied
				if(Main.tileList[index].occupied == true){ //see above
					Main.tileList[index].tile.gotoAndStop(5); //see above
					Main.tileList[index].reCheck = false; //see above
				}else if(maxMoves > 1){ //if there is more than one move available left then surrounding tiles are checked
					Main.checkTiles(maxMoves - 1, element[0], element[1], trueMax, this, foundFunction); //see above
				}
			}
		}		
		
		public function foundTileAttack(maxMoves, trueMax, troop, foundFunction, element, index):void{ //runs when the pathfinding action is set to this and a tile is found
			tileBlacklist.push([element[0], element[1], maxMoves]); //adds the tile to the blacklist
			if(element[0] != troop.troopX || element[1] != troop.troopY){ //if the tile isn't the original tile
				Main.tileList[index].moveDistance = trueMax - maxMoves + 1; //the move distance is updated
				Main.tileList[index].tile.gotoAndStop(3); //the tile frame is set as selectable
				Main.tileList[index].reCheck = false; //the ability to check tiles surrounding this is set to true if it is not occupied
				if(Main.tileList[index].occupied == false){ //see above
					Main.tileList[index].tile.gotoAndStop(5); //see above
					Main.tileList[index].reCheck = true; //see above
					if(maxMoves > 1){ //if there is more than one move available left then surrounding tiles are checked
						Main.checkTiles(maxMoves - 1, element[0], element[1], trueMax, this, foundFunction); //see above
					}
				}
			}
		}
		
		public function move():void{ //runs when a player chooses to start using this ability
			if(moves > 0){ //if the player is able to use the ability
				Main.tileList.forEach(NewTile.defaultTile); //tile selections are reset
				Main.activeAction = occupyTile; //the current action is set
				Main.generalAction = "move"; //see above
					
				tileBlacklist = []; //the blacklist is cleared
				Main.checkTiles(moves, troopX, troopY, moves, this, foundTileMovement); //the pathfinding chain begins 
			}else{ //if the player cannot use the ability a warning is shown
				Main.uiScreen.cannotUseAnimation.cannotUseText.text = "NOT ENOUGH MOVES"; //see above
				Main.uiScreen.cannotUseAnimation.visible = true; //see above
				Main.uiScreen.cannotUseAnimation.gotoAndPlay(1); //see above
			}
		}
		
		public function atk():void{ //runs when a player chooses to start using this ability
			if(actions > 0){ //if the player is able to use the ability
				Main.tileList.forEach(NewTile.defaultTile); //tile selections are reset
				Main.activeAction = inspiredStrike; //the current action is set
				Main.generalAction = "hit"; //see above
						
				tileBlacklist = []; //the blacklist is cleared
				Main.checkTiles(2, troopX, troopY, 2, this, foundTileAttack); //the pathfinding chain begins 
			}else{ //if the player cannot use the ability a warning is shown
				Main.uiScreen.cannotUseAnimation.cannotUseText.text = "NOT ENOUGH ACTIONS"; //see above
				Main.uiScreen.cannotUseAnimation.visible = true; //see above
				Main.uiScreen.cannotUseAnimation.gotoAndPlay(1); //see above
			}
		}
		
		public function util():void{ //runs when a player chooses to start using this ability
			if(actions > 0){ //if the player is able to use the ability
				Main.tileList.forEach(NewTile.defaultTile); //tile selections are reset
				occupiedTile.moveDistance = 1; //moveDistance of the selected tile is set to active (so it can be selected)
				occupiedTile.tile.gotoAndStop(3); //the occupied tile is available for selection
				
				Main.activeAction = enlist; //the current action is  set
				Main.generalAction = "utility"; //see above
			}else{ //if the player cannot use the ability a warning is shown
				Main.uiScreen.cannotUseAnimation.cannotUseText.text = "NOT ENOUGH ACTIONS";
				Main.uiScreen.cannotUseAnimation.visible = true; //see above
				Main.uiScreen.cannotUseAnimation.gotoAndPlay(1); //see above
			}
		}
		
		private function keyDown(e:KeyboardEvent):void{
			if(e.keyCode == 49 && Main.selectedTroop == this){ //if 1 is pressed and this troop is selected
				move(); //ability preparations run
			}else if(e.keyCode == 50 && Main.selectedTroop == this){ //if 2 is pressed and this troop is selected
				atk(); //ability preparations run
			}else if(e.keyCode == 51 && Main.selectedTroop == this && occupiedTile.tileInfo.can_utility){ //if 3 is pressed and this troop is selected
				util(); //ability preparations run
			}
		}		
		
		public function newTurn():void{ //activates at the beginning of the players turn
			moves = maxMoves; //resets the troops moves and actions 
			actions = maxActions; //see above
			if(enlistedThisTurn){ //if enlist has been used the discounts are reset
				if(team == 1){ //see above
					Main.playerOneDiscount = 0; //see above
				}else{ //see above
					Main.playerTwoDiscount = 0; //see above
				}
			}
			enlistedThisTurn = false; //the variable is reset
		}
		
		public function takeDamage(damagersTeam, damage):void{ //is called when the troop is targetted
			HP -= damage; //the troop takes damage
			if(HP <= 0){ //if the troop is at 0 hp or less they are killed
				kill(damagersTeam); //see above
			}
			var damageIndicator:MovieClip = new IndicateDamage(); //small text pops up and indicates damage, then fades away
			damageIndicator.x = troop.x - troop.width/1.25; //see above
			damageIndicator.y = troop.y - troop.height; //see above
			if(team == 1){ //see above
				damageIndicator.indicatorText.textColor = 0x3870c9; //see above 
			}else{ //see above
				damageIndicator.indicatorText.textColor = 0xc43b25; //see above
			} 
			damageIndicator.indicatorText.text = "-" + String(damage); //see above
			damageIndicator.mouseEnabled = false;
			Main.mainGame.addChild(damageIndicator); //see above
			damageIndicator.addEventListener(Event.ENTER_FRAME, indicatorUpdate); //see above
			
			function indicatorUpdate(e:Event):void{
				if(damageIndicator.currentFrame == damageIndicator.totalFrames){ //when the damage indicator animation is over it is deleted
					Main.mainGame.removeChild(damageIndicator); //see above
					damageIndicator.removeEventListener(Event.ENTER_FRAME, indicatorUpdate); //see above
				}
			}
		}
		
		public function kill(killersTeam):void{ //deletes the troop
			occupiedTile.occupied = false; //sets the currently occupied tiles "occupied" variable to false//sets the currently occupied tiles "occupied" variable to false
			Main.mainGame.removeChild(troop); //removes the troop from the display list
			if(team == 1){ //removes the troop from it's list
				Main.playerOneList.removeAt(Main.playerOneList.indexOf(troop)) //see above
			}else{ //see above
				Main.playerTwoList.removeAt(Main.playerTwoList.indexOf(troop)) //see above
			}
			
			if(commander){ //if the troop is a commander (which it always is)
				Main.gameEnd = true; //the game is over
				var winner:Number; //a variable is made to indicate which player one
				Main.uiScreen.gameEndScreen.winningPanel.alpha = 1; //the winner is determined the winning panel fades to their color
				if(team == 1){ //see above
					winner = 2; //see above
					TweenMax.to(Main.uiScreen.gameEndScreen.winningPanel, 1.5, {tint:0xaf0909, delay:0.5}); //see above
					Main.uiScreen.gameEndScreen.p1Banner.gotoAndStop(2); //see above
					Main.uiScreen.gameEndScreen.p2Banner.gotoAndStop(1); //see above
				}else{ //see above
					winner = 1; //see above
					TweenMax.to(Main.uiScreen.gameEndScreen.winningPanel, 1.5, {tint:0x2581c4, delay:0.5}); //see above
					Main.uiScreen.gameEndScreen.p1Banner.gotoAndStop(1); //see above
					Main.uiScreen.gameEndScreen.p2Banner.gotoAndStop(2); //see above
				}
				Main.uiScreen.gameEndScreen.gameWinnerText.text = "PLAYER " + winner + " WINS!" //winner text and post game stats are shown
				Main.uiScreen.gameEndScreen.p1Info.tribeBar.text = Main.playerOneCommander.tribe; //see above
				Main.uiScreen.gameEndScreen.p2Info.tribeBar.text = Main.playerTwoCommander.tribe; //see above
				Main.uiScreen.gameEndScreen.p1Info.enlistedBar.text = "ENLISTED: " + Main.playerOneEnlisted; //see above
				Main.uiScreen.gameEndScreen.p2Info.enlistedBar.text = "ENLISTED: " + Main.playerTwoEnlisted; //see above
				Main.uiScreen.gameEndScreen.p1Info.goldSpentBar.text = "GOLD SPENT: " + Main.playerOneSpent; //see above
				Main.uiScreen.gameEndScreen.p2Info.goldSpentBar.text = "GOLD SPENT: " + Main.playerTwoSpent; //see above
				Main.uiScreen.gameEndScreen.p1Info.fundsRecievedBar.text = "FUNDS RECIEVED: " + Main.playerOneGained; //see above
				Main.uiScreen.gameEndScreen.p2Info.fundsRecievedBar.text = "FUNDS RECIEVED: " + Main.playerTwoGained; //see above
				Main.uiScreen.gameEndScreen.visible = true; //the end game screen fades in
				Main.uiScreen.gameEndScreen.gotoAndPlay(1); //see above
				Main.uiScreen.gameEndScreen.p1Info.gotoAndPlay(1); //see above 
				Main.uiScreen.gameEndScreen.p2Info.gotoAndPlay(1); //see above
			}
		}

	}
}