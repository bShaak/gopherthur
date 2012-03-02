/*
*** FlxInputText v0.92, Input text field extension for Flixel ***
(author Nitram_cero, Martin Sebastian Wain)
(slight modification by Wurmy, seems to work on version 2.34 of Flixel)
(little insignificant update by Tyranus, now works with scroll)
(minor 2.5. update by Kevin Prein)

New members:
	getText()
	setMaxLength()
	
	backgroundColor
	borderColor
	backgroundVisible
	borderVisible
	
	forceUpperCase
	filterMode
	customFilterPattern


Copyright (c) 2009 Martin Sebastian Wain
License: Creative Commons Attribution 3.0 United States
(http://creativecommons.org/licenses/by/3.0/us/)

(A tiny "single line comment" reference in the source code is more than sufficient as attribution :)
 */

package
{
	import org.flixel.*;
	import flash.events.Event;
	import flash.text.*;

	//@desc		Input field class that "fits in" with Flixel's workflow
	public class FlxInputText extends FlxText {
	
		static public const NO_FILTER:uint				= 0;
		static public const ONLY_ALPHA:uint				= 1;
		static public const ONLY_NUMERIC:uint			= 2;
		static public const ONLY_ALPHANUMERIC:uint		= 3;
		static public const CUSTOM_FILTER:uint			= 4;
		
		//@desc		Defines what text to filter. It can be NO_FILTER, ONLY_ALPHA, ONLY_NUMERIC, ONLY_ALPHA_NUMERIC or CUSTOM_FILTER
		//			(Remember to append "FlxInputText." as a prefix to those constants)
		public var filterMode:uint									= NO_FILTER;

		//@desc		This regular expression will filter out (remove) everything that matches. This is activated by setting filterMode = FlxInputText.CUSTOM_FILTER.
		public var customFilterPattern:RegExp						= /[]*/g;

		//@desc		If this is set to true, text typed is forced to be uppercase
		public var forceUpperCase:Boolean							= false;

		//@desc		Same parameters as FlxText
		public function FlxInputText(X:Number, Y:Number, Width:uint, Height:uint, Text:String, Color:uint=0x000000, Font:String=null, Size:uint=8, Justification:String=null, Angle:Number=0)
		{
			//super(X, Y, Width, Height, Text, Color, Font, Size, Justification, Angle);
			super(X, Y, Width, Text);
			
			_textField.selectable = true;
			_textField.type = TextFieldType.INPUT;
			_textField.background = true;
			_textField.backgroundColor = (~Color) & 0xffffff;
			_textField.textColor = Color;
			_textField.border = true;
			_textField.borderColor = Color;
			_textField.visible = false;
			_textField.height = Height;
			this.height = Height;
			this.angle = Angle;
			this.size = Size;

			_textField.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			_textField.addEventListener(Event.REMOVED_FROM_STAGE, onInputFieldRemoved);
			_textField.addEventListener(Event.CHANGE,		onTextChange);
			//FlxG.state.addChild(_textField);
			FlxG.stage.addChild(_textField);
		}
		
		//@desc		Boolean flag in case render() is called BEFORE onEnterFrame() (_textField would be always hidden)
		//			NOTE: I don't think it's necessary, but I'll leave it just in case.
		//@param	Direction		True is Right, False is Left (see static const members RIGHT and LEFT)		
		private var nextFrameHide:Boolean = false;

		
		override public function draw():void
		{
			_textField.x=x;
			_textField.y=y;
			_textField.visible = true;
			nextFrameHide = false;
		}
		
		private function onInputFieldRemoved(event:Event):void
		{
			//Clean up after ourselves
			_textField.removeEventListener(Event.ENTER_FRAME, 	onEnterFrame);
			_textField.removeEventListener(Event.REMOVED, 		onInputFieldRemoved);
			_textField.removeEventListener(Event.CHANGE,		onTextChange);
		}

		private function onEnterFrame(event:Event):void
		{
			if (nextFrameHide) {			
				if (_textField != null) {
					_textField.visible = false;
				}
			}
			nextFrameHide = true;
		}
		
		private function onTextChange(event:Event):void
		{
			if(forceUpperCase)
				_textField.text = _textField.text.toUpperCase();
				
			if(filterMode != NO_FILTER) {
				var pattern:RegExp;
				switch(filterMode) {
					case ONLY_ALPHA:		pattern = /[^a-zA-Z]*/g;		break;
					case ONLY_NUMERIC:		pattern = /[^0-9]*/g;			break;
					case ONLY_ALPHANUMERIC:	pattern = /[^a-zA-Z0-9]*/g;		break;
					case CUSTOM_FILTER:		pattern = customFilterPattern;	break;
					default:
						throw new Error("FlxInputText: Unknown filterMode ("+filterMode+")");
				}
				_textField.text = _textField.text.replace(pattern, "");
			}
		}
		
		//@desc		Text field background color
		public function set backgroundColor(Color:uint):void		{ _textField.backgroundColor	= Color; }
		//@desc		Text field border color
		public function set borderColor(Color:uint):void 			{ _textField.borderColor		= Color; }
		//@desc		Shows/hides background
		public function set backgroundVisible(Enabled:Boolean):void	{ _textField.background		= Enabled; }
		//@desc		Shows/hides border
		public function set borderVisible(Enabled:Boolean):void		{ _textField.border			= Enabled; }

		//@desc		Text field background color
		public function get backgroundColor():uint					{ return _textField.backgroundColor; }
		//@desc		Text field border color
		public function get borderColor():uint						{ return _textField.borderColor; }
		//@desc		Shows/hides background
		public function get backgroundVisible():Boolean				{ return _textField.background; }
		//@desc		Shows/hides border
		public function get borderVisible():Boolean					{ return _textField.border; }

		//@desc		Set the maximum length for the field (e.g. "3" for Arcade type hi-score initials)
		//@param	Length	The maximum length. 0 means unlimited.
		public function setMaxLength(Length:uint):void
		{
			_textField.maxChars = Length;
		}

		//@desc		Get the text the user has typed
		public function getText():String
		{
			return _textField.text;
		}
		
		/**
		 * This is a hack, but the text area will not go away by normal means.
		 */
		public function remove():void {
			_textField.visible = false;
			FlxG.stage.removeChild(_textField);
		}
	}
}