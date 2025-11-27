import UIKit

private let reuseIdentifier = "Cell"

class UsersCollectionViewController: UICollectionViewController {

    // MARK: - Properties -

    var viewModel: UsersViewModel?

    var users = [User]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.collectionView.reloadData()
            }
        }
    }

    // MARK: - Constructors -

    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false

        // Configure collection view
        collectionView.backgroundColor = .systemGroupedBackground

        // Register cell classes
        self.collectionView?.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseIdentifier)

        // Register for trait changes (iOS 17+)
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (self: Self, _) in
            // Invalidate layout when Dynamic Type size changes
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionView.collectionViewLayout.invalidateLayout()
        })
    }

    // MARK: - UICollectionViewDataSource -

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: UserCell.reuseIdentifier,
            for: indexPath
        ) as? UserCell else {
            fatalError("Unable to dequeue UserCell")
        }

        let user = users[indexPath.item]
        guard let viewModel = viewModel else { return cell }

        cell.configure(with: user, imageLoader: viewModel.imageLoader)
        cell.isFollowing = viewModel.isFollowing(userId: user.userId)
        cell.onFollowTapped = { [weak self] userId in
            self?.handleFollowTapped(userId: userId)
        }

        return cell
    }
}

private extension UsersCollectionViewController {
    func handleFollowTapped(userId: Int) {
        viewModel?.toggleFollow(userId: userId)

        // Update the specific cell
        if let index = users.firstIndex(where: { $0.userId == userId }),
           let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? UserCell {
            cell.isFollowing = viewModel?.isFollowing(userId: userId) ?? false
        }
    }
}

extension UsersCollectionViewController {
    func update(viewModel: UsersViewModel?) {
        self.viewModel = viewModel
        users = viewModel?.users ?? []
    }
}

// MARK: - UICollectionViewDelegateFlowLayout -

extension UsersCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        // Use trait collection for reliable orientation detection
        let isLandscape = traitCollection.verticalSizeClass == .compact
        let numberOfColumns: CGFloat = isLandscape ? 3 : 2

        // Layout constants
        let sectionInset: CGFloat = 16 * 2 // left + right
        let interItemSpacing: CGFloat = 12
        let totalSpacing = sectionInset + (interItemSpacing * (numberOfColumns - 1))
        let availableWidth = collectionView.bounds.width - totalSpacing
        let width = floor(availableWidth / numberOfColumns)

        // Calculate dynamic height based on content and accessibility settings
        let height = calculateCellHeight(for: width)

        return CGSize(width: width, height: height)
    }

    /// Calculates cell height dynamically based on content and Dynamic Type settings
    private func calculateCellHeight(for width: CGFloat) -> CGFloat {
        // Fixed components
        let profileImageSize: CGFloat = 80
        let topPadding: CGFloat = 12
        let bottomPadding: CGFloat = 12
        let imageBottomSpacing: CGFloat = 12
        let stackSpacing: CGFloat = 8
        let cellPadding: CGFloat = 24 // Left + right padding

        // Calculate available width for content
        let availableWidth = width - cellPadding

        // Badge height depends on whether they'll stack based on width
        let badgesHeight: CGFloat = calculateBadgesHeight(availableWidth: availableWidth)

        // Name height - use generous estimate since numberOfLines = 0
        let nameFont = UIFont.preferredFont(forTextStyle: .body)
        let nameLineHeight = nameFont.lineHeight
        // Assume max 3 lines for name to handle longer names with large text
        let nameHeight = nameLineHeight * 3

        let locationHeight = estimatedHeight(for: .caption1) + 4 // Location + icon spacing
        let buttonHeight: CGFloat = max(36, estimatedHeight(for: .subheadline) + 16) // Button with min height

        // Calculate total
        let contentHeight = profileImageSize
            + imageBottomSpacing
            + badgesHeight
            + stackSpacing
            + nameHeight
            + stackSpacing
            + locationHeight
            + stackSpacing
            + buttonHeight

        let totalHeight = topPadding + contentHeight + bottomPadding

        // Ensure minimum height for usability
        return max(totalHeight, 230)
    }

    /// Calculates badge height based on whether they'll be horizontal or vertical
    private func calculateBadgesHeight(availableWidth: CGFloat) -> CGFloat {
        let badgeFont = UIFont.preferredFont(forTextStyle: .caption1)
        let iconWidth: CGFloat = 12
        let spacing: CGFloat = 2
        let stackSpacing: CGFloat = 8

        let sampleText = "9.3k" as NSString
        let textWidth = sampleText.size(withAttributes: [.font: badgeFont]).width
        let singleBadgeWidth = iconWidth + spacing + textWidth
        let totalHorizontalWidth = (singleBadgeWidth * 3) + (stackSpacing * 2)

        let badgeLineHeight = badgeFont.lineHeight

        if availableWidth >= totalHorizontalWidth {
            // Horizontal: single row
            return badgeLineHeight
        } else {
            // Vertical: 3 badges stacked
            return (badgeLineHeight * 3) + (stackSpacing * 2)
        }
    }

    /// Estimates height for a given text style considering Dynamic Type
    private func estimatedHeight(for style: UIFont.TextStyle, numberOfLines: Int = 1, width: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
        let font = UIFont.preferredFont(forTextStyle: style)
        let lineHeight = font.lineHeight
        return lineHeight * CGFloat(numberOfLines)
    }
}
