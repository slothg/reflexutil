package net.kandov.reflexutil.types {
	
	import flash.events.EventDispatcher;
	
	import mx.core.UIComponent;
	
	import net.kandov.reflexutil.utils.ClassUtil;
	import net.kandov.reflexutil.utils.IComparable;
	
	[Bindable]
	public class PropertyInfo
	extends EventDispatcher
	implements IComparable {
		
		public var component:UIComponent;
		public var name:String;
		public var access:String;
		public var value:Object;
		public var type:String;
		public var bindable:Boolean;
		
		public function PropertyInfo(component:UIComponent, name:String, access:String) {
			super();
			
			this.component = component;
			this.name = name;
			this.access = access;
		}
		
		override public function toString():String {
			return "[" + ClassUtil.getClassName(this) + " " +
				"component='" + component + "' " +
				"name='" + name + "' " +
				"access='" + access + "' " +
				"value='" + value + "' " +
				"type='" + type + "' " +
				"bindable='" + bindable + "']";
				
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