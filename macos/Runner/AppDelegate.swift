/*
import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    var statusBar: StatusBarController?
    var popover = NSPopover.init()
    
    override init() {
        super.init()
        popover.behavior = NSPopover.Behavior.transient //to make the popover hide when the user clicks outside of it
        
        if #available(macOS 10.12, *) {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: {(timer:Timer) in
                self.clipboardChanged()
            })
        } else {
            // Fallback on earlier versions
        }
        
        
    }
    
    func clipboardChanged(){
        let pasteboardString = NSPasteboard.general.string(forType:       NSPasteboard.PasteboardType.rtf)
        if let theString = pasteboardString {
            print("String is \(theString)")
            // Do cool things with the string
        }
    }
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        let controller: FlutterViewController =
        mainFlutterWindow?.contentViewController as! FlutterViewController
        popover.contentSize = NSSize(width: 360, height: 360) //change this to your desired size
        popover.contentViewController = controller //set the content view controller for the popover to flutter view controller
        statusBar = StatusBarController.init(popover)
        mainFlutterWindow.close() //close the default flutter window
        super.applicationDidFinishLaunching(aNotification)
    }
}
*/
import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        let controller: FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
        
        let binaryChannel = FlutterMethodChannel(name: "clipboard/html",
                                                 binaryMessenger:  controller.registrar(forPlugin: "SwapBuffers").messenger)
        
        
        binaryChannel.setMethodCallHandler({
                  (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                  // Note: this method is invoked on the UI thread.
                  guard call.method == "getClipboardContent" else {
                      result(FlutterMethodNotImplemented)
                      return
                    }
       
                    self.getClipboardContent(result: result)
                })
        
        let popupChannel = FlutterMethodChannel(name: "popup",
                                                 binaryMessenger:  controller.registrar(forPlugin: "SwapBuffers").messenger)
        
        popupChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            print("---------------")
            print(call.method)

            if call.method == "showPopup"  {
                let menu = NSMenu(title: "test")
                menu.addItem(NSMenuItem.separator())
                
                let aboutItem = NSMenuItem(
                        title: "About",
                        action: nil,
                        keyEquivalent: ""
                    )
                menu.addItem(aboutItem)
                menu.addItem(NSMenuItem.separator())
                menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
            }
        })
    }
     
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    private func getClipboardContent(result: FlutterResult) {
        let html = NSPasteboard.general.string(forType: .html);
        let plain = NSPasteboard.general.string(forType: .string);

        guard html == nil else {
            result(html)
            return
        }
        guard plain == nil else {
            result(plain)
            return
        }
    }
}

