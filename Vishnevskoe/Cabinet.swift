//
//  Cabinet.swift
//  Vishnevskoe
//
//  Created by Chingiz Bayshurin on 28.06.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import Foundation
import UIKit


class Cabinet {
    
    static let timeOutShortForNSURLSession : NSTimeInterval = 5.0
    static let timeOutMiddleForNSURLSession : NSTimeInterval = 7.5
    
    static let welcomeString = "Добро пожаловать в наше приложение Вишневое. Приятных поездок!"
    
    
    //для переключения режимов - "0" - это установка времени ОТ, "1" - времени ДО
    static var fromOrTill:Int = 0
    
    //данные пользователя - Единые
    static var fullName = String()  //имя
    static var sex = false          //пол -  false - Мужик, true - Баба
    static var digestOfUuid:String = String()
    static var deviceToken:String = String()
    
    //данные чисто водительские
    static var carNumber:String = ""    // чтобы он был по умолчанию Empty - нам это пригодится
    static var carColor = String()
    static var carModel = String()
    
    //для того чтобы понять какой щас режим - для водилы или пассаджира
    //  false - пассажир      true - водила
    static var type = false
    
    
    //для того, чтобы понять создан ли юзер в системе СЕРВЕРА ЗЕЛЕНОДОЛЬСКОЕ или нет
    static var userExists = false
    
    
    //временные рамки отдельно для пассажира и водителя
    static var passengerTimeFrom = String()
    static var passengerTimeTill = String()
    static var driverTimeFrom    = String()
    static var driverTimeTill    = String()
    
    
    /**** по заявкам на перевозку ****/
    //если актуальная заяка
    static var isAnyCurrentApplication = false
    //какой ее номер
    static var applicationNumber = 0
    //информация о заявке
    static var CurrentApplicationInfo:[String:AnyObject] = [:]
    
    //надо ли ехать до микрорайона "Город"
    static var goToMicrodistrict:Bool = false
    static var departurePointId = 0    /* 0 - Кольцо (пенсионный фонд)    1 - Макдональдс (Энергоинститут)   */
    static let departurePointIdLabel = ["Кольцо (пенсионный фонд)", "Макдональдс (Энергоинститут)"]
    
    //сколько пассажиров возьмет водитель - по умолчанию всегда берем 3
    static var passengersQuantityITake:Int = 3
    
    //переменная для сохранения сообщений
    static var myPushNotifications:[Dictionary<String,String>] = []
    
    //*** костыли - переменная, показывает, что мы обновили статус заявки *****
    //*** надо мне научится наконец-таки рабоать с сетевыми потоками
    static var justNowInfoAboutApplication = false
    
    
    static var favoriteMusicDescription : [String] =  ["ТИШИНА",
                                                       "Радио Рекорд 101.9",
                                                       "Релакс FM 105.3",
                                                       "Серебряный Дождь 88.3",
                                                       "Радио Energy 92.3",
                                                       "Радио МАЯК 93.9"]
    //музыка, которую выбрал пассажир
    static var favoriteMusicILike : Int = 0
    
    //"false" - нет,  "true" - да, только девок хочу возить!
    static var passengersOnlyGirls : Bool = false
    
    static var balance:NSDecimalNumber = 0.0

    
    
    //============ ПОЛУЧАЕМ MD5 ХЭШ ИДЕНТИФИКАТОРА ЮЗЕРА и ЗАВОДИМ ЕГО В СТАТИЧЕСКУЮ ПЕРЕМЕННУЮ  digestOfUuid ================================================
    static public func getPhoneId() -> String
    {
        let uuid = UIDevice.currentDevice().identifierForVendor?.UUIDString
        
        //---------считываем сначала UUID------------------------
        if (uuid != nil)
        {
            print("Вот мой уникальный идентификатор:  \(uuid)")
            //не смог запустить функцию md5 как private функцию класса Cabinet
            //потому так отписал
            //digestOfUuid = md5(uuid)
            //print("Вот мой уникальный идентификатор в MD5 хэше: \(digestOfUuid)")
        }
        else{
            
            print("Возникла ошибка в получением UUID!")
            //!!!!!!!!! ВОЗВРАЩАЮ НУЛЬ ЕСЛИ НЕ СМОГ ПРОЧИТАТЬ ИДЕНТИФИКАТОР и ВЫХОЖУ ДАБЫ КРАША НЕ БЫЛО
            return ""
        }
        
        //---------расчитываем MD5  хэш-----------------------------
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        let data = uuid!.dataUsingEncoding(NSUTF8StringEncoding)
        
        if  (data != nil)  {
            CC_MD5(data!.bytes, CC_LONG(data!.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        digestOfUuid = digestHex
        print("Вот мой уникальный идентификатор в MD5 хэше: \(digestOfUuid)")
        
        return digestOfUuid
        
    }//============ END ПОЛУЧАЕМ MD5 ХЭШ ИДЕНТИФИКАТОРА ЮЗЕРА и ЗАВОДИМ ЕГО В СТАТИЧЕСКУЮ ПЕРЕМЕННУЮ  digestOfUuid =============================================
    
    
    
    
    //---для работы с строками - добалвение произвольной выделенной строки
    static func addBoldText(fullString: NSString, boldPartOfString: NSString, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSFontAttributeName:font!]
        let boldFontAttribute = [NSFontAttributeName:boldFont!]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        boldString.addAttributes(boldFontAttribute, range: fullString.rangeOfString(boldPartOfString as String))
        return boldString
    }
    
    
    
    
    
    
    //не смог запустить функцию md5 как private функцию класса Cabinet
    //потому включил все в одну функцию - СМОТРИ ВЫШЕ
    
    //------функция по расчету MD5 ХЭШу--------------------------------------------------------------
    // Swift 2.0, minor warning on Swift 1.2
    //private func md5(string string: String) -> String {
    //
    //    var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
    //    if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
    //        CC_MD5(data.bytes, CC_LONG(data.length), &digest)
    //    }
    //
    //    var digestHex = ""
    //    for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
    //        digestHex += String(format: "%02x", digest[index])
    //    }
    //
    //     return digestHex
    // }
    //-----------------------------------------------------------------------------------------------
    
    
}