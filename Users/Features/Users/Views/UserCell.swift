import UIKit

final class UserCell: UICollectionViewCell {
    static let reuseIdentifier = "UserCell"

    // MARK: - Properties -

    private var imageLoadTask: Task<Void, Never>?
    private var imageLoader: ImageLoader?
    private var currentUser: User?
    var onFollowTapped: ((Int) -> Void)?

    var isFollowing: Bool = false {
        didSet {
            updateFollowButton()
            updateAccessibility()
        }
    }

    // MARK: - UI Components -

    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray5
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.systemBlue.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0 // Allow unlimited lines to prevent clipping
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private let locationIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "location.fill")
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .systemGray
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var locationStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [locationIconImageView, locationLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()

    private lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .subheadline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // Reputation badge (top right)
    private let reputationBadge: PaddedLabel = {
        let label = PaddedLabel(padding: UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .white
        label.backgroundColor = .systemOrange
        label.textAlignment = .center
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Badge counts
    private lazy var goldBadgeView = createBadgeView(color: .systemYellow)
    private lazy var silverBadgeView = createBadgeView(color: .systemGray)
    private lazy var bronzeBadgeView = createBadgeView(color: .systemBrown)

    private lazy var badgesStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [goldBadgeView, silverBadgeView, bronzeBadgeView])
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.axis = .horizontal // Default to horizontal, will update in layoutSubviews
        return stack
    }()

    private func createBadgeView(color: UIColor) -> UIStackView {
        let iconLabel = UILabel()
        iconLabel.text = "●"
        iconLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        iconLabel.adjustsFontForContentSizeCategory = true
        iconLabel.textColor = color

        let countLabel = UILabel()
        countLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        countLabel.adjustsFontForContentSizeCategory = true
        countLabel.textColor = .secondaryLabel
        countLabel.textAlignment = .left

        let stack = UIStackView(arrangedSubviews: [iconLabel, countLabel])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center

        return stack
    }

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [badgesStackView, nameLabel, locationStackView, followButton])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        imageLoader = nil
        currentUser = nil
        profileImageView.image = nil
        nameLabel.text = nil
        locationLabel.text = nil
        isFollowing = false
        onFollowTapped = nil

        // Reset badges
        (goldBadgeView.arrangedSubviews[1] as? UILabel)?.text = nil
        (silverBadgeView.arrangedSubviews[1] as? UILabel)?.text = nil
        (bronzeBadgeView.arrangedSubviews[1] as? UILabel)?.text = nil
        reputationBadge.text = nil

        // Reset accessibility
        accessibilityElements = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update shadow path to match current bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath

        // Recalculate badge layout based on available width
        let availableWidth = contentView.bounds.width - 24 // Account for padding
        updateBadgesStackOrientation(for: badgesStackView, availableWidth: availableWidth)
    }

    // MARK: - Configuration

    func configure(with user: User, imageLoader: ImageLoader) {
        currentUser = user
        self.imageLoader = imageLoader
        nameLabel.text = user.displayName

        if let location = user.location, !location.isEmpty {
            locationLabel.text = location
            locationStackView.isHidden = false
        } else {
            locationStackView.isHidden = true
        }

        // Configure badge counts
        (goldBadgeView.arrangedSubviews[1] as? UILabel)?.text = "\(user.badgeCounts.gold.formated)"
        (silverBadgeView.arrangedSubviews[1] as? UILabel)?.text = "\(user.badgeCounts.silver.formated)"
        (bronzeBadgeView.arrangedSubviews[1] as? UILabel)?.text = "\(user.badgeCounts.bronze.formated)"

        // Configure reputation badge
        reputationBadge.text = user.reputation.formated

        // Setup accessibility
        setupAccessibility()

        // Load image
        imageLoadTask?.cancel()
        profileImageView.image = nil

        guard let imageUrl = user.profileImage else { return }
        loadImage(from: imageUrl)
    }

    @objc private func followButtonTapped() {
        guard let userId = currentUser?.userId else { return }
        onFollowTapped?(userId)
    }
}

private extension UserCell {
    func setupViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(contentStackView)
        contentView.addSubview(reputationBadge)

        NSLayoutConstraint.activate([
            // Profile image at the top, centered
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            // Reputation badge in top right corner - auto-sizes based on content
            reputationBadge.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            reputationBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            // Location icon size
            locationIconImageView.widthAnchor.constraint(equalToConstant: 14),
            locationIconImageView.heightAnchor.constraint(equalToConstant: 14),

            // Follow button height
            followButton.heightAnchor.constraint(equalToConstant: 36),

            // Content stack below image
            contentStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 12),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        profileImageView.layer.cornerRadius = 40

        // Add button action
        followButton.addTarget(self, action: #selector(followButtonTapped), for: .touchUpInside)
    }

    func setupAppearance() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12

        // Apply shadow to the cell layer, not contentView
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        layer.masksToBounds = false

        // Clip content to contentView bounds
        contentView.layer.masksToBounds = true

        updateFollowButton()
    }

    func updateFollowButton() {
        if isFollowing {
            followButton.setTitle(L10n.Users.Button.following, for: .normal)
            followButton.backgroundColor = .systemGray5
            followButton.setTitleColor(.label, for: .normal)
        } else {
            followButton.setTitle(L10n.Users.Button.follow, for: .normal)
            followButton.backgroundColor = .systemBlue
            followButton.setTitleColor(.white, for: .normal)
        }
    }

    func loadImage(from url: URL) {
        guard let imageLoader = imageLoader else { return }

        imageLoadTask = Task {
            guard let image = try? await imageLoader.loadImage(from: url),
                  !Task.isCancelled else { return }

            await MainActor.run {
                self.profileImageView.image = image
            }
        }
    }

    /// Updates badge stack orientation based on available width and content
    /// Switches to vertical layout when badges won't fit horizontally
    func updateBadgesStackOrientation(for stackView: UIStackView, availableWidth: CGFloat) {
        // Calculate width needed for horizontal layout
        let badgeFont = UIFont.preferredFont(forTextStyle: .caption1)
        let iconWidth: CGFloat = 12 // Approximate width of "●"
        let spacing: CGFloat = 2 // Icon-to-number spacing
        let stackSpacing: CGFloat = 8 // Between badges

        // Estimate width for each badge (icon + space + typical number like "9.3k")
        let sampleText = "9.3k" as NSString
        let textWidth = sampleText.size(withAttributes: [.font: badgeFont]).width
        let singleBadgeWidth = iconWidth + spacing + textWidth

        // Total width needed for 3 badges side-by-side
        let totalHorizontalWidth = (singleBadgeWidth * 3) + (stackSpacing * 2)

        // Decide layout based on available width
        if availableWidth >= totalHorizontalWidth {
            // Enough width: use horizontal layout
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.distribution = .fillEqually
        } else {
            // Not enough width: stack vertically
            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.distribution = .fill
        }
    }

    // MARK: - Accessibility

    func setupAccessibility() {
        guard let user = currentUser else { return }

        // Make individual UI elements non-accessible (they'll be grouped)
        profileImageView.isAccessibilityElement = false
        nameLabel.isAccessibilityElement = false
        reputationBadge.isAccessibilityElement = false
        locationLabel.isAccessibilityElement = false
        locationIconImageView.isAccessibilityElement = false
        locationStackView.isAccessibilityElement = false
        goldBadgeView.isAccessibilityElement = false
        silverBadgeView.isAccessibilityElement = false
        bronzeBadgeView.isAccessibilityElement = false
        badgesStackView.isAccessibilityElement = false
        contentStackView.isAccessibilityElement = false

        // Create grouped accessibility element for cell content
        let cellContentElement = UIAccessibilityElement(accessibilityContainer: self)
        cellContentElement.accessibilityFrameInContainerSpace = contentView.frame
        cellContentElement.accessibilityLabel = buildAccessibilityLabel(for: user)
        cellContentElement.accessibilityTraits = .staticText

        // Configure follow button accessibility
        followButton.isAccessibilityElement = true
        followButton.accessibilityLabel = buildFollowButtonLabel(for: user)
        followButton.accessibilityHint = L10n.Accessibility.UserCell.FollowButton.hint
        followButton.accessibilityTraits = .button

        // Set custom accessibility elements: [cell content, follow button]
        accessibilityElements = [cellContentElement, followButton]
    }

    func updateAccessibility() {
        guard let user = currentUser else { return }

        // Update follow button label when state changes
        followButton.accessibilityLabel = buildFollowButtonLabel(for: user)
    }

    private func buildAccessibilityLabel(for user: User) -> String {
        var components: [String] = []

        // 1. Display name
        components.append(user.displayName)

        // 2. Reputation
        components.append(L10n.Accessibility.UserCell.reputation(user.reputation.formated))

        // 3. Location (if available)
        if let location = user.location, !location.isEmpty {
            components.append(L10n.Accessibility.UserCell.location(location))
        }

        // 4. Badges (gold, silver, bronze)
        let badgesText = L10n.Accessibility.UserCell.badges(
            gold: user.badgeCounts.gold.formated,
            silver: user.badgeCounts.silver.formated,
            bronze: user.badgeCounts.bronze.formated
        )
        components.append(badgesText)

        // Join with periods for natural VoiceOver pauses
        return components.joined(separator: ". ")
    }

    private func buildFollowButtonLabel(for user: User) -> String {
        if isFollowing {
            return L10n.Accessibility.UserCell.FollowButton.following(user.displayName)
        } else {
            return L10n.Accessibility.UserCell.FollowButton.follow(user.displayName)
        }
    }
}

// MARK: - PaddedLabel Helper

/// UILabel subclass that adds padding around text content
/// Ensures text doesn't get clipped when using Dynamic Type
final class PaddedLabel: UILabel {
    private let padding: UIEdgeInsets

    init(padding: UIEdgeInsets) {
        self.padding = padding
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom
        )
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let adjustedSize = CGSize(
            width: size.width - padding.left - padding.right,
            height: size.height - padding.top - padding.bottom
        )
        let textSize = super.sizeThatFits(adjustedSize)
        return CGSize(
            width: textSize.width + padding.left + padding.right,
            height: textSize.height + padding.top + padding.bottom
        )
    }
}
