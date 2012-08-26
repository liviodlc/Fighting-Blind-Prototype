package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.utils.getTimer;

	public class Fighter extends Sprite {

		private static const DEBUG_LIGHTS:Boolean = false;
		private static const DEBUG_HITBOX:Boolean = false;
		private static const DEBUG_REMOVE_CEILING:Boolean = false;

		private static const GRAVITY:Number = 2;
		private static const JUMP:Number = -25.5;

		private static const CRAWL_RUN:Number = 5;
		private static const GROUND_RUN:Number = 5;
		private static const AIR_RUN:Number = 2;
		private static const GROUND_SLOWDOWN:Number = 7;
		private static const CRAWL_SLOWDOWN:Number = 10;
		private static const AIR_SLOWDOWN:Number = 3;
		private static const MAX_SPEED:Number = 10;
		private static const CRAWL_MAX_SPEED:Number = 5;

		private static const WALKING_DELAY:int = 5;

		private var xSpeed:Number = 0;
		private var ySpeed:Number = 0;
		private var newX:Number = 0;
		private var newY:Number = 0;

		[Embed(source = "img/Ryu.gif")]
		private var SpriteSheet:Class;
		[Embed(source = "img/Ryu2.gif")]
		private var SpriteSheet2:Class;
		private var sheet:BitmapData;

		[Embed(source = "img/opacity_feet.png")]
		private var OpacityFeet:Class;
		private var opacFeet:BitmapData;

		[Embed(source = "img/opacity_head.png")]
		private var OpacityHead:Class;
		private var opacHead:BitmapData;

		[Embed(source = "img/opacity_punch.png")]
		private var OpacityPunch:Class;
		private var opacPunch:BitmapData;

		[Embed(source = "sound/jump.mp3")]
		private var JumpSound:Class;
		private var jumpSound:Sound;

		[Embed(source = "sound/land.mp3")]
		private var LandSound:Class;
		private var landSound:Sound;

		[Embed(source = "sound/ceiling.mp3")]
		private var CeilingSound:Class;
		private var ceilingSound:Sound;

		[Embed(source = "sound/step_left.mp3")]
		private var LeftStep:Class;
		private var leftStep:Sound;

		[Embed(source = "sound/step_right.mp3")]
		private var RightStep:Class;
		private var rightStep:Sound;

		[Embed(source = "sound/step_crawl_left.mp3")]
		private var LeftCrawlStep:Class;
		private var leftCrawlStep:Sound;

		[Embed(source = "sound/step_crawl_right.mp3")]
		private var RightCrawlStep:Class;
		private var rightCrawlStep:Sound;

		[Embed(source = "sound/punch_swing.mp3")]
		private var PunchSwing:Class;
		private var punchSwing:Sound;

		[Embed(source = "sound/punch_hit.mp3")]
		private var PunchHit:Class;
		private var punchHit:Sound;
		
		[Embed(source = "sound/punch_block.mp3")]
		private var PunchBlock:Class;
		private var punchBlock:Sound;

		public var hitbox:Rectangle;

		private var anim:Animator;

		private var isStanding:Boolean = false;
		private var isFacingLeft:Boolean = false;

		public var isKey_Right:Boolean = false;
		public var isKey_Left:Boolean = false;
		public var wasKey_Right:Boolean = false;
		public var wasKey_Left:Boolean = false;
		public var isKey_Up:Boolean = false;
		public var isKey_Down:Boolean = false;
		public var isKey_Block:Boolean = false;

		private var sw:Number;
		private var sh:Number;


		public function Fighter(anim:Animator, stageHeight:int, stageWidth:int) {
			sw = stageWidth;
			sh = stageHeight;
			this.anim = anim;
			sheet = (new SpriteSheet() as Bitmap).bitmapData;
			opacFeet = (new OpacityFeet() as Bitmap).bitmapData;
			opacHead = (new OpacityHead() as Bitmap).bitmapData;
			opacPunch = (new OpacityPunch() as Bitmap).bitmapData;
			jumpSound = new JumpSound();
			landSound = new LandSound();
			ceilingSound = new CeilingSound();
			leftStep = new LeftStep();
			rightStep = new RightStep();
			leftCrawlStep = new LeftCrawlStep();
			rightCrawlStep = new RightCrawlStep();
			punchSwing = new PunchSwing();
			punchHit = new PunchHit();
			punchBlock = new PunchBlock();
			hitbox = new Rectangle(13, 17, 45, 92);

			if (DEBUG_LIGHTS) {
				var sp:Bitmap = new Bitmap(getImage(ANIM_IDLE, POWER_FULL));
				addChild(sp);
				this.visible = true;
			} else {
				this.visible = false;
			}
		}


		public function startOnOtherSide():void {
			this.x = newX = sw - hitbox.width - hitbox.x * 2;
			sheet = (new SpriteSheet2() as Bitmap).bitmapData;
		}

		private var faceOffset:int = 0;


		public function faceRight():void {
			isFacingLeft = false;
			faceOffset = 0;
		}


		public function faceLeft():void {
			isFacingLeft = true;
		}


		public function jump():void {
			if (isStanding) {
				isStanding = false;
				ySpeed = JUMP;
				anim.spit(getImage(ANIM_JUMP), new Point(x - faceOffset, y));
			}
		}

		private var punch_delay:uint = 0;

		private static const PUNCH_DELAY_HIT:uint = 10;
		private static const PUNCH_DELAY_MISS:uint = 15;


		public function punch():Rectangle {
			if (isStanding && punch_delay == 0) {
//				anim.spit(getImage(ANIM_PUNCH), new Point(x - faceOffset, y));
				var res:Rectangle = new Rectangle(0, newY + hitbox.y, 51, 31);
				if (!isFacingLeft) {
					res.x = newX + hitbox.x + hitbox.width;
				} else {
					res.x = newX + hitbox.x - res.width;
				}
//				if(DEBUG_HITBOX){
//					var b:BitmapData = new BitmapData(res.width, res.height, true, 0x55FFFFFF);
//					anim.spit(b,res.topLeft);
//				}
				return res;
			}
			return null;
		}


		public function punchSuccess():void {
			anim.spit(getImage(ANIM_PUNCH, POWER_FULL), new Point(x - faceOffset, y));
			punch_delay = PUNCH_DELAY_HIT;
		}


		public function punchFail():void {
			//add delay for failed punches
			anim.spit(getImage(ANIM_PUNCH, POWER_LOW), new Point(x - faceOffset, y));
			punchSwing.play();
			punch_delay = PUNCH_DELAY_MISS;
		}


		public function get trueHitbox():Rectangle {
			return new Rectangle(newX + hitbox.x, newY + hitbox.y, hitbox.width, hitbox.height);
		}


		public function wasHitBy(pb:Rectangle):Boolean {
			if (DEBUG_HITBOX) {
				var b:BitmapData = new BitmapData(pb.width, pb.height, true, 0x55FF0000);
				anim.spit(b, pb.topLeft);
				b = new BitmapData(hitbox.width, hitbox.height, true, 0x550000FF);
				anim.spit(b, new Point(hitbox.x + newX, hitbox.y + newY));
			}
			if (trueHitbox.intersects(pb)) {
				if (isKey_Block) {
					anim.spit(getImage(ANIM_BLOCK, POWER_LOW), new Point(newX - faceOffset, newY));
					punchBlock.play();
				} else {
					anim.spit(getImage(ANIM_HURT, POWER_FULL), new Point(newX - faceOffset, newY));
					punchHit.play();
				}
				return true;
			} else {
//				punchSwing.play();
//				trace("miss");
//				trace(pb, trueHitbox);
				return false;
			}
		}


//		private var anim_delay:int = 0;
		private var anim_delay_right:int = 0;
		private var anim_delay_left:int = 0;
		private var footstep:Boolean = false;

		private var oldX:Number;


		public function onGameLoop():void {
			var hasMoved:Boolean = false;

			if (!isStanding) {
				ySpeed += GRAVITY;
			}

			// move right
			if (isKey_Right && !isKey_Block) {
				if (isStanding) {
//					if (xSpeed <= 0 && newX < sw - hitbox.width - hitbox.x) {
//						anim.spit(getImage(ANIM_WALK_FRONT_START), new Point(newX - faceOffset, newY));
//					}
					if (isKey_Down) {
						xSpeed += CRAWL_RUN;
					} else {
						xSpeed += GROUND_RUN;
					}
					if (anim_delay_right > 0) {
						anim_delay_right--;
					} else {
						anim_delay_right = WALKING_DELAY;
						if (punch_direction) {
							if (isKey_Down) {
								if (footstep)
									rightCrawlStep.play();
								else
									leftCrawlStep.play();
								footstep = !footstep;
							} else {
								anim.spit(getImage(ANIM_WALK_FRONT_START), new Point(newX - faceOffset, newY));
							}
						} else if (!isKey_Down) {
							anim.spit(getImage(ANIM_WALK_FRONT_END), new Point(newX - faceOffset, newY));
						}
						punch_direction = !punch_direction;
					}
				} else if (isKey_Down) {
					xSpeed += CRAWL_RUN;
					anim_delay_right = 0;
				} else {
					xSpeed += AIR_RUN;
					anim_delay_right = 0;
				}
				if (isKey_Down && xSpeed > CRAWL_MAX_SPEED)
					xSpeed = CRAWL_MAX_SPEED;
				else if (!isKey_Down && xSpeed > MAX_SPEED)
					xSpeed = MAX_SPEED;
				hasMoved = true;
			} else {
				anim_delay_right = 0;
			}

			// move left
			if (isKey_Left && !isKey_Block) {
				if (isStanding) {
//					if (xSpeed >= 0 && newX > -hitbox.x) {
//						anim.spit(getImage(ANIM_WALK_BACK_START), new Point(newX - faceOffset, newY));
//					}
					if (isKey_Down) {
						xSpeed -= CRAWL_RUN;
					} else {
						xSpeed -= GROUND_RUN;
					}

					if (anim_delay_left > 0) {
						anim_delay_left--;
					} else {
						anim_delay_left = WALKING_DELAY;
						if (punch_direction)
							if (isKey_Down) {
								if (footstep)
									rightCrawlStep.play();
								else
									leftCrawlStep.play();
								footstep = !footstep;
							} else {
								anim.spit(getImage(ANIM_WALK_BACK_START), new Point(newX - faceOffset, newY));
							} else if (!isKey_Down)
							anim.spit(getImage(ANIM_WALK_BACK_END), new Point(newX - faceOffset, newY));
						punch_direction = !punch_direction;
					}
				} else if (isKey_Down) {
					xSpeed -= CRAWL_RUN;
					anim_delay_left = 0;
				} else {
					xSpeed -= AIR_RUN;
					anim_delay_left = 0;
				}
				if (isKey_Down && xSpeed < -CRAWL_MAX_SPEED)
					xSpeed = -CRAWL_MAX_SPEED;
				else if (!isKey_Down && xSpeed < -MAX_SPEED)
					xSpeed = -MAX_SPEED;
				hasMoved = true;
			} else {
				anim_delay_left = 0;
			}

			// when not moving, slow down
			if (!hasMoved) {
				if (xSpeed > 0) {
					if (isStanding) {
						xSpeed -= GROUND_SLOWDOWN;
//						if (wasKey_Right && !isKey_Down)
//							anim.spit(getImage(ANIM_WALK_FRONT_END), new Point(newX - faceOffset + xSpeed, newY));
					} else {
						xSpeed -= AIR_SLOWDOWN;
					}
					if (xSpeed < 0)
						xSpeed = 0;
				} else if (xSpeed < 0) {
					if (isStanding) {
						xSpeed += GROUND_SLOWDOWN;
//						if (wasKey_Left && !isKey_Down)
//							anim.spit(getImage(ANIM_WALK_BACK_END), new Point(newX - faceOffset + xSpeed, newY));
					} else {
						xSpeed += AIR_SLOWDOWN;
					}
					if (xSpeed > 0)
						xSpeed = 0;
				}
			}

			newX += xSpeed;
			newY += ySpeed;

			if ((newY + hitbox.y + hitbox.height) > sh) {
				ySpeed = 0;
				newY = sh - hitbox.height - hitbox.y;
				isStanding = true;
				anim.spit(getImage(ANIM_LAND), new Point(newX - faceOffset, newY));
			} else if (newY + hitbox.y < 0 && !DEBUG_REMOVE_CEILING) {
				ySpeed = 0;
				newY = 0;
				anim.spit(getImage(ANIM_ROOF), new Point(newX - faceOffset, newY - hitbox.y));
			}

			if (newX + hitbox.x + hitbox.width > sw) {
				newX = sw - hitbox.width - hitbox.x;
				xSpeed = 0;
				if (oldX != newX)
					anim.spit(getImage(ANIM_WALK_FRONT_END), new Point(newX - faceOffset + xSpeed, newY));
			} else if (newX + hitbox.x < 0) {
				newX = -hitbox.x;
				xSpeed = 0;
				if (oldX != newX)
					anim.spit(getImage(ANIM_WALK_BACK_END), new Point(newX - faceOffset + xSpeed, newY));
			}
		}


		public function finishLoop():void {
			oldX = x;
			x = newX;
			y = newY;
			wasKey_Right = false;
			wasKey_Left = false;
			if (punch_delay > 0)
				punch_delay--;
		}


		//TEST
		public function spit():void {
			trace("spit " + getTimer());
			anim.spit(getImage(ANIM_IDLE), new Point(x - faceOffset, y));
		}

		private static const ANIM_IDLE:uint = 0x0;
		private static const ANIM_JUMP:uint = 0x1;
		private static const ANIM_LAND:uint = 0x2;
		private static const ANIM_ROOF:uint = 0x3;
		private static const ANIM_WALK_FRONT_START:uint = 0x4;
		private static const ANIM_WALK_FRONT_END:uint = 0x5;
		private static const ANIM_WALK_BACK_START:uint = 0x6;
		private static const ANIM_WALK_BACK_END:uint = 0x7;
		private static const ANIM_PUNCH:uint = 0x8;
		private static const ANIM_HURT:uint = 0x9;
		private static const ANIM_BLOCK:uint = 0xA;

		private static const POWER_LOW:uint = 0x66000000;
		private static const POWER_FULL:uint = 0xFF000000;

		private var punch_direction:Boolean = false;


		private function getImage(type:uint, power:uint = POWER_LOW):BitmapData {
			var hei:int = 110;
			var wid:int = 110;
			if (DEBUG_HITBOX) {
				if (hei < hitbox.y + hitbox.height) {
					hei = hitbox.y + hitbox.height;
				}
				if (wid < hitbox.x + hitbox.width) {
					wid = hitbox.x + hitbox.width;
				}
			}
			var newAlpha:BitmapData = new BitmapData(wid, hei, true, power);
			var blit:BitmapData = new BitmapData(wid, hei, true, 0x00000000);
			var targetRect:Rectangle = null;
			switch (type) {
				case ANIM_IDLE:
					targetRect = new Rectangle(110, 112, 70, 110);
					break;
				case ANIM_JUMP:
					targetRect = new Rectangle(112, 460, 70, 110);
					jumpSound.play();
					break;
				case ANIM_LAND:
					targetRect = new Rectangle(5, 558, 70, 110);
					landSound.play();
					break;
				case ANIM_ROOF:
					targetRect = new Rectangle(420, 448, 70, 110);
					ceilingSound.play();
					break;
				case ANIM_WALK_FRONT_START:
					targetRect = new Rectangle(144, 222, 70, 110);
					leftStep.play();
					break;
				case ANIM_WALK_FRONT_END:
					targetRect = new Rectangle(371, 222, 70, 110);
					rightStep.play();
					break;
				case ANIM_WALK_BACK_START:
					targetRect = new Rectangle(57, 332, 70, 110);
					leftStep.play();
					break;
				case ANIM_WALK_BACK_END:
					targetRect = new Rectangle(290, 332, 70, 110);
					rightStep.play();
					break;
				case ANIM_PUNCH:
					var xoff:int = 0;
					if (punch_direction)
						xoff = 190;
					else
						xoff = 403;
					punch_direction = !punch_direction;
					targetRect = new Rectangle(xoff, 808, 110, 110);
					break;
				case ANIM_HURT:
					var xoff2:int = 0;
					if (punch_direction)
						xoff2 = 247;
					else
						xoff2 = 329;
					punch_direction = !punch_direction;
					targetRect = new Rectangle(xoff2, 2519, 82, 110);
					break;
				case ANIM_BLOCK:
					var xoff3:int = 0;
					if (punch_direction)
						xoff3 = 259;
					else
						xoff3 = 340;
					punch_direction = !punch_direction;
					targetRect = new Rectangle(xoff3, 684, 80, 110);
					break;
			}
			if (power != POWER_FULL) {
				switch (type) {
					case ANIM_ROOF:
						newAlpha.copyPixels(newAlpha, new Rectangle(0, 0, newAlpha.width, newAlpha.height), new Point(0, 0), opacHead);
						break;
					case ANIM_PUNCH:
						newAlpha.copyPixels(newAlpha, new Rectangle(0, 0, newAlpha.width, newAlpha.height), new Point(0, 0), opacPunch);
						break;
					case ANIM_JUMP:
					case ANIM_LAND:
					case ANIM_WALK_FRONT_START:
					case ANIM_WALK_FRONT_END:
					case ANIM_WALK_BACK_START:
					case ANIM_WALK_BACK_END:
						newAlpha.copyPixels(newAlpha, new Rectangle(0, 0, newAlpha.width, newAlpha.height), new Point(0, 0), opacFeet);
						break;
				}
			}
			blit.copyPixels(sheet, targetRect, new Point(0, 0), newAlpha);
			if (DEBUG_HITBOX) {
				var hit:BitmapData = new BitmapData(hitbox.width, hitbox.height, true, 0x55FFFFFF);
				blit.copyPixels(hit, new Rectangle(0, 0, hitbox.width, hitbox.height), new Point(hitbox.x, hitbox.y), null, null, true);
			}
			if (isFacingLeft) { // && 1==0) {
				faceOffset = blit.width - hitbox.width - hitbox.x * 2;

				var flipHorizontalMatrix:Matrix = new Matrix();
				flipHorizontalMatrix.scale(-1, 1);
				flipHorizontalMatrix.translate(blit.width, 0);

				var blit2:BitmapData = new BitmapData(blit.width, blit.height, true, 0x00000000);
				blit2.draw(blit, flipHorizontalMatrix);
				return blit2;
			} else {
				faceOffset = 0;
				return blit;
			}
		}
	}
}
