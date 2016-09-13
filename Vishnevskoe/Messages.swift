//
//  Messages.swift
//  Vishnevskoe
//
//  Created by Chingiz Bayshurin on 07.07.16.
//  Copyright © 2016 Chingiz Bayshurin All rights reserved.
//

import UIKit

class Messages: UIViewController, UITableViewDataSource, UITableViewDelegate {

   
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var messageTable: UITableView!
   

  
    

    
    //*************************************************************************************************************//
    //**********************  viewDidLoad *************************************************************************//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //--------------инициализация меню SWRevealView для открытия личного кабинета ----------------------
        if (self.revealViewController() != nil)
        {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            
            let prefs = NSUserDefaults.standardUserDefaults()
            let myArray = prefs.objectForKey("pushNotifications") as? [Dictionary<String,String>]
            
            if (myArray != nil ){
                let newArray = myArray!
                print(newArray)
            }
            
        
        }
        //--------------------------------------------------------------------------------------------------
        
       
        messageTable.delegate = self
        
        
    }//*************************************************************************************************************//
    //**********************  viewDidLoad *************************************************************************//
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(Cabinet.myPushNotifications)
        
        return Cabinet.myPushNotifications.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.messageTable.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! MessageTableCell
        //let entry = data.places[indexPath.row]
        //let image = UIImage(named: entry.filename)
        //cell.messageDateLabel.text = "dddd"
        //cell.messageTextLabel.text = "ddssd"
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Justified
        
        //текст сообщения будем выравнивать по ширине
        let text = Cabinet.myPushNotifications[indexPath.item]["Text"]!
        let attributedString = NSAttributedString(string: text,
                                                  attributes: [
                                                    NSParagraphStyleAttributeName: paragraphStyle,
                                                    NSBaselineOffsetAttributeName: NSNumber(float: 0)
            ])
        //раньше вот это применили, для того, чтобы перенос строки заработал
        //cell.messageText.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
        //cell.messageText.numberOfLines = 0
    
        cell.messageText.attributedText = attributedString
        cell.messageText.sizeToFit()
        
        cell.messageDate.font = UIFont.boldSystemFontOfSize(17.0)
        cell.messageDate.text = Cabinet.myPushNotifications[indexPath.item]["createdOn"]!
        
        
        
        return cell
    }
    
    
    
}//=== конец функции

