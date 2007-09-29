package net.kandov.reflexutil.utils {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.describeType;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.core.Container;
	import mx.core.UIComponent;
	
	import net.kandov.reflexutil.components.ComponentHover;
	import net.kandov.reflexutil.types.ComponentInfo;
	import net.kandov.reflexutil.types.PropertyInfo;
	
	public class ComponentUtil {
		
		//--------------------------------------------------------------------------
		// interface
		//--------------------------------------------------------------------------
		
		public static function getHolderComponent(displayObject:DisplayObject):UIComponent {
			if (displayObject is UIComponent) {
				return UIComponent(displayObject);
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
				var component:UIComponent = getHolderComponent(displayObject);
				if (component) {
					components.push(component);
				}
			}
			
			return components;
		}
		
		public static function getUID(component:UIComponent):String {
			var uid:String = component.uid;
			
			if (uid.indexOf(".") != -1) {
				var strArr:Array = uid.split(".");
				uid = strArr[strArr.length - 1];
			}
			
			return uid;
		}
		
		public static function getAbsolutePosition(component:UIComponent):Point {
			//TODO: need to consider padding and gaps values
			return component.parent.localToGlobal(new Point(component.x, component.y));
		}
		
		public static function getRootComponentInfo(componentInfo:ComponentInfo):ComponentInfo {
			if (!componentInfo) {
				return null;
			}
			
			if (componentInfo.parent) {
				return getRootComponentInfo(componentInfo.parent);
			} else {
				return componentInfo;
			}
		}
		
		public static function generateComponentInfo(component:UIComponent):ComponentInfo {
			var componentInfo:ComponentInfo = new ComponentInfo(
				component, getUID(component) + " (" + ClassUtil.getClassName(component) + ")");
			
			if (component is Container) {
				componentInfo.children = new Array();
				for each (var child:DisplayObject in Container(component).getChildren()) {
					if (child is UIComponent && !(child is ComponentHover)) {
						var childComponentInfo:ComponentInfo = generateComponentInfo(UIComponent(child));
						childComponentInfo.parent = componentInfo;
						componentInfo.children.push(childComponentInfo);
					}
				}
			}
			
			return componentInfo;
		}
		
		//TODO: add styles as properties and differentiate them from the original properties
		public static function generatePropertiesInfos(component:UIComponent):ArrayCollection {
			var propertiesInfos:ArrayCollection;
			
			var properties:XMLList = describeType(component).accessor;
			var property:XML;
			var uniqueProperties:XMLList = new XMLList();
			for each (property in properties) {
				if (!uniqueProperties.contains(property)) {
					uniqueProperties += property;
				}
			}
			
			if (uniqueProperties.length() > 0) {
				propertiesInfos = new ArrayCollection();
				var propertyInfo:PropertyInfo;
				
				for each (property in uniqueProperties) {
					propertyInfo = new PropertyInfo(component, property.@name, property.@access);
					
					if (propertyInfo.access != "writeonly") {
						BindingUtils.bindProperty(propertyInfo, "value", component, propertyInfo.name);
						if (component[propertyInfo.name]) {
							propertyInfo.value = component[propertyInfo.name];
							propertyInfo.type = ClassUtil.determineType(propertyInfo.value, property.@type);
						}
					}
					
					var metadataCollection:XMLList = property["metadata"];
					for each (var metadata:XML in metadataCollection) {
						if (metadata.@name == "Bindable") {
							propertyInfo.bindable = true;
							break;
						}
					}
					
					propertiesInfos.addItem(propertyInfo);
				}
			}
			
			return propertiesInfos;
		}
		
		public static function updatePropertyInfoNotBindableValue(propertyInfo:PropertyInfo):void {
			if (!propertyInfo.bindable && propertyInfo.access != "writeonly") {
				propertyInfo.value = propertyInfo.component[propertyInfo.name];
			}
		}
		
	}
	
}