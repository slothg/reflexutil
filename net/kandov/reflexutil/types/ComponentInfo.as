package net.kandov.reflexutil.types {
	
	import flash.events.EventDispatcher;
	
	import mx.core.UIComponent;
	
	import net.kandov.reflexutil.utils.ClassUtil;
	
	[Bindable]
	public class ComponentInfo
	extends EventDispatcher
	implements IComparable {
		
		public var component:UIComponent;
		public var label:String;
		public var parent:ComponentInfo;
		public var children:Array;
		
		public function ComponentInfo(component:UIComponent, label:String) {
			super();
			
			this.component = component;
			this.label = label;
		}
		
		override public function toString():String {
			return "[" + ClassUtil.getClassName(this) + " " +
				"component='" + component + "' " +
				"label='" + label + "' " +
				"parent='" + parent + "' " +
				"children='" + children + "']";
		}
		
		public function equals(anotherObject:Object):Boolean {
			var anotherComponentInfo:ComponentInfo = anotherObject as ComponentInfo;
			if (anotherComponentInfo) {
				return anotherComponentInfo.component == component &&
					anotherComponentInfo.parent == parent;
			}
			return false;
		}
		
	}
	
}