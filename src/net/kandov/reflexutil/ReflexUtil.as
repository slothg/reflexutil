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

package net.kandov.reflexutil {
	
	import flash.display.DisplayObjectContainer;
	import flash.events.ContextMenuEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	
	import mx.core.Application;
	import mx.core.IMXMLObject;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.utils.UIDUtil;
	
	import net.kandov.reflexutil.components.ControlWindow;
	import net.kandov.reflexutil.utils.ComponentUtil;
	
	public class ReflexUtil
	implements IMXMLObject {
		
		include "Version.as"; 
		
		private var _id:String;
		private var stage:DisplayObjectContainer;
		private var application:Application;
		private var window:ControlWindow;
		private var contextMenuItems:Dictionary;
		
		//--------------------------------------------------------------------------
		// interface
		//--------------------------------------------------------------------------
		
		public function ReflexUtil() {
			super();
			
			_id = UIDUtil.createUID();
			
			application = Application(Application.application);
			
			window = new ControlWindow();
			window.application = application;
			window.x = -1;
			window.y = -1;
			window.width = 400;
			window.height = 600;
		}
		
		public function initialized(document:Object, id:String):void {
			_id = id;
			
			load();
		}
		
		public function load():void
		{
			if (application.contextMenu) {
				addContextMenuListeners();
			} else {
				application.addEventListener(FlexEvent.APPLICATION_COMPLETE,
					applicationCompleteHandler, false, 0, true);
			}
		}
		
		public function get x():int {
			return window.x;
		}
		
		public function set x(value:int):void {
			if (window.x != value) {
				window.x = value;
				if (window.y == -1) {
					window.y = 0;
				}
			}
		}
		
		public function get y():int {
			return window.y;
		}
		
		public function set y(value:int):void {
			if (window.y != value) {
				window.y = value;
				if (window.x == -1) {
					window.x = 0;
				}
			}
		}
		
		public function get width():int {
			return window.width;
		}
		
		public function set width(value:int):void {
			if (window.width != value) {
				window.width = value;
			}
		}
		
		public function get height():int {
			return window.height;
		}
		
		public function set height(value:int):void {
			if (window.height != value) {
				window.height = value;
			}
		}
		
		//--------------------------------------------------------------------------
		// private
		//--------------------------------------------------------------------------
		
		private function addContextMenuListeners():void {
			application.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT,
				contextMenuSelectHandler, false, 0, true);
			
			stage = DisplayObjectContainer(application.systemManager);
			stage.contextMenu = new ContextMenu();
			stage.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT,
				contextMenuSelectHandler, false, 0, true);
		}
		
		//--------------------------------------------------------------------------
		// handlers
		//--------------------------------------------------------------------------
		
		private function applicationCompleteHandler(event:FlexEvent):void {
			application.removeEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);
			addContextMenuListeners();
		}
		
		private function contextMenuSelectHandler(event:ContextMenuEvent):void {
			var customItems:Array = event.contextMenuOwner.contextMenu.customItems;
			
			var menuItemIndex:int;
			for (var key:Object in contextMenuItems) {
				menuItemIndex = customItems.indexOf(key);
				if (menuItemIndex != -1) {
					customItems.splice(menuItemIndex, 1);
				}
			}
			
			contextMenuItems = new Dictionary();
			var menuItem:ContextMenuItem;
			
			menuItem = new ContextMenuItem("ReflexUtil Project Page", true);
			menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,
				projectPageMenuItemSelectHandler, false, 0, true);
			contextMenuItems[menuItem] = null;
			customItems.push(menuItem);
			
			if (!window.showing) {
				menuItem = new ContextMenuItem("Open ReflexUtil");
				menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,
					openWindowMenuItemSelectHandler, false, 0, true);
				contextMenuItems[menuItem] = null;
				customItems.push(menuItem);
			}
			
			var components:Array = ComponentUtil.getComponentsUnderMouse(stage);
			for each (var component:UIComponent in components) {
				menuItem = new ContextMenuItem("Inspect [" + ComponentUtil.getUID(component) + "]");
				menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,
					inspectComponentMenuItemSelectHandler, false, 0, true);
				contextMenuItems[menuItem] = component;
				customItems.push(menuItem);
			}
		}
		
		private function projectPageMenuItemSelectHandler(event:ContextMenuEvent):void {
			navigateToURL(new URLRequest("http://reflexutil.googlecode.com"), "_blank");
		}
		
		private function openWindowMenuItemSelectHandler(event:ContextMenuEvent):void {
			window.show();
		}
		
		private function inspectComponentMenuItemSelectHandler(event:ContextMenuEvent):void {
			var component:UIComponent = contextMenuItems[event.target];
			window.addComponent(component);
			window.show();
		}
		
	}
	
}