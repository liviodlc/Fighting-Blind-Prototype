package {
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Animator {

		private static const FADE_COLOR:uint = 0x22010004;//ARGB

		private var canvasData:BitmapData;
		private var canvasRect:Rectangle;

		private var tmpData:BitmapData;

		public function Animator(canvasData:BitmapData) {
			this.canvasData = canvasData;
			this.canvasRect = new Rectangle(0, 0, canvasData.width, canvasData.height);
			
			tmpData = new BitmapData(canvasData.width, canvasData.height, true, FADE_COLOR);
		}


		public function draw():void {
//			canvasData.fillRect(canvasRect, FADE_COLOR);
			canvasData.copyPixels(tmpData, canvasRect, new Point(0, 0), null, null, true);
		}


		public function spit(b:BitmapData, coords:Point):void {
			canvasData.copyPixels(b, new Rectangle(0, 0, b.width, b.height), coords);
		}
	}
}
