//
//  EditProfilViewController.swift
//  FootballApp
//
//  Created by Servan on 05.10.26.
//

//
//  EditProfileViewController.swift
//  FootballApp
//

import UIKit
import PhotosUI

final class EditProfileViewController: UIViewController {

    weak var coordinator: EditProfileNavigating?

    private let original: ProfileInfo
    private var selectedAvatar: UIImage?

    init(profile: ProfileInfo) {
        self.original = profile
        self.selectedAvatar = profile.avatar
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private enum Metrics {
        static let avatarSize: CGFloat = 110
        static let fieldHeight: CGFloat = 56
        static let maxPhotoSide: CGFloat = 600
    }

    private enum Limits {
        static let name = 30
        static let bio = 60
    }

    // MARK: - Views

    private lazy var avatarImageView: AvatarImageView = {
        let imageView = AvatarImageView(size: Metrics.avatarSize)
        imageView.setAvatar(selectedAvatar)
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(changePhotoTapped)))
        return imageView
    }()

    private lazy var changePhotoButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.title = "Change photo"
        config.baseForegroundColor = Palette.accent
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var c = container
            c.font = AppFonts.body.font
            return c
        }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        return button
    }()

    private lazy var nameField: AppTextField = {
        let field = AppTextField(
            placeholder: "Name",
            backgroundColor: .backgroundColor2,
            textColor: .titleColor,
            delegate: self
        )
        field.text = original.name
        field.textField.autocapitalizationType = .words
        field.textField.returnKeyType = .done
        field.textField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)
        return field
    }()

    private lazy var bioField: AppTextField = {
        let field = AppTextField(
            placeholder: "Bio",
            backgroundColor: .backgroundColor2,
            textColor: .titleColor,
            delegate: self
        )
        field.text = original.bio
        field.textField.returnKeyType = .done
        field.textField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)
        return field
    }()

    private let bioCounterLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.litletitle.font
        label.textColor = Palette.secondaryText
        label.textAlignment = .right
        return label
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private lazy var photoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [avatarImageView, changePhotoButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            photoStack,
            makeSection(title: "Name", field: nameField),
            makeSection(title: "Bio", field: bioField, footer: bioCounterLabel)
        ])
        stack.axis = .vertical
        stack.spacing = AppLayout.mediumSpacing.value
        return stack
    }()

    private lazy var saveItem = UIBarButtonItem(
        title: "Save",
        style: .done,
        target: self,
        action: #selector(saveTapped)
    )

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AssetColors.background.color
        configureNavigationBar()
        setupHierarchy()
        setupLayout()
        fieldsChanged()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: - Setup

    private func configureNavigationBar() {
        title = "Edit Profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = saveItem

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AssetColors.background.color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
    }

    private func setupHierarchy() {
        scrollView.addSubviews(contentStack)
        view.addSubviews(scrollView)
    }

    private func setupLayout() {
        let padding = AppLayout.screenPadding.value

        scrollView
            .top(view.safeAreaLayoutGuide.topAnchor).0
            .leading(view.leadingAnchor).0
            .trailing(view.trailingAnchor).0
            .bottom(view.keyboardLayoutGuide.topAnchor)

        contentStack
            .top(scrollView.contentLayoutGuide.topAnchor, AppLayout.spacing.value).0
            .leading(scrollView.contentLayoutGuide.leadingAnchor, padding).0
            .trailing(scrollView.contentLayoutGuide.trailingAnchor, -padding).0
            .bottom(scrollView.contentLayoutGuide.bottomAnchor, -padding).0
            .width(scrollView.frameLayoutGuide.widthAnchor, -padding * 2)

        avatarImageView
            .width(Metrics.avatarSize).0
            .height(Metrics.avatarSize)

        nameField.height(Metrics.fieldHeight)
        bioField.height(Metrics.fieldHeight)
    }

    private func makeSection(title: String, field: UIView, footer: UIView? = nil) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = AppFonts.semiBold.font
        label.textColor = .white

        var views: [UIView] = [label, field]
        if let footer { views.append(footer) }
        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }

    // MARK: - Actions

    @objc private func fieldsChanged() {
        let name = nameField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        saveItem.isEnabled = !name.isEmpty
        bioCounterLabel.text = "\(bioField.text.count)/\(Limits.bio)"
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func cancelTapped() {
        coordinator?.cancelEditProfile()
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        let updated = ProfileInfo(
            name: nameField.text.trimmingCharacters(in: .whitespacesAndNewlines),
            email: original.email,
            bio: bioField.text.trimmingCharacters(in: .whitespacesAndNewlines),
            avatar: selectedAvatar
        )
        coordinator?.didSaveProfile(updated)
    }

    @objc private func changePhotoTapped() {
        view.endEditing(true)
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Choose from library", style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        })
        if selectedAvatar != nil {
            sheet.addAction(UIAlertAction(title: "Remove photo", style: .destructive) { [weak self] _ in
                self?.setAvatar(nil)
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // iPad-də action sheet popover kimi açılır.
        sheet.popoverPresentationController?.sourceView = changePhotoButton
        sheet.popoverPresentationController?.sourceRect = changePhotoButton.bounds
        present(sheet, animated: true)
    }

    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func setAvatar(_ image: UIImage?) {
        selectedAvatar = image
        avatarImageView.setAvatar(image)
    }
}

// MARK: - UITextFieldDelegate

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let current = textField.text ?? ""
        guard let range = Range(range, in: current) else { return true }
        let updated = current.replacingCharacters(in: range, with: string)
        let limit = textField === bioField.textField ? Limits.bio : Limits.name
        return updated.count <= limit
    }
}

// MARK: - PHPickerViewControllerDelegate

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }
            let resized = image.resized(maxSide: Metrics.maxPhotoSide)
            DispatchQueue.main.async {
                self?.setAvatar(resized)
            }
        }
    }
}

// MARK: - Helpers

private enum Palette {
    static let accent = UIColor(red: 0.95, green: 0.62, blue: 0.50, alpha: 1)
    static let secondaryText = UIColor.white.withAlphaComponent(0.7)
}

private extension UIImage {
    /// Böyük şəkilləri yaddaşda saxlamamaq üçün kiçildir.
    func resized(maxSide: CGFloat) -> UIImage {
        let longest = max(size.width, size.height)
        guard longest > maxSide else { return self }
        let scale = maxSide / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
