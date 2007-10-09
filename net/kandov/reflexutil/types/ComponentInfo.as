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
		public var propertiesInfos:Array;
		
		public function ComponentInfo(component:UIComponent, label:String) {
			super();
			
			this.component = component;
			this.label = label;
		}
		
		override public function toString():String {
			return "[" + ClassUtil.getClassName(this) + " label='" + label + "']";
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