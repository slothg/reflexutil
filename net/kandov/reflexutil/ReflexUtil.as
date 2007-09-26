package net.kandov.reflexutil {
	
	import flash.events.ContextMenuEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
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
		
		private var _id:String;
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
			application.addEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);
			
			window = new ControlWindow();
			window.application = application;
			window.x = -1;
			window.y = -1;
			window.width = 400;
			window.height = 400;
		}
		
		public function initialized(document:Object, id:String):void {
			_id = id;
		}
		
		public function get windowWidth():int {
			return window.width;
		}
		
		public function set windowWidth(value:int):void {
			if (window.width != value) {
				window.width = value;
			}
		}
		
		public function get windowHeight():int {
			return window.height;
		}
		
		public function set windowHeight(value:int):void {
			if (window.height != value) {
				window.height = value;
			}
		}
		
		public function get windowX():int {
			return window.x;
		}
		
		public function set windowX(value:int):void {
			if (window.x != value) {
				window.x = value;
				if (window.y == -1) {
					window.y = 0;
				}
			}
		}
		
		public function get windowY():int {
			return window.y;
		}
		
		public function set windowY(value:int):void {
			if (window.y != value) {
				window.y = value;
				if (window.x == -1) {
					window.x = 0;
				}
			}
		}
		
		//--------------------------------------------------------------------------
		// private
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		// handlers
		//--------------------------------------------------------------------------
		
		private function applicationCompleteHandler(event:FlexEvent):void {
			application.removeEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);
			application.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT,
				applicationContextMenuSelectHandler);
		}
		
		private function applicationContextMenuSelectHandler(event:ContextMenuEvent):void {
			var customItems:Array = application.contextMenu.customItems;
			
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
				menuItem = new ContextMenuItem("Open Window");
				menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,
					openWindowMenuItemSelectHandler, false, 0, true);
				contextMenuItems[menuItem] = null;
				customItems.push(menuItem);
			}
			
			var components:Array = ComponentUtil.getComponentsUnderMouse(application);
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