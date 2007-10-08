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
		
		public static const VALUE_CHANGED:String = "valueChanged";
		
		public var component:UIComponent;
		public var name:String;
		public var type:String;
		public var access:String;
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
		
		public function PropertyInfo(component:UIComponent, name:String, type:String, access:String) {
			super();
			
			this.component = component;
			this.name = name;
			this.type = type;
			this.access = access;
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