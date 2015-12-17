import Cocoa
import Darwin

/// The StatusView reflects the current cpu/network load
class StatusView: NSView {
	
	/// The reference to the StatusController
	unowned let statusController: StatusController
	
	/// The fill color of the cpu load bars
	lazy var cpuColor = NSColor(calibratedWhite: 0.22, alpha: 1.0)
	
	/// The fill color of the network download bars
    lazy var networkInputColor = NSColor(calibratedRed: 0.15, green: 0.15, blue: 0.9, alpha: 1.0)
    
    /// The fill color of the network upload bars
    lazy var networkOutputColor = NSColor(calibratedRed: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
	
	/// The stroke color of the load bars
	lazy var strokeColor = NSColor(calibratedWhite: 0.5, alpha: 0.3)

    var counter: Double = 0
    
    // Points on the graph
    var pointsY = [Double]()

	
	/// The background gradient of the load bars
	lazy var backgroundGradient = NSGradient(colors: [
		NSColor(calibratedWhite: 0.5, alpha: 0.25),
		NSColor(calibratedWhite: 0.5, alpha: 0),
		NSColor(calibratedWhite: 0.5, alpha: 0.25)])
	
	/// Initialize the StatusView with a reference to the StatusController
	init(frame frameRect: NSRect, statusController: StatusController) {
		self.statusController = statusController
		super.init(frame: frameRect)
	}

    /// Required initializer for NSView subclasses
	convenience required init?(coder: NSCoder) {
        self.init(frame: NSMakeRect(0, 0, 0, 0), statusController: StatusController())
	}
	
	/// Get the necessary width of the NSStatusItem for a given number of cpu threads
	class func widthOfCPUCount(cpuCount: Int) -> CGFloat {
		let cpuCount = CGFloat(cpuCount)
		return LeftMargin + (2 + cpuCount) * BarWidth + (1 + cpuCount) * GapBetweenBars + RightMargin
	}
	
	/// Draw the load bar
	func drawBarInFrame(frame: NSRect, fillColor: NSColor, percentage: Double) {
		backgroundGradient!.drawInRect(frame, angle: 0)
		strokeColor.setStroke()
		NSBezierPath.strokeRect(frame)
        let loadHeight = CGFloat(floor((Double(frame.size.height) + 1) * percentage))
		let loadFrame = NSMakeRect(frame.origin.x - 0.5, frame.origin.y - 0.5, frame.size.width + 1, loadHeight)
		fillColor.setFill()
		NSBezierPath.fillRect(loadFrame)
	}
    
    func drawChartInFrame( percentage: Double) {
        
        // Init path and and starting point
        let path = NSBezierPath()
        if pointsY.count == 0{
            path.moveToPoint(NSPoint(x:0, y:0))
        } else {
            path.moveToPoint(NSPoint(x:Double(0), y:pointsY[0]))
        }

        // Fill points should hold 10 values. Fill the list with each call until there are 10 values.
        // For every subsequent call to this method, remove first item, add new one to the end.
        if pointsY.count < 51{
            pointsY.append(Double(arc4random_uniform(20))) // you know, a cast cast cast
        } else if pointsY.count >= 50 {
            pointsY.removeAtIndex(0)
            pointsY.append(Double(arc4random_uniform(20)))
        }
        
        // Draw the line (love isn't always on time)
        for i:Int in 0...pointsY.count {
            path.lineToPoint(NSPoint(x:Double(i), y:pointsY[i]))
        }
        path.flatness = 0.01
        path.lineWidth = 1.0
        path.stroke()
        path.closePath()
      
    }
	
	/// Draw the contents of the StatusView
	override func drawRect(dirtyRect: NSRect) {
		super.drawRect(dirtyRect)
		var frame = NSMakeRect(LeftMargin, 3.5, BarWidth, 20)
        
//        drawChartInFrame(longFrame, fillColor: networkOutputColor, percentage: 0.5)
		frame.origin.x += ((BarWidth + GapBetweenBars)*2)
        
		// draw the network bars
		drawBarInFrame(frame, fillColor: networkInputColor, percentage: statusController.networkLoad.input)
		frame.origin.x += (BarWidth + GapBetweenBars)
		drawBarInFrame(frame, fillColor: networkOutputColor, percentage: statusController.networkLoad.output)
		frame.origin.x += (BarWidth + GapBetweenBars)
		
		// draw the cpu bars
		for load in statusController.cpuLoad {
			drawBarInFrame(frame, fillColor: cpuColor, percentage: load)
            drawChartInFrame(0.5)

			frame.origin.x += (BarWidth + GapBetweenBars)
        }
	}
}
