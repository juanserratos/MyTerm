import AppKit

final class LatexAttachmentCell: NSTextAttachmentCell {
    private let image: NSImage

    init(image: NSImage) {
        self.image = image
        super.init(imageCell: image)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func cellSize() -> NSSize {
        var size = image.size
        size.width += 8
        size.height += 8
        return size
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView?) {
        let rect = cellFrame.insetBy(dx: 4, dy: 4)
        NSColor.windowBackgroundColor.setFill()
        let background = NSBezierPath(roundedRect: rect, xRadius: 8, yRadius: 8)
        background.fill()

        image.draw(in: rect)
    }
}

final class LatexAttachmentBuilder {
    static func makeAttachment(from image: NSImage) -> NSTextAttachment {
        let attachment = NSTextAttachment()
        attachment.attachmentCell = LatexAttachmentCell(image: image)
        return attachment
    }
}
