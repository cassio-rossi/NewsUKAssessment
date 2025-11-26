import AnalyticsLibrary
import LoggerLibrary
import UIKit

class MainViewController: UIViewController {

    // MARK: - Properties -

    private let logger = Logger(category: "stackoverflow.users")
    private let analytics = Analytics()
    private let viewModel: UsersViewModel = ViewModelFactory.usersViewModel
    private var usersViewController: UIViewController?

    // MARK: - UI Components -

    private lazy var errorMessage: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Lifecycle -

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        setupUsersViewController()
        fetchUsers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analytics.track(.screenView(name: "Users"))
    }
}

// MARK: - Setup -

private extension MainViewController {
    func setupUI() {
        stackView.addArrangedSubview(errorMessage)
        stackView.addArrangedSubview(containerView)

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    func setupUsersViewController() {
        let usersVC = UIViewController() // UsersCollectionViewController()
        usersViewController = usersVC
        addChild(usersVC)

        usersVC.loadViewIfNeeded()

        usersVC.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(usersVC.view)

        NSLayoutConstraint.activate([
            usersVC.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            usersVC.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            usersVC.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            usersVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        usersVC.didMove(toParent: self)
    }
}

// MARK: - Load content -

private extension MainViewController {
    func fetchUsers() {
        Task {
            errorMessage.text = nil
            containerView.isHidden = true
            do {
                try await viewModel.getUsers()
                logger.info("\(viewModel.users.count) users loaded")
                containerView.isHidden = false
                // usersViewController?.update(viewModel: viewModel)
            } catch {
                logger.error("Failed to load users: \(error)")
                errorMessage.text = viewModel.error?.description
                if let message = errorMessage.text, !message.isEmpty {
                    UIAccessibility.post(notification: .announcement, argument: "Error: \(message)")
                }
            }
        }
    }
}
