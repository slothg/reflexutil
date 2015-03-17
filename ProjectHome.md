## Introduction: ##
This open source utility allows Adobe Flex developers to debug and alter properties of components while running an application.

## How to use: ##
  * Add the `ReflexUtil` SWC library to your flex project
  * Open the Default MXML Application file
  * Add the following attribute to the **`<mx:Application>`** tag: **`xmlns:reflexutil="net.kandov.reflexutil.*"`**
  * Add the following child to the **`<mx:Application>`** tag: **`<reflexutil:ReflexUtil/>`**
  * Debug/Run the application. right click on the application when loaded
  * Click the component you wish to inspect under the mouse point
  * A control window will open, have fun

### Inspecting Styles: ###

Run the application after adding the following argument to the compiler: **`-keep-as3-metadata+=Style`**

On Flex 2.0 - Run in Debug mode only.

### Using as Module: ###

To run the latest version directly from the repository, run this command on
the preinitialize event of the Application:

**`Security.loadPolicyFile("http://reflexutil.googlecode.com/svn/trunk/module/crossdomain.xml");`**

Then use the `ModuleLoader` to load the component on run-time, usage examples:

Flex2: **`<mx:ModuleLoader url="http://reflexutil.googlecode.com/svn/trunk/module/ReflexModule2.swf"/>`**

Flex3: **`<mx:ModuleLoader url="http://reflexutil.googlecode.com/svn/trunk/module/ReflexModule3.swf"/>`**

Flex3.2: **`<mx:ModuleLoader url="http://reflexutil.googlecode.com/svn/trunk/module/ReflexModule32.swf"/>`**

To load component when running the application from localhost, you have to
download the appropriate module file, put it in the bin folder, and change the url:

Flex2: **`<mx:ModuleLoader url="ReflexModule2.swf"/>`**

Flex3: **`<mx:ModuleLoader url="ReflexModule3.swf"/>`**

Flex3.2: **`<mx:ModuleLoader url="ReflexModule32.swf"/>`**