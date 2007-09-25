package net.kandov.reflex {
	
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	
	import mx.core.Application;
	import mx.core.IMXMLObject;
	import mx.core.IUIComponent;
	import mx.events.FlexEvent;
	import mx.utils.UIDUtil;
	
	import net.kandov.reflex.components.ReflexWindow;
	import net.kandov.reflex.utils.ComponentUtil;
	
	//TODO: block designer from adding ReflexWindow.mxml or any other class than Reflex
	//TODO: change project name to ReflexUtil, consider changing main class name also
	//TODO: figure how to expose inspectable metadata for this class (--keep-as3-metadata or something...?)
	public class Reflex
	implements IMXMLObject {
		
		private var _id:String;
		private var application:Application;
		private var reflexWindow:ReflexWindow;
		private var reflexContextMenuItems:Dictionary;
		
		//--------------------------------------------------------------------------
		// interface
		//--------------------------------------------------------------------------
		
		public function Reflex() {
			super();
			
			_id = UIDUtil.createUID();
			
			application = Application(Application.application);
			application.addEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);
			
			reflexWindow = new ReflexWindow();
			reflexWindow.application = application;
			reflexWindow.x = -1;
			reflexWindow.y = -1;
		}
		
		public function initialized(document:Object, id:String):void {
			_id = id;
		}
		
		[Inspectable(defaultValue=400)]
		public function get windowWidth():int {
			return reflexWindow.width;
		}
		
		public function set windowWidth(value:int):void {
			if (reflexWindow.width != value) {
				reflexWindow.width = value;
			}
		}
		
		[Inspectable(defaultValue=400)]
		public function get windowHeight():int {
			return reflexWindow.height;
		}
		
		public function set windowHeight(value:int):void {
			if (reflexWindow.height != value) {
				reflexWindow.height = value;
			}
		}
		
		[Inspectable(defaultValue=-1)]
		public function get windowX():int {
			return reflexWindow.x;
		}
		
		public function set windowX(value:int):void {
			if (reflexWindow.x != value) {
				reflexWindow.x = value;
				if (reflexWindow.y == -1) {
					reflexWindow.y = 0;
				}
			}
		}
		
		[Inspectable(defaultValue=-1)]
		public function get windowY():int {
			return reflexWindow.y;
		}
		
		public function set windowY(value:int):void {
			if (reflexWindow.y != value) {
				reflexWindow.y = value;
				if (reflexWindow.x == -1) {
					reflexWindow.x = 0;
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
			application.contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, applicationContextMenuSelect);
		}
		
		private function applicationContextMenuSelect(event:ContextMenuEvent):void {
			var customItems:Array = application.contextMenu.customItems;
			
			var menuItemIndex:int;
			for (var key:Object in reflexContextMenuItems) {
				menuItemIndex = customItems.indexOf(key);
				if (menuItemIndex != -1) {
					customItems.splice(menuItemIndex, 1);
				}
			}
			
			reflexContextMenuItems = new Dictionary();
			var menuItem:ContextMenuItem;
			
			menuItem = new ContextMenuItem("Open Reflex Window", true);
			menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, openReflexWindowMenuItemSelect);
			reflexContextMenuItems[menuItem] = null;
			customItems.push(menuItem);
			
			var components:Array = ComponentUtil.getComponentsUnderMouse(application);
			for each (var component:IUIComponent in components) {
				menuItem = new ContextMenuItem("Inspect [" + ComponentUtil.getComponentUID(component) + "]");
				menuItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, inspectComponentMenuItemSelect);
				reflexContextMenuItems[menuItem] = component;
				customItems.push(menuItem);
			}
		}
		
		private function openReflexWindowMenuItemSelect(event:ContextMenuEvent):void {
			reflexWindow.show();
		}
		
		private function inspectComponentMenuItemSelect(event:ContextMenuEvent):void {
			var component:IUIComponent = reflexContextMenuItems[event.target];
			reflexWindow.addComponent(component);
			reflexWindow.show();
		}
		
	}
	
}