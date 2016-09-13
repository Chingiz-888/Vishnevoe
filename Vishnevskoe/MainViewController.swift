//
//  MainViewController.swift
//  Vishnevskoe
//
//  Created by Chingiz Bayshurin 19.06.16.
//  Copyright © 2016 Chingiz Bayshurin All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UINavigationControllerDelegate, iCarouselDelegate, iCarouselDataSource, SMSegmentViewDelegate, UIAlertViewDelegate {
    
    //==== АЛГОРИТМ РАСЧЕТА ВРЕМЕНИ =====
    var maps = [String]()
    var mapsLabels = [String]()
    @IBOutlet weak var mapCarousel: iCarousel!
    @IBOutlet weak var buttonSetTimeFrom: UIButton!
    @IBOutlet weak var buttonSetTimeTill: UIButton!
    @IBOutlet weak var passengersQuantity: UISegmentedControl!
    @IBOutlet weak var goToMicrodistrictSwicth: UISwitch!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var personalPageToogleButton: UIBarButtonItem!
    
    @IBOutlet weak var PersonalPocket: UIBarButtonItem!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var letsStartFindingCarsOrPassengersButton: UIButton!
    
    
    //====для того, чтобы можно было скрывать переключатель количества пассажирова =====
    @IBOutlet weak var peopleAmountSwitchHeightConstraint: NSLayoutConstraint!
    var peopleAmountSwitchHeightVisible: CGFloat!
    let peopleAmountSwitchHeightConstraintIFixed : CGFloat = 28.0
  
   //======для работы в 2 РЕЖИМАХ - ПАССАЖИР / ВОДИТЕЛЬ========
    //let cabinet = Cabinet()

    
    //************ для работы с базой сервера *********************
    var makeNewUserBool = false
    //*************************************************************
    

    //===кастомный SMSegment View==========================
    var segmentView: SMSegmentView!
    var margin: CGFloat = 10.0
    //=====================================================
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        maps = ["map1.png", "map2.png"]
    }

    //==== переменная костыли ==============================
    var oneClick : Bool = true
    

    //**********************  viewDidLoad ***************************************************************************************************//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //==== Инициализация данных МОДЕЛИ ===============================================
        //мы инициализируем ВРЕМЯ для ПАССАЖИРА и ВОДИТЕЛЯ
        TimeModel.setInitialTime()
        
        //Проверяем запись режим в UserDefaults
        let prefs = NSUserDefaults.standardUserDefaults()
        if prefs.objectForKey("cabinetType") == nil {
            print("ГЛАВНОЕ ОКНО -> Нет сохраненного ключа в NSUserDefaults")
            Cabinet.type = false
        } else {
            
            Cabinet.type = prefs.boolForKey("cabinetType")
            print("ГЛАВНОЕ ОКНО -> Прочитанный ключ из NSUserDefaults = \(Cabinet.type)")
        }
        
        //если это первый запуск программы - то пишем вот это
        if ((prefs.objectForKey("pushNotifications")) == nil){
            let time = TimeModel.getShortCurrentDate()
            let firstMessage = ["createdOn":"\(time)", "Text":"\(Cabinet.welcomeString)"]
            Cabinet.myPushNotifications.insert(firstMessage, atIndex: 0)
            prefs.setObject(Cabinet.myPushNotifications, forKey: "pushNotifications")
        } else {
            Cabinet.myPushNotifications = prefs.objectForKey("pushNotifications") as! Array
        }
        
        
        
        //УЗНАЕМ СРАЗУ ЕСТЬ ЛИ МЫ В СИСТЕМЕ и ЕСЛИ ДА ТО ЗАПОЛНЯЕМ ПОЛЯ МОДЕЛИ
        Cabinet.getPhoneId()
        if ( NetworkManager.isUserExist() ) {
            NetworkManager.getUserInfo()
        }
        (Cabinet.userExists) ? print("ГЛАВНОЕ ОКНО -> Пользователь существует") : print("ГЛАВНОЕ ОКНО -> Пользователь НЕ существует на сервере")
        
        //если пользователь ЕСТЬ на сервере, то проверяем, есть ли у пользователя заявка
        if ( Cabinet.userExists ) {
           if( NetworkManager.isAnyCurrentApplication() ) {
               print("ГЛАВНОЕ ОКНО -> ЗАЯВКА ЕСТЬ!!!!")
               self.performSegueWithIdentifier("fastMoveToAppliactionIfItExistSegue", sender: self)   //переход на ТРЕТЬЮ ФОРМУ
           } else {
               print("ГЛАВНОЕ ОКНО -> ЗАЯВКИ НЕТ!!!!")
           }
        }
        
        
        //===== Установление графических настроек интерфейса =============================
        self.passengersQuantity.hidden = true
        mapCarousel.type = .Linear
        
        let newBarButton:UIBarButtonItem = UIBarButtonItem.init(title: "", style: .Plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = newBarButton
        
        //устанавливаем обводку кнопок кастомного цвета рамкой и еще скругленной
        buttonSetTimeFrom.layer.cornerRadius = 13;
        buttonSetTimeFrom.layer.borderWidth = 1;
        buttonSetTimeFrom.layer.borderColor = UIColor(red:30/255.0, green:30/255.0, blue:50/255.0, alpha: 1.0).CGColor
        buttonSetTimeTill.layer.cornerRadius = 13;
        buttonSetTimeTill.layer.borderWidth = 1;
        buttonSetTimeTill.layer.borderColor = UIColor(red:30/255.0, green:30/255.0, blue:50/255.0, alpha: 1.0).CGColor
        //-------------------------------------------------------------------------------
        
        

        //---- попробуем инициализировать кастомный UISegementedView --------------------
        self.view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        
        /*
         Init SMsegmentView
         Use a Dictionary here to set its properties.
         Each property has its own default value, so you only need to specify for those you are interested.
         */
        //let segmentFrame = CGRect(x: self.margin+3, y: 70.0, width: self.view.frame.size.width - (self.margin+3)*2, height: 38.0)
        let segmentFrame = CGRect(x: 0.0, y: 0.0, width: self.container.frame.size.width, height: 38.0)
        
        self.segmentView = SMSegmentView( frame: segmentFrame,
                                          separatorColour: UIColor(white: 0.95, alpha: 0.3),
                                          separatorWidth: 0.5,
                                          segmentProperties: [keySegmentTitleFont: UIFont.systemFontOfSize(18.0),
                                            keySegmentOnSelectionColour: UIColor(red: 64.0/255.0, green: 194.0/255.0, blue: 45.0/255.0, alpha: 1.0),
                                            keySegmentOffSelectionColour: UIColor.whiteColor(),
                                            keyContentVerticalMargin: Float(10.0)])
        
        self.segmentView.delegate = self
        self.segmentView.backgroundColor = UIColor.clearColor()
        self.segmentView.layer.cornerRadius = 5.0
        self.segmentView.layer.borderColor = UIColor(white: 0.85, alpha: 1.0).CGColor
        self.segmentView.layer.borderWidth = 1.0
        let view = self.segmentView
        //Add segments
        view.addSegmentWithTitle("Пассажир", onSelectionImage: UIImage(named: "passenger.png"), offSelectionImage: UIImage(named: "passenger.png"))
        view.addSegmentWithTitle("Водитель", onSelectionImage: UIImage(named: "car.png"), offSelectionImage: UIImage(named: "car.png"))
        
        //self.view.addSubview(view)
        //раньше добавляли во вью, теперь в container view
        self.container.addSubview(view)
        //---------------------------------------------------------------------------------
        
        //обновляем интерфейс в зависимости от того, какой у нас режим
        if(!Cabinet.type) { setPassengerMode() }
        else              { setDriverMode()    }
       
        
         //var timer = NSTimer()
         //timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("redrawButtons"), userInfo: nil, repeats: true)
         //iii = 0;
        
     
        //----------- инициализация меню SWRevealView для открытия личного кабинета ------------------------
        if (self.revealViewController() != nil)
        {
            personalPageToogleButton.target = self.revealViewController()
            personalPageToogleButton.action = Selector("revealToggle:")
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //--------------------------------------------------------------------------------------------------
        
    }//**********************  end of viewDidLoad ********************************************************************************************//

    
    
  
    
    
    //************************** viewDidAppear **********************************************************************************************//
    override func viewDidAppear(animated: Bool)
    {
        if ( Cabinet.type == false )                 /* РЕЖИМ ПАССАЖИРА */
        {
            buttonSetTimeFrom.setTitle( Cabinet.passengerTimeFrom, forState: .Normal )
            buttonSetTimeTill.setTitle( Cabinet.passengerTimeTill, forState: .Normal )
             print("ГЛАВНОЕ ОКНО -> Текущее время (did Appear) \(Cabinet.passengerTimeFrom)")
        }
        else                                          /* РЕЖИМ ВОДИТЕЛЯ */
        {
            buttonSetTimeFrom.setTitle( Cabinet.driverTimeFrom, forState: .Normal )
            buttonSetTimeTill.setTitle( Cabinet.driverTimeTill, forState: .Disabled )
            print("ГЛАВНОЕ ОКНО -> Текущее время (did Appear) \(Cabinet.driverTimeFrom)")
        }
        
        
        //выставляем индекс на переключателе режима   //setPassengerMode() //setDriverMode()
        if(!Cabinet.type) {
            peopleAmountSwitchHeightConstraint.constant = peopleAmountSwitchHeightConstraintIFixed
            segmentView.selectSegmentAtIndex(0);
        }   else          {
            peopleAmountSwitchHeightConstraint.constant = 0
            segmentView.selectSegmentAtIndex(1);
        }
        
        
        //===переменная костыли =======
        oneClick = true
    }
    //**********************  end of viewDidAppear *******************************************************************************************//
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    

    //======= SET TIME FROM ======================================================
    @IBAction func setTimeFrom(sender: AnyObject)
    {
        print("ГЛАВНОЕ ОКНО -> Время ОТ установка")
        Cabinet.fromOrTill = 0
        self.performSegueWithIdentifier("showTimeList", sender: self)
    }
    
    
    
    @IBAction func setTimeTill(sender: AnyObject)
    {
        print("ГЛАВНОЕ ОКНО -> Время ДО установка")
        Cabinet.fromOrTill = 1
        self.performSegueWithIdentifier("showTimeList", sender: self)
    }
    

    
    
    //====== SETTINGS and MANAGEMENT of CAROUSEL ====================================
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        return maps.count
    }
    
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        //************
        let height:CGFloat = CGRectGetHeight ( self.mapCarousel.bounds )
        let width:CGFloat = CGRectGetWidth ( self.mapCarousel.bounds )
        
        let tempView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        
        //tempView.backgroundColor = UIColor.blackColor()
        
        let mapView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        //мы запускаем функцию по пририсовке к картам обозначалок
        let mapImage:UIImage =  putTextToImage(Cabinet.departurePointIdLabel[index],
                                               inImage: UIImage(named: maps[index])!,
                                               atPoint: CGPointMake(50, 50) )    //UIImage(named: maps[index])!
        mapView.image = mapImage
        mapView.contentMode = UIViewContentMode.ScaleToFill
        
        tempView.addSubview(mapView)
        
     
        //print("My view's frame is: %@", NSStringFromCGRect(self.mapCarousel.frame));
        return tempView
    }
    
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        if option == iCarouselOption.Spacing{
            return value * 1.1
        }
        else {
            return value
        }
    }
    
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        //в зависимости от выбранной карты меняем пункт отправки
        if (carousel.currentItemIndex == 0){
            Cabinet.departurePointId = 0
        }
        else if (carousel.currentItemIndex==1) {
            Cabinet.departurePointId = 1
        }
        else {}
        
        let karta = Cabinet.departurePointIdLabel[Cabinet.departurePointId]
        print("ГЛАВНОЕ ОКНО -> Выбрана карта № \(Cabinet.departurePointId) а именно \(karta)" )
    }
   //====================================================================================
    
    
    
    
    
 
   
    
    
    
    //=============  ПЕРЕКЛЮЧЕНИЕ ВОДИТЕЛЬ или ПАССАЖИР ==================================
    func segmentView(segmentView: SMBasicSegmentView, didSelectSegmentAtIndex index: Int)
    {
        switch ( index )
        {
        case 0:
            /*** РЕЖИМ ПАССАЖИРА ***/
            setPassengerMode()
            //==ставим режим 0 для инстанса класса модели
            Cabinet.type = false;
            //записываем все в NSUserDefaults
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setBool(Cabinet.type, forKey: "cabinetType")
            print("ГЛАВНОЕ ОКНО -> Записали \(Cabinet.type) в NSUserDefaults")
            break
            
        case 1:
            /*** РЕЖИМ ВОДИТЕЛЯ ***/
            setDriverMode()
            //==ставим режим 1 для инстанса класса модели
            Cabinet.type = true;
            //записываем все в NSUserDefaults
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setBool(Cabinet.type, forKey: "cabinetType")
            print("ГЛАВНОЕ ОКНО -> Записали \(Cabinet.type) в NSUserDefaults")
            break
            
        default: break
        }
    }
    
    
    private func setPassengerMode() {
        /*** РЕЖИМ ПАССАЖИРА ***/
        self.passengersQuantity.hidden = true
        self.buttonSetTimeTill.enabled = true
        //===МЕНЯЕМ УКАЗАТЕЛИ ВРЕМЕНИ============
        buttonSetTimeFrom.setTitle( Cabinet.passengerTimeFrom, forState: .Normal )
        buttonSetTimeTill.setTitle( Cabinet.passengerTimeTill, forState: .Normal )
        //========================================
        //убираем место переключателя количества пассажиров
        togglePickerViewVisibility(true)
        self.letsStartFindingCarsOrPassengersButton.setTitle("Искать машину", forState: .Normal)
        print("ГЛАВНОЕ ОКНО -> Первый режим  - режим пассажира")
    }
    private func setDriverMode() {
        /*** РЕЖИМ ВОДИТЕЛЯ ***/
        self.passengersQuantity.hidden = false
        self.buttonSetTimeTill.enabled = false
        //===МЕНЯЕМ УКАЗАТЕЛИ ВРЕМЕНИ============
        buttonSetTimeFrom.setTitle( Cabinet.driverTimeFrom, forState: .Normal )
        buttonSetTimeTill.setTitle( Cabinet.driverTimeTill, forState: .Disabled )
        //========================================
        //убираем место переключателя количества пассажиров
        togglePickerViewVisibility(true)
        self.letsStartFindingCarsOrPassengersButton.setTitle("Искать пассажиров", forState: .Normal)
        print("ГЛАВНОЕ ОКНО -> Второй режим  - режим водителя")
    }
    
    //=============  ПЕРЕКЛЮЧЕНИЕ ВОДИТЕЛЬ или ПАССАЖИР ==================================
    
    
    //============== СЛУЖЕБНАЯ ФУНКЦИЯ ДЛЯ АНИМИРОВАННОГО УБИРАНИЯ МЕСТА =================
    func togglePickerViewVisibility(animated: Bool = true)
    {
        if peopleAmountSwitchHeightConstraint.constant != 0
        {
            peopleAmountSwitchHeightVisible = peopleAmountSwitchHeightConstraint.constant
            peopleAmountSwitchHeightConstraint.constant = 0
        }
        else
        {
            peopleAmountSwitchHeightConstraint.constant = peopleAmountSwitchHeightVisible
        }
        
        if animated
        {
            UIView.animateWithDuration(0.2, animations:
                {
                   () -> Void in
                   self.view.layoutIfNeeded()
                }, completion: nil)
        }
        else
        {
            view.layoutIfNeeded()
        }
    }//============== СЛУЖЕБНАЯ ФУНКЦИЯ ДЛЯ АНИМИРОВАННОГО УБИРАНИЯ МЕСТА ================
    
    
    //Едит ли пассажир до остановки "Город" или нет
    @IBAction func goToMicrodistrictSwicthChanged(sender: AnyObject) {
        if goToMicrodistrictSwicth.on {
            Cabinet.goToMicrodistrict = true
            print("ГЛАВНОЕ ОКНО -> Я еду до остановки \"Город\"")
        }
        else {
            Cabinet.goToMicrodistrict = false
            print("ГЛАВНОЕ ОКНО -> Я НЕ еду до остановки \"Город\"")

        }
    }
    
    
    //Сколько пассажиров возьмет водитель
    @IBAction func passengersQuantityChanged(sender: AnyObject) {
        switch passengersQuantity.selectedSegmentIndex {
        case 0:
            Cabinet.passengersQuantityITake = 1
            print("ГЛАВНОЕ ОКНО -> Я как водитель перевезу 1")
            break
        case 1:
            Cabinet.passengersQuantityITake = 2
            print("ГЛАВНОЕ ОКНО -> Я как водитель перевезу 2")
            break
        case 2:
            Cabinet.passengersQuantityITake = 3
            print("ГЛАВНОЕ ОКНО -> Я как водитель перевезу 3")
            break
        default:
            break
        }
    }
    
 
    
    //-------------начало поиска пассажиров или водителей
    @IBAction func letsStartFindingMeCarOrPassengers(sender: AnyObject) {
        
        
                
    }//------------конце запуска поиска пассажиров или водителей--------------------------------------------------------------------------------
    

    
    //Функция пририсовки label'ов к картинке-карте для iCraousel -----------------------------------
    private func putTextToImage(drawText: NSString, inImage: UIImage, atPoint: CGPoint) -> UIImage{
        
        // Setup the font specific variables
        var textColor = UIColor.blackColor()
        var textFont = UIFont(name: "Helvetica Neue", size: 64)!
        
        // Setup the image context using the passed image
        let scale = UIScreen.mainScreen().scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        //---
        // set the line spacing to 6
        var paraStyle = NSMutableParagraphStyle()
        paraStyle.lineSpacing = 6.0
        // set the Obliqueness to 0.1
        //var skew = 0.1
        //---
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: paraStyle,
            //NSObliquenessAttributeName: skew
            ]
        
        // Put the image into a rectangle as large as the original image
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Create a point within the space that is as bit as the image
        var rect = CGRectMake(atPoint.x, inImage.size.height*0.85, inImage.size.width - atPoint.x*2, inImage.size.height*0.15)
        
        // Draw the text into an image
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage
        
    }
    
    
    

    
    
    @IBAction func personalPocketClick(sender: AnyObject) {
        
        if (Cabinet.userExists && NetworkManager.getYourBalance() )  {
            
            let formatter = NSNumberFormatter()
            formatter.minimumFractionDigits = 2
            let string = formatter.stringFromNumber(Cabinet.balance)
            
            let Alert: UIAlertView = UIAlertView(title: "У Вас \(string!) рублей",
                                                message: "Хотите пополнить баланс?",
                                                delegate: self,
                                                cancelButtonTitle: nil,
                                                otherButtonTitles: "Да", "Выход");
       
            Alert.tag = 888;
            Alert.show()

            
           
        } else {
             //let Alert: UIAlertView = UIAlertView(title: "Вы не зарегистрированы", message: "Зарегистрируйтесь сначала в личном профиле пассажира или водителя",
            //                                     delegate: nil, cancelButtonTitle: "Ok")
            //Alert.show()
            
            
            if #available(iOS 8.0, *) {
                var alertController = UIAlertController(title: "Вы не зарегистрированы", message: "Зарегистрируйтесь сначала в личном профиле пассажира или водителя", preferredStyle: .Alert)
                var cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                }
                alertController.addAction(cancelAction)
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                let Alert: UIAlertView = UIAlertView(title: "Вы не зарегистрированы", message: "Зарегистрируйтесь сначала в личном профиле пассажира или водителя",
                                                     delegate: nil, cancelButtonTitle: "Ok")
                Alert.show()
            }
            
            
         
        }
        
    }
    


    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (alertView.tag == 888) {
            if (buttonIndex == 0) {
                NetworkManager.openPersonalPocket()
            }
        }
    }

    
    
}//====END OF FILE
















