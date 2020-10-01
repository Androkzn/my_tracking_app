//
//  Checkbox.swift
//  my_tracking_app
//
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit

@IBDesignable
class Checkbox: UIControl {

    private weak var imageView: UIImageView!

    private var image: UIImage {
        return isChecked ? UIImage(systemName: "checkmark.square.fill")! :
            UIImage(systemName: "square")!
    }

    @IBInspectable
    public var isChecked: Bool = false {
        didSet {
            imageView.image = image
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // add a strong reference
        addSubview(imageView)

        imageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor).isActive = true

        imageView.image = self.image
        imageView.contentMode = .scaleAspectFit

        self.imageView = imageView

        backgroundColor = .clear

        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
    }

    @objc func touchUpInside() {
        sendActions(for: .valueChanged)
    }
}
