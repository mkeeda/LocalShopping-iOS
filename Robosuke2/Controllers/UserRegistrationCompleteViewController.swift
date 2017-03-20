//
//  UserRegistrationCompleteViewController.swift
//  Robosuke2
//
//  Created by IppeiMukaida on 2017/03/17.
//  Copyright © 2017年 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class UserRegistrationCompleteViewController: UIViewController {

    @IBAction func onClickStartButton(_ sender: Any) {
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

	//Viewを読み込み
	override func loadView() {
		if let view = UINib(nibName: "UserRegistrationCompleteView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView{
			self.view = view
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
