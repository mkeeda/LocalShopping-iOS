//
//  TopViewController.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 5/31/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {
	
	//Viewを読み込み
	override func loadView() {
		if let view = UINib(nibName: "TopView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView{
			self.view = view
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationController?.setNavigationBarHidden(false, animated: true)
		
		//戻るボタンを設定
		let back_button = UIBarButtonItem()
		back_button.title = "戻る"
		self.navigationItem.backBarButtonItem = back_button
		// Do any additional setup after loading the view, typically from a nib.
	}

	//[商品を探す]ボタン
	@IBAction func searchItems(_ sender: AnyObject) {
		performSegue(withIdentifier: "selectSeller", sender: self)
	}
	//[注文状況]ボタン
	@IBAction func getOrderStatus(_ sender: AnyObject) {
		
		performSegue(withIdentifier: "orderStatus", sender: self)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}
