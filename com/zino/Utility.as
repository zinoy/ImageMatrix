package com.zino
{

	public class Utility
	{

		public function Utility()
		{
			// constructor code
		}

		public static function addCommas(number:Number):String
		{
			var negNum:String = "";
			if (number < 0)
			{
				negNum = "-";
				number = Math.abs(number);
			}
			var num:String = String(number);
			var results:Array = num.split(/\./);
			num = results[0];

			if (num.length > 3)
			{
				var mod:Number = num.length % 3;
				var output:String = num.substr(0,mod);
				for (var i:Number = mod; i<num.length; i += 3)
				{
					output += ((mod == 0 && i == 0) ? "" : ",")+num.substr(i, 3);
				}
				if (results.length > 1)
				{
					if (results[1].length == 1)
					{
						return negNum+output+"."+results[1]+"0";

					}
					else
					{
						return negNum+output+"."+results[1];
					}
				}
				else
				{
					return negNum+output;
				}
			}

			if (results.length > 1)
			{
				if (results[1].length == 1)
				{
					return negNum+num+"."+results[1]+"0";

				}
				else
				{
					return negNum+num+"."+results[1];
				}
			}
			else
			{
				return negNum+num;
			}
		}
	}

}