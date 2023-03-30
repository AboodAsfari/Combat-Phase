package  {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import com.greensock.TweenMax;
	
	public class RecruitInfoPanel extends MovieClip{
		private var panel:MovieClip; //stores the movieclip
		private var panelInfo:Object; //stores the info of thee panel
		private var parentSpawner:Object; //a reference to the spawner that made this pane
		
		public function RecruitInfoPanel(info, panelNumber, spawnerID):void{
			panel = this; //sets panel to the movieclip
			panelInfo = info; //sets panel info
			parentSpawner = Main.tileList[spawnerID - 1]; //finds the parent spawner
			panel.x = -(panel.width/2) + Main.uiScreen.recruitPanelUI.recruitPanel.width/2; //sets the x and y of the panel
			panel.y = -185 + ((panel.height + 10) * panelNumber) + Main.uiScreen.recruitPanelUI.recruitPanel.height/2; //see above
			
			panel.recruitName.mouseEnabled = false;	//disables the text elements of the panel so you can hover on the panel		
			panel.recruitInfo.mouseEnabled = false;	//see above
			panel.recruitCost.mouseEnabled = false; //see above
			if(Main.playersTurn == 1){ //changes the border of the panel depending on the players turn
				TweenMax.to(panel.colorChange, 0, {tint:0x3870c9}); //see above
			}else{ //see above
				TweenMax.to(panel.colorChange, 0, {tint:0xc43b25}); //see above
			}
			
			Main.uiScreen.recruitPanelUI.recruitPanel.addChild(panel); //adds the panel to the display list
			panel.addEventListener(Event.ENTER_FRAME, hoverCheck); //adds the appropriate event listeners 
			panel.addEventListener(MouseEvent.CLICK, panelClicked); //see above
		}
		
		private function hoverCheck(e:Event):void{ 
			if(panel.hitTestPoint(Main._stage.mouseX, Main._stage.mouseY, true)){ //if hovering changes the frame
				panel.gotoAndStop(2); //see above
			}else{ //if not hovering reverts to original
				panel.gotoAndStop(1); //see above
			}
			
			panel.recruitName.text = panelInfo.troopName; //sets the info in the panel
			panel.recruitInfo.text = String(panelInfo.maxHP) + " HP - " + String(panelInfo.maxMoves) + " MOVES -"; //see above
			if(Main.playersTurn == 1){
				panel.recruitCost.text = String(panelInfo.troopCost - Main.playerOneDiscount); //see above
			}else{
				panel.recruitCost.text = String(panelInfo.troopCost - Main.playerTwoDiscount); //see above
			}
			//panel.recruitCost.text = String(panelInfo.troopCost); //see above
			panel.attackIcon.gotoAndStop(panelInfo.attackIcon); //see above
			panel.utilityIcon.gotoAndStop(panelInfo.utilityIcon); //see above
		}
		
		private function panelClicked(e:MouseEvent):void{ //when clicked
			if(Main.playersTurn == 1){ //if it is player one's turn
				if(panelInfo.troopCost - Main.playerOneDiscount <= Main.playerOneGold){ //if the player can afford it
					Main.playerOneGold -= (panelInfo.troopCost - Main.playerOneDiscount); //the money is taken away
					Main.playerOneSpent += (panelInfo.troopCost - Main.playerOneDiscount); //and the gold spent stat and troops recruited is updates
					Main.playerOneEnlisted ++; //see above
					Main.uiScreen.goldGain.goldGainText.text = "-" + (panelInfo.troopCost - Main.playerOneDiscount) + " GOLD"; //transaction animation plays
					Main.uiScreen.goldGain.visible = true; //see above
					Main.uiScreen.goldGain.gotoAndPlay(1); //see above
					Main.playerOneDiscount -= panelInfo.troopCost; //the player discount decreases and is set to zero if it is negative
					if(Main.playerOneDiscount < 0){  //see above
						Main.playerOneDiscount = 0; //see above
					}
					Main.playerOneList.push(new panelInfo(parentSpawner.column, parentSpawner.row, 1, false)); //the new troop is created
					NewTile.resetSelections(); //selections are reser
				}else{ //if the player cannot afford the troop a warning is shown
					Main.uiScreen.cannotUseAnimation.cannotUseText.text = "NEED " + String((panelInfo.troopCost - Main.playerOneDiscount) - Main.playerOneGold) + " MORE GOLD"; //see above
					Main.uiScreen.cannotUseAnimation.visible = true; //see above
					Main.uiScreen.cannotUseAnimation.gotoAndPlay(1); //see above
				}
			}else{ //the same occurs but for player two 
				if(panelInfo.troopCost - Main.playerTwoDiscount <= Main.playerTwoGold){ //see above
					Main.playerTwoGold -= (panelInfo.troopCost - Main.playerTwoDiscount); //see above
					Main.playerTwoSpent += (panelInfo.troopCost - Main.playerTwoDiscount); //see above
					Main.playerTwoEnlisted ++; //see above
					Main.uiScreen.goldGain.goldGainText.text = "-" + (panelInfo.troopCost - Main.playerTwoDiscount) + " GOLD"; //see above
					Main.uiScreen.goldGain.visible = true; //see above
					Main.uiScreen.goldGain.gotoAndPlay(1); //see above
					Main.playerTwoDiscount -= panelInfo.troopCost; //see above
					if(Main.playerTwoDiscount < 0){ //see above
						Main.playerTwoDiscount = 0; //see above
					}
					Main.playerTwoList.push(new panelInfo(parentSpawner.column, parentSpawner.row, 2, false)); //see above
					NewTile.resetSelections(); //see above
				}else{
					Main.uiScreen.cannotUseAnimation.cannotUseText.text = "NEED " + String((panelInfo.troopCost - Main.playerTwoDiscount) - Main.playerTwoGold) + " MORE GOLD"; //see above
					Main.uiScreen.cannotUseAnimation.visible = true; //see above
					Main.uiScreen.cannotUseAnimation.gotoAndPlay(1); //see above
				}
			}
			
		}
		
		public function kill():void{ //deletes the panel
			panel.removeEventListener(Event.ENTER_FRAME, hoverCheck); //removes event listeners
			panel.addEventListener(MouseEvent.CLICK, panelClicked); //see above
			Main.uiScreen.recruitPanelUI.recruitPanel.removeChild(panel); //removes the panel from the display list
			Main.troopBuy.removeAt(Main.troopBuy.indexOf(panel)) //removes the panel from the panel array
		}

	}
}
