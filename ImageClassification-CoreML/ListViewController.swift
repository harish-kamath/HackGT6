//
//  ListViewController.swift
//  ImageClassification-CoreML
//
//  Created by Harish Kamath on 10/27/19.
//  Copyright © 2019 GwakDoyoung. All rights reserved.
//

import UIKit
import SearchTextField

func catalogGet(){
    let url = URL(string: "https://gateway-staging.ncrcloud.com/catalog/items")!
    var request = URLRequest(url: url)
    request.setValue("CorrID", forHTTPHeaderField: "nep-correlation-id")
    request.setValue("hack-harishkamath", forHTTPHeaderField: "nep-organization")
    request.setValue("8a008d406ddb112d016e0bd3c63f0045", forHTTPHeaderField: "nep-application-key")
    request.setValue("Basic \("acct:root@hack_harishkamath:0XDe4F!9+>".toBase64())", forHTTPHeaderField: "Authorization")
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("error: \(error)")
        } else {
            if let response = response as? HTTPURLResponse {
                print("statusCode: \(response.statusCode)")
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("data: \(dataString)")
            }
        }
    }
    task.resume()
}

class ListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var selected:[String]?
    var finished:[String]?
    @IBOutlet weak var table: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selected?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let row = indexPath.row
        print("Checking at row \(row) with length \(selected?.count)")
        let text = selected?[row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 35)
        cell.textLabel?.text = text
        for c in finished! {
            if c == text {
                cell.backgroundColor = UIColor.green
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let text = selected?[row]
        print(text)
        let mapVC = self.storyboard?.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
        mapVC.label = text!
        self.present(mapVC, animated: true, completion: nil)
    }
    
    
    func markItemDone(_ item:String){
        for c in selected!{
            if c == item {
                finished?.append(c)
                self.table.reloadData()
            }
        }
    }

    @IBOutlet weak var mySearchTextField: SearchTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mySearchTextField.filterStrings(catalogGet())
        //mySearchTextField.filterStrings(["Computer", "Backpack", "Bottle"])
        selected = []
        finished = []
        table.delegate = self
        table.dataSource = self
        
        mySearchTextField.itemSelectionHandler = { filteredResults, itemPosition in
            // Just in case you need the item position
            let item = filteredResults[itemPosition]
            print("Item at position \(itemPosition): \(item.title)")

            // Do whatever you want with the picked item
            self.mySearchTextField.text = ""
            self.selected?.append(item.title)
            print(self.selected)
            self.table.reloadData()
        }

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}
