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
        cell.configure(with: user)
        cell.isFollowing = viewModel?.isFollowing(userId: user.userId) ?? false
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
        let numberOfColumns: CGFloat
        let isLandscape = collectionView.bounds.width > collectionView.bounds.height

        if isLandscape {
            numberOfColumns = 3
        } else {
            numberOfColumns = 2
        }

        let sectionInset: CGFloat = 16 * 2 // left + right
        let interItemSpacing: CGFloat = 12
        let totalSpacing = sectionInset + (interItemSpacing * (numberOfColumns - 1))
        let availableWidth = collectionView.bounds.width - totalSpacing
        let width = floor(availableWidth / numberOfColumns)

        return CGSize(width: width, height: 200)
    }
}
