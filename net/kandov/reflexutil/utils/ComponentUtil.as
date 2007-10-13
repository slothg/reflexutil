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
	import mx.styles.StyleManager;
	
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
			var propertiesInfos:Array = new Array();
			
			var type:XML = describeType(component);
			var propertyInfo:PropertyInfo;
			var value:Object;
			
			//get properties
			
			var properties:XMLList = type.accessor;
			var property:XML;
			var uniqueProperties:XMLList = new XMLList();
			for each (property in properties) {
				if (!uniqueProperties.contains(property)) {
					uniqueProperties += property;
				}
			}
			
			if (uniqueProperties.length() != 0) {
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
							value = component[propertyInfo.name];
							if (value) {
								propertyInfo.value = value;
							}
							if (propertyInfo.bindable && propertyInfo.name != "data") {
								//FIXME: data property causes stack overflow exception which is not catched
								BindingUtils.bindProperty(propertyInfo, "value", component, propertyInfo.name);
							}
						} catch (error:Error) {
							//cannot get value or from component's property
							propertyInfo.bindable = false;
						}
					}
					
					propertiesInfos.push(propertyInfo);
				}
			}
			
			//get styles
			
			var styles:XMLList = type.metadata.(attribute("name") == "Style");
			var style:XML;
			var uniqueStyles:XMLList = new XMLList();
			for each (style in styles) {
				if (!uniqueStyles.contains(style)) {
					uniqueStyles += style;
				}
			}
			
			/* EXAMPLE STYLES (All possible keys included)
			<metadata name="Style">
			  <arg key="name" value="paddingBottom"/>
			  <arg key="type" value="Number"/>
			  <arg key="format" value="Length"/>
			  <arg key="inherit" value="no"/>
			</metadata>
			<metadata name="Style">
			  <arg key="name" value="textAlign"/>
			  <arg key="type" value="String"/>
			  <arg key="enumeration" value="left,center,right"/>
			  <arg key="inherit" value="yes"/>
			</metadata>
			<metadata name="Style">
			  <arg key="name" value="fillColors"/>
			  <arg key="type" value="Array"/>
			  <arg key="arrayType" value="uint"/>
			  <arg key="format" value="Color"/>
			  <arg key="inherit" value="no"/>
			</metadata>
			 */
			 
			if (uniqueStyles.length() != 0) {
				var styleArgs:Object;
				for each (style in uniqueStyles) {
					styleArgs = new Object();
					for each (var arg:XML in style.arg) {
						styleArgs[arg.@key] = arg.@value;
					}
					
					propertyInfo = new PropertyInfo(
						component, styleArgs.name, styleArgs.type);
					
						try {
							value = component.getStyle(styleArgs.name);
							if (value) {
								propertyInfo.value = value;
							}
							//TODO: how to bind a style?
							//BindingUtils.bindProperty(propertyInfo, "value", component, ?styleArgs.name?);
						} catch (error:Error) {
							//cannot get value from component's style
						}
					
					propertiesInfos.push(propertyInfo);
				}
			}
			
			//get layout constraints
			//TODO:
			
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