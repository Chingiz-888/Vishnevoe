//
//  Application.swift
//  Vishnevskoe
//
//  ТРЕТЬЯ ФОРМА
//
//  Created by Chingiz Bayshurin on 30.06.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//


import UIKit

//*** мы ставим наследования от UIAlertViewDelegate так как мы работаем с устаершим UIAlertView -
//*** и нам нужна обработка нажатий на клавиши



class Application: UIViewController,  UINavigationControllerDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var cabinetTitle: UILabel!
    @IBOutlet weak var carStateNumber: UITextField!
    @IBOutlet weak var carColor: UITextField!
    @IBOutlet weak var carModel: UITextField!
    @IBOutlet weak var manOrWomanSwitch: UISegmentedControl!
    @IBOutlet weak var fullName: UITextField!
    
    @IBOutlet weak var lupa: UIImageView!
    @IBOutlet weak var searchingIsPerforming: UILabel!
    
    @IBOutlet weak var departurePoint: UILabel!
    @IBOutlet weak var dateOfRidingLabel: UILabel!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    
    //label'ы обозначалки
    
    @IBOutlet weak var awaitingTimeTitleLabel: UILabel!
    @IBOutlet weak var driverNameTitleLabel: UILabel!
    @IBOutlet weak var carDescriptionTitleLable: UILabel!
    @IBOutlet weak var carColorTitleLabel: UILabel!
    @IBOutlet weak var carNumberTitleLabel: UILabel!
    
    
    //получаемые данные при SUCCEDED APPLICATION
    @IBOutlet weak var awaitingTimeLabel: UILabel!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var carDescriptionLabel: UILabel!
    @IBOutlet weak var carColorLabel: UILabel!
    @IBOutlet weak var carNumberLabel: UILabel!
    @IBOutlet weak var foundPassengersDetailsLabel: UILabel!
    
    var spareString : String = ""
    var blinkingString : String = ""
    var updateNumber:Int = 1
    
    
    //для примивной анимации
    var applicationCancelled = false
    var clickCount = 0
    var frameNumber = 0
    var requestState = 0
    
    //названия этой кнопки будем менять в зависимости от ответа сервера Зелендольское
    //есть или нет юзер в системе
    @IBOutlet weak var findButtonTitle: UIButton!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    //************ для работы с базой сервера *********************
    //var digestOfUuid : String = String()  --  перенес в класс Cabinet
    var makeNewUserBool = false
    //*************************************************************
    @IBOutlet weak var cancelButton: UIButton!
    
    
    //таймеры
    var timer1 = NSTimer()
    var timer2 = NSTimer()
    
    
    //*********  для отладки *************
    @IBOutlet weak var giveInfoNowButton: UIButton!
    @IBOutlet weak var isAnyApplicationNowButton: UIButton!
    
    
  

    
    
    override func viewDidLoad()
    {//=================================== VIEW DID LOAD =================================================================================================
        super.viewDidLoad()
        
        
        //метод взял из уроков Rob Percival'а - на скрытие клавиатуры по щелчку на пустую область экрана
        //let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        //view.addGestureRecognizer(tap)
        
        //хоть это и не нужно (так как есть перекрытие кнопкой burger), для гарантии все равно скрываю кнопку Back
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        //--------------инициализация меню SWRevealView для открытия бокового меню ----------------------
        if (self.revealViewController() != nil)
        {
            menuButton.target = self.revealViewController()
            menuButton.action = Selector("revealToggle:")
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //--------------------------------------------------------------------------------------------------
        
        navigationController?.delegate = self
        
        
        //по умолчанию индикатор сетевой активности не показываем
        self.activityIndicator.hidden = true
        
        //------------------------------------------------------------------------------
        //Создаем новую заявку и если все прошло успешно обновляем интерфйес
        //---запускаем индикатор сетевой активности и блокируем кнопку отмены
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        self.cancelButton.enabled = false
       //------------------------------------------------------------------------------
        
        //убираем данные по найденной анкете
         awaitingTimeLabel.text = ""
         driverNameLabel.text = ""
         carDescriptionLabel.text = ""
         carNumberLabel.text = ""
         carColorLabel.text = ""
        
        lupa.image = UIImage(named: "poisk.png")
        
 
        //var timer = NSTimer()
        //***************** CREATE NEW APPLICATION *************************
        let timer = NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: #selector(Application.createNewApplicationNow), userInfo: nil, repeats: false)
        
        //let button2Alert: UIAlertView = UIAlertView(title: "Вас еще нет в сиcтеме", message: "Но вы можете зарегистрироваться\rВаш id = \(Cabinet.digestOfUuid)",
        //delegate: self, cancelButtonTitle: "Ok", otherButtonTitles: "Cancel")
        //
        //button2Alert.show()
        
        /******* для ОТЛАДКИ 2 КНОПКИ ************************/
        giveInfoNowButton.hidden = true
        isAnyApplicationNowButton.hidden = true
        
        
        //по умолчанию не показываем label'ы по найденным пассажирам
        foundPassengersDetailsLabel.hidden      = true
        
    }//=================================== VIEW DID LOAD =========================================================================================
    
    

    //=== Функция создания Новой Заявки =====
    func createNewApplicationNow(){
        if ( NetworkManager.createNewApplication() ) {
            //сначала запускаем функцию на получение информации о заявке, а потом обновляем интерфейс
            if(NetworkManager.getInfoAboutApplication()){
                updateInfoAboutApplication()
            }
            
            self.activityIndicator.hidden = true
            self.activityIndicator.startAnimating()
            self.cancelButton.enabled = true
            
            //**************************************************************************
            timer1 = NSTimer.scheduledTimerWithTimeInterval(3.2, target: self, selector: #selector(Application.updateInfoAboutApplication), userInfo: nil, repeats: true)
            timer2 = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(Application.tochka), userInfo: nil, repeats: true)
            //**************************************************************************
        }
        else if (NetworkManager.isAnyCurrentApplication() ){
            
            //сначала запускаем функцию на получение информации о заявке, а потом обновляем интерфейс
            if(NetworkManager.getInfoAboutApplication()){
                updateInfoAboutApplication()
                
                //**************************************************************************
                timer1 = NSTimer.scheduledTimerWithTimeInterval(3.2, target: self, selector: #selector(Application.updateInfoAboutApplication), userInfo: nil, repeats: true)
                timer2 = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(Application.tochka), userInfo: nil, repeats: true)
                //**************************************************************************
            }
            
            self.activityIndicator.hidden = true
            self.activityIndicator.startAnimating()
            self.cancelButton.enabled = true
            
        }
        else{
            let alert: UIAlertView = UIAlertView(title: "Ошибка", message: "Произошла ошибка при создании заявки на перевозку",
                                                 delegate: nil, cancelButtonTitle: "Ok", otherButtonTitles: "Cancel")
            alert.show()
            
            self.activityIndicator.hidden = true
            self.activityIndicator.startAnimating()
            self.cancelButton.enabled = true
        }

    }
    
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    override func viewWillAppear(animated: Bool)  {
  }

    
    
    
    
    

    
    func tochka() {
        
        if(requestState==0){
        if(!Cabinet.type){
            
            if(      frameNumber == 0) {   self.searchingIsPerforming.text = "Идет поиск водителя"; frameNumber += 1;  blinkingString="..."}
            else if( frameNumber == 1) {   self.searchingIsPerforming.text = "Идет поиск водителя."; frameNumber += 1}
            else if( frameNumber == 2) {   self.searchingIsPerforming.text = "Идет поиск водителя.."; frameNumber += 1}
            else if( frameNumber == 3) {   self.searchingIsPerforming.text = "Идет поиск водителя..."; frameNumber += 1; blinkingString=""}
            else if( frameNumber == 4) {   self.searchingIsPerforming.text = "Идет поиск водителя...."; frameNumber += 1}
            else if( frameNumber == 5) {   self.searchingIsPerforming.text = "Идет поиск водителя....."; frameNumber += 1}
            else if( frameNumber == 6) {   self.searchingIsPerforming.text = "Идет поиск водителя......"; frameNumber = 0;}
            else { frameNumber = 0 }
            //Cabinet.CurrentApplicationInfo["requestState"]=1     - для ручной эмуляции события отмены сервером
            
            //для тестов эмулируем сработку
            //if(updateNumber > 8) { Cabinet.CurrentApplicationInfo["requestState"]=1 }
            
        } else{
            
            if(      frameNumber == 0) {   self.searchingIsPerforming.text = "Идет поиск пассажира"; frameNumber += 1;    }
            else if( frameNumber == 1) {   self.searchingIsPerforming.text = "Идет поиск пассажира."; frameNumber += 1}
            else if( frameNumber == 2) {   self.searchingIsPerforming.text = "Идет поиск пассажира.."; frameNumber += 1; blinkingString=""}
            else if( frameNumber == 3) {   self.searchingIsPerforming.text = "Идет поиск пассажира..."; frameNumber += 1;  }
            else if( frameNumber == 4) {   self.searchingIsPerforming.text = "Идет поиск пассажира...."; frameNumber += 1;  }
            else if( frameNumber == 5) {   self.searchingIsPerforming.text = "Идет поиск пассажира....."; frameNumber += 1; blinkingString=" ? "}
            else if( frameNumber == 6) {   self.searchingIsPerforming.text = "Идет поиск пассажира......"; frameNumber = 0;  }
            else { frameNumber = 0 }
            
            //для тестов эмулируем сработку
            //if(updateNumber > 7) { Cabinet.CurrentApplicationInfo["requestState"]=2 }
        }
        } else if (requestState==1) {
            spareString = ""
        }
          else if (requestState==2){
            spareString = ""
        }
        else{
            
        }

    }
    
    
    

    
    

    //=== ОБНОВЛЕНИЕ ИНФОРМАЦИИ О ЗАЯВКЕ ===================================================
    func updateInfoAboutApplication()  {
        //---запускаем индикатор сетевой активности и блокируем кнопку отмены
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        self.cancelButton.enabled = false
        
        //---если информация о заявке, то тогда pupulating делаем----
        if ( NetworkManager.getInfoAboutApplication() )
        {
            //Логгирование
            print(""); print("")
            let gotRequestState = Cabinet.CurrentApplicationInfo["requestState"] as! Int
            print("updateInfoAboutApplication() # \(updateNumber) ********************************** requestState = \(gotRequestState)")
            print(""); print("")
            updateNumber += 1;
            
            //ставим номер заявки в шапку
            Cabinet.applicationNumber = Cabinet.CurrentApplicationInfo["requestNumber"] as! Int
            self.title = "Заявка № \(Cabinet.applicationNumber)"
   
            
            //---инициализируем Label'ы------------------------
            self.timeIntervalLabel.text = ""
            if( Cabinet.CurrentApplicationInfo["timeFrom"] != nil )
            {
                let time = getForMeOnlyHourMinutes (   Cabinet.CurrentApplicationInfo["timeFrom"]  as! String )
                self.timeIntervalLabel.text = time + "-"
            }
            
            if( Cabinet.CurrentApplicationInfo["timeTo"] != nil )
            {
                let time = getForMeOnlyHourMinutes (   Cabinet.CurrentApplicationInfo["timeTo"]  as! String )
                self.timeIntervalLabel.text = self.timeIntervalLabel.text! + time
            }
            
            
            if( Cabinet.CurrentApplicationInfo["timeFrom"] != nil )
            {
                self.dateOfRidingLabel.text = TimeModel.getForMeOnlyShortDate ( Cabinet.CurrentApplicationInfo["timeFrom"] as! String  )
                
                //!!!!!!!!!! ***************************************
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
            }
            
            //устанавливаем метку, какой пункт отправки    /* 0 - Кольцо (пенсионный фонд)    1 -  Энергоинститут   */
            
            self.departurePoint.text = Cabinet.departurePointIdLabel[ Cabinet.departurePointId ]
            //обновляем размеры на экране
            departurePoint.sizeToFit()
            
            
            
            
            
            

            
            
            //============ проверяем  статусы RequestId =======================================
            switch ( Cabinet.CurrentApplicationInfo["requestState"] as! Int ) {
            case 0:                           // ИДЕТ ПОИСК
                
                
                
             
                break
            case 1:                            // ВОДИТЕЛЬ НЕ НАЙДЕН
                
                    if(!Cabinet.type){
                        self.searchingIsPerforming.text = "К сожалению, для Вас не найден водитель"
                    } else{
                        self.searchingIsPerforming.text = "К сожалению, для Вас не найдены пассажиры"
                    }
                    searchingIsPerforming.sizeToFit()         //чтобы был перенос на новую строку
                    lupa.image = UIImage(named: "fail.png")   //выставляем иконку ошибки
                    applicationFailed()                       //функция фейла заявки
                    searchingIsPerforming.setNeedsDisplay()
                    requestState = 1
                break
            case 2:                             // ВОДИТЕЛЬ НАЙДЕН!
                
                    if(!Cabinet.type){
                        self.searchingIsPerforming.text = "Успех! Для Вас найден водитель!"
                    } else{
                        self.searchingIsPerforming.text = "Успех! Для Вас найдены пассажиры!"
                    }
                    self.searchingIsPerforming.sizeToFit()      //чтобы был перенос на новую строку
                    lupa.image = UIImage(named: "success.png")  //выставляем иконку успеха
                    applicationSucceded()                       //останавливаем таймеры
                    requestState = 2
                break
            default:
                break
            }
            //============ проверяем  статусы RequestId =======================================
            
           
       
            if(requestState==0) { spareString = blinkingString }
            else                { spareString = "" }
            
           
            //если режим пассажира - то прказываем соответствующие поля//
            if(!Cabinet.type) {                 /* РЕЖИМ ПАССАЖИРА */
            //====наполняем данные, если есть данные по найденной машине======================
            spareString = ""
            let waitingTime = TimeModel.getAwaitingHours( Cabinet.CurrentApplicationInfo["awaitingTimeFrom"] as! String,
                                                          awaitingTimeTo: Cabinet.CurrentApplicationInfo["awaitingTimeTo"] as! String)
            if ( waitingTime == "00:00 - 00:00") {
                awaitingTimeLabel.text = spareString
            } else {
                awaitingTimeLabel.text = waitingTime
            }
            
            if (Cabinet.CurrentApplicationInfo["driverName"] != nil) {
                driverNameLabel.text = Cabinet.CurrentApplicationInfo["driverName"] as! String
            } else {
                driverNameLabel.text = spareString
            }
            
            if (Cabinet.CurrentApplicationInfo["carDescription"] != nil) {
                carDescriptionLabel.text = Cabinet.CurrentApplicationInfo["carDescription"] as! String
            } else {
                carDescriptionLabel.text = spareString
            }
            
            if (Cabinet.CurrentApplicationInfo["carColor"] != nil) {
                carColorLabel.text = Cabinet.CurrentApplicationInfo["carColor"] as! String
            } else {
                carColorLabel.text = spareString
            }
            
            if (Cabinet.CurrentApplicationInfo["carNumber"] != nil) {
                carNumberLabel.text = Cabinet.CurrentApplicationInfo["carNumber"] as! String
            } else {
                carNumberLabel.text = spareString
            }
            //==================================================================================
            } else {                          /* РЕЖИМ ВОДИТЕЛЯ */
                driverNameLabel.hidden = true
                carDescriptionLabel.hidden = true
                carColorLabel.hidden = true
                carNumberLabel.hidden = true
                
                //для улучшения форматирования, просто меняем label "Время ожидания"
                awaitingTimeTitleLabel.text = "Найденные пассажиры:"
                driverNameTitleLabel.hidden = true
                carDescriptionTitleLable.hidden = true
                carColorTitleLabel.hidden = true
                carNumberTitleLabel.hidden = true
                
            
                foundPassengersDetailsLabel.hidden = false
                
                //циклом показываем найденных пассажиров *******************************
                if (Cabinet.CurrentApplicationInfo["passengerList"] != nil  &&
                             Cabinet.CurrentApplicationInfo["passengersCount"]  != nil) {
                    
                    var i:Int                = 0
                    var line:String          = ""
                    var passengerName:String = String()
                    var passengerRadioId:Int  = 0
                    var radio:String         = String()
                    //Cabinet.CurrentApplicationInfo["passengersCount"] as! Int
                    while ( i < Cabinet.CurrentApplicationInfo["passengerList"]!.count) {
                        passengerName    = Cabinet.CurrentApplicationInfo["passengerList"]![i]["name"] as! String
                        passengerRadioId = Cabinet.CurrentApplicationInfo["passengerList"]![i]["favoriteMusicId"] as! Int
                        radio = Cabinet.favoriteMusicDescription[ passengerRadioId  ]
                        
                        if( passengerRadioId == 0){
                        line = line + "\(i+1)) \(passengerName), любит слушать просто тишину\r\r"
                        } else {
                        line = line + "\(i+1)) \(passengerName), любит слушать радиостанцию  \(radio)\r\r"
                        }
                        i++
                    }
                    
                    foundPassengersDetailsLabel.text = line
                    foundPassengersDetailsLabel.sizeToFit()
                }
                
                
            }
                
                
            //загружаем сообщения
            getPushNotificationsNow()
          
            
            self.lupa.hidden = false
            //-------------------------------------------------
        }//-----isAnyApplication-----------------------------------
        
        //---запускаем индикатор сетевой активности и блокируем кнопку отмены
        self.activityIndicator.stopAnimating()
        self.activityIndicator.hidden = true
        self.cancelButton.enabled = true
    }//=== ОБНОВЛЕНИЕ ИНФОРМАЦИИ О ЗАЯВКЕ ========================================================================================================
    
    
    
    
    
    
    
    
    //============================== ФУНКИЦЯ ВЫЧЛЕНЕНИЯ ТОЛЬКО ЧАСОВ и МИНУТ из ДЛИННОЙ ДАТЫ ======================================================
    func getForMeOnlyHourMinutes (stringDate: String) -> String
    {
   
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "Moscow/Europe")
        let finish = dateFormatter.dateFromString(stringDate)
        
        if( finish != nil )
        {
            
            let calendar = NSCalendar.currentCalendar()
            let components = calendar.components([ .Hour, .Minute, .Second], fromDate: finish!)
            let hour = components.hour
            let minutes = components.minute
            let seconds = components.second
            
            
            
            //если минут меньше 10, то добавляем нолик, чтобы было например, "00"
            var str_hours = String()
            if (hour < 10)    {  str_hours  = "0\(hour)"  }
            else              {  str_hours  =  "\(hour)"  }
  
            //если минут меньше 10, то добавляем нолик, чтобы было например, "00"
            var str_minutes = String()
            if (minutes < 10)    {  str_minutes = "0\(minutes)"  }
            else                 {  str_minutes =  "\(minutes)"  }
            
            return "\(str_hours):\(str_minutes)"
            
        }
        else
        {
            return "00:00"
        }
    }
    
    
    //==== успешно найдены водитель или пассажир ===
    func applicationSucceded() {
        //выключаем таймеры
        timer1.invalidate();
        timer2.invalidate();
    }
    
    //==== не найден водитель или пассажир =========
    func applicationFailed()  {
        //выключаем таймеры
        timer1.invalidate();
        timer2.invalidate();
        
        //*** принудительно отменяем заявку *****
        if ( NetworkManager.cancelCurrentApplication() || !NetworkManager.cancelCurrentApplication()){
            print("ТРЕТЬЯ ФОРМА -> Для тестов я принудительно отменил заявку функцией NetworkManager.cancelCurrentApplication()")
        }
        
        //для работы с кнопкой ОТМЕНА
        applicationCancelled = true
        clickCount = clickCount + 1
        cancelButton.setTitle("НА ГЛАВНУЮ", forState: .Normal)
 
        //и далее в зависимости в качестве кого мы выступали, мы обнуляем label'ы
        if (!Cabinet.type) {    /*режим пассажира */
         /*awaitingTimeLabel.text    = "   "
           driverNameLabel.text      = "   "
           carDescriptionLabel.text  = "   "
           carColorLabel.text        = "   "
           carNumberLabel.text       = "   "*/
           spareString               = "   "
        } else {                /*режим водителя */
            
            //******* пока пусть тоже так будет
            spareString               = "   "
            
        }
    }
    
    
   
    
    //==== нажатие на Отмену текущей заявки =======
    @IBAction func cancelApplication(sender: AnyObject)  {
        print("")
        
        if( !applicationCancelled ) {
            let cancel_result = NetworkManager.cancelCurrentApplication()
            if ( cancel_result == true || cancel_result == false ) {
                cancelButton.setTitle("НА ГЛАВНУЮ", forState: .Normal)
                
                self.timeIntervalLabel.text = "   "
                self.title = "Заявка отменена"
                self.dateOfRidingLabel.text = "   "
                self.departurePoint.text = "   "
                
                self.awaitingTimeLabel.text = "  "
                self.driverNameLabel.text = "   "
                self.carDescriptionLabel.text = "   "
                self.carColorLabel.text = "   "
                self.carNumberLabel.text = "    "
                
                self.searchingIsPerforming.text = "   "
                self.lupa.hidden = true
                
                applicationCancelled = true
                timer1.invalidate();
                timer2.invalidate();
             
            }
        } else {
            clickCount = clickCount + 1
        }
        print("ОТМЕНИТЬ-ОТМЕНИТЬ-ОТМЕНИТЬ")
        print("")
    }
    
    

 
    
    
    //============================ НЕ ПРОПУСТИМ ПОЛЬЗОВАТЕЛЯ НА ПЕРЕХОД НА ГЛАВНУЮ ПОКА НЕТ ОТМЕНЫ ЗАЯВКИ =================================
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool
    {
        if (identifier == "returnToMainWindowSegue")
        {
            if (applicationCancelled && clickCount >= 1 )
            {
                //отменена - отлично - вперед и с песней
                print("ТРЕТЬЯ ФОРМА -> заявка уже отменена, переход на главную")
                return true
            }
            else
            {
                //не пускаем на главную
                print("ТРЕТЬЯ ФОРМА -> заявка еще сущесьвует, не пущу на главную")
                return false
            }
            
        }
        return true
        
    }//=====================================================================================================================================
    
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        timer1.invalidate();
        timer2.invalidate();
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        //let viewControllers: NSArray = self.navigationController?.viewControllers as! NSArray
        //if viewControllers.indexOfObject(self) == NSNotFound {
        //    self.navigationController?.setNavigationBarHidden(true, animated: true)
       // }
        timer1.invalidate();
        timer2.invalidate();
        super.viewWillDisappear(animated)
    }
    
    
    /****** СЛУЖЕБНО-ОТЛАДОЧНЕЫЕ КНОПКИ - В РЕЛИЗЕ БУДУТ НЕВИДИМЫМИ ******/
    @IBAction func isAnyApplicationNow(sender: AnyObject) {
        NetworkManager.isAnyCurrentApplication()
    }
    
    @IBAction func getInfoAboutApplicationNow(sender: AnyObject) {
        NetworkManager.getInfoAboutApplication()
        
        //обновляем информацию о заявке
        if(NetworkManager.getInfoAboutApplication()) {
            updateInfoAboutApplication()
        }
    }
    
    
    private func getPushNotificationsNow() {
        
        //self.activityIndicator.hidden = false
        //self.activityIndicator.startAnimating()
        
        if( !NetworkManager.getPushNotifications() ||
            NetworkManager.getPushNotifications() )
        {
          //  self.activityIndicator.hidden = true
          //  self.activityIndicator.stopAnimating()
        }
    }
    
    
    
}//===== когнец объявления класса==========
