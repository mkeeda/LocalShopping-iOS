//
//  ItemListView.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 4/23/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class ItemListViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
	
//	@IBOutlet weak var total: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	
	//DetailedItemInfoView.xibのパーツ
	@IBOutlet weak var DII_mainView: UIView!
	@IBOutlet weak var DII_number: UILabel!
	@IBOutlet weak var DII_image: UIImageView!
	@IBOutlet weak var DII_name: UILabel!
	@IBOutlet weak var DII_price: UILabel!
	@IBOutlet weak var DII_textView: UITextView!
	@IBOutlet weak var DII_stepper: UIStepper!
	
	let parentView: ItemCategoryPageMenuViewController!
    var shelfList: [Shelf] = []
    var totalIndex: Int
	let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
	
	var detailedInfoWindow: UIWindow! //商品の詳細情報を表示するWindow
	
	@IBAction func unwindAction(_ sppeiegue: UIStoryboardSegue) {
		//戻ってきたらCollectionViewをリロードして，変更を適用
		collectionView.reloadData()
	}
	@IBAction func DII_closeButton(_ sender: UIButton) {
		appDelegate.window?.makeKeyAndVisible()
		detailedInfoWindow.isHidden = true
	}
	
    init(parent: ItemCategoryPageMenuViewController, shelfList: [Shelf], totalIndex: Int){
        self.parentView = parent
        self.shelfList = shelfList
        self.totalIndex = totalIndex
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//Viewを読み込み
	override func loadView() {
		if let view = UINib(nibName: "ItemListView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView{
			self.view = view
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//戻るボタンを設定
		let back_button = UIBarButtonItem()
		back_button.title = "戻る"
		self.navigationItem.backBarButtonItem = back_button
		
		// Do any additional setup after loading the view, typically from a nib.
		collectionView.backgroundColor = UIColor(red: 238.0/255, green: 238.0/255, blue: 238.0/255, alpha: 238.0/255)
		
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 10
		layout.minimumInteritemSpacing = 10
		layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
		collectionView.setCollectionViewLayout(layout, animated: false)
		
		//CustomCellをViewに登録
		let nibName = UINib(nibName: "ItemCellView", bundle: nil)
		collectionView.register(nibName, forCellWithReuseIdentifier: "itemCell")
	}
	
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - UICollectionViewDelegate Protocol
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell:ItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemCell

        guard
            let priceString = shelfList[(indexPath as NSIndexPath).row].price?.getTaxPriceStringWithFormated(),
            let numOfOrders = shelfList[(indexPath as NSIndexPath).row].productDetail?.numOfOrders
            else {
                return cell
        }
		//セルにデータをセット
		cell.title.text = shelfList[(indexPath as NSIndexPath).row].productDetail?.name
		cell.image.image = shelfList[(indexPath as NSIndexPath).row].productDetail?.loadImage()
        cell.price.text = "¥" + priceString
		cell.backgroundColor = UIColor.white
		cell.stepper.value = Double(numOfOrders)
		
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
		
		//stepperのvalueChangedイベントを監視
		cell.stepper.tag = (indexPath as NSIndexPath).row
		cell.stepper.addTarget(self, action: #selector(ItemListViewController.onStepperChanged(_:)), for: UIControlEvents.valueChanged)
		
		cell.number.sizeToFit()
		
		//セルの角を丸める
		cell.layer.cornerRadius = 3
		
		//注文数をLabelに表示

        if let itemNum = shelfList[(indexPath as NSIndexPath).row].productDetail?.numOfOrders {
            if itemNum != 0 {
                cell.number.text = "×" + String(itemNum)
                cell.number.textColor = UIColor.white
                let gray = UIColor.gray
                cell.number.backgroundColor = gray.withAlphaComponent(0.6)
            }
            else{
                cell.number.text = ""
                cell.number.backgroundColor = UIColor.clear
            }
        }

		//合計金額と合計個数を計算
		var sum = 0
        var num = 0
		for shelf in shelfList {
            if let taxPrice = shelf.price?.taxPrice, let numOfOrders = shelf.productDetail?.numOfOrders {
                sum += taxPrice * numOfOrders
                num += numOfOrders
            }
		}
        parentView.total[totalIndex].setValue((total: sum, num: num))
		
		return cell
	}
	
	//stepperの値が変わったときの処理
	func onStepperChanged(_ sender: UIStepper){
		//注文数を取得
		shelfList[sender.tag].productDetail?.numOfOrders = Int(sender.value)
		
		//collectionViewをリロードする
		collectionView.reloadData()
		
		if sender.restorationIdentifier	== "DII_stepper" {
            if let numOfOrders = shelfList[sender.tag].productDetail?.numOfOrders {
                DII_number.text = "×" + String(numOfOrders)
            }
		}
	}
	
	// Screenサイズに応じたセルサイズを返す
	// UICollectionViewDelegateFlowLayoutの設定が必要
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		let stepperSize:Int = 29
		let labelSize:Int = 36
		let margin = 10
		let cellSizeWidth:CGFloat = (UIScreen.main.bounds.size.width - CGFloat(margin) * 3 ) / 2
		let cellSizeHeight:CGFloat = cellSizeWidth + CGFloat(stepperSize) + CGFloat(labelSize) * 3
		return CGSize(width: cellSizeWidth, height: cellSizeHeight)
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
 
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return shelfList.count;
	}

	//セル選択時に呼び出されるメソッド
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		//window初期化
		detailedInfoWindow = UIWindow()
		
		let gray = UIColor.gray
		detailedInfoWindow.backgroundColor = gray.withAlphaComponent(0.6)
		detailedInfoWindow.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
		detailedInfoWindow.layer.position = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
		detailedInfoWindow.windowLevel = UIWindowLevelNormal + 1
		
		if let view = UINib(nibName: "DetailedItemInfoView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView{
			view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
            view.layer.position = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)

            guard
                let priceString = shelfList[(indexPath as NSIndexPath).row].price?.getTaxPriceStringWithFormated(),
                let numOfOrders = shelfList[(indexPath as NSIndexPath).row].productDetail?.numOfOrders
                else {
                    return
            }
			//角を丸める
			DII_mainView.layer.cornerRadius = 3
			//影をつける
			DII_mainView.layer.masksToBounds = false //必須
			DII_mainView.layer.shadowOffset = CGSize(width: 0.0, height: 0.2)
			DII_mainView.layer.shadowOpacity = 0.6
			DII_mainView.layer.shadowRadius = 4.0
			//データをセット
            if let numOfOrders = shelfList[(indexPath as NSIndexPath).row].productDetail?.numOfOrders {
                DII_number.text = "×" + String(numOfOrders)
            }
			DII_number.backgroundColor = gray.withAlphaComponent(0.6)
			DII_name.text = shelfList[(indexPath as NSIndexPath).row].productDetail?.name
			DII_image.image = shelfList[(indexPath as NSIndexPath).row].productDetail?.loadImage()
			DII_image.contentMode = .scaleAspectFit
			DII_price.text = "￥" + priceString
			DII_textView.text = shelfList[(indexPath as NSIndexPath).row].productDetail?.com
			DII_textView.isEditable = false
			
			//stepperのvalueChangedイベントを監視
			DII_stepper.tag = (indexPath as NSIndexPath).row
			DII_stepper.value = Double(numOfOrders)
			DII_stepper.addTarget(self, action: #selector(ItemListViewController.onStepperChanged(_:)), for: UIControlEvents.valueChanged)
			
			detailedInfoWindow.addSubview(view)
		}
		
		// detailedInfoWindowをkeyWindowにする.
		detailedInfoWindow.makeKey()
		
		// windowを表示する.
		self.detailedInfoWindow.makeKeyAndVisible()
		
	}
}

