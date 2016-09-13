//
//  Zayvka.swift
//  Vishnevskoe
//
//  ВТОРАЯ ФОРМА   
//
//  Created by Chingiz Bayshurin on 29.06.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//


import UIKit

//*** мы ставим наследования от UIAlertViewDelegate так как мы работаем с устаершим UIAlertView -
//*** и нам нужна обработка нажатий на клавиши



class Zayavka: UIViewController,  UINavigationControllerDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var cabinetTitle: UILabel!
    @IBOutlet weak var carStateNumber: UITextField!
    @IBOutlet weak var carColor: UITextField!
    @IBOutlet weak var carModel: UITextField!
    @IBOutlet weak var manOrWomanSwitch: UISegmentedControl!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var favoriteMusicTitleLabel: UILabel!
    
    //названия этой кнопки будем менять в зависимости от ответа сервера Зелендольское
    //есть или нет юзер в системе
    @IBOutlet weak var findButtonTitle: UIButton!
    @IBOutlet weak var favoriteMusicLabel: UILabel!
    @IBOutlet weak var favoriteMusicSegment: UISegmentedControl!
    
    
  

    
    
    //************ для работы с базой сервера *********************
    //var digestOfUuid : String = String()  --  перенес в класс Cabinet
    var makeNewUserBool = false
    var oneClick = false
    var NOW_I_INPUT_CAR_NUMBER = false
    //*************************************************************
    

    
    override func viewDidLoad()
    {//============================================= viewDidLoad ========================================================================================
        super.viewDidLoad()
        

        //метод взял из уроков Rob Percival'а - на скрытие клавиатуры по щелчку на пустую область экрана
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        
        
        let newBarButton:UIBarButtonItem = UIBarButtonItem.init(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = newBarButton
        
        fullName.addTarget(nil, action:Selector("dismissKeyboard:"), forControlEvents:.EditingDidEndOnExit)
        carStateNumber.addTarget(nil, action:Selector("dismissKeyboard:"), forControlEvents:.EditingDidEndOnExit)
        carModel.addTarget(nil, action:Selector("dismissKeyboard:"), forControlEvents:.EditingDidEndOnExit)
        carColor.addTarget(nil, action:Selector("dismissKeyboard:"), forControlEvents:.EditingDidEndOnExit)
    }//============================================= viewDidLoad ========================================================================================
    
    
    
      override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    override func viewWillAppear(animated: Bool)
    {//============= WILL APPAER ===========================================================================================================================
   
        
        //мы все это показываем зарегистрированному пользователю и тут же переводим его на 3 ФОРМЫ
        if(Cabinet.userExists &&  !Cabinet.type){
            //---make 1 sec pause for iOS 7 ----
            if #available(iOS 8.0, *){
                 self.performSegueWithIdentifier("sendApplication", sender: self)
            } else {
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue())        {
                    self.performSegueWithIdentifier("sendApplication", sender: self)
                }
            }//----------------------------------
        }
        else if (Cabinet.userExists &&  Cabinet.type && !Cabinet.carNumber.isEmpty) {
            //---make 1 sec pause for iOS 7 ----
            if #available(iOS 8.0, *){
                 self.performSegueWithIdentifier("sendApplication", sender: self)
            } else {
                let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
                dispatch_after(time, dispatch_get_main_queue())        {
                    self.performSegueWithIdentifier("sendApplication", sender: self)
                }
            }//----------------------------------
        }
        else {
            /* вводи номер авто! **/
        }
        
        
        //====ПЕРЕКЛЮЧЕНИЯ РЕЖИМОВ в ЗАВИСИМОСТИ ОТ ТИПА=============================
        if(!Cabinet.type){
            cabinetTitle.text = "Вы пассажир:"
            self.carColor.hidden = true
            self.carModel.hidden = true
            self.carStateNumber.hidden = true
            
            //указываем выбранную музыку
            addBoldText()
            
        }
        else{
            cabinetTitle.text = "Вы водитель:"
            
            self.favoriteMusicTitleLabel.hidden = true
            self.favoriteMusicLabel.hidden = true
            self.favoriteMusicSegment.hidden = true
            
            self.carColor.hidden = false
            self.carModel.hidden = false
            self.carStateNumber.hidden = false
            
            self.carModel.text = Cabinet.carModel
            self.carColor.text = Cabinet.carColor
            self.carStateNumber.text = Cabinet.carNumber
            
        }
        //делаем строку rezhim для печати в консоли
        let rezhim = !Cabinet.type ? "пасажаира" : "водителя"
        print("ВТОРАЯ ФОРМА -> Личный кабинет в режиме \(rezhim)")
        //================================================================================
        
        
        //=== я точно знаю что раз запускалась ГЛАВНАЯ АКТИВИТИ - ЗНАЧИТ В КАБИНЕТЕ ВСЕ ЕСТЬ
        self.fullName.text = Cabinet.fullName
        self.manOrWomanSwitch.selectedSegmentIndex = !(Cabinet.sex) ? 0 : 1
        
        //====  мы уже в MainView проверили, есть ли пользователь или нет, потому сразу обращаемся
         if (Cabinet.userExists)
         {//--------- ПОЛЬЗОВАТЕЛЬ ЕСТЬ В СИСТЕМЕ--------------------------------------------
            //а если пользователь есть в системе Зеленодольское, то тогда кнопку
            //поставить на искать машину
                if ( !Cabinet.type )
                {
                    self.findButtonTitle.setTitle("Искать машину", forState: .Normal)
                }
                else
                {
                    self.findButtonTitle.setTitle("Искать пассажиров", forState: .Normal)
                }
           }//--------- END ПОЛЬЗОВАТЕЛЬ ЕСТЬ В СИСТЕМЕ ---------------------
          else
            {//-------- ПОЛЬЗОВАТЕЛЯ НЕТ В СИСТЕМЕ-----------------------------
                print("ВТОРАЯ ФОРМА -> Пользователя НЕТ на СЕРВЕРЕ!")
                //только по нажатию на OK будет создан новый юзер
                //а для того, чтобы он создавался только один раз (я не совладал с перехватом нажатий на кнопик
                //AlertView - я завел отдельную переменную класса
                self.makeNewUserBool = true
                            
                //для того чтобы перерисовать кнопку вместо "ИСКАТЬ ТАЧКИ" - на создать порльзователя
                Cabinet.userExists = false
                self.findButtonTitle.setTitle("Зарегистрироваться", forState: .Normal)
    
            }//------ END ПОЛЬЗОВАТЕЛЯ НЕТ В СИСТЕМЕ ----------------------

        //===========================================================================================================
     
        //for beauty
        addBoldTextInZayavka()
     
    }//============= WILL APPAER ===========================================================================================================================
  
    
    
    

    
    
    
    
    
    //**************************************************************************************************
    //override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //**************************************************************************************************
    
    
    
    
    //****** НОВЫЙ СПОСОБ ПЕРЕДАЧИ ДАННЫХ ПО НАЖАТИЮ КЛАВИЩИ BACK **************************************
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
    }
    //**************************************************************************************************
    
    
    
    
    
    
    //============МНОГОФУНКЦИОНАЛЬНАЯ КНОПКА FIND/SEND - МЫ ПРОВЕРЯЕМ УСЛОВИЯ ПРЕЖДЕ ЧЕМ ПУСТИТЬ НА VIEW ФОРМИРОВАНИЯ ЗАЯВКИ ==================================================
    @IBAction func findMeCarsOrPassen(sender: AnyObject) {
   
      if( !Cabinet.userExists)
      {//========================== ЕСЛИ ПОЛЬЗОВАТЕЛЬ НЕ  ЗАРЕГИСТРИРОВАН НА СЕРВЕРЕ ======================================================================
        
        //он это должен сделать сейчас
        //Условия:     
        
        //для пассажира 
        //1) ФИО должно быть заполнено
        if(!Cabinet.type && (self.fullName.text?.isEmpty)!) {
            //---------------
            if #available(iOS 8.0, *) {
                var alertController = UIAlertController(title: "Не заполнены обязательные поля", message: "Пожалуйста, введите свое имя как пассажир", preferredStyle: .Alert)
                var cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                }
                alertController.addAction(cancelAction)
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                let Alert: UIAlertView = UIAlertView(title: "Не заполнены обязательные поля", message: "Пожалуйста, введите свое имя как пассажир",
                                                     delegate: nil, cancelButtonTitle: "Ok")
                Alert.show()
            }
            //-----------------
            
            
            return
        }
        
        //для водителя
        //1) ФИО ддолжно быть заполнено
        if(Cabinet.type && (self.fullName.text?.isEmpty)!) {
            //---------------
            if #available(iOS 8.0, *) {
                var alertController = UIAlertController(title: "Не заполнены обязательные поля", message: "Пожалуйста, введите свое имя как водитель", preferredStyle: .Alert)
                var cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                }
                alertController.addAction(cancelAction)
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                let Alert: UIAlertView = UIAlertView(title: "Не заполнены обязательные поля", message: "Пожалуйста, введите свое имя как водитель",
                                                     delegate: nil, cancelButtonTitle: "Ok")
                Alert.show()
            }
            //-----------------
            return
        }
        //номер машины
        if(Cabinet.type && (self.carStateNumber.text?.isEmpty)!) {
            //---------------
            if #available(iOS 8.0, *) {
                var alertController = UIAlertController(title: "Не заполнены обязательные поля", message: "Водитель, пожалуйста, укажите государственный регистрационный номер своего автомобиля", preferredStyle: .Alert)
                var cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                }
                alertController.addAction(cancelAction)
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                let Alert: UIAlertView = UIAlertView(title: "Не заполнены обязательные поля", message: "Водитель, пожалуйста, укажите государственный регистрационный номер своего автомобиля",
                                                     delegate: nil, cancelButtonTitle: "Ok")
                Alert.show()
            }
            //-----------------
            return
        }
        
        
    
           //все - создавай мне нового юзера! и снимай фоажок - я думаю за 1 попытку все будет ок
            if (self.makeNewUserBool){
                
                //******* СОЗДАЕМ НОВОГО ЮЗЕРА ОБРАЩАЯСЬ К ФУНКЦИЯ КЛАССОВ Cabinet & NetworkManager ***********
                //для тестов если симулятор затупит Cabinet.digestOfUuid = "d41d8cd98f00b204e9800998ec888887" /**/
                
                Cabinet.fullName = self.fullName.text!
                Cabinet.carNumber = self.carStateNumber.text!
                Cabinet.carColor = self.carColor.text!
                Cabinet.carModel = self.carModel.text!
                Cabinet.favoriteMusicILike = self.favoriteMusicSegment.selectedSegmentIndex
                if( NetworkManager.registerNewUser() || !NetworkManager.registerNewUser() ) {
                    //****  пока мы так поступаем, чтобы заморозить главный поток, до получения ответа
                    //****  от результатов выполнения фоновой функции  NetworkManager.registerNewUser()
                }
                
                
                //self.makeNewUserBool  = false
            }
            
            //морозим кнопку на 1 секунду, чтобы юзер не щелкал зазря
            self.findButtonTitle.enabled = false
            let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
            dispatch_after(time, dispatch_get_main_queue())
            {
                // разморажиаем черещ 1 секунду
                 self.findButtonTitle.enabled = true
                //а также меняем та
                if ( !Cabinet.type ) {
                    self.findButtonTitle.setTitle("Искать машину", forState: .Normal)
                } else {
                    self.findButtonTitle.setTitle("Искать пассажиров", forState: .Normal)
                }
                self.oneClick = true
            }
       
        
      }///================================================================================================================================================
        
      else if(Cabinet.userExists && Cabinet.type && (self.carStateNumber.text?.isEmpty)!) {
        let button2Alert: UIAlertView = UIAlertView(title: "Не заполнены обязательные поля", message: "Водитель, пожалуйста, укажите государственный номер своего автомобиля",
                                                    delegate: self, cancelButtonTitle: "Ok", otherButtonTitles: "Cancel")
        button2Alert.show()
        return
      }
       
        //все, пассажир, перешедший в роль водителя ЗАПОЛНИЛ номер своего авто - и ФЛАЖОК РАЗОВОСТИ
      else if(Cabinet.userExists && Cabinet.type && !(self.carStateNumber.text?.isEmpty)! && !NOW_I_INPUT_CAR_NUMBER) {
      
        //морозим кнопку на 1 секунду, чтобы юзер не щелкал зазря
        self.findButtonTitle.enabled = false
        let time = dispatch_time(dispatch_time_t(DISPATCH_TIME_NOW), 1 * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue())
        {
            // разморажиаем черещ 1 секунду
            self.findButtonTitle.enabled = true
            self.oneClick = true
            self.NOW_I_INPUT_CAR_NUMBER = true
        }
        if( NetworkManager.changeRegisterData() || !NetworkManager.changeRegisterData() ) {
            //****  пока мы так поступаем, чтобы заморозить главный поток, до получения ответа
            //****  от результатов выполнения фоновой функции  NetworkManager.registerNewUser()
        }

        
        return
      }
        
      
      else
      {//=============ВСЕ ПОЛЬЗОВАТЕЛЬ ЗАРЕГИСТРИРОВАН и МОЖНО СОЗДАВАТЬ ЗАЯВКУ ==========================================================================
            //NetworkManager.createNewApplication()
           self.oneClick = true
           print("ВТОРАЯ ФОРМА - пора переходить на ТРЕТЬЮ ФОРМУ!")
      }//=================================================================================================================================================
        

        
        
        
        
        
    }//======================================================================================================================================================
    
    
    
    

    //============================ НЕ ПРОПУСТИМ ПОЛЬЗОВАТЕЛЯ НА ПЕРЕХОД ПОКА ОН НЕ ЗАРЕГИСТРИРУЕТСЯ ========================================================
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool
    {
        if (identifier == "sendApplication")
        {
            if (!Cabinet.userExists || !self.oneClick )
            {
                //пользоватль на сервере не существует
                //на отправку заявки мы его, разумеется, не пускаем
                print("ВТОРАЯ ФОРМА - НЕ ПУСКАЮ НА ТРЕТЬЮ ФОРМУ")
                return false
            }
            else if (self.oneClick)
            {
                //сущесвует - отлично - вперед и с песней
                self.oneClick = false
                return true
            }
            else
            {
                return false
            }
            
        }
        return true
        
    }//======================================================================================================================================================
    
    
    
    //=====================ДЛЯ ТОГО ЧТОБЫ ПО ЩЕЛЧКУ НА RETURN ПРОСИХОДИЛО СВОРАЧИВАНИЕ КЛАВЫ =================================================================
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    //=========================================================================================================================================================
    
    
    
    
    
    
    //================ КОСТЫЛИ - обработчик нажатий на клавишу OK в устаервшем UIView==========================================================================
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch (buttonIndex)
        {//---swicth
        case 0:
            if( self.makeNewUserBool ) {
                
                //мы теперь автоматом небудем вызвать эту фнукцию, только по щелчку на нопку findButton
                //у которой Title меняется
                //!!! и отныне именно по щелчку той кнопки findButton будет меняться флажок self.makeNewUserBool 
                //self.createNewUser(self.digestOfUuid)
                //self.makeNewUserBool  = false
            }
            print("выбор в AlertView выбор кнопки Ok")
            break
        default:
            
            print("выбор в AlertView кнопки Сancel")
            break
        }//---switch
    }
    //================ КОСТЫЛИ - обработчик нажатий на клавишу OK в устаервшем UIView==============================================================================
    

    

    //======= Calls this function when the tap is recognized. =====================================================================================================
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    //наполнение favoriteMusicDescription и выделение выбора
    //мы берем выбранный индекс, затем сначала получаем строку
    //из массива всех станций
    //и затем с помощью хитрой функции addBoldText делаем жирной только нужную строку
    private func addBoldText() {
        let number = Cabinet.favoriteMusicILike
        var desciptionString = String()
        for line in Cabinet.favoriteMusicDescription {
            desciptionString += line
        }
        favoriteMusicLabel.attributedText = Cabinet.addBoldText(desciptionString,
                                                                boldPartOfString: Cabinet.favoriteMusicDescription[number],
                                                                font: UIFont.systemFontOfSize(17),
                                                                boldFont: UIFont.boldSystemFontOfSize(17))
        Cabinet.favoriteMusicILike = number
    }
    
    
    
    @IBAction func favoriteMusicSegmentChanged(sender: AnyObject) {
        addBoldTextInZayavka()
        let number = favoriteMusicSegment.selectedSegmentIndex
        print("ВТОРАЯ ФОРМА -> Выбрано музыка: #", Cabinet.favoriteMusicILike, "  ", Cabinet.favoriteMusicDescription[number])
        
    }
    
    //наполнение favoriteMusicDescription и выделение выбора
    //мы берем выбранный индекс, затем сначала получаем строку
    //из массива всех станций
    //и затем с помощью хитрой функции addBoldText делаем жирной только нужную строку
    private func addBoldTextInZayavka() {
        let number = favoriteMusicSegment.selectedSegmentIndex
        var i = 0
        var descriptionString = String()
        for line in Cabinet.favoriteMusicDescription {
            descriptionString += line
            if i < Cabinet.favoriteMusicDescription.count - 1 {
                descriptionString += "\r"  //we add new line symbol except lest element
            }
            i += 1
        }
        favoriteMusicLabel.attributedText = Cabinet.addBoldText(descriptionString,
                                                                boldPartOfString: Cabinet.favoriteMusicDescription[number],
                                                                font: UIFont.systemFontOfSize(17),
                                                                boldFont: UIFont.boldSystemFontOfSize(17))
        
        Cabinet.favoriteMusicILike = number
    }

    
    @IBAction func manOrWomanSegmentChanged(sender: AnyObject) {
        if ( self.manOrWomanSwitch.selectedSegmentIndex == 0 ) {
            Cabinet.sex = false
            print("Вторая ФОРМА -> Установлен Cabinet.sex  = \(Cabinet.sex), то есть МУЖСКОЙ пол пользователя")
        } else {
            Cabinet.sex = true
            print("Вторая ФОРМА -> Установлен Cabinet.sex  = \(Cabinet.sex), то есть ЖЕНСКИЙ пол пользователя")
        }
        
    }
    
    
    
}//===== когнец объявления класса==========
