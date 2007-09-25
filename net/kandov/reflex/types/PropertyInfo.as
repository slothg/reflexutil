package net.kandov.reflex.types {
	
	import flash.events.EventDispatcher;
	
	import mx.core.UIComponent;
	
	import net.kandov.reflex.utils.ClassUtil;
	import net.kandov.reflex.utils.IComparable;
	
	[Bindable]
	public class PropertyInfo
	extends EventDispatcher
	implements IComparable {
		
		public var component:UIComponent;
		public var name:String;
		public var type:String;
		public var access:String;
		public var bindable:Boolean;
		public var value:Object;
		
		public function PropertyInfo(component:UIComponent, name:String, type:String, access:String) {
			super();
			
			this.component = component;
			this.name = name;
			this.type = type;
			this.access = access;
		}
		
		override public function toString():String {
			return "[" + ClassUtil.getClassName(this) + " " +
				"component='" + component + "' " +
				"name='" + name + "' " +
				"type='" + type + "' " +
				"access='" + access + "' " +
				"bindable='" + bindable + "' " +
				"value='" + value + "']";
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