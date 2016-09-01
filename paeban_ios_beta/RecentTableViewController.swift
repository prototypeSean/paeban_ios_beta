import UIKit

class RecentTableViewController: UITableViewController {
    var rTVModel = RecentTableViewModel?()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rTVModel = RecentTableViewModel(data: nowTopicCellList)
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rTVModel!.lenCount()
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("nowTopicListCell", forIndexPath: indexPath) as! RecentTableViewCell
        
        return rTVModel!.getCell(indexPath.row,cell: cell)
    }
    
}
