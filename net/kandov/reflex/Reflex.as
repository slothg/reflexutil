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
	
	public class Reflex
	implements IMXMLObject {
		
		private var _id:String;
		private var application:Application;
		private var reflexWindow:ReflexWindow;
		private var inspectedComponents:Dictionary;
		private var openReflexWindow:ContextMenuItem;
		
		//--------------------------------------------------------------------------
		// interface
		//--------------------------------------------------------------------------
		
		public function Reflex() {
			super();
			
			_id = UIDUtil.createUID();
			
			application = Application(Application.application);
			application.addEventListener(FlexEvent.APPLICATION_COMPLETE, applicationCompleteHandler);
			
			reflexWindow = new ReflexWindow();
			reflexWindow.x = -1;
			reflexWindow.y = -1;
			
			openReflexWindow = new ContextMenuItem("Open Reflex Window");
			openReflexWindow.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, openReflexWindowMenuItemSelect);
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
			//TODO: fix showing order, use splice
			var customItems:Array = application.contextMenu.customItems;
			var inspect:Object;
			
			var inspectIndex:int;
			for (inspect in inspectedComponents) {
				inspectIndex = customItems.indexOf(inspect);
				if (inspectIndex != -1) {
					customItems.splice(inspectIndex, 1);
				}
			}
			
			inspectedComponents = new Dictionary();
			var components:Array = ComponentUtil.getComponentsUnderMouse(application);
			var separatorUsed:Boolean;
			for each (var component:IUIComponent in components) {
				inspect = new ContextMenuItem(
					"Inspect [" + ComponentUtil.getComponentUID(component) + "]", !separatorUsed);
				if (!separatorUsed) {
					separatorUsed = true;
				}
				inspect.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, inspectMenuItemSelect);
				inspectedComponents[inspect] = component;
				customItems.push(inspect);
			}
			
			var openReflexWindowIndex:int = customItems.indexOf(openReflexWindow);
			if (!reflexWindow.showing && openReflexWindowIndex == -1) {
				customItems.push(openReflexWindow);
			} else if (reflexWindow.showing && openReflexWindowIndex != -1) {
				customItems.splice(openReflexWindowIndex, 1);
			}
		}
		
		private function inspectMenuItemSelect(event:ContextMenuEvent):void {
			var component:IUIComponent = inspectedComponents[event.target];
			reflexWindow.addComponent(component);
			reflexWindow.show();
		}
		
		private function openReflexWindowMenuItemSelect(event:ContextMenuEvent):void {
			reflexWindow.show();
		}
		
	}
	
}