//
//  CreateUserViewController.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 10/31/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class CreateUserViewController: UITableViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!

	let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBAction func onClickNextButton(_ sender: UIButton) {
        createUser()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createUser() {
        guard
            let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let email = emailTextField.text
            else { return }
        API.call(request: Endpoint.RequestUser.post(firstName: firstName, LastName: lastName, email: email)) { response in
            switch response {
            case .success(let result):
                print(result)
                self.appDelegate.user = result
                self.performSegue(withIdentifier: "gotoInputUserProfile", sender: self)
            case .failure(let error):
                print("Create user error: \(error)")
                let alert = UIAlertController(title: "ユーザ登録失敗", message: nil, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "戻る", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }

}
