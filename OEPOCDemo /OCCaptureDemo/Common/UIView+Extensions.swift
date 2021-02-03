//
//  UIView+Constraints.swift
//  OCCaptureDemo
//
//  Created by rcadmin on 2021/2/2.
//

import Foundation
import UIKit

public extension UIView {
    @discardableResult
    func makeConstraints(_ block: (UIView) -> [NSLayoutConstraint]) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(block(self))
        return self
    }

    @discardableResult
    func makeConstraintsToBindToSuperview(_ inset: UIEdgeInsets = .zero) -> Self {
        return makeConstraints { [
            $0.leftAnchor.constraint(equalTo: $0.superview!.leftAnchor, constant: inset.left),
            $0.rightAnchor.constraint(equalTo: $0.superview!.rightAnchor, constant: -inset.right),
            $0.topAnchor.constraint(equalTo: $0.superview!.topAnchor, constant: inset.top),
            $0.bottomAnchor.constraint(equalTo: $0.superview!.bottomAnchor, constant: -inset.bottom),
        ] }
    }

    @discardableResult
    func makeConstraintsToCenterOfSuperview(dx: CGFloat = 0, dy: CGFloat = 0) -> Self {
        return makeConstraints { [
            $0.centerXAnchor.constraint(equalTo: $0.superview!.centerXAnchor, constant: dx),
            $0.centerYAnchor.constraint(equalTo: $0.superview!.centerYAnchor, constant: dy),
        ] }
    }

    @available(*, deprecated, message: "Use makeConstraints instead.")
    @discardableResult func rcv_makeConstraints(_ block: (UIView) -> [NSLayoutConstraint]) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(block(self))
        return self
    }

    @available(*, deprecated, message: "Use makeConstraintsToBindToSuperview instead.")
    @discardableResult func rcv_makeConstraintsToBindToSuperview(_ inset: UIEdgeInsets = .zero) -> Self {
        return makeConstraints { [
            $0.leftAnchor.constraint(equalTo: $0.superview!.leftAnchor, constant: inset.left),
            $0.rightAnchor.constraint(equalTo: $0.superview!.rightAnchor, constant: -inset.right),
            $0.topAnchor.constraint(equalTo: $0.superview!.topAnchor, constant: inset.top),
            $0.bottomAnchor.constraint(equalTo: $0.superview!.bottomAnchor, constant: -inset.bottom),
        ] }
    }

    @available(*, deprecated, message: "Use makeConstraintsToCenterOfSuperview instead.")
    @discardableResult func rcv_makeConstraintsToCenterOfSuperview(dx: CGFloat = 0, dy: CGFloat = 0) -> Self {
        return makeConstraints { [
            $0.centerXAnchor.constraint(equalTo: $0.superview!.centerXAnchor, constant: dx),
            $0.centerYAnchor.constraint(equalTo: $0.superview!.centerYAnchor, constant: dy),
        ] }
    }
}

extension UIView {
    open var safeLeadingAnchor: NSLayoutXAxisAnchor {
        return self.safeAreaLayoutGuide.leadingAnchor
    }

    open var safeTrailingAnchor: NSLayoutXAxisAnchor {
        return self.safeAreaLayoutGuide.trailingAnchor
    }

    open var safeLeftAnchor: NSLayoutXAxisAnchor {
        return self.safeAreaLayoutGuide.leftAnchor
    }

    open var safeRightAnchor: NSLayoutXAxisAnchor {
        return self.safeAreaLayoutGuide.rightAnchor
    }

    open var safeTopAnchor: NSLayoutYAxisAnchor {
        return self.safeAreaLayoutGuide.topAnchor
    }

    open var safeBottomAnchor: NSLayoutYAxisAnchor {
        return self.safeAreaLayoutGuide.bottomAnchor
    }

    open var safeWidthAnchor: NSLayoutDimension {
        return self.safeAreaLayoutGuide.widthAnchor
    }

    open var safeHeightAnchor: NSLayoutDimension {
        return self.safeAreaLayoutGuide.heightAnchor
    }

    open var safeCenterXAnchor: NSLayoutXAxisAnchor {
        return self.safeAreaLayoutGuide.centerXAnchor
    }

    open var sfaeCenterYAnchor: NSLayoutYAxisAnchor {
        return safeAreaLayoutGuide.centerYAnchor
    }
}

