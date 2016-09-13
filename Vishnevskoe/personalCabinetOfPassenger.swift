//
//  personalCabinetOfPassenger.swift
//  Vishnevskoe
//
//  Created by Chingiz Bayshurin on 07.07.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import UIKit

class personalCabinetOfPassenger: UIViewController {

    
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var passengerFullName: UITextField!
    @IBOutlet weak var passengerSexSwitch: UISegmentedControl!
    
    @IBOutlet weak var changeOrRegisterButton: UIButton!
    
    @IBOutlet weak var favoriteMusicSegment: UISegmentedControl!
   
    @IBOutlet weak var favoriteMusicLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    

  //**********************  viewDidLoad ****************************************************************************//
  override func viewDidLoad() {
        super.viewDidLoad()
 
    if( Cabinet.userExists ) {
       passengerFullName.text = Cabinet.fullName
        
    }
    
    
    //метод взял из уроков Rob Percival'а - на скрытие клавиатуры по щелчку на пустую область экрана
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(personalCabinetOfPassenger.dismissKeyboard))
    view.addGestureRecognizer(tap)
    
    //--------------инициализация меню SWRevealView для открытия личного кабинета ----------------------
    if (self.revealViewController() != nil)
    {
        menuButton.target = self.revealViewController()
        menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    //--------------------------------------------------------------------------------------------------
    
    
    passengerFullName.addTarget(nil, action:"dismissKeyboard:", forControlEvents:.EditingDidEndOnExit)
    
    
    
    var desciptionString = String()
    for line in Cabinet.favoriteMusicDescription {
        desciptionString += line
    }
    favoriteMusicLabel.text = desciptionString
    
    }//**********************  viewDidLoad *************************************************************************//
    
    
    override func viewWillAppear(animated: Bool) {
        
        //меняем кнопки в зависимости от того, есть ли пользователь на сервере
        if( Cabinet.userExists ) {
            changeOrRegisterButton.setTitle("ИЗМЕНИТЬ", forState: .Normal)
            
            //востанавливаем сохраненную музыку и выделяем жирным выбранную музыку
            favoriteMusicSegment.selectedSegmentIndex = Cabinet.favoriteMusicILike
            addBoldText()
            
        } else {
            //по умолчанию ставим ТИШИНУ
            favoriteMusicSegment.selectedSegmentIndex = 0
            addBoldText()
            changeOrRegisterButton.setTitle("ЗАРЕГИСТРИРОВАТЬСЯ", forState: .Normal)
        }
        
        //устанавливаем пол пассажира (в viewDidLoad неадекватно работало
        if (Cabinet.sex == false) {
            passengerSexSwitch.selectedSegmentIndex = 0
            print("ЛИЧНЫЙ КАБИНЕТ ПАССАЖИРА -> По умолчанию установлен ПОЛ пассажира МУСЖКОЙ,   Cabinet.sex=\(Cabinet.sex)")
        } else {
            passengerSexSwitch.selectedSegmentIndex = 1
            print("ЛИЧНЫЙ КАБИНЕТ ПАССАЖИРА -> По умолчанию установлен ПОЛ пассажира ЖЕНСКИЙ,   Cabinet.sex=\(Cabinet.sex)")
        }
        
        //по умолчанию не показфываем индикатор сетевой активности
        activityIndicator.hidden = true
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeUserData(sender: AnyObject) {
        Cabinet.fullName =  passengerFullName.text!
        
        if ( passengerSexSwitch.selectedSegmentIndex == 0) {
           Cabinet.sex = false
        } else {
            Cabinet.sex = true
        }
        
        /* РАЗРЕШЕГО МЕНЯТЬ ПОЛЬЗОВАТЕЛЬСКИЕ ДАННЫЕ, ЕСЛИ НЕТ АКТИВНОЙ ЗАЯВКИ */
        if(!Cabinet.isAnyCurrentApplication) {
      
           //   в зависимости есть или нет пользователь на сервере - либо вызываем
           //   регистрацию либо функцию изменения
            if ( !(Cabinet.userExists) )
            {
                //******И ПРИ ИЗМЕНЕНИИ ДАННЫХ, ВСЕ РАВНО ПРОВЕРЯЕМ, ПОЛНОТУ ВВОДА**********
                if( !(passengerFullName.text?.isEmpty)! ) {
                    activityIndicator.hidden = false
                    activityIndicator.startAnimating()
                    self.changeOrRegisterButton.enabled = false
                    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
                    dispatch_after(time, dispatch_get_main_queue())
                    {
                        /****  на одну секунду морозим интерфейс  ****/
                        /****  для того, чтобы юзер часто не жал и не перегружал сервер  ****/
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                        self.changeOrRegisterButton.enabled = true
                      }
                    //***если регистрация прошла успещно - обновить название кнопки***
                    if (  NetworkManager.registerNewUser()  ) {
                        changeOrRegisterButton.setTitle("ИЗМЕНИТЬ", forState: .Normal)
                    }
                  } else {
                      let alert: UIAlertView = UIAlertView(title: "Неполные данные", message: "Пожалуйста, введите свое ФИО",
                                                         delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "Cancel")
                      alert.show()
                  }
                //****************************************************************************
            }
            else
            {
                //******И ПРИ ИЗМЕНЕНИИ ДАННЫХ, ВСЕ РАВНО ПРОВЕРЯЕМ, ПОЛНОТУ ВВОДА**********
                if( !(passengerFullName.text?.isEmpty)! ) {
                    activityIndicator.hidden = false
                    activityIndicator.startAnimating()
                    self.changeOrRegisterButton.enabled = false
                    let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
                    dispatch_after(time, dispatch_get_main_queue())
                    {
                        /****  на одну секунду морозим интерфейс  ****/
                        /****  для того, чтобы юзер часто не жал и не перегружал сервер  ****/
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.hidden = true
                        self.changeOrRegisterButton.enabled = true
                    }
                    NetworkManager.changeRegisterData()
                } else {
                    let alert: UIAlertView = UIAlertView(title: "Неполные данные", message: "Пожалуйста, введите свое ФИО",
                                                         delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "Cancel")
                    alert.show()
                }
                //****************************************************************************
            }
      
        }
        else  /* ПРИ АКТИВНОЙ ЗАЯВКЕ ЗАПРЕЩАЕМ МЕНЯТЬ ПОЛЬЗОВАТЕЛЬСКИЕ ДАННЫЕ */
        {
            let Alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Нельзя менять свои пользовательские данные при активной заявке на перевозку",
                                                        delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "Cancel")
            Alert.show()
        }
        
    }
    
    @IBAction func passengerSexChange(sender: AnyObject) {
        if ( passengerSexSwitch.selectedSegmentIndex == 0) {
            Cabinet.sex = false
            print("ЛИЧНЫЙ КАБИНЕТ ПАССАЖИРА -> Установлен ПОЛ пассажира МУСЖКОЙ,   Cabinet.sex=\(Cabinet.sex)")
        } else {
            Cabinet.sex = true
            print("ЛИЧНЫЙ КАБИНЕТ ПАССАЖИРА -> Установлен ПОЛ пассажира ЖЕНСИКЙ,   Cabinet.sex=\(Cabinet.sex)")
        }
    }
    
    
    //======= Calls this function when the tap is recognized. =====================================================================================================
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
   
    
    @IBAction func favoriteMusicSegmentChanged(sender: AnyObject) {
        addBoldText()
        let number = favoriteMusicSegment.selectedSegmentIndex
        print("ЛИЧНЫЙ КАБИНЕТ ПАССАЖИРА -> Выбрано музыка: #", Cabinet.favoriteMusicILike, "  ", Cabinet.favoriteMusicDescription[number])
      
    }
    
    //наполнение favoriteMusicDescription и выделение выбора
    //мы берем выбранный индекс, затем сначала получаем строку
    //из массива всех станций
    //и затем с помощью хитрой функции addBoldText делаем жирной только нужную строку
    private func addBoldText() {
        
        let number = favoriteMusicSegment.selectedSegmentIndex
        var i = 0
        var desciptionString = String()
        for line in Cabinet.favoriteMusicDescription {
            desciptionString += line
            if i < Cabinet.favoriteMusicDescription.count - 1 {
                desciptionString += "\r"  //we add new line symbol except lest element
            }
            i += 1
        }
        favoriteMusicLabel.attributedText = Cabinet.addBoldText(desciptionString,
                                                                boldPartOfString: Cabinet.favoriteMusicDescription[number],
                                                                font: UIFont.systemFontOfSize(17),
                                                                boldFont: UIFont.boldSystemFontOfSize(17))
        
        Cabinet.favoriteMusicILike = number
    }
    
    
}//=== конец функции








