//
//  InputUserProfileViewController.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 3/16/17.
//  Copyright © 2017 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class InputUserProfileViewController: UITableViewController {

    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!

	let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBAction func onClickNextButton(_ sender: UIButton) {
        guard
            let zipcode = zipcodeTextField.text,
            let address = addressTextField.text,
            let phoneNumber = phoneNumberTextField.text
            else { return }

        appDelegate.user?.userProfile.zipcode = zipcode
        appDelegate.user?.userProfile.address = address
        appDelegate.user?.userProfile.phoneNumber = phoneNumber

        let vc = BusSetupViewController(params: [:], setupStatus: .area)
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

		let back_button = UIBarButtonItem()
		back_button.title = "戻る"
		navigationItem.backBarButtonItem = back_button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
