//
//  ViewController.swift
//  UITableViewDiffableSample
//
//  Created by s.wakasugi on 2024/07/11.
//

import UIKit

struct Food: Hashable {
    let id: UUID
    var name: String
}

enum Section: CaseIterable {
    case main
}

class ViewController: UIViewController {
    private var tableView: UITableView!
    /// データソース
    private var dataSource: UITableViewDiffableDataSource<Section, Food>!
    /// データの大元となる配列
    private var foodArray: [Food] = [
        Food(id: UUID(), name: "りんご"),
        Food(id: UUID(), name: "バナナ"),
        Food(id: UUID(), name: "オレンジ")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupDataSource()
        setupButtons()
        applySnapshot()
    }
    
    private func setupTableView() {
        tableView = UITableView(frame: view.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<Section, Food>(tableView: tableView) { tableView, indexPath, food in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = "\(food.name) (ID: \(food.id.uuidString.prefix(8)))"
            return cell
        }
    }
    
    /// 配列の内容をデータソースに反映
    private func applySnapshot(animatingDifferences: Bool = true) {
        // 配列を元にスナップショット作成
        var snapshot = NSDiffableDataSourceSnapshot<Section, Food>()
        snapshot.appendSections([.main])
        snapshot.appendItems(foodArray)
        // dataSourceに適用
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
    
    private func setupButtons() {
        let buttonTitles = ["🍌更新", "🍎追加", "🍊削除", "同ID🍎追加"]
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 10
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttonStack.addArrangedSubview(button)
        }
        
        view.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStack.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            updateBananas()
        case 1:
            addApple()
        case 2:
            removeOrange()
        case 3:
            addSameBanana()
        default:
            break
        }
    }
    
    /// 配列にある要素を編集
    private func updateBananas() {
        if let index = foodArray.firstIndex(where: { $0.name == "バナナ" }) {
            foodArray[index].name = "更新されたバナナ"
            applySnapshot()
        }
    }
    
    /// 配列に新規追加
    private func addApple() {
        let newApple = Food(id: UUID(), name: "りんご")
        foodArray.append(newApple)
        applySnapshot()
    }
    
    /// 配列にある要素を削除
    private func removeOrange() {
        foodArray.removeAll { $0.name == "オレンジ" }
        applySnapshot()
    }
    
    /// 配列にすでに存在するものと同IDを追加(クラッシュする)
    private func addSameBanana() {
        if let banana = foodArray.first(where: { $0.name == "バナナ" }) {
            let newBanana = Food(id: banana.id, name: "新バナナ")
            foodArray.append(newBanana)
            applySnapshot()
            /*
             クラッシュ
             *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Fatal: supplied item identifiers are not unique. Duplicate identifiers: {(
                 UITableViewDiffableSample.Food(id: 26ED61C0-93E9-4142-B394-D4AA5FD44610, name: "新バナナ")
             )}'
             */
        }
    }
}
