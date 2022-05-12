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
        let pasteboardString = NSPasteboard.general.string(forType: .string)
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
