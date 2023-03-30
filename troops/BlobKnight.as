package troops{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;
	import fl.motion.easing.Back;
	import flash.utils.setTimeout;
	import flash.events.KeyboardEvent;
	import flash.events.Event;
	
	public class BlobKnight extends MovieClip{
private var troop:MovieClip; //stores the movieclip
		private var occupiedTile; //stores the occupied tile
		public var commander:Boolean; //indicates if the troop is a commander or not
		public var tileBlacklist:Array; //stops tiles being found multiple times in pathfinding
		
		public static const troopName:String = "Blob Knight"; //the info of the troop
		public static const troopDesc:String = "While this basic troop may be weak, it is loyal to it's commander, often getting up-front with the enemies so it's superior doesn't have to."; //see above
		public static const troopCost:Number = 25; //see above
		public static const maxMoves:Number = 2; //see above
		public static const maxHP:Number = 10; //see above
		public static const maxActions:Number = 1; //see above
		public var team:Number; //indicates what team the troop belongs to 
		public const tribe:String = "BLOBULOUS"; //indicates what tribe the troop belongs to
		
		public static const attackIcon:Number = 1; //info about the abilities of the troop
		public static const attackName:String = "Strike"; //see above
		public static const attackDesc:String = "Deals 4 damage to target enemy up to 1 tile away from this troop. \n\n\n\n\n ACTION"; //see above
		public static const utilityIcon:Number = 1; //see above
		public static const utilityName:String = "Shield"; //see above
		public static const utilityDesc:String = "Prevents the next 3 damage this troop takes next turn, at the cost of all the troops movement points \n\n [CLICK TROOP TO CONFIRM] \n 2 MOVES"; //see above
		public static const goldDrop:Number = 17; //indicates how much gold the killer of this troop gains
		
		public var troopX:Number; //basic info about the specific troop
		public var troopY:Number; //see above
		public var HP:Number; //see above
		public var moves:Number; //see above
		public var actions:Number; //see above
		public var damageProtection:Number; //see above
		
		private var shieldIndicator:MovieClip; //a movieclip to indicate how much shield the troop has
			
		public function BlobKnight(column, row, teamR, commanderR):void{
			troop = this; //puts the movieclip in the variable
			troop.mouseEnabled = false; //stops the mouse from detecting the troop
			
			commander = commanderR; //sets information about the troop
			team = teamR //see above
			HP = maxHP; //see above
			moves = maxMoves; //see above
			actions = maxActions; //see above
			damageProtection = 0; //see above
			
			if(team == 1){ //changes the color of the shield indicator based on the team of the troop
				shieldIndicator = new ShieldIndicator1(); //see above
			}else{ //see above
				shieldIndicator = new ShieldIndicator2(); //see above
			}
			shieldIndicator.mouseEnabled = false; //stops the mouse from detecting the shield
			shieldIndicator.visible = false; //hides the shield
			
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
		
		public function strike(column, row):void{ //activates when the player is using this ability and select a target
			actions -=1; //decreases the actions of the troop
			Main.tileCoords.forEach(findTile); //finds the specified tile
 
			function findTile(element, index, array):void{ 
				if(element[0] == column && element[1] == row){ //when the tile is found
					Main.tileList[index].occupiedTroop.takeDamage(team, 4); //the troop in the selected tile takes 4 damage
				}
			}
		}
		
		public function shield(column, row):void{ //activates when the player is using this ability and select a target
			moves -= maxMoves; //uses all of the troops movements
			Main.tileCoords.forEach(findTile) //finds the specified tile

			function findTile(element, index, array):void{
				if(element[0] == column && element[1] == row){ //when the tile is found
					Main.tileList[index].occupiedTroop.damageProtection += 3; //the troop gains 3 shield
					shieldIndicator.visible = true; //the shield fades in above the player and shows the amount of shield the troop has
					shieldIndicator.x = troop.x - troop.width/2.30; //see above
					shieldIndicator.y = troop.y - troop.height * 1.25; //see above
					shieldIndicator.shieldAmount.text = Main.tileList[index].occupiedTroop.damageProtection; //see above
					Main.mainGame.addChild(shieldIndicator); //see above 
					shieldIndicator.gotoAndPlay(1); //see above
				}
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
				Main.activeAction = strike; //the current action is set
				Main.generalAction = "hit"; //see above
						
				tileBlacklist = []; //the blacklist is cleared
				Main.checkTiles(1, troopX, troopY, 1, this, foundTileAttack); //the pathfinding chain begins 
			}else{ //if the player cannot use the ability a warning is shown 
				Main.uiScreen.cannotUseAnimation.cannotUseText.text = "NOT ENOUGH ACTIONS"; //see above
				Main.uiScreen.cannotUseAnimation.visible = true; //see above
				Main.uiScreen.cannotUseAnimation.gotoAndPlay(1); //see above
			}
		}
		
		public function util():void{ //runs when a player chooses to start using this ability
			if(moves == maxMoves){ //if the player is able to use the ability
				Main.tileList.forEach(NewTile.defaultTile); //tile selections are reset
				occupiedTile.moveDistance = 1; //moveDistance of the selected tile is set to active (so it can be selected)
				occupiedTile.tile.gotoAndStop(3);  //the occupied tile is available for selection
				
				Main.activeAction = shield; //the current action is  set
				Main.generalAction = "utility"; //see above
			}else{ //if the player cannot use the ability a warning is shown 
				Main.uiScreen.cannotUseAnimation.cannotUseText.text = "NOT ENOUGH MOVES"; //see above
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
			if(damageProtection != 0){ //if the troop has any shield
				shieldIndicator.play(); //the shield indicator fades out
				damageProtection = 0; //and shield is set to zero
			}
		}
		
		public function takeDamage(damagersTeam, damage):void{ //is called when the troop is targetted
			if(damageProtection > 0){ //if the troop has any shield 
				damageProtection -= damage; //the shield tries to absorb the damage
				if(damageProtection <= 0){ //but if it falls below zero
					HP -= Math.abs(damageProtection); //the troop takes damage
					damageProtection = 0; //and shield is set to zero
					if(HP <= 0){ //if the troop is at 0 hp or less they are killed
						kill(damagersTeam); //see above
					}
					shieldIndicator.play(); //the shield fades out when broken
				}else{ //if the shield doesn't break it updates
					shieldIndicator.shieldAmount.text = damageProtection; //see above
				}
			}else{ //if the troop has no shield
				HP -= damage; //the troop takes damage
				if(HP <= 0){ //if the troop is at 0 hp or less they are killed
					kill(damagersTeam); //see above
				}
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
			Main.mainGame.removeChild(troop); //removes the troop from the display list
			if(team == 1){ //removes the troop from it's list
				Main.playerOneList.removeAt(Main.playerOneList.indexOf(troop)) //see above
			}else{ //see above
				Main.playerTwoList.removeAt(Main.playerTwoList.indexOf(troop)) //see above
			}
			
			if(!Main.gameEnd){ //if the game isn't over
				occupiedTile.occupied = false; //sets the currently occupied tiles "occupied" variable to false
				
				if(killersTeam == 1){ //gives gold to the killer of the troop
					Main.playerOneGold += goldDrop; //see above
					Main.playerOneGained += goldDrop; //see above
				}else{ //see above
					Main.playerTwoGold += goldDrop //see above
					Main.playerTwoGained += goldDrop //see above
				}
				Main.uiScreen.goldGain.goldGainText.text = "+" + goldDrop + " GOLD"; //a gold gain animation plays
				Main.uiScreen.goldGain.visible = true; //see above
				Main.uiScreen.goldGain.gotoAndPlay(1); //see above
				
				var deathAnimation:MovieClip = new DeathAnimation(); //a small death animation plays
				deathAnimation.scaleX = 0.5; //see above 
				deathAnimation.scaleY = 0.5; //see above
				deathAnimation.x = occupiedTile.tile.x - 28; //see above 
				deathAnimation.y = occupiedTile.tile.y - 60; //see above
				deathAnimation.mouseEnabled = false; //see above
				Main.mainGame.addChild(deathAnimation); //see above
				deathAnimation.addEventListener(Event.ENTER_FRAME, deathUpdate); //see above
				
				function deathUpdate(e:Event):void{
					if(deathAnimation.currentFrame == deathAnimation.totalFrames){ //if the animation is over
						Main.mainGame.removeChild(deathAnimation); //the movieclip is deleted
						deathAnimation.removeEventListener(Event.ENTER_FRAME, deathUpdate); //the event listener is removed
					}
				}
			}
		}

	}
}