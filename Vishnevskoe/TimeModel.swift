//
//  TimeManipulations.swift
//  Vishnevskoe
//
//  Created by Chingiz Bayshurin on 12.07.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import Foundation

class TimeModel {
    
    
    //=====функция вычленения минут - 4го символа в xx:Yy нашей временной строке=======
    public static func plusTenMinutes (string : String) -> String    {
        //объявление массива Character
        var charArray: Array<Character> = Array(count: 5, repeatedValue: "\u{2663}")
        var i = 0
        
        //------наполнения массива символов-------------
        for index in string.characters.indices {
            charArray[i] = string[index]
            i += 1
        }
        //----------------------------------------------
        
        //мы берем 4ый символ, что задает десятки минут и преобразуем его в Int
        var ii = Int(String(charArray[3]))
        var result = String()
        
        if ii != nil
        {
            //print(charArray[3])
            //print(ii)
            ii = ii! + 1
            charArray[3] = characterFromInt(ii!)
        }
        
        
        var finalString = String()
        i=0
        //------наполнения массива символов-------------
        while (i < 5) {
            finalString.append( charArray[i] )
            i += 1
        }
        //----------------------------------------------
        
        return finalString
    }
    
    
    
    
    
    //=====функция преобразования Int в Character (ее можно настроить на возврат String)=======
    static func characterFromInt(index : Int) -> Character {
        let startingValue = Int(("0" as UnicodeScalar).value)
        //var characterString = ""
        //characterString.append(Character(UnicodeScalar(startingValue + index)))
        //return characterString
        
        var char:Character
        char = Character(UnicodeScalar(startingValue + index))
        return char
    }
    
    
    
    
    //===== ФУНКЦИЯ УСТАНОВКИ ВРЕМЕНИ ПО УМОЛЧАНИЮ =======
    static func setInitialTime()  {
        /**
         *  по умолчанию мы ставим время - текущее + 30 минут
         */
        
        let date = NSDate()
        print(date)
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([ .Hour, .Minute, .Second], fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        let seconds = components.second
        
        print("Hour = \(hour)  Minutes = \(minutes) Seconds = \(seconds)")
        var current_hour :Int = hour
        
        //======= АЛГОРИТМ УСТАНОВКИ ТЕКУЩЕГО ВРЕМЕНИ timeFrom & timeTill ===============
        /**
         *   Наша задача получить округленное вверх время в рамках наших 30 минутных
         *   промежутков.
         *   Также у нас "мертвая зона" - это промежуток с 23:30 - 00:00 - в ходе которого
         *   транспорт ходить не будет
         */
        var timeFrom = String()
        var timeTill = String()
        
        print("Hour = \(hour)  Minutes = \(minutes) Seconds = \(seconds)")
        
        //*** интервал для периодов - 30 минутный что для пассажиров, что для водителей ***
        let INTERVAL = 30
        
        //служебные переменные
        var string_hour = String()
        var string_minute = String()
        var remainder = Int()  //это остаток
        var minutesTime = Int()
        
        //инициализируем переменную по часам
        current_hour = hour
        
        
        //===== ПОЛУЧАЕМ ВРЕМЯ ОТ -  timeFrom ================================
        //Действие № 1
        //сначала мы получаем время в минутах кратное INTERVAL и немного большее, чем текущее
        //например, на часах 22:22, мы получаем 22:30
        remainder = minutes%INTERVAL
        minutesTime = minutes-remainder + INTERVAL
        
        
        //Действие № 2
        //затем, если при нашем INTERVAL=30мин мы получаем время типа xx:30, то все ок
        //если типа xx:60 то тогда мы передвигаемся на следующий час, если не упираемся в 24-00
        switch (minutesTime){
        case 30: //ничего не делаем
            break
            
        case 60:  //переходим на новый час
            current_hour  += 1
            minutesTime = 0
            if (current_hour > 23){
                current_hour  = 0
            }
            break
            
        default:  //ничего не делаем
            break
        }
        
        //Действие № 3
        //так как мы все преобразуем в строку, то делаем красивое форматирование
        //дополняем часы нулем, если часов на часах <10, чтобы было 01:00, а не 1:00
        if (current_hour<10) {
            string_hour = "0\(current_hour)"
        } else       {
            string_hour = "\(current_hour)"
        }
        //--
        //дополняем минуты нулем, если минуты на часах <10, чтобы было 01:03, а не 01:3
        if (minutesTime<10) {
            string_minute = "0\(minutesTime)"
        } else       {
            string_minute = "\(minutesTime)"
        }
        
        //и вот оно наше ВРЕМЯ ОТ
        timeFrom = ("\(string_hour):\(string_minute)")
        
        
        //==== ТЕПЕРЬ ПОЛУЧАЕМ ВРЕМЯ ДО=================================================
        //Действие № 1
        //Сразу же передвигаем минутное время на ИНТЕРВАЛ минут вперед
        minutesTime += INTERVAL
        
        //Действие № 2
        //снова проверяем, не вышли ли за границы часа, если вышли, то увеличиваем время на 1 час
        if ( minutesTime < 60)
        {
            //ничего не делаем
        }
        else
        {
            current_hour  += 1
            minutesTime = 0
            if (current_hour > 23){  //чтобы было 00:00 вместо 24:00
                current_hour  = 0
            }
        }
        
        //Действие № 3
        //так как мы все преобразуем в строку, то делаем красивое форматирование
        //дополняем часы нулем, если часов на часах <10, чтобы было 01:00, а не 1:00
        if (current_hour<10) {
            string_hour = "0\(current_hour)"
        } else       {
            string_hour = "\(current_hour)"
        }
        //--
        //дополняем минуты нулем, если минуты на часах <10, чтобы было 01:03, а не 01:3
        if (minutesTime<10) {
            string_minute = "0\(minutesTime)"
        } else       {
            string_minute = "\(minutesTime)"
        }
        
        //и вот оно наше ВРЕМЯ ДО
        timeTill = ("\(string_hour):\(string_minute)")
        
        
        if (timeFrom == "00:00")  {
            print("TimeModel -> Слишком поздно! Нет возможного времени")
        }  else   {
            print("TimeModel -> Есть возможные варианты")
        }
        //===========КОНЕЦ РАСЧЕТА ВРЕМЕНИ=================
        
  
        //инициализируем переменные в нашей модели
        Cabinet.passengerTimeFrom = "\(timeFrom)"
        Cabinet.passengerTimeTill = "\(timeTill)"
        Cabinet.driverTimeFrom =  "\(timeFrom)"
        Cabinet.driverTimeTill =  TimeModel.plusTenMinutes(Cabinet.driverTimeFrom)
   
        print("Текущее время \(Cabinet.passengerTimeFrom)")
    }
    
    
    
    
    
    //=== ФУНКЦИЯ ОПРЕДЕЛЕНИЯ ВОЗМОЖНЫХ ВРЕМЕННЫХ ВАРИАНТОВ ===
    /**
     *   Задача получить массив String с возможными временными отметками
     *   availableTime[] может получиться пустым, если не будет возможного времени (если попробовать искать с 23-30 до 00-00
     **/
    static func setAvailableTime()->[String] {
    //availableTime = ["04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30","08:00","08:30","09:00","09:30","10:00" ]
    
    var availableTime = [String]()
    
    
    //==== АЛГОРИТМ РАСЧЕТА ВРЕМЕНИ=======
    let date = NSDate()
    print(date)
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components([ .Hour, .Minute, .Second], fromDate: date)
    let hour = components.hour
    let minutes = components.minute
    let seconds = components.second
    
    print("Hour = \(hour)  Minutes = \(minutes) Seconds = \(seconds)")
    
    
    //*** интервал для периодов - 30 минутный что для пассажиров, что для водителей ***
    let INTERVAL = 30
    
    
    //служебные переменные
    var string_hour = String()
    var string_minute = String()
    var remainder = Int()  //это остаток
    var current_hour = Int()
    var startTime = Int()
    
    
    current_hour = hour
    
    //----считаем сначала первый час, отталкиваясь от сколько минут сейчас в реальном времени --
    //---цикл расчета минутных промежутков-----------
    //целочисленным делением с получением остатка мы определяем с какого времени
    //нам отмерять промежутки (например, 10 минутные)
    remainder = minutes%INTERVAL
    startTime = minutes-remainder + INTERVAL
    
    while ( startTime < 60)
    {
    //дополняем часы нулем, если <10, чтобы было 01:00, а не 1:00
    if (current_hour<10) {
    string_hour = "0\(current_hour)"
    } else       {
    string_hour = "\(current_hour)"
    }
    
    //print(string_hour)
    //заносим в массив
    availableTime.append("\(string_hour):\(startTime)")
    startTime += INTERVAL
    }//----------------------------------------------
    //-----------------------------------------------
    //print (availableTime)
    
    
    //-----а затем проходимся по часам до 00:00 ---------------
    //передивагаем час дальше, потому как по текущему часу мы уже посчитали
    //возможные промежутки
    current_hour += 1
    while ( current_hour <= 23 )
    {
    //---цикл расчета минутных промежутков-----------
    var startTime = 0
    
    while ( startTime < 60)
    {
    //дополняем часы нулем, если <10, чтобы было 01:00, а не 1:00
    if (current_hour<10) {
    string_hour = "0\(current_hour)"
    } else       {
    string_hour = "\(current_hour)"
    }
    
    //и вот тут, нам также надо дополнять минуты нулем, когда время, скажем 04:00
    if (startTime<10) {
    string_minute = "0\(startTime)"
    } else       {
    string_minute = "\(startTime)"
    }
    
    //заносим в массив
    availableTime.append("\(string_hour):\(string_minute)")
    startTime += INTERVAL
    }//------------------------------------------------
    current_hour += 1
    }//---------------------------------------------------------
    
    
    //костыли, если время 23:50 и позже, то мы не можем впихнуть даже
    //одтн 10 минутный промежуток и чтобы совсем не было все пусто запишем 00:00
    //также записывать 00:00 нужно, потому что иначе массив остановится на 23:50
    //availableShortTime.append("00:00")
  
        
    return availableTime
    //===========КОНЕЦ РАСЧЕТА ВРЕМЕНИ==================================================================================
  }

    
    
    
    
    
    //=== функция получения текущей даты ===
    static func getCurrentDateInString() -> String    {
        let date = NSDate()
        let formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd";  //"yyyy-MM-dd HH:mm:ss ZZZ";
        let stringDateInLocalTimeZone = formatter.stringFromDate(date);
        
        return stringDateInLocalTimeZone
    }
 
    
    
    
    
    //=== функция получения текущей даты c часами, минутами и секундами ===
    static func getCurrentDateWithHoursMinutesSecondsInString() -> String    {
        let date = NSDate()
        let formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";  //"yyyy-MM-dd HH:mm:ss ZZZ";
        let stringDateInLocalTimeZone = formatter.stringFromDate(date);
        
        return stringDateInLocalTimeZone
    }
   
    
    
    
    //=== получение короткой даты из полного таймстемпа ======
    static func getForMeOnlyShortDate(originalStringDate : String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone(name: "Moscow/Europe")
        let originalDate = dateFormatter.dateFromString(originalStringDate)
        
        let dateFormatter2 = NSDateFormatter()
        dateFormatter2.dateFormat = "yyyy.MM.dd"
        let shortStringDate = dateFormatter2.stringFromDate(originalDate!)
        
        return shortStringDate
    }
    
    
     //=== получение времени ожидания в часах ======
    /**
     *    На вход мы получаем awaitingTimeFrom и awaitingTimeTo в таком формате "0001-01-01T00:00:00"
     *    Эта функция вычленяет только часы и пишет их в одну строчку типа "00:00:00 - 00:00:00"
     **/
    static func getAwaitingHours(awaitingTimeFrom: String, awaitingTimeTo: String) -> String  {
        //0001-01-01T00:00:00
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let awaitingTimeFromInNSDATE = dateFormatter.dateFromString(awaitingTimeFrom)
        let awaitingTimeToInNSDATE   = dateFormatter.dateFromString(awaitingTimeTo)
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let awaitingTimeFromInString = timeFormatter.stringFromDate(awaitingTimeFromInNSDATE!)
        let awaitingTimeToInString   = timeFormatter.stringFromDate(awaitingTimeToInNSDATE!)
        
        let finalHourString = awaitingTimeFromInString + " - " + awaitingTimeToInString
        
        return finalHourString
    }
    
    
    
    
    //убрать микросекунды
    static func clearFromMicroseconds(originalDate: String) -> String  {
        //0001-01-01T00:00:00
        let originalFormatter = NSDateFormatter()
        originalFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS"
        let originalTimeInNSDATE = originalFormatter.dateFromString(originalDate)
 
        let shortDateFormatter = NSDateFormatter()
        shortDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let shortDateInString = shortDateFormatter.stringFromDate(originalTimeInNSDATE!)
  
        return shortDateInString
    }
    
    //дай мне короткий таймстемп
    static func getShortCurrentDate() -> String  {
        let shortDateFormatter = NSDateFormatter()
        shortDateFormatter.dateFormat = "yyyy-MM-dd   HH:mm"
        let shortDateInString = shortDateFormatter.stringFromDate(NSDate())
        
        return shortDateInString
    }


    
    
    
    
}//===class declaration