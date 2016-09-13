//
//  personaCabinetOfDriver.swift
//  Vishnevoe
//
//  Created by Chingiz Bayshurin on 07.07.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import UIKit

class personaCabinetOfDriver: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var driverFullName: UITextField!
    @IBOutlet weak var driverSexSwitch: UISegmentedControl!
    @IBOutlet weak var carModel: UITextField!
    @IBOutlet weak var carColor: UITextField!
    @IBOutlet weak var carNumber: UITextField!
    @IBOutlet weak var changeOrSaveButton: UIButton!
    
    @IBOutlet weak var passengersOnlyGirls: UISwitch!
    @IBOutlet weak var passengerOnlyGirlsLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    

    //**********************  viewDidLoad *************************************************************************//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if( Cabinet.userExists ) {                         /** ПОЛЬЗОВАТЕЛЯ ЕСТЬ НА САЙТЕ, ЕГО ДАННЫЕ МОЖНО ИЗМЕНИТЬ   **/
            driverFullName.text = Cabinet.fullName
            
            if (Cabinet.sex == false) {
                driverSexSwitch.selectedSegmentIndex = 0
                print("ЛИЧНЫЙ КАБИНЕТ ВОДИТЕЛЯ -> По умолчанию установлен ПОЛ водителя МУСЖКОЙ,   Cabinet.sex=\(Cabinet.sex)")
            } else {
                driverSexSwitch.selectedSegmentIndex = 1
                print("ЛИЧНЫЙ КАБИНЕТ ВОДИТЕЛЯ -> По умолчанию установлен ПОЛ водителя ЖЕНСКИЙ,   Cabinet.sex=\(Cabinet.sex)")
            }
           //загружаем данные по машине, если они есть
           if (!Cabinet.carModel.isEmpty){
              carModel.text = Cabinet.carModel
           }
           if (!Cabinet.carColor.isEmpty){
               carColor.text = Cabinet.carColor
           }
           if (!Cabinet.carNumber.isEmpty){
               carNumber.text = Cabinet.carNumber
           }
            //здесь нам не надо проверять на пустоту
            passengersOnlyGirls.setOn(Cabinet.passengersOnlyGirls, animated: false)
            
            changeOrSaveButton.setTitle("ИЗМЕНИТЬ", forState: .Normal)
        }
        else {                                              /** ПОЛЬЗОВАТЕЛЯ НЕТ НА САЙТЕ   **/
            changeOrSaveButton.setTitle("ЗАРЕГИСТРИРОВАТЬСЯ", forState: .Normal)
        }
        
        
        //метод взял из уроков Rob Percival'а - на скрытие клавиатуры по щелчку на пустую область экрана
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(personaCabinetOfDriver.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        
        //--------------инициализация меню SWRevealView для открытия личного кабинета ----------------------
        if (self.revealViewController() != nil)
        {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //--------------------------------------------------------------------------------------------------


              driverFullName.addTarget(nil, action:Selector("dismissKeyboard:"), forControlEvents:.EditingDidEndOnExit)
              carModel.addTarget(nil, action:Selector("dismissKeyboard:"), forControlEvents:.EditingDidEndOnExit)
              carColor.addTarget(nil, action:Selector("dismissKeyboard:"), forControlEvents:.EditingDidEndOnExit)
              carNumber.addTarget(nil, action:Selector("dismissKeyboard:"), forControlEvents:.EditingDidEndOnExit)
        
        
       
 
    }//**********************  viewDidLoad *************************************************************************//
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        //выбирать перевозку только девушек может только ЖЕНЩИНА водитель
        if(!Cabinet.sex) {      /* для мужчин скрываем */
            self.passengersOnlyGirls.alpha = 0
            self.passengerOnlyGirlsLabel.alpha = 0
        } else {                /* для женщин показываем */
            self.passengersOnlyGirls.alpha = 1
            self.passengerOnlyGirlsLabel.alpha = 1
        }
        
        //по умолчанию не показываем идикатор сетевой активности
        activityIndicator.hidden = true
   
    }
    
    
    
    
    @IBAction func changeUserData(sender: AnyObject) {
        
        if (Cabinet.userExists)
        {                      /** ПОЛЬЗОВАТЕЛЯ ЕСТЬ НА САЙТЕ, ЕГО ДАННЫЕ МОЖНО ИЗМЕНИТЬ   **/
            Cabinet.fullName =  driverFullName.text!
            if ( driverSexSwitch.selectedSegmentIndex == 0) {
                Cabinet.sex = false
            } else {
                Cabinet.sex = true
            }
            //снимаем данные по машине
            Cabinet.carModel = carModel.text!
            Cabinet.carColor = carColor.text!
            Cabinet.carNumber = carNumber.text!
            
            /* ТОЛЬКО ЕСЛИ НЕТ ЗАЯВКИ АКТИВНОЙ МОЖНО МЕНЯТЬ ПОЛЬЗОВАТЕЛЬСКИЕ ДАННЫЕ */
            if (!Cabinet.isAnyCurrentApplication)
            {
                  //И ПРИ ИЗМЕНЕНИИ ДАННЫХ, ВСЕ РАВНО ПРОВЕРЯЕМ, ПОЛНОТУ ВВОДА
                  if( !(driverFullName.text?.isEmpty)! && !(carNumber.text?.isEmpty)! ) {
                    activityIndicator.hidden = false
                    activityIndicator.startAnimating()
                    self.changeOrSaveButton.enabled = false
                    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
                    dispatch_after(time, dispatch_get_main_queue())
                    {
                        /****  на одну секунду морозим интерфейс  ****/
                        /****  для того, чтобы юзер часто не жал и не перегружал сервер  ****/
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                        self.changeOrSaveButton.enabled = true
                    }
                       NetworkManager.changeRegisterData()
                  } else {
                    let alert: UIAlertView = UIAlertView(title: "Неполные данные", message: "Пожалуйста, введите свое ФИО и государственный номер своего автомобиля",
                                                         delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "Cancel")
                    alert.show()
                  }
            }
            else
            {
                    let Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Нельзя менять свои пользовательские данные при активной заявке на перевозку", delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "Cancel")
                    Alert.show()
            }
        }
        else {                                       /** ПОЛЬЗОВАТЕЛЯ НЕТ НА САЙТЕ   **/
            if( !(driverFullName.text?.isEmpty)! && !(carNumber.text?.isEmpty)! )
            {
                Cabinet.fullName =  driverFullName.text!
                if ( driverSexSwitch.selectedSegmentIndex == 0) {
                    Cabinet.sex = false
                } else {
                    Cabinet.sex = true
                }
                //снимаем данные по машине
                Cabinet.carModel = carModel.text!
                Cabinet.carColor = carColor.text!
                Cabinet.carNumber = carNumber.text!
                
                
                //и теперь вызываем функцию изменения данныъ на сервере
                activityIndicator.hidden = false
                activityIndicator.startAnimating()
                self.changeOrSaveButton.enabled = false
                
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue())
                {
                    /****  на одну секунду морозим интерфейс  ****/
                    /****  для того, чтобы юзер часто не жал и не перегружал сервер  ****/
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                    self.changeOrSaveButton.enabled = true
                }
                //***если регистрация прошла успещно - обновить кнопку***
                if (  NetworkManager.registerNewUser()  ) {
                    self.changeOrSaveButton.setTitle("ИЗМЕНИТЬ", forState: .Normal)
                }
            }
            else
            {
                let alert: UIAlertView = UIAlertView(title: "Неполные данные", message: "Пожалуйста, введите свое ФИО и государственный номер своего автомобиля",
                                                            delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "Cancel")
                alert.show()
            }
        }
        
     
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //======= Calls this function when the tap is recognized. =====================================================================================================
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    
    
    //определяем, везем ли только девушек или нет
    @IBAction func passengersOnlyGirlsChanged(sender: AnyObject) {
        if (passengersOnlyGirls.on) {
        Cabinet.passengersOnlyGirls = true
            print("ЛИЧНЫЙ КАБИНЕТ ВОДИТЕЛЯ -> Cabinet.passengersOnlyGirls = ", Cabinet.passengersOnlyGirls, "Перевезу только девушек")
        } else {
            Cabinet.passengersOnlyGirls = false
            print("ЛИЧНЫЙ КАБИНЕТ ВОДИТЕЛЯ -> Cabinet.passengersOnlyGirls = ", Cabinet.passengersOnlyGirls, "Мне не важен пол пассажира")
        }
    }
    
    
    
    
    @IBAction func sexChanged(sender: AnyObject) {
        
        
        let sex = driverSexSwitch.selectedSegmentIndex
        
        
        if ( sex == 0) {
            Cabinet.sex = false
            print("ЛИЧНЫЙ КАБИНЕТ ВОДИТЕЛЯ -> Установлен ПОЛ водителя МУСЖКОЙ,   Cabinet.sex=\(Cabinet.sex)")
        } else {
            Cabinet.sex = true
            print("ЛИЧНЫЙ КАБИНЕТ ВОДИТЕЛЯ -> Установлен ПОЛ водителя ЖЕНСКИЙ,   Cabinet.sex=\(Cabinet.sex)")
        }
        
        
        if (sex==0) {
            UIView.animateWithDuration(0.4, delay: 0.1, options: .CurveEaseOut, animations: {
                self.passengersOnlyGirls.alpha = 0
                self.passengerOnlyGirlsLabel.alpha = 0
                }, completion: nil)
        } else {
            UIView.animateWithDuration(0.4, delay: 0.1, options: .CurveEaseOut, animations: {
                self.passengersOnlyGirls.alpha = 1
                self.passengerOnlyGirlsLabel.alpha = 1
                }, completion: nil)
        }
    }
    
    
}//=== конец класса

