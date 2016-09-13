//
//  NetworkManager.swift
//  Vishnevskoe
//
//  Created by Chingiz Bayshurin on 30.06.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import Foundation


class NetworkManager
{//==== BEGINNING OF CLASS DECLARATION
    
    
    //----переменные для работы с сетью и API CHERRYDOL ------------------
    static var jsonString:String = ""
    static var jsonData = NSData ()
    
    
    //для работы с сетью
    static var registerUserUrl = String()
    static var url = NSURL()
    
    static let baseUrl:String = "http://api.cherrydol.ru"
    static let userExists:String = "/user/exists"
    static let registerUser:String = "/user/register"
    static let getUserInfoUrl:String = "/user/get"
    static let createNewApplicationUrl:String = "/request/add"
    static let updateUserInfo:String = "/user/update"
    static let isAnyCurrentApplicationUrl:String = "/request/exists"
    static let getInfoAboutApplicationUrl:String = "/request/result/get"
    static let CancelCurrentApplicationUrl:String = "/request/cancel"
    static let getPushNotificationsUrl:String     = "/user/messages/get"
    static let personalPocketUrl:String           = "/ym/pay"
    static let getPersonalBalanceUrl:String       = "/user/balance/get"
    static let savePushTokenUrl:String            = "/user/savepushtoken"
    
    
    static let savePushTokenUrlTest:String            = "http://www.ecomonitoring.net/test/savetoken.php"
    
    static var resultUrl:String = String()
    
    static var userExistsInSystem = false
    static var dict:[String:AnyObject] =  [:]
    
    
    
    
    

    //========= IS USER EXIST  ======   ПРОВЕРЯЕМ НЕТ ЛИ ТАКОГО ПОЛЬЗОВАТЕЛЯ  НА СЕРВЕЕ ================================================
    static func isUserExist() -> Bool
    {
      resultUrl = baseUrl + userExists + "?id=" + Cabinet.digestOfUuid
      print("NetworkManager:isUserExist -> Провеярем по такому url \(resultUrl)")
      url = NSURL(string: resultUrl)!
        

        
      let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
      urlconfig.timeoutIntervalForRequest = Cabinet.timeOutShortForNSURLSession       //5.0 sec
      urlconfig.timeoutIntervalForResource = Cabinet.timeOutShortForNSURLSession
      //у нас своя NSURLSession что создается с нашими кастомными настройками (время таймаута)
      //let session1 = NSURLSession.sharedSession()
      let session = NSURLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
      let request = NSMutableURLRequest (URL: url)
      request.HTTPMethod = "GET"
        
        
       //идентификатор загрузки
       UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
       //*******  создаем СЕМАФОР  ************************************
       let semaphore = dispatch_semaphore_create(0)
        
       let task = session.dataTaskWithRequest(request, completionHandler:
        {//-------SESSION TASK--------------------------
            (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
            
            //Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else
            {
                print("NetworkManager:isUserExist -> Получен не 200 код или превышен таймаут")
                dispatch_semaphore_signal(semaphore)
                return
            }
            
            //убрать индикатор работы с сетью
            dispatch_async(dispatch_get_main_queue())
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            //есть ответ
            if ( error == nil )
            {
                //print("NetworkManager:isUserExist ->  RESULT from server: ", data)
                //print("NetworkManager:isUserExist ->  Error from method: ", error)
                let answer = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                //print("NetworkManager:isUserExist -> Наша строка \(answer)")
                
                if (answer == "true" )
                {//------- ПОЛЬЗОВАТЕЛЬ СУЩЕСТВУЕТ------------------------
                    print("NetworkManager:isUserExist -> Пользователь существует на сервере!")
                    userExistsInSystem = true
                    //************* ЛОГИКА ОБРАБОТКИ - ПОЛЬЗОВАТЕЛЬ СУЩЕСТВУЕТ **********************
                    //а если пользователь есть в системе Зеленодольское, то тогда кнопку
                    //поставить на искать машину
                    Cabinet.userExists = true
                    //*******************************************************************************
                }//--------------------------------------------------------
                    
                else
                {//------ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ-----------------------
                    print("NetworkManager:isUserExist -> Пользователь не существует на сервере!")
                    userExistsInSystem = false
                    //************* ЛОГИКА ОБРАБОТКИ - ПОЛЬЗОВАТЕЛЬ СУЩЕСТВУЕТ **********************
                    //для того чтобы перерисовать кнопку вместо "ИСКАТЬ ТАЧКИ" - на создать порльзователя
                    Cabinet.userExists = false
                    //*******************************************************************************
                    
                }//----------------------------------------------------------
            }//------  END OO IF error == nil
            
            dispatch_semaphore_signal(semaphore)
            
        }).resume()
        //-----END of SESSION TASK---------------------------------------------------------------------------------------
            

 
      //ждем окончания семафора
      dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
      return Cabinet.userExists
    }//============================END OF IS USER EXIST FUNC============================================================================

    
    
    
    
    
    
    





    //=============  regsiterNewUser - РЕГИСТРАЦЦИЯ НОВОГО ПОЛЬЗОВАТЕЛЯ НА СЕРВЕРЕ ======================================================
    static func registerNewUser() -> Bool
    {
      //================ СОЗДАНИЕ РЕГИСТРАЦИОННОЙ JSON СТРОКИ ==================================================
      //====берем данные из нашего текстовых полей
      let name = Cabinet.fullName
      let digestOfUuid = Cabinet.digestOfUuid
      var result:Bool = false
    
      //пол пользователя
      let sex = !(Cabinet.sex) ? 1 : 2  /*По API сервера "1" - МУЖИК   "2" - БАБЕЦ */
      //тип пользователя
      let userType = !(Cabinet.type) ?  1 : 2  //passengers = 1, drivers = 2
    
     if(!Cabinet.type) {                       //режим пассажира
         dict = ["id":                "\(digestOfUuid)",
         "device":                   "iOS",
         "name":                     "\(name)",
         "sex":                      sex,
         "favoriteMusicId":          "\(Cabinet.favoriteMusicILike)",
         "userType":                 userType,
         "carNumber":                "\(Cabinet.carNumber)",
         "carDescription":           "\(Cabinet.carModel)",
         "carColor":                 "\(Cabinet.carColor)",
         "passengersOnlyGirls":      Cabinet.passengersOnlyGirls,
         "message":                  "null"]
      }
      else {                                   //режим водителя
        dict = ["id":                "\(digestOfUuid)",
                "device":                   "iOS",
                "name":                     "\(name)",
                "sex":                      sex,
                "favoriteMusicId":          "\(Cabinet.favoriteMusicILike)",
                "userType":                 userType,
                "carNumber":                "\(Cabinet.carNumber)",
                "carDescription":           "\(Cabinet.carModel)",
                "carColor":                 "\(Cabinet.carColor)",
                "passengersOnlyGirls":      Cabinet.passengersOnlyGirls,
                "message":                  "null"]
      }
    
      //-- теперь пробуем заJSONить и сразу же посмотреть строку
      do
      {
          jsonData = try!  NSJSONSerialization.dataWithJSONObject  (dict, options: NSJSONWritingOptions.PrettyPrinted)
          jsonString = NSString  (data: jsonData, encoding: NSUTF8StringEncoding)! as String
          print("NetworkManager:registerNewUser -> Создаем пользователя с такими параметрами")
          print(jsonString)
      }  catch let error as NSError   {
          print("NetworkManager:registerNewUser -> Ошибка при создании JSON объекта")
          print(error)
      }
      //===========================================================================================================
    
    
      //==============ТЕПЕРЬ СЕТЕВОЕ ОБРАЩЕНИЕ НА РЕГИСТРАЦИЮ======================================================================
      //создаем урлу на регистрацию
      registerUserUrl = baseUrl + registerUser
    
      url = NSURL(string: registerUserUrl)!
      let session = NSURLSession.sharedSession()
      let request = NSMutableURLRequest (URL: url)
      request.HTTPMethod = "POST"
      request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    
      //---вот ЗАПИХИВАЕМ НАШ JSON как тЕЛО ЗАПРОСА
      request.HTTPBody = jsonData
    
     //идентификатор загрузки
     UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
      //*******  создаем СЕМАФОР  ************************************
     let semaphore = dispatch_semaphore_create(0)
    
      session.dataTaskWithRequest (request, completionHandler:
      {//------START SEESION TASK----------------
          (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
    
          //Make sure we get an OK response
          guard let realResponse = response as? NSHTTPURLResponse where
              realResponse.statusCode == 200 else
              {
                  print("NetworkManager:registerNewUser - > Not a 200 response")
                  dispatch_semaphore_signal(semaphore)
                  return
              }
    
        
          //убрать индикатор работы с сетью
          dispatch_async(dispatch_get_main_queue())   {
             UIApplication.sharedApplication().networkActivityIndicatorVisible = false
          }
        
          //read JSON
          if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
              {
                  //Print what we got from the call
                  print("NetworkManager:registerNewUser -> Результат регистрации Нового юзера на сервере: ")
                  print(postString)
                
                
                //============  JSON ДЕКОДИРОВКА ================================================
                do
                {
                    let decoded = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    //print("NetwrokManager:createNewApplication -> декодированный ответ")
                    //print(decoded)
                    let dictFromJSON = decoded as! [String:AnyObject]
                    
                    //print(dictFromJSON)
                    //print("NetworkManager:registerNewUser -> количество элементов в Dictionary \(dictFromJSON.count)")

                
                
                  //---- осторожно и с проверками вытаскиваем ключ code и requestId из JSON'а ------------
                  if let checkUserExists = dictFromJSON["code"]
                  {
                      if( checkUserExists as! NSObject == 0 )
                      {
                        Cabinet.userExists = true
                        result=true
                        print("NetworkManager:registerNewUser-> Пользователь успешно создан. Code = \(checkUserExists)")
                      }
                      else
                      {
                          print("NetworkManager:registerNewUser-> Пользователь не создан. Возвращенный Code =  \(checkUserExists)")
                      }
                  }
                  else
                  {
                      print("NetworkManager:registerNewUser -> Ошибка парсинга. Нет ключа \"code\"")
                  }
                    
                }
                  //-----------------------------------------------------------------------------------------
                catch let error as NSError
                {
                    print("NetworkManager:registerNewUser-> ", error)
                }
               //============  JSON ДЕКОДИРОВКА ================================================
        
                dispatch_semaphore_signal(semaphore)
              }
    }).resume()
    //==============ТЕПЕРЬ СЕТЕВОЕ ОБРАЩЕНИЕ НА РЕГИСТРАЦИЮ=======================================================================
    

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    return result
    }//=============  regsiterNewUser - РЕГИСТРАЦЦИЯ НОВОГО ПОЛЬЗОВАТЕЛЯ НА СЕРВЕРЕ =====================================================

    
    
    
    
    
    
    
    
    
    
    
    
    

    //========= GET USER INFO   ======   ПОЛУЧЕНИЕ ИНФОРМАЦИИ О СУЩЕСТВУЮЩЕМ ПОЛЬЗОВАТЕЛЕ С СЕРВЕА =======================================
    static func getUserInfo()
    {
        resultUrl = baseUrl + getUserInfoUrl + "?id=" + Cabinet.digestOfUuid
        url = NSURL(string: resultUrl)!
        let session2 = NSURLSession.sharedSession()
        let request = NSMutableURLRequest (URL: url)
        request.HTTPMethod = "GET"
        
        //идентификатор загрузки
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        
        session2.dataTaskWithRequest (request, completionHandler:
            {//-------SESSION TASK--------------------------
                (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
                
                //Make sure we get an OK response
                guard let realResponse = response as? NSHTTPURLResponse where
                    realResponse.statusCode == 200 else
                {
                    print("NetworkManager:getUserInfo -> Not a 200 response")
                    return
                }
                
                //убрать индикатор работы с сетью
                dispatch_async(dispatch_get_main_queue())
                {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                
                
                //есть ответ
                if ( error == nil )
                {
                    let answer = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                    
                    do
                    {
                        let decoded = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        print("NetworkManager:getUserInfo -> Получена вот такой JSON ответ")
                        print(decoded)
                        
                        let dictFromJSON = decoded as! [String:AnyObject]
                        
                        
                        print("Декодированный JSON вот он:")
                        print(dictFromJSON)
                        
                        //читаем имя
                        if let name = dictFromJSON["name"]{             /*name*/
                            if !(name is NSNull)  {
                                Cabinet.fullName = name as! String
                            }
                        }
                        //читаем пол
                        if let sex = dictFromJSON["sex"] {              /*sex*/
                            let sexString = sex as! Int
                            if (sexString == 1) {             /*По API сервера "1" - МУЖИК   "2" - БАБЕЦ */
                                Cabinet.sex = false
                            } else {
                                Cabinet.sex = true
                            }
                        }
                        //читаем марку машины
                        if let name = dictFromJSON["carDescription"] {   /*carDescription*/
                            if !(name is NSNull)  {
                                Cabinet.carModel = name as! String
                            }
                        }
                        //читаем цвет машины
                        if let name = dictFromJSON["carColor"] {        /*carColor*/
                            if !(name is NSNull)  {
                                Cabinet.carColor = name as! String
                            }
                        }
                        //читаем номер машины
                        if let name = dictFromJSON["carNumber"] {       /*carNumber*/
                            if !(name is NSNull)  {
                                Cabinet.carNumber = name as! String
                            }
                        }
                        
                        //читаем любимую музыку
                        if let name = dictFromJSON["favoriteMusicId"]{ /*favoriteMusicId*/
                            if !(name is NSNull)  {
                                Cabinet.favoriteMusicILike = name as! Int
                            }
                        }
                        
                    }
                    catch let error as NSError
                    {
                        print("NetworkManager:getUserInfo -> Ошибка при попытке декодирования JSON ответа")
                        print(error)
                    }
                }//------  END OO IF error == nil
                
                
        }).resume()
        //-----END of SESSION TASK---------------------------------------------------------------------------------------
    }//=======================END OF GET USER INFO FUNC==================================================================================

    
    
    
    
    
    
    
    
    
    
    
    

    //======================= createNewApplication =====   СОЗАТЬ НОВУЮ ЗАЯВКУ НА ПЕРЕВОЗКУ===============================================
    static internal func createNewApplication() -> Bool
    {
    //================ СОЗДАНИЕ РЕГИСТРАЦИОННОЙ JSON СТРОКИ ==================================================
    //====берем данные из нашего текстовых полей
    let name = Cabinet.fullName
    let digestOfUuid = Cabinet.digestOfUuid

    if ( !Cabinet.type ) {  //режим пассажира - берем время пассажира  requestTypeId=1
    dict = ["userId":                               "\(digestOfUuid)",
            "requestTypeId":                        "1",
            "departurePointId":                      "\(Cabinet.departurePointId)",
            "createdOn":                            TimeModel.getCurrentDateWithHoursMinutesSecondsInString(),
            "timeFrom":                             TimeModel.getCurrentDateInString() + " " + Cabinet.passengerTimeFrom + ":00",
            "timeTo":                               TimeModel.getCurrentDateInString() + " " + Cabinet.passengerTimeTill + ":00",
            "passengersCount":                      "1",
            "goToMicrodistrictCity":                "\(Cabinet.goToMicrodistrict)"
            ]
    }
    else {                //режим водителя - берем время водителя     requestTypeId=2
        dict = ["userId":                               "\(digestOfUuid)",
                "requestTypeId":                        "2",
                "departurePointId":                      "\(Cabinet.departurePointId)",
                "createdOn":                            TimeModel.getCurrentDateWithHoursMinutesSecondsInString(),
                "timeFrom":                             TimeModel.getCurrentDateInString() + " " + Cabinet.driverTimeFrom + ":00",
                "timeTo":                               TimeModel.getCurrentDateInString() + " " + Cabinet.driverTimeTill + ":00",
                "passengersCount":                      "\(Cabinet.passengersQuantityITake)",
                "goToMicrodistrictCity":                "\(Cabinet.goToMicrodistrict)"
        ]
    }
    //*******  создаем СЕМАФОР  ************************************
    let semaphore = dispatch_semaphore_create(0)
    //--для оценки результат создания заявки
    var result = false
    
    //-- теперь пробуем заJSONить и сразу же посмотреть строку
    do
    {
        jsonData = try!  NSJSONSerialization.dataWithJSONObject  (dict, options: NSJSONWritingOptions.PrettyPrinted)
        jsonString = NSString  (data: jsonData, encoding: NSUTF8StringEncoding)! as String
        print("NetwrokManager:createNewApplication -> Создаем заявку на перевозку с такими параметрами")
        print(jsonString)
        
    }
    catch let error as NSError
    {
        print("NetwrokManager:createNewApplication -> Ошибка при создании JSON объекта")
        print(error)
    }
    //===========================================================================================================
    
    
    //==============ТЕПЕРЬ СЕТЕВОЕ ОБРАЩЕНИЕ НА РЕГИСТРАЦИЮ======================================================================
    //создаем урлу на регистрацию
    registerUserUrl = baseUrl + createNewApplicationUrl
    url = NSURL(string: registerUserUrl)!
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest (URL: url)
    request.HTTPMethod = "POST"
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    
    //---вот ЗАПИХИВАЕМ НАШ JSON как тЕЛО ЗАПРОСА
    request.HTTPBody = jsonData
    
    
    session.dataTaskWithRequest (request, completionHandler:
        {//------START SEESION TASK----------------
            (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
            
            //Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else
            {
                print("NetwrokManager:createNewApplication -> Not a 200 response")
                return
            }
            
            //читаем ответ
            if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
            {
                print("NetwrokManager:createNewApplication -> Результат заявки на перевозку: ")
                print(postString)
                
                //******  НА БУДУЩЕЕ БОЛЕЕ РАЗВЕРНУТАЯ ПРОВЕРКА, НО ПОКА БУДЕМ СЧИТАТЬ 
                //******  ЧТО ЗАЯВКА СОЗДАНА ЕСЛИ ЕСТЬ ХОТЬ КАКОЙ-ТО ОТВЕТ
                
                do
                {
                    let decoded = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    //print("NetwrokManager:createNewApplication -> декодированный ответ")
                    //print(decoded)
                    let dictFromJSON = decoded as! [String:AnyObject]
        
                    print("NetworkManager:createNewApplication -> Информация о существующей заявке декодированная")
                    print(dictFromJSON)
                    print("NetworkManager:createNewApplication -> количество элементов в Dictionary \(dictFromJSON.count)")
                    
                    //---- осторожно и с проверками вытаскиваем ключ code и requestId из JSON'а ------------
                    if let checkCode = dictFromJSON["code"]
                    {
                        if( checkCode as! NSObject == 0 )
                        {
                            Cabinet.isAnyCurrentApplication = true
                            result = true
                            print("NetworkManager:createNewApplication -> Код расшифрован и он равен 0, что значит OK")
                        }
                        else
                        {
                            result = false
                            print("NetworkManager:createNewApplication -> Код расшифрован и он равен \(checkCode), что означает какую-то ошибку")
                        }
                    }
                    else
                    {
                        print("NetworkManager:createNewApplication -> Ошибка парсинга. Нет ключа \"code\"")
                    }
                    //----------
                    if let checkRequestId = dictFromJSON["requestId"]
                    {
                        //я считаю, что код выше выполнится до, и если там результат ОК
                        //значит можно обращаться к номеру заявки
                        if( Cabinet.isAnyCurrentApplication  )
                        {
                            Cabinet.applicationNumber = dictFromJSON["requestId"] as! Int
                            print("NetworkManager:createNewApplication -> Номер заявки на перевозку \(Cabinet.applicationNumber)")
                        }
                    }
                    else
                    {
                        print("NetworkManager:createNewApplication -> Ошибка парсинга. Нет ключа \"requestId\"")
                    }
                    //-----------------------------------------------------------------------------------------
                }
                catch let error as NSError
                {
                    print("NetworkManager:createNewApplication -> ", error)
                }
            }
            dispatch_semaphore_signal(semaphore);
            
    }).resume()
    //==============ТЕПЕРЬ СЕТЕВОЕ ОБРАЩЕНИЕ НА РЕГИСТРАЦИЮ=======================================================================
    
    //ждем окончания семафора
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    //ВОЗРАЩАЕМ РЕЗУЛЬТАТ СОЗДАНИЯ ЗАЯВКИ - получилось или нет
    return result
    }//========================== СОЗАТЬ НОВУЮ ЗАЯВКУ НА ПЕРЕВОЗКУ====================================================================

    
    
    
    
    
    
    
    
    
    
    
    

    //========================= ИЗМЕНИТЬ РЕГИСТРАЦИОННЫЕ ДАННЫЕ =======================================================================
    static internal func changeRegisterData() -> Bool
    {
    //================ СОЗДАНИЕ РЕГИСТРАЦИОННОЙ JSON СТРОКИ ==================================================
    //====берем данные из нашего текстовых полей
    let name = Cabinet.fullName
    let digestOfUuid = Cabinet.digestOfUuid
    //*******  создаем СЕМАФОР  ************************************
    let semaphore = dispatch_semaphore_create(0)
    //--для оценки результат создания заявки
    var result = false
    
    //пол пользователя
    let sex = !(Cabinet.sex) ? 1 : 2  /*По API сервера "1" - МУЖИК   "2" - БАБЕЦ */
    //тип пользователя
    let userType = !(Cabinet.type) ?  1 : 2  //passengers = 1, drivers = 2

    
    if(!Cabinet.type) {                       //Режим пассажира
       dict = ["id":                                   "\(digestOfUuid)",
               "device":                               "iOS",
               "name":                                 "\(name)",
               "sex":                                  sex,
               "favoriteMusicId":                      Cabinet.favoriteMusicILike,
               "userType":                             userType,
               "carNumber":                            "\(Cabinet.carNumber)",
               "carDescription":                       "\(Cabinet.carModel)",
               "carColor":                             "\(Cabinet.carColor)",
               "passengersOnlyGirls":                  Cabinet.passengersOnlyGirls,
               "message":                              "null"
       ]
    }
    else {                                   //Режим водителя
        dict = ["id":                                   "\(digestOfUuid)",
                "device":                               "iOS",
                "name":                                 "\(name)",
                "sex":                                  sex,
                "favoriteMusicId":                      Cabinet.favoriteMusicILike,
                "userType":                             userType,
                "carNumber":                            "\(Cabinet.carNumber)",
                "carDescription":                       "\(Cabinet.carModel)",
                "carColor":                             "\(Cabinet.carColor)",
                "passengersOnlyGirls":                  Cabinet.passengersOnlyGirls,
                "message":                              "null"
        ]
    }
    
    
    //-- теперь пробуем заJSONить и сразу же посмотреть строку
    do
    {
        jsonData = try!  NSJSONSerialization.dataWithJSONObject  (dict, options: NSJSONWritingOptions.PrettyPrinted)
        jsonString = NSString  (data: jsonData, encoding: NSUTF8StringEncoding)! as String
        print("NetworkManager:changeRegisterData -> Создаем заявку на изменения прользовательских данных с такими параметрами")
        print(jsonString)
        
    }
    catch let error as NSError
    {
        print("NetworkManager:changeRegisterData -> Ошибка при создании JSON объекта")
        print(error)
    }
    //===========================================================================================================
    
    
    //==============ТЕПЕРЬ СЕТЕВОЕ ОБРАЩЕНИЕ НА РЕГИСТРАЦИЮ======================================================================
    //создаем урлу на регистрацию
    registerUserUrl = baseUrl + updateUserInfo
    url = NSURL(string: registerUserUrl)!
    let session = NSURLSession.sharedSession()
    let request = NSMutableURLRequest (URL: url)
    request.HTTPMethod = "POST"
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    
    //---вот ЗАПИХИВАЕМ НАШ JSON как тЕЛО ЗАПРОСА
    request.HTTPBody = jsonData
    
    
    session.dataTaskWithRequest (request, completionHandler:
        {//------START SEESION TASK----------------
            (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
            
            //Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else
            {
                print("NetworkManager:changeRegisterData -> Not a 200 response")
                return
            }
            
            //read JSON
            if let postString = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String
            {
                //Print what we got from the call
                print("NetworkManager:changeRegisterData -> Результат заявки на изменения пользовательских данных: ")
                print(postString)
            }
            dispatch_semaphore_signal(semaphore);
    }).resume()
    //==============ТЕПЕРЬ СЕТЕВОЕ ОБРАЩЕНИЕ НА РЕГИСТРАЦИЮ=======================================================================
    
    //ждем окончания семафора
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    //ВОЗРАЩАЕМ РЕЗУЛЬТАТ СОЗДАНИЯ ЗАЯВКИ - получилось или нет
    return result
    }//=========================== ИЗМЕНИТЬ РЕГИСТРАЦИОННЫЕ ДАННЫЕ =====================================================================

    
    
    
    
   
    
    
    
    
    
    
    
    
    

    //========================== isAnyCurrentApplication ======  ПРОВЕРКА ЕСТЬ ЛИ ТЕКУЩАЯ ЗАЯВКА ========================================
    static internal func isAnyCurrentApplication() -> Bool
    {
    let resultUrl = baseUrl + isAnyCurrentApplicationUrl + "?id=" + Cabinet.digestOfUuid
    url = NSURL(string: resultUrl)!
    let session1 = NSURLSession.sharedSession()
    let request = NSMutableURLRequest (URL: url)
    request.HTTPMethod = "GET"
    
    //**************  создаем СЕМАФОР  *****************************************
    let semaphore = dispatch_semaphore_create(0)
    //--для оценки результат создания заявки
    var result = false
    
    //идентификатор загрузки
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    
    session1.dataTaskWithRequest (request, completionHandler:
        {//-------SESSION TASK--------------------------
            (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
            
            //Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else
            {
                print("NetworkManager:isAnyCurrentApplication -> Not a 200 response")
                return
            }
            
            //убрать индикатор работы с сетью
            dispatch_async(dispatch_get_main_queue())
            {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            
            
            //есть ответ
            if ( error == nil )
            {
                
                //print("NetworkManager:isAnyCurrentApplication -> Error from method: ", error)
                let answer = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                print("NetworkManager:isAnyCurrentApplication -> RESULT from server: ", answer)
                //print("NetworkManager:isAnyCurrentApplication -> Наша строка \(answer)")
                
                if (answer == "true" )
                {//------- ПОЛЬЗОВАТЕЛЬ СУЩЕСТВУЕТ------------------------
                    print("NetworkManager:isAnyCurrentApplication -> У пользователя есть текущая заявка!")
                    userExistsInSystem = true
         
                    //************* ЛОГИКА ОБРАБОТКИ - ПОЛЬЗОВАТЕЛЬ СУЩЕСТВУЕТ **********************
                    //а если пользователь есть в системе Зеленодольское, то тогда кнопку
                    //поставить на искать машину
                    Cabinet.isAnyCurrentApplication = true
                    //*******************************************************************************
            }//--------------------------------------------------------
                    
                else
                {//------ПОЛЬЗОВАТЕЛЬ НЕ СУЩЕСТВУЕТ-----------------------
                    print("NetworkManager:isAnyCurrentApplication -> У пользователя нет текущей заявки!")
                    userExistsInSystem = false
       
                    //************* ЛОГИКА ОБРАБОТКИ - ПОЛЬЗОВАТЕЛЬ СУЩЕСТВУЕТ **********************
                    //для того чтобы перерисовать кнопку вместо "ИСКАТЬ ТАЧКИ" - на создать порльзователя
                    Cabinet.isAnyCurrentApplication = false
                    //*******************************************************************************
                }//----------------------------------------------------------
                
            }//------  END OO IF error == nil
            dispatch_semaphore_signal(semaphore);
    }).resume()
    //-----END of SESSION TASK---------------------------------------------------------------------------------------
    //ждем окончания семафора
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    //ВОЗРАЩАЕМ РЕЗУЛЬТАТ СОЗДАНИЯ ЗАЯВКИ - получилось или нет
    return Cabinet.isAnyCurrentApplication
    }//======================== ПРОВЕРКА ЕСТЬ ЛИ ТЕКУЩАЯ ЗАЯВКА =========================================================================
    
    

    
    
    
    
    
    
    

    
    //========================= getInfoAboutApplication ======= ИНФОРМАЦИЯ О ЗАЯВКЕ  =====================================================
    static internal func getInfoAboutApplication() -> Bool
    {
    resultUrl = baseUrl + getInfoAboutApplicationUrl + "?id=" + Cabinet.digestOfUuid
    url = NSURL(string: resultUrl)!
    let session2 = NSURLSession.sharedSession()
    let request = NSMutableURLRequest (URL: url)
    request.HTTPMethod = "GET"

    //**************  создаем СЕМАФОР  *****************************************
    let semaphore = dispatch_semaphore_create(0)
    //--для оценки результат создания заявки
    var result = false
    
    print("NetworkManager:getInfoAboutApplication -> Пробуем получить инфу по \(url)")
    
    //идентификатор загрузки
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true

    session2.dataTaskWithRequest (request, completionHandler:
    {//-------SESSION TASK--------------------------
        (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
        //Make sure we get an OK response
        guard let realResponse = response as? NSHTTPURLResponse where
            realResponse.statusCode == 200 else
        {
            print("NetworkManager:getInfoAboutApplication -> Not a 200 response")
            return
        }
        //убрать индикатор работы с сетью
        dispatch_async(dispatch_get_main_queue())
        {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
        
        //есть ответ
        if ( error == nil )
        {
            //print("RESULT from server: ", data)
            //print("NetworkManager:getInfoAboutApplication -> Error from method: ", error)
            let answer = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
            //print("NetworkManager:getInfoAboutApplication -> RAW ответ от СЕРВЕРА \(answer)")
            
            do
            {
                let decoded = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                print("NetworkManager:getInfoAboutApplication -> полученный овтет в JSON формате")
                print(decoded)
                let dictFromJSON = decoded as! [String:AnyObject]
                
                //if let dictFromJSON = decoded as? [String:String]
                //{
                // .......  раньше так обрамлял
                //}
                
                print("NetworkManager:getInfoAboutApplication -> Информация о существующей заявке декодированная")
                print(dictFromJSON)
                print("");   print("")
                print("NetworkManager:getInfoAboutApplication -> количество элементов В DICT \(dictFromJSON.count)")
         
               
  
                //-------------------timeFrom - время ОТ ------------------------------------------------------
                if let check = dictFromJSON["timeFrom"]   {
                    Cabinet.CurrentApplicationInfo["timeFrom"] = dictFromJSON["timeFrom"] as! String
                }  else  {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа)")
                }
                
                //-------------------timeFrom - время ОТ ------------------------------------------------------
                if let check = dictFromJSON["timeTo"]      {
                    Cabinet.CurrentApplicationInfo["timeTo"] = dictFromJSON["timeTo"] as! String
                }  else  {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа)")
                }
      
                
                //-------------------userRequestState - статус заявки -------------------------------------------
                if let check = dictFromJSON["requestState"]  {
                    Cabinet.CurrentApplicationInfo["requestState"] = dictFromJSON["requestState"] as! Int
                }  else  {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа)")
                }

                
                //-------------------RequestNumber - статус заявки ---------------------------------------------
                if let check = dictFromJSON["requestNumber"]  {
                    Cabinet.CurrentApplicationInfo["requestNumber"] = dictFromJSON["requestNumber"] as! Int
                }  else  {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа)")
                }
                
                
                /***********  ПОЛУЧАЕМЫЕ ДАННЫЕ ПРИ SUCCEDED APPLICATION ****************************************/
                
                //--------------awaitingTimeFrom - время ожидания ОТ----------------------------------------------
                if let check = dictFromJSON["awaitingTimeFrom"] {
                    Cabinet.CurrentApplicationInfo["awaitingTimeFrom"] = dictFromJSON["awaitingTimeFrom"] as! String
                    //********** СЧИТАЕМ, ЧТО РАЗ ПРИШЕЛ ХОТЬ ОДИН ПАРАМЕТР JSON - ТО ОПЕРАЦИЯ УСПЕШНО ПРОШЛА ****
                    result = true
            
                }  else    {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа)")
                }
                
                //-------------------awaitingTimeTo - время ожидания ДО------------------------------------------
                if let check = dictFromJSON["awaitingTimeTo"]   {
                    Cabinet.CurrentApplicationInfo["awaitingTimeTo"] = dictFromJSON["awaitingTimeTo"] as! String
                }  else   {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа)")
                }
                
                //-------------------driverName - имя найденного водителя-----------------------------------------
                if let check = dictFromJSON["driverName"]   {
                    //если "<null>", то меняем на nil
                    if !(check is NSNull) {
                        Cabinet.CurrentApplicationInfo["driverName"] = dictFromJSON["driverName"] as! String
                    } else {
                        Cabinet.CurrentApplicationInfo["driverName"] = nil
                    }
                }  else   {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа)")
                }
                
                //-------------------carDescription - модель машины ----------------------------------------------
                if let check = dictFromJSON["carDescription"]   {
                    //если "<null>", то меняем на nil
                    if !(check is NSNull) {
                        Cabinet.CurrentApplicationInfo["carDescription"] = dictFromJSON["carDescription"] as! String
                    }  else {
                        Cabinet.CurrentApplicationInfo["carDescription"] = nil
                    }
                }  else   {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа)")
                }
                
                //-------------------carColor - цвет машины ------------------------------------------------------
                if let check = dictFromJSON["carColor"]   {
                    //если "<null>", то меняем на nil
                    if !(check is NSNull) {
                        Cabinet.CurrentApplicationInfo["carColor"] = dictFromJSON["carColor"] as! String
                    }  else {
                        Cabinet.CurrentApplicationInfo["carColor"] = nil
                    }
                }  else   {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа)")
                }
                
                //-------------------carNumber - номер машины -----------------------------------------------------
                if let check = dictFromJSON["carNumber"]   {
                    //если "<null>", то меняем на nil
                    if !(check is NSNull) {
                        Cabinet.CurrentApplicationInfo["carNumber"] = dictFromJSON["carNumber"] as! String
                    }  else {
                        Cabinet.CurrentApplicationInfo["carNumber"] = nil
                    }
                }  else   {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа)")
                }
                
                //-------------------passengerList - список найденных пассажиров ------------------------------------
                if let check = dictFromJSON["passengerList"]   {
                    //если "<null>", то меняем на nil
                    if !(check is NSNull) {
                        Cabinet.CurrentApplicationInfo["passengerList"] = dictFromJSON["passengerList"] as! [Dictionary<String,AnyObject>]
                    }  else {
                        Cabinet.CurrentApplicationInfo["passengerList"] = nil
                    }
                }  else   {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа 'passengerList')")
                }

                
                //-------------------passengersCount - сколько будет пассажиров --------------------------------------
                if let check = dictFromJSON["passengersCount"]   {
                    //если "<null>", то меняем на nil
                    if ( !(check is NSNull)  ) {
                        Cabinet.CurrentApplicationInfo["passengersCount"] = dictFromJSON["passengersCount"] as! Int
                    }  else {
                        Cabinet.CurrentApplicationInfo["passengersCount"] = nil
                    }
                }  else   {
                    print("NetworkManager:getInfoAboutApplication -> Ошибка парсинга. Нет ключа)")
                }
                

            }
            catch let error as NSError
            {
                print(error)
            }
        }//------  END OO IF error == nil
        dispatch_semaphore_signal(semaphore);
    }).resume()
    //-----END of SESSION TASK---------------------------------------------------------------------------------------

    //ждем окончания семафора
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    //ВОЗРАЩАЕМ РЕЗУЛЬТАТ СОЗДАНИЯ ЗАЯВКИ - получилось или нет
    return result
   }//========================== ИНФОРМАЦИЯ О ЗАЯВКЕ  =================================================================================




    

    
    
    //============ CANCEL CURRENT APPLICATION   ======   ОТМЕНА ТЕКУЩЕЙ ЗАЯВКИ ==============================================================
    static func cancelCurrentApplication() -> Bool
    {
        resultUrl = baseUrl + CancelCurrentApplicationUrl + "?id=" + Cabinet.digestOfUuid
        print("NetworkManager:cancelCurrentApplication-> Щас удалю по такому URL \(resultUrl)")
        url = NSURL(string: resultUrl)!
        let session2 = NSURLSession.sharedSession()
        let request = NSMutableURLRequest (URL: url)
        request.HTTPMethod = "GET"
        
        //идентификатор загрузки
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //**************  создаем СЕМАФОР  *****************************************
        let semaphore = dispatch_semaphore_create(0)
        //--для оценки результат создания заявки
        var result = false
        
        
        session2.dataTaskWithRequest (request, completionHandler:
            {//-------SESSION TASK--------------------------
                (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
                
                //Make sure we get an OK response
                guard let realResponse = response as? NSHTTPURLResponse where
                    realResponse.statusCode == 200 else
                {
                    print("NetworkManager:cancelCurrentApplication-> Not a 200 response")
                    return
                }
                
                //убрать индикатор работы с сетью
                dispatch_async(dispatch_get_main_queue())
                {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                
                
                //есть ответ
                if ( error == nil )
                {
                    let answer = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                    
                    do
                    {
                        let decoded = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        //print("NetworkManager:cancelCurrentApplication -> Получена вот такой JSON ответ")
                        //print(decoded)
                        
                        let dictFromJSON = decoded as! [String:AnyObject]
                        
                        
                        print("NetworkManager:cancelCurrentApplication -> Декодированный JSON вот он:")
                        print(dictFromJSON)
                        
                        //we are reading the code
                        if let name = dictFromJSON["code"] {
                            if (name as! Int == 0){
                                print("NetworkManager:cancelCurrentApplication -> Заявка успешно отменена!")
                                result = true
                            }
                            else{
                                print("NetworkManager:cancelCurrentApplication -> Проблема при отмене заявки!")
                                result = false
                            }
                        }
                    }  catch let error as NSError   {
                        print("NetworkManager:cancelCurrentApplication -> Ошибка при попытке декодирования JSON ответа")
                        print(error)
                    }
                }//------  END OO IF error == nil
                dispatch_semaphore_signal(semaphore);
                
        }).resume()
        //-----END of SESSION TASK---------------------------------------------------------------------------------------
        //ждем окончания семафора
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        //ВОЗРАЩАЕМ РЕЗУЛЬТАТ СОЗДАНИЯ ЗАЯВКИ - получилось или нет
        return result
    }//===========================END OF CANCEL CURRENT APPLICATION =====================================================================

    
    
    
    
    
    
    
    
    
    
    

    //============ GET NOTIFICATIONS   ======   ПОЛУЧЕНИЕ МАССИВА СООБЩЕНИЙ =============================================================
    static func getPushNotifications() -> Bool
    {
        resultUrl = baseUrl + getPushNotificationsUrl + "?userId=" + Cabinet.digestOfUuid
        print("NetworkManager:getPushNotifications -> Стучимся по URL \(resultUrl)")
        url = NSURL(string: resultUrl)!
        let session = NSURLSession.sharedSession()
        let request = NSMutableURLRequest (URL: url)
        request.HTTPMethod = "GET"
        
        //идентификатор загрузки
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //**************  создаем СЕМАФОР  *****************************************
        let semaphore = dispatch_semaphore_create(0)
        //--для оценки результат создания заявки
        var result = false
        
        
        session.dataTaskWithRequest (request, completionHandler:
            {//-------SESSION TASK--------------------------
                (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
                
                //Make sure we get an OK response
                guard let realResponse = response as? NSHTTPURLResponse where
                    realResponse.statusCode == 200
                else    {
                    print("NetworkManager:getPushNotifications-> Not a 200 response")
                    return
                }
                
                //убрать индикатор работы с сетью
                dispatch_async(dispatch_get_main_queue())    {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                
                
                //есть дата ответ
                if ( error == nil )
                {
                    let answer = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                    
                    do
                    {
                        let decoded = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        print("NetworkManager:getPushNotifications -> Получен вот такой data ответ")
                        print(answer)
                        
                        print("NetworkManager:getPushNotifications -> Получен вот такой decode ответ")
                        print(decoded)
                        
                        //***********************************************************************//
                        //тут главное поеять, что у нас тут массив словарей
                        //тут мы делаем casting __NSCFArray ->  NSArray of Dictionary<String,String>
                        //но чтобы не было ошибок кастинг as?  - то есть у нас может возвращаться nil
                        let dictFromJSON = decoded as? [Dictionary<String,String>]
                        if  (dictFromJSON != nil && dictFromJSON!.count > 0 ) {
                            print("NetworkManager:getPushNotifications -> Декодированный JSON вот он:")
                            print(dictFromJSON!)
                            //print(dictFromJSON![0]["Text"]!)
                            
                            //мы точно значем, что пришло только одно сообщение
                            //его мы и вставляем в наш массив
                            
                            Cabinet.myPushNotifications.insert(dictFromJSON![0], atIndex: 0)
                            //но сначала правим дату
                            Cabinet.myPushNotifications[0]["createdOn"] = TimeModel.clearFromMicroseconds(Cabinet.myPushNotifications[0]["createdOn"]!)
                            let prefs = NSUserDefaults.standardUserDefaults()
                            prefs.setObject(Cabinet.myPushNotifications, forKey: "pushNotifications")
                        } else {
                            print("NetworkManager:getPushNotifications -> Декодированный JSON вот он:")
                            print(dictFromJSON)
                        }
                        
                        //читаем код
                        //if let name = dictFromJSON["code"] {
                        //    if (name as! Int == 0){
                        //        print("NetworkManager:getPushNotifications -> Заявка успешно отменена!")
                        //        result = true
                        //    }
                        //    else{
                        //        print("NetworkManager:getPushNotifications -> Проблема при отмене заявки!")
                        //        result = false
                        //    }
                        //
                        //}
                        
                    }
                    catch let error as NSError
                    {
                        print("NetworkManager:getPushNotifications -> Ошибка при попытке декодирования JSON ответа")
                        print(error)
                    }
                }//------  END OO IF error == nil
                dispatch_semaphore_signal(semaphore);
                
        }).resume()
        //-----END of SESSION TASK---------------------------------------------------------------------------------------
        //ждем окончания семафора
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        //ВОЗРАЩАЕМ РЕЗУЛЬТАТ СОЗДАНИЯ ЗАЯВКИ - получилось или нет
        return result
    }//============ GET NOTIFICATIONS   ======   ПОЛУЧЕНИЕ МАССИВА СООБЩЕНИЙ ============================================================
    
    
    
    
    //========= OPEN EXTERNALLY (in Safari) OUR POCKET ===================================================================================
    static func openPersonalPocket() {
        resultUrl = baseUrl + personalPocketUrl + "?p=" + Cabinet.digestOfUuid
        url = NSURL(string: resultUrl)!
        UIApplication.sharedApplication().openURL(url)
        
        
    }
    
    
    
    
    
    
    //========================== GET YOUR BALANCE ==========================================================================================
    static func getYourBalance() -> Bool
    {
        resultUrl = baseUrl + getPersonalBalanceUrl + "?id=" + Cabinet.digestOfUuid
        url = NSURL(string: resultUrl)!
        var result:Bool = false
        
        
        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlconfig.timeoutIntervalForRequest = Cabinet.timeOutShortForNSURLSession   //5.0 sec
        urlconfig.timeoutIntervalForResource = Cabinet.timeOutShortForNSURLSession
        //у нас своя NSURLSession что создается с нашими кастомными настройками (время таймаута)
        //let session1 = NSURLSession.sharedSession()
        let session = NSURLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest (URL: url)
        request.HTTPMethod = "GET"
        
        
        //идентификатор загрузки
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //*******  создаем СЕМАФОР  ************************************
        let semaphore = dispatch_semaphore_create(0)
        
        let task = session.dataTaskWithRequest(request, completionHandler:
            {//-------SESSION TASK--------------------------
                (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
                
                //Make sure we get an OK response
                guard let realResponse = response as? NSHTTPURLResponse where
                    realResponse.statusCode == 200 else
                {
                    print("NetworkManager:getYourBalance -> Получен не 200 код или превышен таймаут")
                    dispatch_semaphore_signal(semaphore)
                    return
                }
                
                //убрать индикатор работы с сетью
                dispatch_async(dispatch_get_main_queue())
                {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                
                //есть ответ
                if ( error == nil )
                {
                    //print("NetworkManager:isUserExist ->  RESULT from server: ", data)
                    //print("NetworkManager:isUserExist ->  Error from method: ", error)
                    let answer = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                    
                    //**** NSDecimal ******//
                    Cabinet.balance = NSDecimalNumber(string: answer)
                    let formatter = NSNumberFormatter()
                    formatter.minimumFractionDigits = 2
                    let string = formatter.stringFromNumber(Cabinet.balance)
                    
                    print("NetworkManager:getYourBalance -> Баланс \(string!)")
                    result = true
                }//------  END OO IF error == nil
                
                dispatch_semaphore_signal(semaphore)
                
        }).resume()
        //-----END of SESSION TASK---------------------------------------------------------------------------------------
        
        
        
        //ждем окончания семафора
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return result
    }//======================= END GET YOUR BALANCE =====================================================================================

    
    
    
    
    
    

    //======================== SAVE PUSH NOTIFICATIONS TOKEN ===========================================================================
    static func savePushToken() -> Bool
    {
        resultUrl = baseUrl + savePushTokenUrl
        url = NSURL(string: resultUrl)!

        //================ СОЗДАНИЕ РЕГИСТРАЦИОННОЙ JSON СТРОКИ ==================================================
        let digestOfUuid = Cabinet.digestOfUuid
        let token = Cabinet.deviceToken
        var result:Bool = false
        //let's make small dictionary
         dict = ["id":                      "\(digestOfUuid)",
                 "token":                   "\(token)"]

        //now we convert dictionary into JSON object for payload
        do   {
            jsonData = try!  NSJSONSerialization.dataWithJSONObject  (dict, options: NSJSONWritingOptions.PrettyPrinted)
            jsonString = NSString  (data: jsonData, encoding: NSUTF8StringEncoding)! as String
            print("NetworkManager:savePushToken -> Отправляем такой вот запрос на сохранение deviceToken'а")
            print(jsonString)
        }  catch let error as NSError   {
            print("NetworkManager:savePushToken -> Ошибка при создании JSON объекта")
            print(error)
        }
        //===========================================================================================================
        

        //==NOW WE ARE SETTING UP OUR SESSION =======================================================================
        //создаем урлу на регистрацию
        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlconfig.timeoutIntervalForRequest = Cabinet.timeOutMiddleForNSURLSession      //7.5 sec
        urlconfig.timeoutIntervalForResource = Cabinet.timeOutMiddleForNSURLSession
        let session = NSURLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest (URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonData    //we put our JSON payload into POST request
        
        //activity indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        

        
        let task = session.dataTaskWithRequest(request, completionHandler:
            {//-------SESSION TASK--------------------------
                (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
                
                //Make sure we get an OK response
                guard let realResponse = response as? NSHTTPURLResponse where
                    realResponse.statusCode == 200 else
                {
                    print("NetworkManager:savePushToken -> Получен не 200 код или превышен таймаут")
                    return
                }
                
                //remove activity indicator
                dispatch_async(dispatch_get_main_queue())
                {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                
                //we have answer
                if ( error == nil )
                {
                    let answer = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                    do  {
                        let decoded = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        //print("NetworkManager:savePushToken -> Получен вот такой JSON ответ")
                        //print(decoded)
                        let dictFromJSON = decoded as! [String:AnyObject]
                        
                        //we are reading the code
                        if let name = dictFromJSON["code"] {
                            if (name as! Int == 0){
                                print("NetworkManager:savePushToken-> deviceToken успешно сохранен на сервере!")
                                result = true
                            }
                            else{
                                print("NetworkManager:savePushToken -> Проблема при попытке сохранения deviceToken'а на сервере!")
                                result = false
                            }
                        }
                    }  catch let error as NSError   {
                        print("NetworkManager:savePushToken -> Ошибка при попытке декодирования JSON ответа")
                        print(error)
                    }
                    
                }//------  END OO IF error == nil
                
 
        }).resume()
        //-----END of SESSION TASK---------------------------------------------------------------------------------------
        

        return result
        
    }//========================== SAVE PUSH NOTIFICATIONS TOKEN =========================================================================
    
    
    
    
    
    
    
    
    
    //======================== SAVE PUSH NOTIFICATIONS TOKEN ===========================================================================
    static func savePushTokenTest() -> Bool
    {
        //resultUrl = savePushTokenUrlTest
        //url = NSURL(string: resultUrl)!
  
        resultUrl = baseUrl + savePushTokenUrl
        url = NSURL(string: resultUrl)!
        
        //================ СОЗДАНИЕ РЕГИСТРАЦИОННОЙ JSON СТРОКИ ==================================================
        let digestOfUuid = Cabinet.digestOfUuid
        let token = Cabinet.deviceToken
        var result:Bool = false
        //let's make small dictionary
        dict = ["id":                      "\(digestOfUuid)",
                "token":                   "\(token)"]
        
        //now we convert dictionary into JSON object for payload
        do   {
            jsonData = try!  NSJSONSerialization.dataWithJSONObject  (dict, options: NSJSONWritingOptions.PrettyPrinted)
            jsonString = NSString  (data: jsonData, encoding: NSUTF8StringEncoding)! as String
            print("NetworkManager:savePushToken -> Отправляем такой вот запрос на сохранение deviceToken'а")
            print(jsonString)
        }  catch let error as NSError   {
            print("NetworkManager:savePushToken -> Ошибка при создании JSON объекта")
            print(error)
        }
        //===========================================================================================================
        
        
        //==NOW WE ARE SETTING UP OUR SESSION =======================================================================
        //создаем урлу на регистрацию
        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlconfig.timeoutIntervalForRequest = Cabinet.timeOutMiddleForNSURLSession      //7.5 sec
        urlconfig.timeoutIntervalForResource = Cabinet.timeOutMiddleForNSURLSession
        let session = NSURLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
        let request = NSMutableURLRequest (URL: url)
        print(url)
        request.HTTPMethod = "POST"
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //jsonData = "id=\(digestOfUuid)&token=\(token)".dataUsingEncoding(NSUTF8StringEncoding)!
        request.HTTPBody = jsonData    //we put our JSON payload into POST request
        
        //activity indicator
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        //*******  создаем СЕМАФОР  ************************************
        let semaphore = dispatch_semaphore_create(0)

        
        let task = session.dataTaskWithRequest(request, completionHandler:
            {//-------SESSION TASK--------------------------
                (data: NSData?, response: NSURLResponse?, error: NSError?)   -> Void in
                
                //Make sure we get an OK response
                guard let realResponse = response as? NSHTTPURLResponse where
                    realResponse.statusCode == 200 else
                {
                    print("NetworkManager:savePushTokenTest -> Получен не 200 код или превышен таймаут")
                      dispatch_semaphore_signal(semaphore)
                    return
                }
                
                //remove activity indicator
                dispatch_async(dispatch_get_main_queue())
                {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }
                
                //we have answer
                if ( error == nil )
                {
                    let answer = NSString(data: data!, encoding: NSUTF8StringEncoding) as! String
                    do  {
                        let decoded = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        print("NetworkManager:savePushTokenTest -> Получен вот такой JSON ответ")
                        print(decoded)
                        let dictFromJSON = decoded as! [String:AnyObject]
                        
                        //we are reading the code
                        if let name = dictFromJSON["code"] {
                            if (name as! Int == 0){
                                print("NetworkManager:savePushTokenTest-> deviceToken успешно сохранен на сервере!")
                                result = true
                            }
                            else{
                                print("NetworkManager:savePushTokenTest -> Проблема при попытке сохранения deviceToken'а на сервере!")
                                result = false
                            }
                        }
                    }  catch let error as NSError   {
                        print("NetworkManager:savePushTokenTest -> Ошибка при попытке декодирования JSON ответа")
                        print(error)
                    }
                }//------  END OO IF error == nil
             dispatch_semaphore_signal(semaphore)
                
        }).resume()
        //-----END of SESSION TASK---------------------------------------------------------------------------------------

        //ждем окончания семафора
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return result
    }//========================== SAVE PUSH NOTIFICATIONS TOKEN =========================================================================

    
    




}//==== END OF CLASS DECLARATION
