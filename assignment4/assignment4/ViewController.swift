//
//  ViewController.swift
//  assignment4
//
//  Created by Kato on 2/4/25.
//
import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let contactsVC = ContactsViewController()
        let navController = UINavigationController(rootViewController: contactsVC)
        addChild(navController)
        view.addSubview(navController.view)
        navController.view.frame = view.bounds
        navController.didMove(toParent: self)
    }
}

struct Contact {
    let name: String
    let number: String
}

class ContactsViewController: UIViewController {
    var contactsDict: [String: [Contact]] = [:]
    var expandedSections: Set<String> = []
    var isListView = true
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(ContactCell.self, forCellWithReuseIdentifier: "cell")
        collection.register(CollectionHeaderView.self,
                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                          withReuseIdentifier: "header")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.backgroundColor = .white
        return collection
    }()
    
    lazy var toggleButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "square.grid.2x2"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(toggleLayout))
        return button
    }()
    
    lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add,
                                   target: self,
                                   action: #selector(addContact))
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItems = [toggleButton]
        view.addSubview(tableView)
        view.addSubview(collectionView)
        setupConstraints()
        updateView()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func updateView() {
        tableView.isHidden = !isListView
        collectionView.isHidden = isListView
        toggleButton.image = UIImage(systemName: isListView ? "square.grid.2x2" : "list.bullet")
    }
    
    @objc func toggleLayout() {
        isListView.toggle()
        updateView()
    }
    
    @objc func addContact() {
        let alert = UIAlertController(title: "New Contact",
                                    message: "Enter name and number",
                                    preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Name" }
        alert.addTextField {
            $0.placeholder = "Phone Number"
            $0.keyboardType = .phonePad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
            if let name = alert.textFields?[0].text, !name.isEmpty,
               let number = alert.textFields?[1].text, !number.isEmpty {
                self.insertContact(name: name, number: number)
            }
        })
        present(alert, animated: true)
    }
    
    func insertContact(name: String, number: String) {
        let firstLetter = String(name.prefix(1)).uppercased()
        if contactsDict[firstLetter] == nil {
            contactsDict[firstLetter] = []
        }
        contactsDict[firstLetter]?.append(Contact(name: name, number: number))
        contactsDict[firstLetter]?.sort { $0.name < $1.name }
        expandedSections.insert(firstLetter)
        tableView.reloadData()
        collectionView.reloadData()
    }
}

class ContactCell: UICollectionViewCell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray6
        contentView.layer.cornerRadius = 10
        
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CollectionHeaderView: UICollectionReusableView {
    let label = UILabel()
    let button = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(label)
        addSubview(button)
        
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactsDict.keys.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let key = Array(contactsDict.keys.sorted())[section]
        let headerView = UIView()
        headerView.backgroundColor = UIColor(white: 0.9, alpha: 0.5)
        
        let label = UILabel()
        label.text = "  \(key)"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle(expandedSections.contains(key) ? "Collapse" : "Expand", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = section
        button.addTarget(self, action: #selector(toggleSection(_:)), for: .touchUpInside)
        
        headerView.addSubview(label)
        headerView.addSubview(button)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            button.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -8),
            button.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(contactsDict.keys.sorted())[section]
        return expandedSections.contains(key) ? contactsDict[key]?.count ?? 0 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let key = Array(contactsDict.keys.sorted())[indexPath.section]
        if let contact = contactsDict[key]?[indexPath.row] {
            cell.textLabel?.text = "\(contact.name) - \(contact.number)"
            cell.textLabel?.font = .systemFont(ofSize: 17)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let key = Array(contactsDict.keys.sorted())[indexPath.section]
            contactsDict[key]?.remove(at: indexPath.row)
            
            if contactsDict[key]?.isEmpty ?? false {
                contactsDict.removeValue(forKey: key)
            }
            
            tableView.reloadData()
            collectionView.reloadData()
        }
    }
    
    @objc func toggleSection(_ sender: UIButton) {
        let key = Array(contactsDict.keys.sorted())[sender.tag]
            
            if expandedSections.contains(key) {
                expandedSections.remove(key)
            } else {
                expandedSections.insert(key)
            }
            
            tableView.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
            collectionView.reloadSections(IndexSet(integer: sender.tag))
    }
}

extension ContactsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return contactsDict.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let key = Array(contactsDict.keys.sorted())[section]
            return expandedSections.contains(key) ? (contactsDict[key]?.count ?? 0) : 0 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ContactCell
        let key = Array(contactsDict.keys.sorted())[indexPath.section]
        if let contact = contactsDict[key]?[indexPath.row] {
            cell.label.text = "\(contact.name)\n\(contact.number)"
            cell.label.font = .systemFont(ofSize: 17)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath) as! CollectionHeaderView
            
            let key = Array(contactsDict.keys.sorted())[indexPath.section]
            headerView.label.text = key
            headerView.button.setTitle(expandedSections.contains(key) ? "Collapse" : "Expand", for: .normal)
            headerView.button.tag = indexPath.section
            headerView.button.addTarget(self, action: #selector(toggleSection(_:)), for: .touchUpInside)
            
            return headerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 44)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 30) / 2
        return CGSize(width: width, height: width * 0.75)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let key = Array(contactsDict.keys.sorted())[indexPath.section]
        let contact = contactsDict[key]?[indexPath.row]
        
        let alert = UIAlertController(title: "Delete Contact?", message: "Are you sure you want to delete \(contact?.name ?? "this contact")?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.contactsDict[key]?.remove(at: indexPath.row)
            if self.contactsDict[key]?.isEmpty ?? false {
                self.contactsDict.removeValue(forKey: key)
            }
            self.collectionView.reloadData()
            self.tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}
