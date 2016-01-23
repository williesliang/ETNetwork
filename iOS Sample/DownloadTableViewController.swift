//
//  DownloadTableViewController.swift
//  iOS Sample
//
//  Created by gengduo on 15/12/15.
//  Copyright © 2015年 ethan. All rights reserved.
//

import UIKit
import ETNetwork


class DownloadTableViewController: UITableViewController {

    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var processView: UIProgressView!
    var downloadRows: DownloadRows?
    var downloadApi: ETRequest?

    @IBOutlet weak var resumeBtn: UIButton!
    deinit {
        downloadApi?.cancel()

        print("\(self.dynamicType)  deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.downloadRequest()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
    }
    
    class func saveLastData(data: NSData?) {
        guard let data = data else {
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "resumeData")
            return
        }
        
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: "resumeData")
    }
    class func lastData() -> NSData? {
        return NSUserDefaults.standardUserDefaults().dataForKey("resumeData")
    }

    @IBAction func refresh() {
        refreshControl?.beginRefreshing()
        DownloadTableViewController.saveLastData(nil)
        self.downloadRequest()
        self.refreshControl?.endRefreshing()
    }

    func downloadRequest() {
        guard let downloadRows = downloadRows else { fatalError("not set rows") }
        downloadApi?.cancel()
        switch downloadRows {
        case .Download:
            downloadApi = GetDownloadApi(bar: "GetDownloadApi")
        case .DownloadWithResumeData:
            downloadApi = DownloadResumeDataApi(data: DownloadTableViewController.lastData())
        }


        self.title = "\(downloadRows.description)"

        downloadApi?.start()

        //        if let data = downloadApi?.cachedData {
        //            print("cached data: \(data)")
        //        }
        downloadApi?.progress({ [weak self] (bytesRead, totalBytesRead, totalBytesExpectedToRead) -> Void in
            guard let strongSelf = self else { return }
//            print("bytesRead: \(bytesRead), totalBytesRead: \(totalBytesRead), totalBytesExpectedToRead: \(totalBytesExpectedToRead)")
            let percent = Float(totalBytesRead)/Float(totalBytesExpectedToRead)
//            print("percent: \(percent)")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                strongSelf.processView.progress = percent
                strongSelf.readLabel.text = "read: \(totalBytesRead/1024) KB"
                strongSelf.totalLabel.text = "total: \(totalBytesExpectedToRead/1024) KB"
            })
           
        }).response({ (data, error) -> Void in
            print("data: \(data) size: \(data?.length), error: \(error)")
            DownloadTableViewController.saveLastData(data)
        }).httpResponse({ (httpResponse, error) -> Void in
            print("httpResponse \(httpResponse), error: \(error)")
        })
    }


    @IBAction func responseToResumeBtn(sender: UIButton) {
        if sender.selected {
            self.downloadApi?.resume()
            sender.selected = false
        } else {
            self.downloadApi?.suspend()
            sender.selected = true
        }
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
