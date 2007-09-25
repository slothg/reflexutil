package net.kandov.reflex.utils {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.describeType;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.core.Container;
	import mx.core.IUIComponent;
	import mx.core.IUID;
	
	import net.kandov.reflex.types.ComponentInfo;
	import net.kandov.reflex.types.PropertyInfo;
	
	public class ComponentUtil {
		
		public static function getHolderComponent(displayObject:DisplayObject):IUIComponent {
			if (displayObject is IUIComponent) {
				return IUIComponent(displayObject);
			} else {
				if (displayObject.parent) {
					return getHolderComponent(displayObject.parent);
				} else {
					return null;
				}
			}
		}
		
		public static function getComponentsUnderMouse(container:DisplayObjectContainer):Array {
			var components:Array = new Array;
			
			var globalMousePoint:Point = container.localToGlobal(new Point(container.mouseX, container.mouseY));
			var displayObjects:Array = container.getObjectsUnderPoint(globalMousePoint);
			
			for each (var displayObject:DisplayObject in displayObjects) {
				var component:IUIComponent = getHolderComponent(displayObject);
				if (component) {
					components.push(component);
				}
			}
			
			return components.reverse();
		}
		
		public static function getComponentUID(component:IUIComponent):String {
			var uidComponent:IUID = component as IUID;
			if (!uidComponent) {
				return "(" + ClassUtil.getClassName(component) + ")";
			}
			
			var uid:String = uidComponent.uid;
			if (uid.indexOf(".") != -1) {
				var strArr:Array = uid.split(".");
				uid = strArr[strArr.length - 1];
			}
			return uid;
		}
		
		public static function getAbsolutePosition(component:IUIComponent):Point {
			//TODO: why parent?
			return component.parent.localToGlobal(new Point(component.x, component.y));
		}
		
		public static function generateComponentInfo(component:IUIComponent):ComponentInfo {
			var componentInfo:ComponentInfo = new ComponentInfo(
				component, getComponentUID(component) + " (" + ClassUtil.getClassName(component) + ")");
			
			if (component is Container) {
				componentInfo.children = new Array();
				for each (var child:DisplayObject in Container(component).getChildren()) {
					if (child is IUIComponent) {
						componentInfo.children.push(generateComponentInfo(IUIComponent(child)));
					}
				}
			}
			
			return componentInfo;
		}
		
		public static function generatePropertiesInfos(component:IUIComponent):ArrayCollection {
			var propertiesInfos:ArrayCollection;
			
			var properties:XMLList = describeType(component).accessor;
			if (properties.length() > 0) {
				propertiesInfos = new ArrayCollection();
				var propertyInfo:PropertyInfo;
				
				for each (var property:XML in properties) {
					propertyInfo = new PropertyInfo(component, property.@name, property.@type, property.@access);
					
					var metadataCollection:XMLList = property["metadata"];
					for each (var metadata:XML in metadataCollection) {
						if (metadata.@name == "Bindable") {
							propertyInfo.bindable = true;
							break;
						}
					}
					
					if (propertyInfo.access != "writeonly") {
						BindingUtils.bindProperty(propertyInfo, "value", component, propertyInfo.name);
						if (component[propertyInfo.name]) {
							propertyInfo.value = component[propertyInfo.name];
						}
					}
					
					propertiesInfos.addItem(propertyInfo);
				}
				
				//TODO: add styles as properties and differentiate them from the original properties
			}
			
			return propertiesInfos;
		}
		
	}
	
}