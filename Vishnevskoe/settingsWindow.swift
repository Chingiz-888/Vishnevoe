//
//  settingsWindow.swift
//  Vishnevskoe
//
//  Created by Chingiz Bayshurin on 08.09.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

//
//  personalCabinet.swift
//  Vishnevskoe
//
//  Created by Chingiz Bayshurin on 07.07.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import UIKit

class settingsWindow: UIViewController {
    
    
   
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var user_id: UILabel!
    @IBOutlet weak var push_device_token: UILabel!
    
    //**********************  viewDidLoad ****************************************************************************//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //--------------инициализация меню SWRevealView для открытия личного кабинета ----------------------
        if (self.revealViewController() != nil)
        {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //--------------------------------------------------------------------------------------------------
    }//**********************  viewDidLoad *************************************************************************//
    
    
    override func viewWillAppear(animated: Bool) {
        
        //выводим что знаем
        user_id.text = Cabinet.digestOfUuid
        push_device_token.text = Cabinet.deviceToken
        
        
          }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

    
    @IBAction func sendToServer(sender: AnyObject)
    {
        
        if( NetworkManager.savePushTokenTest() ) {
            print("уСПЕХ!")
            //---------------
            if #available(iOS 8.0, *) {
                var alertController = UIAlertController(title: "Ответ от сервера Вишневое", message: "Push DeviceToken успешно сохранен на сервере", preferredStyle: .Alert)
                var cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                }
                alertController.addAction(cancelAction)
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                let Alert: UIAlertView = UIAlertView(title: "Ответ от сервера Вишневое", message: "Push DeviceToken успешно сохранен на сервере",
                                                     delegate: nil, cancelButtonTitle: "Ok")
                Alert.show()
            }
            //-----------------
            
            
            
        } else {
            
            print("НЕУДАЧА!")
            //---------------
            if #available(iOS 8.0, *) {
                var alertController = UIAlertController(title: "Ответ от сервера Вишневое", message: "Ошибка! Push DeviceToken не был сохранен на сервере", preferredStyle: .Alert)
                var cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                }
                alertController.addAction(cancelAction)
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                let Alert: UIAlertView = UIAlertView(title: "Ответ от сервера Вишневое", message: "Ошибка! Push DeviceToken не был сохранен на сервере",
                                                     delegate: nil, cancelButtonTitle: "Ok")
                Alert.show()
            }
            //-----------------
            
            
        }
        
    }

    
    
    
}//=== end of class declaration





















