//
//  OrderCompleteViewController.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 4/29/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class OrderCompleteViewController: UIViewController {

    @IBAction func goBackToTopView(_ sender: AnyObject) {
		navigationController?.setNavigationBarHidden(false, animated: true)
		_ = navigationController?.popToRootViewController(animated: true)

    }

	var timer: Timer = Timer()
	//Viewを読み込み
	override func loadView() {
		if let view = UINib(nibName: "OrderCompleteView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView{
			self.view = view
		}
	}

    override func viewWillAppear(_ animated: Bool) {
		navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
