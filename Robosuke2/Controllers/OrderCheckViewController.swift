//
//  OrderCheckViewController.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 4/25/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class OrderCheckViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var priceLabel: UILabel! //合計金額
    @IBOutlet weak var tableView: UITableView!

    //ItemListViewControllerからのデータを受け取る変数
    var orderItemList:[Product] = [] //注文リスト
    var totalPrice: Price = Price(nonTaxPrice: 0)
    var totalNum: Int = 0

    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    //Viewを読み込み
    override func loadView() {
        if let view = UINib(nibName: "OrderCheckView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView{
            self.view = view
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //CustomCellをViewに登録
        let nibName = UINib(nibName: "OrderCheckCellView", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "orderCheckCell")

        //3桁ごとにカンマを打つ
        priceLabel.text = "￥" + totalPrice.getTaxPriceStringWithFormated()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //画面遷移時の処理をオーバーライド
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //注文確定時
        if segue.identifier == "orderComplete" {

            //注文データ送信
            if let params = setupOrderJSON() {
                AuthorizationModel.sharedInstance.call(request: Endpoint.RequestOrder.post(json: params)) { response in
                    switch response {
                    case .success:
                        print("Order is success.")
                    case .failure(let error):
                        print("Failed with error: \(error)")
                    }
                }
            }
            else {
                let alert = UIAlertController(title: "注文エラー", message: "Json is nil", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "戻る", style: .cancel, handler: nil)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
            }
        }
    }


    @IBAction func goOrderComplete(_ sender: AnyObject) {
        let alert = UIAlertController(title: "注文していいですか？", message: "「注文する」を押すと変更できません", preferredStyle: .alert)

        let defaultAction = UIAlertAction(title: "注文する", style: .default, handler: { (_)  in
            self.performSegue(withIdentifier: "orderComplete", sender: self)
        })

        let cancelAction = UIAlertAction(title: "戻る", style: .cancel, handler: nil)

        alert.addAction(defaultAction)
        alert.addAction(cancelAction)

        present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        let cell:OrderCheckCell = tableView.dequeueReusableCell(withIdentifier: "orderCheckCell", for: indexPath) as! OrderCheckCell

        guard
            let priceString = orderItemList[(indexPath as NSIndexPath).row].price?.getTaxPriceStringWithFormated(),
            let numOfOrders = orderItemList[(indexPath as NSIndexPath).row].numOfOrders
            else {
                return cell
        }
        //セルにデータをセット
        cell.titleLabel.text = orderItemList[(indexPath as NSIndexPath).row].name
        cell.productImage.image = orderItemList[(indexPath as NSIndexPath).row].loadImage()
        cell.priceLabel.text = "¥" + priceString

		cell.titleLabel.sizeToFit()
		cell.titleLabel.minimumScaleFactor = 0.6

        //画像のアスペクト比を維持
        cell.productImage.contentMode = .scaleAspectFit

        //注文数をLabelに表示
        cell.numberLabel.text = String(numOfOrders)

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderItemList.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = tableView.frame

        let title = UILabel()
        title.frame =  CGRect(x: 10, y: 10, width: headerFrame.size.width-20, height: 20)
        title.font = title.font.withSize(18)
        title.text = "全\(totalNum)点の商品"
        title.textColor = UIColor.darkGray

        let headerView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: headerFrame.size.width, height: headerFrame.size.height))
        headerView.addSubview(title)
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    //サーバへ送る注文リストのJSONを作る関数
    func setupOrderJSON() -> [String: Any]? {
        
        //orderItemListをDictionaryの配列に変換
        //サーバへ送る価格は税抜き
        var orderDetails: [[String: Any]] = []
        for orderItem in orderItemList {
            guard
                let productId = orderItem.id,
                let price = orderItem.price?.nonTaxPrice,
                let numOfOrders = orderItem.numOfOrders
                else { return nil }
            
            let json = [
                "product_id": productId,
                "price": price,
                "number": numOfOrders
            ]
            orderDetails	.append(json)
        }

        guard let sellerId = appDelegate.sellerId else { return nil }
        
        let orderJson: [String: Any] = [
            "seller_id": sellerId,
            "orderdetails": orderDetails
        ]
        
        return orderJson
    }
    
}
