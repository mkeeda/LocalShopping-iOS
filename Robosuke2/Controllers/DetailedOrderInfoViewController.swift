//
//  DetailedOrderInfoViewController.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 5/2/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class DetailedOrderInfoViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {

//	@IBOutlet weak var collectionView: UICollectionView!
	var collectionView: UICollectionView!
	var order: Order!
	
    override func viewDidLoad() {
		view.backgroundColor = UIColor.white
        super.viewDidLoad()
		//戻るボタンを設定
		let back_button = UIBarButtonItem()
		back_button.title = "戻る"
		self.navigationItem.backBarButtonItem = back_button
		
		// レイアウト作成
		let flowLayout = UICollectionViewFlowLayout()
		flowLayout.scrollDirection = .vertical
		flowLayout.minimumInteritemSpacing = 10
		flowLayout.minimumLineSpacing = 10
		flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		flowLayout.itemSize = CGSize(width: 100, height: 100)
		
		// コレクションビュー作成
		collectionView = UICollectionView(frame: view.frame, collectionViewLayout: flowLayout)
		collectionView.backgroundColor = UIColor(red: 238.0/255, green: 238.0/255, blue: 238.0/255, alpha: 238.0/255)
		collectionView.dataSource = self
		collectionView.delegate = self
		view.addSubview(collectionView)
		
		//CustomCellをViewに登録
		let infoNib = UINib(nibName: "DetailedOrderInfoCellView", bundle: nil)
		collectionView.register(infoNib, forCellWithReuseIdentifier: "detailedInfoCell")
		
		let itemNib = UINib(nibName: "ItemCellView", bundle: nil)
		collectionView.register(itemNib, forCellWithReuseIdentifier: "itemCell")
    }
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// MARK: - UICollectionViewDelegate Protocol
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		//セルにデータをセット
		if (indexPath as NSIndexPath).section == 0 {
			let cell:DetailedOrderInfoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailedInfoCell", for: indexPath) as! DetailedOrderInfoCell
			
			cell.backgroundColor = UIColor.white

            guard
                let sellerId = order.sellerId,
                let price = order.price
                else {
                    return cell
            }
			cell.date.text = order.setupFormatOfCreateAt("yyyy/MM/dd HH:mm")
			cell.sellerName.text = seller[sellerId]

            //金額(合計金額のみ，サーバから受け取った時点で税込み）
			cell.price.text = price.getNonTaxPriceStringWithFormated()
			cell.state.text = order.getState().rawValue
			
			//影をつける
			cell.layer.masksToBounds = false //必須
			cell.layer.shadowOffset = CGSize(width: 0.0, height: 0.2)
			cell.layer.shadowOpacity = 0.2
			cell.layer.shadowRadius = 2.0
			
			//角を丸める
			cell.layer.cornerRadius = 3
			
			return cell
		}
		else {
			let cell:ItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemCell

            guard
                let orderDetails = order.orderDetails
                else {
                    return cell
            }

			let orderDetail = orderDetails[(indexPath as NSIndexPath).row]
			let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
			
			cell.backgroundColor = UIColor.white
            if let priceString = orderDetail.price?.getTaxPriceStringWithFormated() {
                cell.price.text = "￥" + priceString
            }

            for (_, eachShelfList) in appDelegate.shelfList {
                for category in eachShelfList {
                    if let shelfList = category.getValue() {
                        if let index = shelfList.index(where: { $0.productId == orderDetail.productId }) {
                            cell.title.text = shelfList[index].productDetail?.name
                            cell.image.image = shelfList[index].productDetail?.loadImage()
                        }
                    }
                }
            }

			//Stepperはいらないので隠す
			cell.stepper.isHidden = true
			cell.stepperHeightConstraint.constant = 0

            if let numOfOrders = orderDetail.numOfOrders {
                cell.number.text = "×" + String(numOfOrders)
            }
			cell.number.textColor = UIColor.white
			let gray = UIColor.gray
			cell.number.backgroundColor = gray.withAlphaComponent(0.6)
			
			cell.number.sizeToFit()
			
			//Labelのフォントサイズを可変に
			cell.title.numberOfLines = 2
			cell.title.adjustsFontSizeToFitWidth = true
			cell.title.minimumScaleFactor = 0.6
			
			//画像のアスペクト比を維持
			cell.image.contentMode = .scaleAspectFit
			
			//影をつける
			cell.layer.masksToBounds = false //必須
			cell.layer.shadowOffset = CGSize(width: 0.0, height: 0.2)
			cell.layer.shadowOpacity = 0.2
			cell.layer.shadowRadius = 2.0
			
			//角を丸める
			cell.layer.cornerRadius = 3
			
			return cell
		}
		
		
	}
	
	// Screenサイズに応じたセルサイズを返す
	// UICollectionViewDelegateFlowLayoutの設定が必要
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
	
		let margin = 10
		var cellSizeWidth:CGFloat = 20.0
		var cellSizeHeight:CGFloat = 20.0
		
		if (indexPath as NSIndexPath).section == 0 {
			cellSizeWidth = self.view.frame.size.width - CGFloat(margin) * 2
			cellSizeHeight = 210.0
		}
		else {
			let labelSize:Int = 36
			cellSizeWidth = (self.view.frame.size.width - CGFloat(margin) * 3) / 2
			cellSizeHeight = cellSizeWidth + CGFloat(labelSize) * 3
		}
		return CGSize(width: cellSizeWidth, height: cellSizeHeight)
	}
	
	//セクション数
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 2
	}
 
	//セル数
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let orderDetails = order.orderDetails {
            switch section {
            case 0:
                return 1
            case 1:
                return orderDetails.count
            default:
                print("collectionView section error")
                return 0
            }
        }

        print("orderDetails is empty")
        return 0
	}
	
}
