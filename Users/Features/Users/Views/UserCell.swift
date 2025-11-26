import UIKit

final class UserCell: UICollectionViewCell {
    static let reuseIdentifier = "UserCell"

    // MARK: - Properties -

    private var imageLoadTask: Task<Void, Never>?
    var isFollowing: Bool = false {
        didSet {
            updateFollowButton()
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
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 2
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
        label.font = .systemFont(ofSize: 12, weight: .regular)
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
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, locationStackView, followButton])
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
        profileImageView.image = nil
        nameLabel.text = nil
        locationLabel.text = nil
        isFollowing = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update shadow path to match current bounds
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
    }

    // MARK: - Configuration

    func configure(with user: User) {
        nameLabel.text = user.displayName

        if let location = user.location, !location.isEmpty {
            locationLabel.text = location
            locationStackView.isHidden = false
        } else {
            locationStackView.isHidden = true
        }

        imageLoadTask?.cancel()
        profileImageView.image = nil

        guard let imageUrl = user.profileImage else { return }
        load(imageUrl: imageUrl)
    }
}

private extension UserCell {
    func setupViews() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            // Profile image at the top, centered
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            profileImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

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
            followButton.setTitle("Following", for: .normal)
            followButton.backgroundColor = .systemGray5
            followButton.setTitleColor(.label, for: .normal)
        } else {
            followButton.setTitle("Follow", for: .normal)
            followButton.backgroundColor = .systemBlue
            followButton.setTitleColor(.white, for: .normal)
        }
    }

    func load(imageUrl: URL) {
        imageLoadTask = Task {
            guard let image = try? await ImageLoader.shared.loadImage(from: imageUrl),
                  !Task.isCancelled else { return }

            await MainActor.run {
                self.profileImageView.image = image
            }
        }
    }
}
