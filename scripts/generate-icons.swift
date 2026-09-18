import AppKit

// 正式应用图标的可复现源文件。坐标沿用 256 × 256 的设计网格，原点位于左上角。
func color(_ rgb: UInt32, alpha: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat((rgb >> 16) & 0xff) / 255,
            green: CGFloat((rgb >> 8) & 0xff) / 255,
            blue: CGFloat(rgb & 0xff) / 255, alpha: alpha)
}

func roundedRect(_ rect: CGRect, radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

func gradient(_ context: CGContext, path: CGPath, from: CGColor, to: CGColor,
              start: CGPoint, end: CGPoint) {
    context.saveGState()
    context.addPath(path)
    context.clip()
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                              colors: [from, to] as CFArray, locations: [0, 1])!
    context.drawLinearGradient(gradient, start: start, end: end,
                               options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
    context.restoreGState()
}

func drawIcon(_ context: CGContext) {
    let base = roundedRect(CGRect(x: 8, y: 8, width: 240, height: 240), radius: 55)
    gradient(context, path: base, from: color(0x283342), to: color(0x10151e),
             start: CGPoint(x: 8, y: 8), end: CGPoint(x: 200, y: 248))
    context.addPath(roundedRect(CGRect(x: 9, y: 9, width: 238, height: 238), radius: 54))
    context.setStrokeColor(color(0xffffff, alpha: 0.09))
    context.setLineWidth(1)
    context.strokePath()

    let left = roundedRect(CGRect(x: 31, y: 87, width: 89, height: 68), radius: 9)
    context.addPath(left)
    context.setFillColor(color(0x343d4c))
    context.fillPath()
    context.addPath(left)
    context.setStrokeColor(color(0x667285))
    context.setLineWidth(3)
    context.strokePath()

    let right = roundedRect(CGRect(x: 136, y: 87, width: 89, height: 68), radius: 9)
    gradient(context, path: right, from: color(0xfff4d6), to: color(0xdcb684),
             start: CGPoint(x: 136, y: 87), end: CGPoint(x: 190, y: 155))

    context.setLineWidth(5)
    context.setLineCap(.round)
    for (center, shade) in [(CGFloat(75), UInt32(0x687589)), (CGFloat(180), UInt32(0xeed9b0))] {
        context.setStrokeColor(color(shade))
        context.move(to: CGPoint(x: center, y: 156))
        context.addLine(to: CGPoint(x: center, y: 174))
        context.move(to: CGPoint(x: center - 18, y: 174))
        context.addLine(to: CGPoint(x: center + 18, y: 174))
        context.strokePath()
    }
}

let output = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                                      bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true,
                                      isPlanar: false, colorSpaceName: .deviceRGB,
                                      bytesPerRow: 0, bitsPerPixel: 0)!
        let context = NSGraphicsContext(bitmapImageRep: bitmap)!.cgContext
        context.clear(CGRect(x: 0, y: 0, width: pixels, height: pixels))
        context.translateBy(x: 0, y: CGFloat(pixels))
        context.scaleBy(x: CGFloat(pixels) / 256, y: -CGFloat(pixels) / 256)
        drawIcon(context)
        let suffix = scale == 2 ? "@2x" : ""
        let filename = "icon_\(size)x\(size)\(suffix).png"
        try bitmap.representation(using: .png, properties: [:])!.write(to: output.appendingPathComponent(filename))
    }
}
