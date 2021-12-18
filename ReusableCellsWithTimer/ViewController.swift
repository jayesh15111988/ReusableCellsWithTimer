//
//  ViewController.swift
//  ReusableCellsWithTimer
//
//  Created by Jayesh Kawli on 12/17/21.
//

import UIKit

class ViewController: UIViewController {

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()
    
    var cellRowToTimerMapping: [Int: Timer] = [:]
    var cellRowToPauseFlagMapping: [Int: Bool] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Setup title
        title = "Cells with Timer"
        
        // Setup Table view
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        // Tableview Constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        setupTimer(for: cell, indexPath: indexPath)
        return cell
    }
    
    private func setupTimer(for cell: UITableViewCell, indexPath: IndexPath) {
        let row = indexPath.row
        if cellRowToTimerMapping[row] == nil {
            var numberOfSecondsPassed = 0
            let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { capturedTimer in
                
                if self.cellRowToPauseFlagMapping[row] != nil && self.cellRowToPauseFlagMapping[row] == true {
                    return
                }
                                
                numberOfSecondsPassed += 1
                
                let visibleCell = self.tableView.cellForRow(at: indexPath)

                if let visibleCell = visibleCell {
                    visibleCell.textLabel?.text = "\(String(numberOfSecondsPassed)) seconds before update"
                }

                if numberOfSecondsPassed == 10 {
                    numberOfSecondsPassed = 0
                    self.cellRowToPauseFlagMapping[row] = true
                    if let visibleCell = visibleCell {
                        visibleCell.textLabel?.text = "Loading..."
                    }
                    self.makeNetworkCall {
                        self.cellRowToPauseFlagMapping[row] = false
                    }
                }
            }
            cellRowToTimerMapping[row] = timer
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    private func makeNetworkCall(completion: @escaping () -> Void) {
        let seconds = 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
}

