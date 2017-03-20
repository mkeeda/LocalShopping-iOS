//
//  ViewController.swift
//  Robosuke2
//
//  Created by IppeiMUKAIDA on 4/23/16.
//  Copyright © 2016 IppeiMUKAIDA. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

	let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var documentsPath: String?
    var lastUpdatedAt: Date?
	
	//Viewを読み込み
	override func loadView() {
		if let view = UINib(nibName: "LoadingView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView{
			self.view = view
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()

        //ローカルにproductImagesディレクトリを作る
        documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let directoryName = "productImages"
        let createPath = documentsPath! + "/" + directoryName

        do {
            try FileManager.default.createDirectory(atPath: createPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("can not create directory: " + directoryName)
        }

        // 端末変わるとusernameを調べるのが面倒なので表示
        let label = UILabel(frame: CGRect(x: 0, y: 400, width: UIScreen.main.bounds.size.width, height: 20))
        label.text = Endpoint.Login.authorization.parameters?["username"] as? String
        label.numberOfLines = 0
        label.sizeToFit()
        view.addSubview(label)

        lastUpdatedAt = loadLastUpdatedAt()
	}

	override func viewWillAppear(_ animated: Bool) {
		self.navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	override func viewDidAppear(_ animated: Bool) {
        API.call(request: Endpoint.Login.authorization) { response in
            switch response {
            case .success(let result):
                self.appDelegate.login = result
                print("success: token = \(result.token)")
                self.getShelfList()
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.lappingTime()
                self.performSegue(withIdentifier: "goToStartView", sender: self)

            case .failure(let error):
                print("failure \(error)")
                self.performSegue(withIdentifier: "userRegistration", sender: self)
            }
        }
	}

    func getShelfList() {

        var shelfList: [Category<[Shelf]>] = []

		//起動時にproductを取得
        var count = 1
        for (sellerId, _) in seller {
            let dispatchGroup = DispatchGroup()
            let tmpShelfList: [Category<[Shelf]>] = [
                .processedFoods(value: nil),
                .freshFoods(value: nil),
                .snacks(value: nil),
                .drink(value: nil),
                .otherFoods(value: nil),
                .dailyNecessities(value: nil),
                .others(value: nil)
            ]
            
            for var category in tmpShelfList {
                dispatchGroup.enter()
                AuthorizationModel.sharedInstance.callArray(request: Endpoint.RequestShelf.get(sellerId: sellerId, category: category)) { response in
                    switch response {
                    case .success(let result):
                        print("success \(result)")
                        //データ格納
                        category.setValue(result)
                        shelfList.append(category)

                        //画像をダウンロード
                        for item in result {
                            guard let imgName = item.productDetail?.imgName,
                                let updatedAt = item.productDetail?.updatedAt else {
                                    return
                            }

                            // 画像がなければ取得
                            let manager = FileManager()
                            let filepath = self.documentsPath! + "/" + imgName
                            if !manager.fileExists(atPath: filepath) {
                                self.getProductImage(imgName)
                            }
                            // lastUpdatedAtがロードできなかったら画像を取得する
                            else if self.lastUpdatedAt == nil {
                                self.getProductImage(imgName)
                            }
                            // 最新でなければ画像を取得する
                            else if !self.lastestCheck(updatedAt: updatedAt, lastUpdatedAt: self.lastUpdatedAt!) {
                                self.getProductImage(imgName)
                            }
                        }
                        print(category.name)
                        
                    case .failure(let error):
                        print("failure \(error)")
                    }
                    dispatchGroup.leave()
                }
            }

            //全ての通信の終了を待って，メインスレッドへ戻る
            dispatchGroup.notify(queue: DispatchQueue.main, execute: {
                //順番が揃っているとは限らないため，並べ替える
                var sortedShelfList = [Category<[Shelf]>](repeating: .processedFoods(value: nil), count: 7)
                for category in shelfList {
                    switch category {
                    case .processedFoods:
                        sortedShelfList[0] = category
                    case .freshFoods:
                        sortedShelfList[1] = category
                    case .snacks:
                        sortedShelfList[2] = category
                    case .drink:
                        sortedShelfList[3] = category
                    case .otherFoods:
                        sortedShelfList[4] = category
                    case .dailyNecessities:
                        sortedShelfList[5] = category
                    case .others:
                        sortedShelfList[6] = category
                    }
                }
                self.appDelegate.shelfList[sellerId] = sortedShelfList

                if count == seller.count {
                    return
                }
                else {
                    count += 1
                }
            })
        }
        
        
    }
	
	func getProductImage( _ imgName: String ){
        API.download(request: Endpoint.RequestImage.get(imgName: imgName)) { response in
            switch response {
            case .success(let result):
                let fullpath = self.documentsPath! + "/" + imgName

                // 保存処理
                do {
                    try result.write(to: URL(fileURLWithPath: fullpath), options: Data.WritingOptions.atomic)
                    print(imgName + ": save OK")
                }
                catch {
                    print(imgName + ": save error")
                }

            case .failure(let error):
                print(imgName)
                print("Failed with error: \(error)")
            }
        }
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

    // 現在時刻をファイル保存
    func lappingTime() {
        var now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'+09:00'" // Choose format
        now = formatter.date(from: formatter.string(from: now))!

        if let path = documentsPath {
            let filepath = path + "/lastUpdatedAt.dat"
            let success = NSKeyedArchiver.archiveRootObject(now, toFile: filepath)
            if success {
                print("last updatedAt: \(now)")
            }
            else {
                print("lapping error: \(now)")
            }
        }
    }

    func loadLastUpdatedAt() -> Date? {
        if let path = documentsPath {
            let filepath = path + "/lastUpdatedAt.dat"
            if let lastUpdatedAt = NSKeyedUnarchiver.unarchiveObject(withFile: filepath) as? Date {
                return lastUpdatedAt
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }

    // 最終更新日が最新ならばtrue
    // そうでないならfalse
    func lastestCheck(updatedAt: Date, lastUpdatedAt: Date) -> Bool {
        //lastUpdatedAt > updatedAt
        if lastUpdatedAt.compare(updatedAt) == .orderedDescending {
            return true
        }
        else {
            return false
        }
    }

}

