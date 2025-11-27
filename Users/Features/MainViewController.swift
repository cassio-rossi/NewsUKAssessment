import AnalyticsLibrary
import LoggerLibrary
import UIKit

class MainViewController: UIViewController {

    // MARK: - Properties -

    private let viewModel: UsersViewModel = ViewModelFactory.usersViewModel
    private var usersViewController: UsersCollectionViewController?

    private var logger: LoggerProtocol? { viewModel.logger }

    // MARK: - UI Components -

    private lazy var errorMessage: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "network.error"
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

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Users.Button.retry, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle -

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.Users.title

        setupUI()
        setupUsersViewController()
        fetchUsers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.analytics.track(.screenView(name: "Users"))
    }
}

// MARK: - Setup -

private extension MainViewController {
    func setupUI() {
        stackView.addArrangedSubview(errorMessage)
        stackView.addArrangedSubview(retryButton)
        stackView.addArrangedSubview(containerView)
        stackView.spacing = 16

        view.addSubview(stackView)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            retryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }

    @objc func retryButtonTapped() {
        fetchUsers()
    }

    func setupUsersViewController() {
        let usersVC = UsersCollectionViewController()
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
            // Show loading indicator, hide error and retry button
            errorMessage.text = nil
            retryButton.isHidden = true
            containerView.isHidden = true
            loadingIndicator.startAnimating()

            do {
                try await viewModel.getUsers()
                logger?.info("\(viewModel.users.count) users loaded")

                // Hide loading indicator
                loadingIndicator.stopAnimating()

                // Check for empty state
                if viewModel.users.isEmpty {
                    errorMessage.text = L10n.Users.Error.notfound
                    containerView.isHidden = true
                    if let message = errorMessage.text {
                        UIAccessibility.post(notification: .announcement, argument: message)
                    }
                } else {
                    containerView.isHidden = false
                    usersViewController?.update(viewModel: viewModel)
                }
            } catch {
                // Hide loading indicator
                loadingIndicator.stopAnimating()

                logger?.error("Failed to load users: \(error)")
                errorMessage.text = viewModel.error?.description

                // Show retry button only for network errors
                if case .network = viewModel.error {
                    retryButton.isHidden = false
                }

                if let message = errorMessage.text, !message.isEmpty {
                    UIAccessibility.post(notification: .announcement, argument: "Error: \(message)")
                }
            }
        }
    }
}
