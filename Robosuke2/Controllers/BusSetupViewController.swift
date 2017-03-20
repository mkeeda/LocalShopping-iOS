//
//  BusSetupViewController.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 3/13/17.
//  Copyright © 2017 IppeiMUKAIDA. All rights reserved.
//

import UIKit
import Alamofire

enum BusSetupStatus: String {
    case area = "お住いの地域選択"
    case busLine = "よく使うバス路線選択"
    case busStop = "最寄りのバス停選択"
}

class BusSetupViewController: UIViewController {

    let tableView = UITableView()

    var setupStatus: BusSetupStatus
    var params: [String: BusInfo]
    var options: [BusInfo] = []

    init(params: [String: BusInfo], setupStatus: BusSetupStatus) {
        self.setupStatus = setupStatus
        self.params = params
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.frame = UIScreen.main.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "busSetupCell")
        self.view.addSubview(tableView)

		let backButton = UIBarButtonItem()
		backButton.title = "戻る"
		navigationItem.backBarButtonItem = backButton

        navigationItem.title = setupStatus.rawValue

        updateOptions()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func updateOptions() {
        switch setupStatus {
        case .area:
            AuthorizationModel.sharedInstance.callArray(request: Endpoint.RequestArea.get, completion: reloadDataInMainQueue)
        case .busLine:
            guard let areaId = params["area"]?.id else { return }
            AuthorizationModel.sharedInstance.callArray(request: Endpoint.RequestBusLine.get(areaId: areaId), completion: reloadDataInMainQueue)
        case .busStop:
            guard let lineName = params["busLine"]?.name else { return }
            AuthorizationModel.sharedInstance.callArray(request: Endpoint.RequestBusStop.get(lineName: lineName), completion: reloadDataInMainQueue)
        }
    }

    func reloadDataInMainQueue(_ response: Result<[BusInfo]>) {
        switch response {
        case .success(let result):
            self.options = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        case .failure(let error):
            print(error)
        }
    }

    func editUserProfile(completion: @escaping () -> Void) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard
            let userProfile = appDelegate.user?.userProfile,
            let area = params["area"],
            let busLine = params["busLine"],
            let busStop = params["busStop"]
            else { return }
        userProfile.area = area
        userProfile.busLine = busLine
        userProfile.busStop = busStop
        API.call(request: Endpoint.Login.authorization) { response in
            switch response {
            case .success(let result):
                appDelegate.login = result
                AuthorizationModel.sharedInstance.call(request: Endpoint.RequestUserProfile.put(userProfile: userProfile)) { response in
                    switch response {
                    case .success(let result):
                        print(result)
                        completion()
                    case .failure(let error):
                        print(error)
                        let alert = UIAlertController(title: "ユーザプロファイル編集失敗", message: nil, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "戻る", style: .cancel, handler: nil)
                        alert.addAction(cancelAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "ログイン失敗", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "戻る", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension BusSetupViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "busSetupCell", for: indexPath)
        cell.textLabel?.text = options[indexPath.row].name
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch setupStatus {
        case .area:
            params["area"] = options[indexPath.row]
            let vc = BusSetupViewController(params: params, setupStatus: .busLine)
            navigationController?.pushViewController(vc, animated: true)
        case .busLine:
            params["busLine"] = options[indexPath.row]
            let vc = BusSetupViewController(params: params, setupStatus: .busStop)
            navigationController?.pushViewController(vc, animated: true)
        case .busStop:
            params["busStop"] = options[indexPath.row]

            editUserProfile(completion: {(_) -> Void in
                let vc = UserRegistrationCompleteViewController()
                self.present(vc, animated: true, completion: nil)
            })
        }
    }
}
