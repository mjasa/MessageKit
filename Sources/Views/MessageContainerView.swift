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

open class MessageContainerView: UIImageView {

    private let imageMask = UIImageView()

    open override var frame: CGRect {
        didSet {
            applyMessageStyle()
        }
    }

    open var style: MessageStyle = .none {
        didSet {
            applyMessageStyle()
        }
    }

    // MARK: - Methods

    private func applyMessageStyle() {
        switch style {
        case .bubble, .bubbleTail:
            imageMask.image = style.image
            imageMask.frame = bounds
            mask = imageMask
            image = nil
        case .bubbleOutline(let color):
            let bubbleStyle: MessageStyle = .bubble
            imageMask.image = bubbleStyle.image
            imageMask.frame = bounds.insetBy(dx: 1.0, dy: 1.0)
            mask = imageMask
            image = style.image
            tintColor = color
        case .bubbleTailOutline(let color, let tail, let corner):
            let bubbleStyle: MessageStyle = .bubbleTailOutline(.white, tail, corner)
            imageMask.image = bubbleStyle.image
            imageMask.frame = bounds.insetBy(dx: 1.0, dy: 1.0)
            mask = imageMask
            image = style.image
            tintColor = color
        case .none:
            mask = nil
            image = nil
            tintColor = nil
        case .custom(let configurationClosure):
            mask = nil
            image = nil
            tintColor = nil
            configurationClosure(self)
        }
    }

    lazy var contentView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.addArrangedSubview(messageLabel)
        view.addArrangedSubview(mediaView)
        return view
    }()

    let messageLabel = MessageLabel()
    let mediaView = MediaView()

    func configureData(for message: MessageType) {
        switch message.data {
        case .text(let text), .emoji(let text):
            messageLabel.text = text
        case .attributedText(let text):
            messageLabel.attributedText = text
        case .photo(let image):
            mediaView.image = image
        case .video(_, let thumbnail):
            mediaView.image = thumbnail
        case .location(_):
            break
        }
    }

    func configureVisibleViews(for messageType: MessageType) {
        switch messageType.data {
        case .attributedText, .text, .emoji:
            messageLabel.isHidden = false
            mediaView.configureVisibleViews(for: messageType)
        case .photo, .video, .location:
            messageLabel.isHidden = true
            mediaView.configureVisibleViews(for: messageType)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }

    convenience init() {
        self.init(frame: .zero)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
