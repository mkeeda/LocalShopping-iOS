//
//  SelectSellerViewController.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 6/10/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class SelectSellerViewController: UIViewController {
	var loadingView: UIView!
	let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

	//Viewを読み込み
	override func loadView() {
		if let view = UINib(nibName: "SelectSellerView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView{
			self.view = view
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		let back_button = UIBarButtonItem()
		back_button.title = "戻る"
		self.navigationItem.backBarButtonItem = back_button
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func onClickSeller1(_ sender: AnyObject) {
		let sellerId = 1
		appDelegate.sellerId = sellerId
        performSegue(withIdentifier: "searchItems", sender: self)
	}
	
	@IBAction func onClickSeller2(_ sender: AnyObject) {
		let sellerId = 2
		appDelegate.sellerId = sellerId
        performSegue(withIdentifier: "searchItems", sender: self)
	}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let itemCategoryPageMenuVC = segue.destination as? ItemCategoryPageMenuViewController,
            let selectedShelfList = appDelegate.shelfList[appDelegate.sellerId!]
        else {
            return
        }
        itemCategoryPageMenuVC.selectedShelfList = selectedShelfList
    }
}
