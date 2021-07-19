//
//  SearchFriendsController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/24.
//

import UIKit

private let reuseIdentifier = "UserCell"
private let cellIdentifier = "FriendCell"

class SearchFriendsController: UIViewController {
    
    //MARK: - Properties
    
    private let tableView = UITableView()
    private var users = [User]()
    private var filteredUsers = [User]()
    private var friends = [User]()
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var inSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Hiclose friends🔥"
        label.textColor = .white
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.delegate = self
        cv.dataSource = self
        cv.backgroundColor = .backgroundColor
        cv.register(UserCell.self, forCellWithReuseIdentifier: cellIdentifier)
        return cv
    }()
    
    private var ifNoFriendLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "Find your friends🤥"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private var ifNoFriendLabel2: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "友達を検索してリクエストを送ろう！"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchController()
        configureUI()
        fetchFriends()
        friendsAreExist()
        fetchUsers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        navigationController?.navigationBar.barStyle = .black
    }
    
    //MARK: - API
    
    private func fetchFriends() {
        FriendService.fetchMyFriends { friends in
            self.friends = friends
            self.collectionView.reloadData()
        }
    }
    
    private func fetchUsers() {
        UserService.fetchUsers { users in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    private func friendsAreExist() {
        FriendService.friendsAreExist { bool in
            self.ifNoFriendLabel.isHidden = !bool
            self.ifNoFriendLabel2.isHidden = !bool
        }
    }
    
    //MARK: - Actions
    
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .backgroundColor
        navigationItem.title = "My Friends👋"
        navigationController?.navigationBar.isHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(handleDismissal))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationController?.navigationBar.barTintColor = .backgroundColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        tableView.backgroundColor = .backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 52
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        view.addSubview(descriptionLabel)
        descriptionLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                                right: view.rightAnchor, paddingTop: 8, paddingLeft: 16,
                                paddingRight: 16)
        
        view.addSubview(tableView)
        tableView.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor,
                         bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 8)
        tableView.isHidden = true
                
        view.addSubview(collectionView)
        collectionView.anchor(top: descriptionLabel.bottomAnchor, left: view.leftAnchor,
                              bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 8)
        
        let stack = UIStackView(arrangedSubviews: [ifNoFriendLabel, ifNoFriendLabel2])
        stack.axis = .vertical
        stack.spacing = 4
        
        collectionView.addSubview(stack)
        stack.centerX(inView: collectionView)
        stack.anchor(top: collectionView.topAnchor, paddingTop: 120)
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = .white
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = false
        UISearchBar.appearance().keyboardAppearance = UIKeyboardAppearance.dark
    }
}

//MARK: - UITableViewDataSource

extension SearchFriendsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filteredUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.viewModel = UserCellViewModel(user: user)
        return cell
    }
}

//MARK: - UITableViewDelegate

extension SearchFriendsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filteredUsers[indexPath.row] : users[indexPath.row]
        let controller = SearchUserProfileController()
        controller.viewModel = SearchUserProfileViewModel(user: user)
        presentPanModal(controller)
    }
}

//MARK: - UISearchBarDelegate

extension SearchFriendsController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        collectionView.isHidden = true
        tableView.isHidden = false
        descriptionLabel.text = "Let's search your new friends🔥"
        navigationItem.title = "Explore🤫"
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        
        collectionView.isHidden = false
        tableView.isHidden = true
        descriptionLabel.text = "Your Hiclose friends🔥"
        navigationItem.title = "My Friends👋"
    }
}

//MARK: - UISearchResultsUpdating
 
extension SearchFriendsController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        filteredUsers = users.filter({
            $0.username.contains(searchText) ||
                $0.fullname.lowercased().contains(searchText)
        })
        
        self.tableView.reloadData()
    }
}

//MARK: - UICollectionViewDataSource

extension SearchFriendsController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        friends.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! UserCell
        cell.viewModel = UserCellViewModel(user: friends[indexPath.row])
        return cell
    }
}

//MARK: - UICollectionViewDelegate

extension SearchFriendsController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("DEBUG: DID SELECT \(friends[indexPath.row])")
    }
}

//MARK: - UICollectionViewDelegateFlowLayout

extension SearchFriendsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2)  / 3
        return CGSize(width: width, height: width)
    }
}
