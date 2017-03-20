//
//  ItemCategoryPageMenuViewController.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 7/11/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit
import PageMenu

class ItemCategoryPageMenuViewController: UIViewController {
	
	var pageMenu: CAPSPageMenu?
	var controllerArray: [ItemListViewController] = []
    var selectedShelfList: [Category<[Shelf]>] = []
    var total: [Category<(total: Int, num: Int)>] = [
        .processedFoods(value: (0, 0)),
        .freshFoods(value: (0, 0)),
        .snacks(value: (0, 0)),
        .drink(value: (0, 0)),
        .otherFoods(value: (0, 0)),
        .dailyNecessities(value: (0, 0)),
        .others(value: (0, 0))
        ] {
        didSet {
            let (totalPrice, _) = calculateTotal()
            totalLabel.text = "￥" + totalPrice.getTaxPriceStringWithFormated()
        }
    }

	@IBOutlet weak var totalView: UIView!
	@IBOutlet weak var totalLabel: UILabel!
	@IBOutlet weak var orderButton: UIButton!
	
	@IBAction func unwindAction(_ sppeiegue: UIStoryboardSegue) {
		//戻ってきたらCollectionViewをリロードして，変更を適用
		for controller in controllerArray {
			if controller.isViewLoaded {
				controller.collectionView.reloadData()
			}
		}
	}

	//Viewがロードされる前
	override func viewWillAppear(_ animated: Bool) {
		//NavigationBarを表示
		self.navigationController?.setNavigationBarHidden(false, animated: true)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        //戻るボタンを設定
        let back_button = UIBarButtonItem()
        back_button.title = "戻る"
        self.navigationItem.backBarButtonItem = back_button

        // 注文数の初期化
        setZeroToProduct()

		//タブの設定
        for count in 0 ..< selectedShelfList.count {
            let category = selectedShelfList[count]
            if let shelfList = category.getValue(), shelfList.count != 0 {
                /*メモ
                 ItemListViewControllerにcountを渡す理由
                 各タブのViewControllerで各カテゴリの小計金額を計算し，
                 親（ItemCategoryPageMenuViewController）のtotalに反映させるため
                 */
                let controller = ItemListViewController(parent: self, shelfList: shelfList, totalIndex: count)
                controller.title = category.name
                controllerArray.append(controller)
            }
        }
		
		let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor(red: 255.0/255.0, green: 153.0/255.0, blue: 0.0/255.0, alpha: 1.0)),
            .viewBackgroundColor(UIColor(red: 238.0/255, green: 238.0/255, blue: 238.0/255, alpha: 238.0/255)),
            .menuItemFont(UIFont.boldSystemFont(ofSize: 18)),
            .selectedMenuItemLabelColor(UIColor.white),
            .unselectedMenuItemLabelColor(UIColor(red: 255.0/255, green: 255.0/255, blue: 255.0/255, alpha: 0.4)),
            .menuHeight(40.0),
            .selectionIndicatorHeight(0.0),
            .menuItemWidthBasedOnTitleTextWidth(true),
            .centerMenuItems(true),
            .addBottomMenuHairline(false)
		]
		
		let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
		let naviheight = self.navigationController!.navigationBar.frame.size.height
		let y_position = naviheight + statusBarHeight
		let totalViewHeight = totalView.frame.height
		
		pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: y_position, width: self.view.frame.width, height: self.view.frame.height - y_position - totalViewHeight), pageMenuOptions: parameters)
		
		self.view.addSubview(pageMenu!.view)
	
		//totalViewを最前面に
		view.bringSubview(toFront: totalView)
		//totalViewに影をつける
		totalView.layer.masksToBounds = false
		totalView.layer.shadowOffset = CGSize(width: 0.0, height: -3.0)/* 影の大きさ */
		totalView.layer.shadowOpacity = 0.2 /* 透明度 */
		totalView.layer.shadowRadius = 3.0 /* 影の距離 */

		//合計金額を初期化
		totalLabel.text = "￥0"

		orderButton.setTitleColor(UIColor.lightGray, for: .highlighted)
		orderButton.addTarget(self, action: #selector(ItemCategoryPageMenuViewController.onClickOrderButton), for: .touchUpInside)
	
    }
	
	
	//画面遷移時の処理をオーバーライド
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "orderCheck" {
			let orderCheckViewController: OrderCheckViewController = segue.destination as! OrderCheckViewController

			//注文数が1以上の商品を注文確認画面に渡す
			for category in selectedShelfList {
                if let shelfList = category.getValue() {
                    for shelf in shelfList {
                        if let product = shelf.productDetail, product.numOfOrders != 0 {
                            product.price = shelf.price
                            orderCheckViewController.orderItemList.append(product)
                        }
                    }
                }
			}
            let (totalPrice, totalNum) = calculateTotal()
            orderCheckViewController.totalPrice = totalPrice
            orderCheckViewController.totalNum = totalNum
		}
	}
	
	func onClickOrderButton(){
		if totalLabel.text != "￥0" {
			performSegue(withIdentifier: "orderCheck", sender: self)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func filterProductsByShelf(_ productList: [Product], shelfList: [Shelf]) -> [Product] {
        var filteredProductList: [Product] = []

        for product in productList {
            //選択数を0に初期化
            product.numOfOrders = 0
            for shelf in shelfList {
                if(product.id == shelf.productId) {
                    product.price = shelf.price
                    filteredProductList.append(product)
                }
            }
        }
        return filteredProductList
    }

    func calculateTotal() -> (Price, Int) {
        let sum = Price(nonTaxPrice: 0)
        var num = 0
        for category in total {
            if let subTotal = category.getValue() {
                sum.taxPrice += subTotal.total
                num += subTotal.num
            }
        }
        return (sum, num)
    }

    func setZeroToProduct() {
        for category in selectedShelfList {
            if let eachShelf = category.getValue() {
                for shelf in eachShelf {
                    shelf.productDetail?.numOfOrders = 0
                }
            }
        }
    }
}
