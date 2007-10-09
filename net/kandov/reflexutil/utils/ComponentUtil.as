package net.kandov.reflexutil.utils {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.describeType;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.utils.ObjectUtil;
	
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
			
			var displayObjects:Array = container.getObjectsUnderPoint(
				new Point(container.stage.mouseX, container.stage.mouseY));
			
			for each (var displayObject:DisplayObject in displayObjects) {
				var component:UIComponent = getHolderComponent(displayObject);
				if (component && components.indexOf(component) == -1) {
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
			var nativeParent:DisplayObjectContainer = component.mx_internal::$parent;
			return nativeParent.localToGlobal(new Point(component.x, component.y));
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
			
			if (component.numChildren != 0) {
				var child:DisplayObject;
				for (var i:int = 0; i < component.numChildren; i ++) {
					child = component.getChildAt(i);
					
					if (child is UIComponent && !(child is ComponentHover)) {
						if (!componentInfo.children) {
							componentInfo.children = new Array();
						}
						
						var childComponentInfo:ComponentInfo = generateComponentInfo(UIComponent(child));
						childComponentInfo.parent = componentInfo;
						componentInfo.children.push(childComponentInfo);
					}
				}
			}
			
			componentInfo.propertiesInfos = generatePropertiesInfos(component);
			
			return componentInfo;
		}
		
		//TODO: add styles as properties and differentiate them from the original properties
		public static function generatePropertiesInfos(component:UIComponent):Array {
			var propertiesInfos:Array;
			
			var properties:XMLList = describeType(component).accessor;
			var property:XML;
			var uniqueProperties:XMLList = new XMLList();
			for each (property in properties) {
				if (!uniqueProperties.contains(property)) {
					uniqueProperties += property;
				}
			}
			
			if (uniqueProperties.length() > 0) {
				propertiesInfos = new Array();
				var propertyInfo:PropertyInfo;
				
				for each (property in uniqueProperties) {
					propertyInfo = new PropertyInfo(
						component, property.@name, property.@type, property.@access, property.@uri);
					
					var metadataCollection:XMLList = property["metadata"];
					for each (var metadata:XML in metadataCollection) {
						if (metadata.@name == "Bindable") {
							propertyInfo.bindable = true;
							break;
						}
					}
					
					if (propertyInfo.access != "writeonly" && propertyInfo.uri != PropertyInfo.URI_MX_INTERNAL) {
						try {
							if (component[propertyInfo.name]) {
								propertyInfo.value = component[propertyInfo.name];
							}
							if (propertyInfo.bindable && propertyInfo.name != "data") {
								//FIXME: data property causes stack overflow exception which is not catched
								BindingUtils.bindProperty(propertyInfo, "value", component, propertyInfo.name);
							}
						} catch (error:Error) {
							//cannot get value from component's property
							propertyInfo.bindable = false;
						}
					}
					
					propertiesInfos.push(propertyInfo);
				}
			}
			
			return propertiesInfos;
		}
		
		public static function updateValueIfNotBindable(propertyInfo:PropertyInfo):void {
			if (!propertyInfo.bindable &&
				propertyInfo.access != "writeonly" && propertyInfo.uri != PropertyInfo.URI_MX_INTERNAL) {
				try {
					propertyInfo.value = propertyInfo.component[propertyInfo.name];
				} catch (error:Error) {
					//cannot get value from component's property
				}
			}
		}
		
	}
	
}