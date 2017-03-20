//
//  OrderStatusViewController.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 4/24/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class OrderStatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var loadingView: UIView!
    var orderList: [Order] = []

    //DetailedOrderInfoにデータを渡すための変数
    var selectOrder: Order!

    //Viewを読み込み
    override func loadView() {
        if let view = UINib(nibName: "OrderStatusView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView{
            self.view = view
        }
    }

    //ロードされるタイミングは親画面から遷移してきた時
    //子画面から戻ってきた時は呼ばれない
    override func viewDidLoad() {
        super.viewDidLoad()

        //戻るボタンを設定
        let back_button = UIBarButtonItem()
        back_button.title = "戻る"
        self.navigationItem.backBarButtonItem = back_button

        // Do any additional setup after loading the view, typically from a nib.
        let nibName = UINib(nibName: "OrderCellView", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "orderCell")

        //tableのcellの高さ
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = 100

        tableView.backgroundColor = UIColor(red: 238.0/255, green: 238.0/255, blue: 238.0/255, alpha: 238.0/255)

        orderList.removeAll()
        //APIへリクエスト送信
        AuthorizationModel.sharedInstance.callArray(request: Endpoint.RequestOrder.get) { response in
            switch response {
            case .success(let result):
                print(result)
                self.orderList = result
                //リストを逆順にする
                self.orderList = self.orderList.reversed()

                //メインスレッドへ戻る
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }


    override func viewDidAppear(_ animated: Bool) {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //セクション数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "section"
    }

    //cell数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderList.count
    }



    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {

        let cell: OrderCell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath) as! OrderCell

        let order = orderList[(indexPath as NSIndexPath).row]

        //注文日時
        cell.orderTime.text = order.setupFormatOfCreateAt("yyyy/MM/dd")

        //金額(合計金額のみ，サーバから受け取った時点で税込み）
        if let price = order.price {
            cell.price.text = price.getNonTaxPriceStringWithFormated()
        }

        //配達状況
        cell.state.text = order.getState().rawValue

        return cell
    }

    // Cell が選択された場合
    func tableView(_ table: UITableView, didSelectRowAt indexPath:IndexPath) {
        selectOrder = orderList[(indexPath as NSIndexPath).row]
        
        performSegue(withIdentifier: "toDetailedOrderInfo",sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailedOrderInfo" {
            
            let detailedOrderViewController: DetailedOrderInfoViewController = segue.destination as! DetailedOrderInfoViewController
            
            detailedOrderViewController.order = selectOrder
            
        }
    }
}


