/*
 MIT License

 Copyright (c) 2017 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import MapKit

open class MessageCollectionViewCell: MessageBaseCell, CollectionViewReusable {
    open class func reuseIdentifier() -> String { return "messagekit.cell.base-cell" }

    // MARK: - Properties

    open var messageContainerView: MessageContainerView = {
        let messageContainerView = MessageContainerView()
        messageContainerView.clipsToBounds = true
        messageContainerView.layer.masksToBounds = true
        return messageContainerView
    }()

    // MARK: - Initializer

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupGestureRecognizers()
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    open override func setupSubviews() {
        contentView.addSubview(messageContainerView)
    }

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageContainerView.frame = attributes.messageContainerFrame
            messageContainerView.messageLabel.textInsets = attributes.messageLabelInsets
            messageContainerView.messageLabel.font = attributes.messageLabelFont
        }
    }

    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let touchLocation = gesture.location(in: self)
        let containsTouch = messageContainerView.frame.contains(touchLocation)
        let localTouch = convert(touchLocation, to: messageContainerView)
        let canHandle = !cellContentView(canHandle: localTouch)
        if containsTouch && canHandle {
            delegate?.didTapMessage(in: self)
        }
    }


    /// Handle `ContentView`'s tap gesture, return false when `ContentView` don't needs to handle gesture
    open func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        return false
    }

    open func configureMessageStyle(_ style: MessageStyle, backgroundColor: UIColor) {
        messageContainerView.backgroundColor = backgroundColor
        messageContainerView.style = style
    }

    open func configureDelegate(_ delegate: MessageCellDelegate?, for message: MessageType) {
        if delegate == nil, let cellDelegate = delegate {
            self.delegate = cellDelegate
            switch message.data {
            case .text, .attributedText, .emoji:
                messageContainerView.messageLabel.delegate = delegate
            default:
                break
            }
        }
    }

    open func configure(with message: MessageType) {
        messageContainerView.configureVisibleViews(for: message)
        messageContainerView.configureData(for: message)
    }
}
