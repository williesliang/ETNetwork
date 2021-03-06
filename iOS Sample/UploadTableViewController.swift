//
//  UploadTableViewController.swift
//  iOS Sample
//
//  Created by gengduo on 15/12/15.
//  Copyright © 2015年 ethan. All rights reserved.
//

import UIKit
import ETNetwork

class UploadTableViewController: UITableViewController {

    @IBOutlet weak var writeLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var processView: UIProgressView!
    var uploadRows: UploadRows?
    var uploadApi: NetRequest?
    
    deinit {
        uploadApi?.cancel()
        print("\(type(of: self))  deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()


        guard let uploadRows = uploadRows else { fatalError("not set rows") }
        switch uploadRows {
        case .uploadFile:
            let fileURL = Bundle.main.url(forResource: "upload", withExtension: "png")
            uploadApi = UploadFileApi(fileURL: fileURL!)
        case .uploadData:
            if let path = Bundle.main.path(forResource: "sample", ofType: "json") {
                if let data = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    uploadApi = UploadDataApi(data: data)
                }

            }

        case .uploadStream:
            if let jsonPath = Bundle.main.path(forResource: "sample", ofType: "json"), let imgPath = Bundle.main.path(forResource: "upload", ofType: "png"){
                if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)), let imgData = try? Data(contentsOf: URL(fileURLWithPath: imgPath)) {
                    uploadApi = UploadStreamApi(jsonData: jsonData, imgData: imgData)
                }

            }
        }

        title = "\(uploadRows.description)"


        guard let uploadApi = uploadApi else { fatalError("request nil") }

        uploadApi.start()
        uploadApi.progress({ [weak self] (totalBytesWrite, totalBytesExpectedToWrite) -> Void in
            print("totalBytesWrite: \(totalBytesWrite), totalBytesExpectedToWrite: \(totalBytesExpectedToWrite)")
            print("percent: \(100 * Float(totalBytesWrite)/Float(totalBytesExpectedToWrite))")
            
            let percent = Float(totalBytesWrite)/Float(totalBytesExpectedToWrite)
            guard let strongSelf = self else { return }
            DispatchQueue.main.async(execute: { () -> Void in
                strongSelf.processView.progress = percent
                let read = String(format: "%.2f", Float(totalBytesWrite)/1024)
                let total = String(format: "%.2f", Float(totalBytesExpectedToWrite)/1024)
                strongSelf.writeLabel.text = "read: \(read) KB"
                strongSelf.totalLabel.text = "total: \(total) KB"
            })
        }).responseJSON({ (json, error) -> Void in
            if (error != nil) {
                print("==========error: \(error)")
            } else {
                print(self.uploadApi.debugDescription)
                print("==========json: \(json)")
            }
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    */
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
