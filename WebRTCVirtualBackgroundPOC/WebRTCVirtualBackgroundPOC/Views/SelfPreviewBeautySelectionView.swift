//
//  SelfPreviewBeautySelectionView.swift
//  Glip
//
//  Created by Jamie Yao on 2020/9/1.
//  Copyright © 2020 RingCentral. All rights reserved.
//

import UIKit

protocol SelfPreviewBeautySelectionViewDelegate: class {
    func selectionView(_ selectionView: SelfPreviewBeautySelectionView, didSelectItemAt indexPath: IndexPath)
    func selectionView(_ selectionView: SelfPreviewBeautySelectionView, didRemoveItemAt indexPath: IndexPath)
}

@objc protocol SelfPreviewBeautySelectionModelProtocol {
    /// Properties for UI
    var backgroundImage: UIImage? { get }
    var textColor: UIColor? { get }
    var titleFont: UIFont? { get }
    var title: String? { get }
    var selectable: Bool { get }
    var removable: Bool { get }
    var isMore: Bool { get }
    var accesibilityString: String { get }

    /// Property for model compare
    var identifier: String { get }
}

class SelfPreviewBeautySelectionView: UIView {
    // MARK: - Constants

    /// 82.0 = (backgroundImageSize 64) + (backgroundImageViewInset 3) * 2 + (containerViewTopRightInset 13)
    private static let itemSize = CGSize(width: 160.0, height: 83.0)

    /// 13.0 = (Design inset 16.0) - (backgroundImageViewInset 3)
    private static let collectionViewHorizontalInset: CGFloat = 13.0

    /// 1.0 = (Removebutton right to next item backgroundImage left spacing 4.0) - (backgroundImageViewInset 3)
    private static let itemSpacing: CGFloat = 1.0

    static let selectionViewheight: CGFloat = 100.0
    static let backgroundImageSize: CGSize = CGSize(width: 64.0, height: 64.0)

    weak var delegate: SelfPreviewBeautySelectionViewDelegate?

    private var models: [SelfPreviewBeautySelectionModelProtocol] = []
    private var lastSelectedModel: SelfPreviewBeautySelectionModelProtocol?

    private var collectionView: UICollectionView = {
        let horizontalSectionInset = SelfPreviewBeautySelectionView.collectionViewHorizontalInset
        let itemSpacing = SelfPreviewBeautySelectionView.itemSpacing
        let itemSize = SelfPreviewBeautySelectionView.itemSize
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: horizontalSectionInset, bottom: 0, right: horizontalSectionInset)
        layout.minimumLineSpacing = itemSpacing
        layout.itemSize = itemSize

        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsHorizontalScrollIndicator = false
        let reuseIdentifier = NSStringFromClass(SelfPreviewBeautySelectionCell.self)
        collectionView.register(SelfPreviewBeautySelectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        return collectionView
    }()

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
        collectionView.delegate = self
        collectionView.dataSource = self
        addSubview(collectionView)
        collectionView.makeConstraints { [
            $0.topAnchor.constraint(equalTo: topAnchor),
            $0.leadingAnchor.constraint(equalTo: leadingAnchor),
            $0.trailingAnchor.constraint(equalTo: trailingAnchor),
            $0.heightAnchor.constraint(equalToConstant: SelfPreviewBeautySelectionView.itemSize.height),
        ] }
    }

    // MARK: - Public

    public func updateModels(_ models: [SelfPreviewBeautySelectionModelProtocol]) {
        self.models = models
        collectionView.reloadData()
    }

    public func selectModel(_ model: SelfPreviewBeautySelectionModelProtocol) {
        if let selectedIndex = models.firstIndex(where: { $0.identifier == model.identifier }) {
            let selectedIndexPath = IndexPath(item: selectedIndex, section: 0)
            updateCellsSelectedStatus(selectedIndexPath: selectedIndexPath)
            collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
        }
    }

    public func updateSelectedModel(_ model: SelfPreviewBeautySelectionModelProtocol) {
        lastSelectedModel = model
    }
}

// MARK: - UICollectionViewDataSource

extension SelfPreviewBeautySelectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = NSStringFromClass(SelfPreviewBeautySelectionCell.self)

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? SelfPreviewBeautySelectionCell else {
            return UICollectionViewCell()
        }

        let model = models[indexPath.item]
        cell.configure(with: model)
        cell.delegate = self

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let model = models[indexPath.item]
        let isSelected = (model.identifier == lastSelectedModel?.identifier)
        guard let cell = cell as? SelfPreviewBeautySelectionCell else {
            return
        }
        cell.updateSelected(isSelected)
    }
}

// MARK: - UICollectionViewDelegate

extension SelfPreviewBeautySelectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        delegate?.selectionView(self, didSelectItemAt: indexPath)
        updateCellsSelectedStatus(selectedIndexPath: indexPath)
    }

    private func updateCellsSelectedStatus(selectedIndexPath: IndexPath) {
        let model = models[selectedIndexPath.item]
        // Return unselectable model
        guard model.selectable else {
            return
        }

        // Unselect last selected cell
        if let lastSelectedModel = lastSelectedModel {
            if let lastSelectedIndex = models.firstIndex(where: { $0.identifier == lastSelectedModel.identifier }) {
                let lastSelectedIndexPath = IndexPath(item: lastSelectedIndex, section: 0)
                let cell = collectionView.cellForItem(at: lastSelectedIndexPath) as? SelfPreviewBeautySelectionCell
                cell?.updateSelected(false)
            }
        }

        // Select cell
        let cell = collectionView.cellForItem(at: selectedIndexPath) as? SelfPreviewBeautySelectionCell
        cell?.updateSelected(true)
        lastSelectedModel = model
    }
}

extension SelfPreviewBeautySelectionView: SelfPreviewBeautySelectionCellDelegate {
    func selectionCellDidTapRemove(_ selectionCell: SelfPreviewBeautySelectionCell) {
        if let indexPath = collectionView.indexPath(for: selectionCell) {
            delegate?.selectionView(self, didRemoveItemAt: indexPath)
        }
    }

    func selectionCellDidTapAdd(_ selectionCell: SelfPreviewBeautySelectionCell) {
        if let indexPath = collectionView.indexPath(for: selectionCell) {
            delegate?.selectionView(self, didSelectItemAt: indexPath)
        }
    }
}

protocol SelfPreviewBeautySelectionCellDelegate: class {
    func selectionCellDidTapRemove(_ selectionCell: SelfPreviewBeautySelectionCell)
    func selectionCellDidTapAdd(_ selectionCell: SelfPreviewBeautySelectionCell)
}

class SelfPreviewBeautySelectionCell: UICollectionViewCell {
    /// Selected state has border, Design is outside border but iOS is inside border. Design inset is 2.0, so we need 3.0.
    private static let backgroundImageViewInset: CGFloat = 3.0

    /// Design backgroundImage with remove button right and top inset is 16.0. backgroundImageViewInset is 3.0, so containerViewTopRightInset = 16.0 - 3.0
    private static let containerViewTopRightInset: CGFloat = 13.0

    private lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.layer.borderColor = UIColor(red: 9, green: 187, blue: 253, alpha: 1).cgColor
        containerView.layer.cornerRadius = 12.0
        return containerView
    }()

    private var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12.0
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 13.0, weight: .medium)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        return titleLabel
    }()

    private var actionButton: UIButton = {
        let actionButton = UIButton(type: .custom)
        return actionButton
    }()

    weak var delegate: SelfPreviewBeautySelectionCellDelegate?

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
        // containerView
        contentView.addSubview(containerView)
        let containerViewTopRightInset = SelfPreviewBeautySelectionCell.containerViewTopRightInset
        containerView.makeConstraintsToBindToSuperview(UIEdgeInsets(top: containerViewTopRightInset, left: 0, bottom: 0, right: containerViewTopRightInset))

        // backgroundImageView
        containerView.addSubview(backgroundImageView)
        let backgroundImageViewInset = SelfPreviewBeautySelectionCell.backgroundImageViewInset
        backgroundImageView.makeConstraintsToBindToSuperview(UIEdgeInsets(top: backgroundImageViewInset, left: backgroundImageViewInset, bottom: backgroundImageViewInset, right: backgroundImageViewInset))

        // titleLabel
        containerView.addSubview(titleLabel)
        titleLabel.makeConstraints { [
            $0.centerYAnchor.constraint(equalTo: backgroundImageView.centerYAnchor),
            $0.centerXAnchor.constraint(equalTo: backgroundImageView.centerXAnchor),
            $0.leadingAnchor.constraint(equalTo: backgroundImageView.leadingAnchor, constant: 8.0),
            $0.trailingAnchor.constraint(equalTo: backgroundImageView.trailingAnchor, constant: -8.0),
        ] }

        // removeButton, add to contentView
        contentView.addSubview(actionButton)
        actionButton.makeConstraints { [
            $0.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            $0.topAnchor.constraint(equalTo: contentView.topAnchor),
        ] }
    }

    // MARK: - Public

    public func configure(with model: SelfPreviewBeautySelectionModelProtocol) {
        backgroundImageView.image = model.backgroundImage
        titleLabel.textColor = model.textColor
        titleLabel.font = model.titleFont
        titleLabel.text = model.title
        containerView.accessibilityLabel = model.accesibilityString
        if model.isMore {
            actionButton.accessibilityLabel = "Add"
            actionButton.isHidden = false
            if RcvXVbgModel.isLessThanMaximumCustomImageCount {
                actionButton.setImage(UIImage(named: "btn_rcv_virtual_background_add"), for: .normal)
            } else {
                actionButton.setImage(UIImage(named: "btn_rcv_virtual_background_add_disabled"), for: .normal)
            }
            actionButton.removeTarget(self, action: #selector(removeAction(sender:)), for: .touchUpInside)
            actionButton.addTarget(self, action: #selector(addAction(sender:)), for: .touchUpInside)
        } else {
            actionButton.setImage(UIImage(named: "btn_rcv_virtual_background_remove"), for: .normal)
            actionButton.accessibilityLabel = "Delete"
            actionButton.isHidden = !model.removable
            actionButton.removeTarget(self, action: #selector(addAction(sender:)), for: .touchUpInside)
            actionButton.addTarget(self, action: #selector(removeAction(sender:)), for: .touchUpInside)
        }
    }

    public func updateSelected(_ selected: Bool) {
        if selected {
            containerView.layer.borderWidth = 1
        } else {
            containerView.layer.borderWidth = 0
        }
    }

    // MARK: - Actions

    @objc private func removeAction(sender: UIButton) {
        delegate?.selectionCellDidTapRemove(self)
    }

    @objc private func addAction(sender: UIButton) {
        delegate?.selectionCellDidTapAdd(self)
    }
}
