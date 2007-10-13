/*
*	Copyright 2007 Alon Kandov (kandov@gmail.com)
*	ReflexUtil <http://reflexutil.googlecode.com>
*	
*	==========================================================================
*	
*	This file is part of ReflexUtil.
*	
*	ReflexUtil is free software: you can redistribute it and/or modify
*	it under the terms of the GNU General Public License as published by
*	the Free Software Foundation, either version 3 of the License, or
*	(at your option) any later version.
*	
*	ReflexUtil is distributed in the hope that it will be useful,
*	but WITHOUT ANY WARRANTY; without even the implied warranty of
*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*	GNU General Public License for more details.
*	
*	You should have received a copy of the GNU General Public License
*	along with ReflexUtil.  If not, see <http://www.gnu.org/licenses/>.
*/

package net.kandov.reflexutil.types {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.core.UIComponent;
	
	import net.kandov.reflexutil.utils.ClassUtil;
	
	[Event(type="flash.events.Event", name="valueChanged")]
	
	[Bindable]
	public class PropertyInfo
	extends EventDispatcher
	implements IComparable {
		
		public static const URI_MX_INTERNAL:String = "http://www.adobe.com/2006/flex/mx/internal";
		
		public static const VALUE_CHANGED:String = "valueChanged";
		
		public var component:UIComponent;
		public var name:String;
		public var type:String;
		public var access:String;
		public var uri:String;
		public var bindable:Boolean;
		
		private var _value:Object;
		
		[Bindable(event="valueChanged")]
		public function get value():Object {
			return _value;
		}
		
		public function set value(newValue:Object):void {
			if (_value != newValue) {
				_value = newValue;
				dispatchEvent(new Event(VALUE_CHANGED));
			}
		}
		
		public function PropertyInfo(component:UIComponent, name:String, type:String,
			access:String = null, uri:String = null) {
			super();
			
			this.component = component;
			this.name = name;
			this.type = type;
			this.access = access;
			this.uri = uri;
		}
		
		override public function toString():String {
			return "[" + ClassUtil.getClassName(this) + " name='" + name + "']";
		}
		
		public function equals(anotherObject:Object):Boolean {
			var anotherPropertyInfo:PropertyInfo = anotherObject as PropertyInfo;
			if (anotherPropertyInfo) {
				return anotherPropertyInfo.component == component &&
					anotherPropertyInfo.name == name;
			}
			return false;
		}
		
	}
	
}