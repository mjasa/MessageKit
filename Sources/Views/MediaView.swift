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

class MediaView: UIImageView {

    open var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

    open lazy var playButtonView: PlayButtonView = {
        let playButtonView = PlayButtonView()
        playButtonView.frame.size = CGSize(width: 35, height: 35)
        return playButtonView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playButtonView)
        addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        playButtonView.translatesAutoresizingMaskIntoConstraints = false
        playButtonView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
       playButtonView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        playButtonView.widthAnchor.constraint(equalToConstant: playButtonView.bounds.width).isActive = true
        playButtonView.heightAnchor.constraint(equalToConstant: playButtonView.bounds.height).isActive = true

    }

    convenience init() {
        self.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func configureVisibleViews(for message: MessageType) {
        switch message.data {
        case .video:
            isHidden = false
            playButtonView.isHidden = false
        case .location, .photo:
            isHidden = false
            playButtonView.isHidden = true
        default:
            isHidden = true
            playButtonView.isHidden = true
        }
        activityIndicator.isHidden = true
    }

    open func configureForLocation(_ location: CLLocation, options: LocationMessageSnapshotOptions, annotation: MKAnnotationView?, animation: ((UIImageView) -> Void)?) {

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        let snapshotOptions = MKMapSnapshotOptions()
        snapshotOptions.region = MKCoordinateRegion(center: location.coordinate, span: options.span)
        //snapshotOptions.size = frame.size
        snapshotOptions.showsBuildings = options.showsBuildings
        snapshotOptions.showsPointsOfInterest = options.showsPointsOfInterest

        let snapShotter = MKMapSnapshotter(options: snapshotOptions)
        snapShotter.start { (snapshot, error) in
            defer { self.activityIndicator.stopAnimating() }
            guard let snapshot = snapshot, error == nil else { return }

            guard let annotationView = annotation else {
                self.image = snapshot.image
                return
            }

            UIGraphicsBeginImageContextWithOptions(snapshotOptions.size, true, 0)

            snapshot.image.draw(at: .zero)

            var point = snapshot.point(for: location.coordinate)
            //Move point to reflect annotation anchor
            point.x -= annotationView.bounds.size.width / 2
            point.y -= annotationView.bounds.size.height / 2
            point.x += annotationView.centerOffset.x
            point.y += annotationView.centerOffset.y

            annotationView.image?.draw(at: point)
            let composedImage = UIGraphicsGetImageFromCurrentImageContext()

            UIGraphicsEndImageContext()
            self.image = composedImage
            animation?(self)
        }
    }
}
