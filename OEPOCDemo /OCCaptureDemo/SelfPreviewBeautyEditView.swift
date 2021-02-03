//
//  SelfPreviewBeautyEditView.swift
//  Glip
//
//  Created by Jamie Yao on 2020/9/1.
//  Copyright © 2020 RingCentral. All rights reserved.
//

import UIKit

@objc protocol SelfPreviewBeautyEditViewDelegate: class {
    func editView(_ editView: SelfPreviewBeautyEditView, didSelectBackgroundAt indexPath: IndexPath)
    func editView(_ editView: SelfPreviewBeautyEditView, didRemoveBackgroundAt indexPath: IndexPath)
    func editViewWillDismiss(_ editView: SelfPreviewBeautyEditView)
}

@objc class SelfPreviewBeautyEditView: UIView {
    // MARK: - Constants

    private static let containerViewHeight: CGFloat = 180.0
    private static let animationDuration: TimeInterval = 0.25
    private static let hideButtonSizeWH: CGFloat = 48.0

    private let backgroundSelectionView: SelfPreviewBeautySelectionView = {
        let backgroundSelectionView = SelfPreviewBeautySelectionView()
        backgroundSelectionView.translatesAutoresizingMaskIntoConstraints = false
        return backgroundSelectionView
    }()

    private let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()

    private let hideButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "FSLayoutDown"), for: .normal)
        button.layer.cornerRadius = hideButtonSizeWH / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        button.accessibilityIdentifier = "HideVirtualBackground"
        button.accessibilityLabel = "Hide virtual background"
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    private let topSpaceView: UIView = {
        let spaceView = UIView()
        spaceView.backgroundColor = .clear
        return spaceView
    }()

    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.numberOfLines = 0
        return label
    }()

    private let labelContainView: UIView = {
        let view = UIView()
        return view
    }()

    private let visualEffectView: UIVisualEffectView = {
        let effectiveView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        return effectiveView
    }()

    @objc var isShowing: Bool {
        return superview != nil && !isHidden
    }

    @objc var showingInfoLabel: Bool = false {
        didSet {
            infoLabel.text = showingInfoLabel ? "Select a virtual background below. Others won't see your video while you make a selection." : ""
            topSpaceViewheightValue = showingInfoLabel ? 30 : 15
            topSpaceViewheightConstraint?.constant = topSpaceViewheightValue
        }
    }

    private var topSpaceViewheightConstraint: NSLayoutConstraint?
    private var topSpaceViewheightValue: CGFloat = 30

    @objc weak var delegate: SelfPreviewBeautyEditViewDelegate?

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false

        // Setup containerView
        addSubview(containerView)
        containerView.makeConstraints { [
            $0.leadingAnchor.constraint(equalTo: leadingAnchor),
            $0.trailingAnchor.constraint(equalTo: trailingAnchor),
            $0.bottomAnchor.constraint(equalTo: bottomAnchor),
        ] }

        // Setup effect view
        containerView.addSubview(visualEffectView)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.makeConstraintsToBindToSuperview()

        // Setup topSpace view
        containerView.addSubview(topSpaceView)
        topSpaceView.makeConstraints { [
            $0.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0),
            $0.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0),
            $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0),
        ] }
        topSpaceViewheightConstraint = topSpaceView.heightAnchor.constraint(equalToConstant: topSpaceViewheightValue)
        topSpaceViewheightConstraint?.isActive = true

        // Setup info label
        containerView.addSubview(infoLabel)
        infoLabel.makeConstraints { [
            $0.leadingAnchor.constraint(equalTo: containerView.safeLeadingAnchor, constant: 16),
            $0.trailingAnchor.constraint(equalTo: containerView.safeTrailingAnchor, constant: -31),
            $0.topAnchor.constraint(equalTo: topSpaceView.bottomAnchor, constant: 0),
        ] }

        // Setup backgroundSelectionView
        backgroundSelectionView.delegate = self
        containerView.addSubview(backgroundSelectionView)
        backgroundSelectionView.makeConstraints { [
            $0.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            $0.heightAnchor.constraint(equalToConstant: SelfPreviewBeautySelectionView.selectionViewheight),
            $0.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 0),
            $0.bottomAnchor.constraint(equalTo: containerView.safeBottomAnchor, constant: 0),
        ] }

        // Setup hide button
        addSubview(hideButton)
        hideButton.makeConstraints { [
            $0.topAnchor.constraint(equalTo: containerView.topAnchor, constant: -SelfPreviewBeautyEditView.hideButtonSizeWH / 2),
            $0.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            $0.heightAnchor.constraint(equalToConstant: SelfPreviewBeautyEditView.hideButtonSizeWH),
            $0.widthAnchor.constraint(equalToConstant: SelfPreviewBeautyEditView.hideButtonSizeWH),
            $0.topAnchor.constraint(equalTo: topAnchor),
        ] }
    }

    // MARK: - Public

    @objc public func showInView(_ inView: UIView) {
        inView.addSubview(self)
        makeConstraints { [
            $0.leftAnchor.constraint(equalTo: inView.leftAnchor),
            $0.rightAnchor.constraint(equalTo: inView.rightAnchor),
            $0.bottomAnchor.constraint(equalTo: inView.bottomAnchor),
        ] }
        transform = CGAffineTransform(translationX: 0, y: SelfPreviewBeautyEditView.containerViewHeight + inView.safeAreaInsets.bottom)
        // Animate the container view
        UIView.animate(withDuration: SelfPreviewBeautyEditView.animationDuration, animations: { [weak self] in
            self?.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: { finish in
        })
    }

    @objc public func dismiss() {
        // Animate the container view
        UIView.animate(withDuration: SelfPreviewBeautyEditView.animationDuration, animations: { [weak self] in
            guard let self = self else { return }
            self.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
        }, completion: { finish in
            self.removeFromSuperview()
        })
        delegate?.editViewWillDismiss(self)
    }

    @objc public func updateBackgroundModels(_ models: [SelfPreviewBeautySelectionModelProtocol]) {
        backgroundSelectionView.updateModels(models)
    }

    @objc public func selectBackgroundModel(_ model: SelfPreviewBeautySelectionModelProtocol) {
        layoutIfNeeded()
        backgroundSelectionView.selectModel(model)
    }

    @objc public func updateBackgroundSelectedModel(_ model: SelfPreviewBeautySelectionModelProtocol) {
        backgroundSelectionView.updateSelectedModel(model)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension SelfPreviewBeautyEditView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: self)
        if containerView.frame.contains(location) {
            return false
        }

        return true
    }
}

// MARK: - SelfPreviewBeautySelectionViewDelegate

extension SelfPreviewBeautyEditView: SelfPreviewBeautySelectionViewDelegate {
    @objc func selectionView(_ selectionView: SelfPreviewBeautySelectionView, didSelectItemAt indexPath: IndexPath) {
        if selectionView == backgroundSelectionView {
            delegate?.editView(self, didSelectBackgroundAt: indexPath)
        }
    }

    @objc func selectionView(_ selectionView: SelfPreviewBeautySelectionView, didRemoveItemAt indexPath: IndexPath) {
        if selectionView == backgroundSelectionView {
            delegate?.editView(self, didRemoveBackgroundAt: indexPath)
        }
    }
}
