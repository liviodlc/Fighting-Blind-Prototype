package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;

	[SWF(width = "950", height = "480")]
	public class Main extends Sprite {

		private static const FPS:int = 30;
		private static const PERIOD:int = 1000 / FPS;

		public static const SCALE_CANVAS:Number = 2;

		private var timer:Timer;
		private var anim:Animator;

		private var fighter1:Fighter;
		private var fighter2:Fighter;
		
		[Embed(source = "img/menu.png")]
		private var Menu:Class;
		private var menu:Bitmap


		public function Main() {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);

			var canvasData:BitmapData = new BitmapData(stage.stageWidth, stage.stageHeight, false, 0x00010009);
			var canvas:Bitmap = new Bitmap(canvasData);
			anim = new Animator(canvasData);
			canvas.width *= SCALE_CANVAS;
			canvas.height *= SCALE_CANVAS;
			addChild(canvas);

			fighter1 = new Fighter(anim, stage.stageHeight / SCALE_CANVAS, stage.stageWidth / SCALE_CANVAS);
			addChild(fighter1);

			fighter2 = new Fighter(anim, stage.stageHeight / SCALE_CANVAS, stage.stageWidth / SCALE_CANVAS);
			fighter2.startOnOtherSide();
			addChild(fighter2);

			timer = new Timer(PERIOD);
			timer.addEventListener(TimerEvent.TIMER, onGameLoop, false, 0, true);
			
			menu = new Menu();
			addChild(menu);
			
			stage.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
		}
		
		private function onClick(evt:MouseEvent):void{
			menu.visible = false;
			timer.start();
		}

		private var key_Up:Boolean = false;

		private var space1:Boolean = false;
		private var jump1:Boolean = false;
		private var space2:Boolean = false;
		private var jump2:Boolean = false;

		private var fight1:Boolean = false;
		private var punch1:Boolean = false;
		private var fight2:Boolean = false;
		private var punch2:Boolean = false;


		private function onKeyDown(evt:KeyboardEvent):void {
			switch (evt.keyCode) {
				case 87: // W (p1)
					if (!space1)
						jump1 = true;
					space1 = true;
					break;
				case 38: //up arrow (p2)
					if (!space2)
						jump2 = true;
					space2 = true;
					break;
				case 68: // D (p1)
					fighter1.isKey_Right = true;
					break;
				case 65: // A (p1)
					fighter1.isKey_Left = true;
					break;
				case 83: // S (p1)
					fighter1.isKey_Down = true;
					break;
				case 70: // F (p1)
				case 90: // Z (p1)
					if (!fight1)
						punch1 = true;
					fight1 = true;
					break;
				case 71: // G (p1)
				case 88: // X (p1)					
					fighter1.isKey_Block = true;
					break;
				case 39: //right arrow (p2)
					fighter2.isKey_Right = true;
					break;
				case 37: //left arrow (p2)
					fighter2.isKey_Left = true;
					break;
				case 40: //down arrow (p2)
					fighter2.isKey_Down = true;
					break;
				case 188: // < (p1)
				case 75: // K (p1)
					if (!fight2)
						punch2 = true;
					fight2 = true;
					break;
				case 190: // > (p1)
				case 76: // L (p1)					
					fighter2.isKey_Block = true;
					break;
			}


		}


		private function onKeyUp(evt:KeyboardEvent):void {
			switch (evt.keyCode) {
				case 87: // W (p1)
					space1 = false;
					break;
				case 38: //up arrow (p2)
					space2 = false;
					break;
				case 68: // D (p1)
					fighter1.isKey_Right = false;
					break;
				case 65: // A (p1)
					fighter1.isKey_Left = false;
					break;
				case 83: // S (p1)
					fighter1.isKey_Down = false;
					break;
				case 70: // F (p1)
				case 90: // Z (p1)
					fight1 = false;
					break;
				case 71: // G (p1)
				case 88: // X (p1)					
					fighter1.isKey_Block = false;
					break;
				case 39: //right arrow (p2)
					fighter2.isKey_Right = false;
					break;
				case 37: //left arrow (p2)
					fighter2.isKey_Left = false;
					break;
				case 40: //down arrow (p2)
					fighter2.isKey_Down = false;
					break;
				case 188: // < (p1)
				case 75: // K (p1)
					fight2 = false;
					break;
				case 190: // > (p1)
				case 76: // L (p1)					
					fighter2.isKey_Block = false;
					break;
			}
		}


		private function onGameLoop(evt:TimerEvent):void {
			updateStates();
			updateCollisions();
			updateCanvas();
		}


		private function updateStates():void {
			if (fighter1.x > fighter2.x) {
				fighter1.faceLeft();
				fighter2.faceRight();
			} else {
				fighter1.faceRight();
				fighter2.faceLeft();
			}

			if (jump1) {
				jump1 = false;
				fighter1.jump();
			}
			fighter1.onGameLoop();

			if (jump2) {
				jump2 = false;
				fighter2.jump();
			}
			fighter2.onGameLoop();

			var punchBox1:Rectangle = null;
			var punchBox2:Rectangle = null;
			if (punch1) {
				punch1 = false;
				punchBox1 = fighter1.punch();
				if (punchBox1) {
					if (fighter2.wasHitBy(punchBox1)) {
						fighter1.punchSuccess();
					} else {
						fighter1.punchFail();
					}
				}
			}
			if (punch2) {
				punch2 = false;
				punchBox2 = fighter2.punch();
				if (punchBox2) {
					if (fighter1.wasHitBy(punchBox2)) {
						fighter2.punchSuccess();
					} else {
						fighter2.punchFail();
					}
				}
			}


//			if (punchBox1 && punchBox2 && punchBox1.intersects(punchBox2)) {
//				trace("whoa!");
//				fighter1.punchSuccess();
//				fighter2.punchSuccess();
//			}
		}


		private function updateCollisions():void {

		}


		private function updateCanvas():void {
			fighter1.finishLoop();
			fighter2.finishLoop();
			anim.draw();
		}
	}
}
