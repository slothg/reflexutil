package net.kandov.reflexutil.utils {
	
	import flash.utils.getQualifiedClassName;
	
	public class ClassUtil {
		
		//--------------------------------------------------------------------------
		// interface
		//--------------------------------------------------------------------------
		
		public static function getClassName(object:Object):String {
	        var name:String = getQualifiedClassName(object);
	        
			var index:int;
			if ((index = name.indexOf ("::")) != -1) {
				name = name.substr(index + 2);
			} else if ((index = name.indexOf ('as$')) != -1){
				name = name.slice(index + 3);
			}
	        
	        return name;
		}
		
	}
}