//
//  personalCabinet.swift
//  Vishnevoe
//
//  Created by Chingiz Bayshurin on 07.07.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import UIKit

class personalCabinet: UIViewController {
    
    
    
    @IBOutlet weak var mainWindowButton: UIButton!
    @IBOutlet weak var myApplicationButton: UIButton!
    @IBOutlet weak var passengerButton: UIButton!
    @IBOutlet weak var driverButton: UIButton!
    
    @IBOutlet weak var mainWindowHeight: NSLayoutConstraint!
    @IBOutlet weak var myApplicationHeight: NSLayoutConstraint!
    
    var mainWindowHeightVisible: CGFloat! = 39.0
    var myApplicationHeightVisible: CGFloat! = 39.0

 

    let disabledColor = UIColor.lightGrayColor() //UIColor(red:120/255.0, green:120/255.0, blue:200/255.0, alpha: 1.0)
    let enableColor = UIColor.blackColor()
    
    
    //для того, чтобы изначально кнопка Моя Заявка была убрана

    
    //**********************  viewDidLoad ****************************************************************************//
    override func viewDidLoad() {
       super.viewDidLoad()
        
      
        
   
    }//**********************  viewDidLoad *************************************************************************//
    
    
    override func viewWillAppear(animated: Bool) {
        if(!Cabinet.type)
        {
            passengerButton.enabled = true
            driverButton.enabled = false
            passengerButton.setTitleColor(enableColor, forState: .Normal)
            driverButton.setTitleColor(disabledColor, forState: .Normal)
        }
        else
        {
            passengerButton.enabled = false
            driverButton.enabled = true
            passengerButton.setTitleColor(disabledColor, forState: .Normal)
            driverButton.setTitleColor(enableColor, forState: .Normal)
        }
        
        
        if(!Cabinet.isAnyCurrentApplication) {
            showMainWindowButtonVisibility(false)
            hideMyApplicationButtonVisibility(false)
        }
        else {
            hideMainWindowButtonVisibility(false)
            showMyApplicationButtonVisibility(false)
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    
    //============== УБИРАЕМ МЕСТО ИЗ-ПОД КНОПКИ =================
    func hideMainWindowButtonVisibility(animated: Bool = true)
    {
        
        mainWindowHeight.constant = 0
        mainWindowButton.hidden = true
        if animated
        {
            UIView.animateWithDuration(3.2, animations:
                {
                    () -> Void in
                    self.view.layoutIfNeeded()
                }, completion: nil)
        }
        else
        {
            view.layoutIfNeeded()
        }
    }//============= УБИРАЕМ МЕСТО ИЗ-ПОД КНОПКИ =================
    //============== ВОЗВРАЩАЕМ МЕСТО ИЗ-ПОД КНОПКИ ==============
    func showMainWindowButtonVisibility(animated: Bool = true)
    {
        mainWindowHeight.constant = mainWindowHeightVisible
        mainWindowButton.hidden = false
        if animated
        {
            UIView.animateWithDuration(3.2, animations:
                {
                    () -> Void in
                    self.view.layoutIfNeeded()
                }, completion: nil)
        }
        else
        {
            view.layoutIfNeeded()
        }
    }//============= ВОЗВРАЩАЕМ МЕСТО ИЗ-ПОД КНОПКИ ==============
    
    
    
    
    
    //============== УБИРАЕМ МЕСТО ИЗ-ПОД КНОПКИ =================
    func hideMyApplicationButtonVisibility(animated: Bool = true)
    {
        myApplicationHeight.constant = 0
        myApplicationButton.hidden = true
       if animated   {
            UIView.animateWithDuration(3.2, animations:
                {
                    () -> Void in
                    self.view.layoutIfNeeded()
                }, completion: nil)
        }  else   {
            view.layoutIfNeeded()
        }
    }//============== УБИРАЕМ МЕСТО ИЗ-ПОД КНОПКИ ================
    //============= ВОЗВРАЩАЕМ МЕСТО ИЗ-ПОД КНОПКИ ==============
    func showMyApplicationButtonVisibility(animated: Bool = true)
    {
        myApplicationHeight.constant = myApplicationHeightVisible
        myApplicationButton.hidden = false
        if animated   {
            UIView.animateWithDuration(3.2, animations:
                {
                    () -> Void in
                    self.view.layoutIfNeeded()
                }, completion: nil)
        }  else   {
            view.layoutIfNeeded()
        }
    } //============= ВОЗВРАЩАЕМ МЕСТО ИЗ-ПОД КНОПКИ =============
    
    
   

    
}//=== конец функции








