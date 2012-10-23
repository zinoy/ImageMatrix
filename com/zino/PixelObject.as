package com.zino
{
	import flash.display.*;
	import flash.geom.ColorTransform;

	public class PixelObject extends Sprite
	{
		var pixel:Bitmap;
		var _bm:BitmapData;
		var _color:uint;
		var _alpha:Number = 1;
		var _default:Boolean = true;
		var _lightcolor:uint;

		public function get isDefaultColor():Boolean
		{
			return _default;
		}

		public function get getColor():uint
		{
			return _lightcolor;
		}
		
		public function get getAlpha():Number
		{
			return _alpha;
		}

		public function PixelObject(bitmap:BitmapData,color:uint=0x333333)
		{
			_bm = bitmap;
			_lightcolor = _color = color;
			init();
		}

		private function init():void
		{
			pixel = new Bitmap(_bm);
			addChild(pixel);
			//setColor(_color);
		}

		public function setColor(color:uint,a:Number=1.0):void
		{
			var t:ColorTransform = this.transform.colorTransform;
			t.color = color;
			t.alphaMultiplier = a;
			this.transform.colorTransform = t;
			_alpha = a;
			_lightcolor = color;
			if (color != _color)
			{
				_default = false;
			}
		}

		public function reset():void
		{
			setColor(_color);
			_default = true;
		}

		public function red():void
		{
			setColor(0xFF0000);
			_default = false;
		}

		public function green():void
		{
			setColor(0x00FF00);
			_default = false;
		}

		public function blue():void
		{
			setColor(0x0000FF);
			_default = false;
		}

	}

}