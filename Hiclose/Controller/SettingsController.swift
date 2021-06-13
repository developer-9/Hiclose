//
//  SettingsController.swift
//  Hiclose
//
//  Created by Taisei Sakamoto on 2021/05/04.
//

import UIKit
import Firebase

private let accountIdentifier = "AccountCell"
private let infoIdentifier = "InfoCell"
private let actionIdentifier = "ActionCell"


class SettingsController: UIViewController {
    
    //MARK: - Properties
    
    private let tableView = UITableView()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
        navigationController?.navigationBar.barStyle = .black
    }
        
    //MARK: - Actions
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Helpers
    
    private func configureUI() {
        connfigureTableView()
        navigationItem.title = "Settings"
        
        let image = UIImage(systemName: "multiply")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self,
                                                           action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationController?.navigationBar.barTintColor = .backgroundColor
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private func connfigureTableView() {
        tableView.backgroundColor = .backgroundColor
        tableView.rowHeight = 48
        tableView.tableFooterView = UIView()
        tableView.register(AccountCell.self, forCellReuseIdentifier: accountIdentifier)
        tableView.register(InfoCell.self, forCellReuseIdentifier: infoIdentifier)
        tableView.register(ActionCell.self, forCellReuseIdentifier: actionIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.frame = view.frame
    }
}

//MARK: - UITableViewDataSource

extension SettingsController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? 4 : 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "MY ACCOUNT"
        } else if section == 1 {
            return "INFORMATION"
        } else {
            return "ACTIONS"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: accountIdentifier, for: indexPath) as! AccountCell
            let viewModel = AccountViewModel(rawValue: indexPath.row)
            cell.viewModel = viewModel
            cell.accessoryType = .disclosureIndicator
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: infoIdentifier, for: indexPath) as! InfoCell
            let viewModel = InformationViewModel(rawValue: indexPath.row)
            cell.viewModel = viewModel
            cell.accessoryType = .disclosureIndicator
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: actionIdentifier, for: indexPath) as! ActionCell
            let viewModel = ActionsViewModel(rawValue: indexPath.row)
            cell.viewModel = viewModel
            cell.accessoryType = .disclosureIndicator
            return cell
            
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let label = UILabel()
        label.frame = CGRect(x: 20, y: 8, width: 320, height: 40)
        label.textColor = .white
        label.font = UIFont.init(name: "GillSans", size: 16)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)

        let headerView = UIView()
        headerView.backgroundColor = .backgroundColor
        headerView.addSubview(label)
        label.anchor(left: headerView.leftAnchor, paddingLeft: 20)
        label.centerY(inView: headerView)

        return headerView
    }
}

//MARK: - UITableViewDelegate

extension SettingsController: UITableViewDelegate {
    
}
