//
//  setTime.swift
//  Vishnevoe
//
//  Created by Chingiz Bayshurin on 20.06.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import UIKit


class setTime: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate {

    @IBOutlet weak var timeBaraban: UIPickerView!
    @IBOutlet weak var chosenTimeLabel: UILabel!
    
    var availableTime = [String]()
    //для переключения режимов - "0" - это установка времени ОТ, "1" - времени ДО
    var fromOrTill:Int = 0
    var chosenTimeIndex:Int = 0
    
    var myTimeFrom:String = "00:00"
    var myTimeTill:String = "00:00"
    
    
    
    

    
    
    
    
   
    
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        //availableTime = ["04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30","08:00","08:30","09:00","09:30","10:00" ]
        
        //устанавливаем возможное для выбора ВРЕМЕННЫЕ ПОЗИЦИИ
        availableTime = TimeModel.setAvailableTime()
        print (availableTime)
        if availableTime.isEmpty  {
            print("Слишком поздно! Нет возможного времени")
        }  else   {
            print("Есть возможные варианты")
        }
        
        
        //ставим label c первым возможным для выбора временем
        if availableTime.isEmpty  {
            //или заглушкой, если нет вообще вариантов
            chosenTimeLabel.text = "нет вариантов"
        }  else   {
            chosenTimeLabel.text=availableTime[0]
            chosenTimeIndex = timeBaraban.selectedRowInComponent(0)
        }
        
        //графические установки и делегаты
        self.navigationItem.title = "Выберите время"
        
        //меняем просто на события change value нашей крутилки
        //navigationController?.delegate = self   //****************
        
        timeBaraban.delegate = self
        timeBaraban.dataSource = self
    }//-----end of viewDidLoad Function--------
    
    

    override func didReceiveMemoryWarning()    {
        super.didReceiveMemoryWarning()
    }
    


    
    //================== ФУНКЦИИ ПО РАБОТЕ С PICKERVIEW - нашим БАРАБАНОМ ============================================================
    /**
     *   1. Мы устанавливаем 1 секцию и количество компонентов-выборов по числу массива строк-выбора времени
     *   2. У нас определена функция выбора времени -  didSelectRow
     */
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int   {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int    {
        return availableTime.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?   {
        return availableTime[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)    {
        chosenTimeIndex = row
        chosenTimeLabel.text = availableTime[chosenTimeIndex]
        
        //====сейчас мы просто передаем установленное время в переменные класса Модели -  Cabinet======
        //====и затем MainViewController будет обновлять интерфейс, опираясь на это время        ======
        
        if( Cabinet.type == false )                         /*  РЕЖИМ ПАССАЖИРА */
        {
            if (Cabinet.fromOrTill == 0)                     /* ВРЕМЯ ОТ */
            {
                //****** ПРОВЕРКА ЧТО НЕ НУЛЬ ;;;;;;;;;;;;;;
                if (!availableTime.isEmpty){
                    Cabinet.passengerTimeFrom = availableTime[chosenTimeIndex]
                } else {
                    Cabinet.passengerTimeFrom = "00:01"
                }
                
                
                //===== проверка на то, чтобы время ДО было всегда больше времени ОТ
                if (  !(Cabinet.passengerTimeTill>Cabinet.passengerTimeFrom)  )
                {
                    Cabinet.passengerTimeTill = Cabinet.passengerTimeFrom
                    //ToDo:   НУЖНО НАПИСАТЬ ФУНКЦИЮ ПРИБАВЛЕНИЯ 30 МИНУТ
                }
                print("PassangerTimeFrom  = \(Cabinet.passengerTimeFrom)")
            }
            else                                    /* ВРЕМЯ ДО */
            {
                Cabinet.passengerTimeTill = availableTime[chosenTimeIndex]
                //===== проверка на то, чтобы время ДО было всегда больше времени ОТ
                if (  !(Cabinet.passengerTimeTill>Cabinet.passengerTimeFrom)  )
                {
                    Cabinet.passengerTimeTill = Cabinet.passengerTimeFrom
                    //ToDo:   НУЖНО НАПИСАТЬ ФУНКЦИЮ ПРИБАВЛЕНИЯ 30 МИНУТ
                }
                print("PassengerTimeFrom  = \(Cabinet.passengerTimeTill)")
            }
        }
        else                                                     /*  РЕЖИМ ВОДИТЕЛЯ  */
        {
            Cabinet.driverTimeFrom  =  availableTime[chosenTimeIndex]
            Cabinet.driverTimeTill  =  TimeModel.plusTenMinutes (  availableTime[chosenTimeIndex]  )
            print("DriverTimeTill  = \(Cabinet.driverTimeTill)")
        }
        
    }
    //================== ФУНКЦИИ ПО РАБОТЕ С PICKERVIEW - нашим БАРАБАНОМ =============================================================
    

    
    //**************************************************************************************************
    //override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //
    //    if segue.identifier == "returnFromTimeSet"
    //    {
    //       let destinationVC : MainViewController = segue.destinationViewController as! MainViewController
    //
    //        if fromOrTill == 0
    //        {
    //            destinationVC.myTimeFrom = availableTime[chosenTimeIndex]
    //            destinationVC.myTimeTill = myTimeTill
    //            print("Установлено время ОТ!")
    //            print(availableTime[chosenTimeIndex])
    //        }
    //        else
    //        {
    //            destinationVC.myTimeFrom = myTimeFrom
    //            destinationVC.myTimeTill = availableTime[chosenTimeIndex]
    //            print("Установлено время ДО!")
    //            print(availableTime[chosenTimeIndex])
    //        }
    //    }
    //}
    //**************************************************************************************************
    
    
    
    //****** НОВЫЙ СПОСОБ ПЕРЕДАЧИ ДАННЫХ ПО НАЖАТИЮ КЛАВИЩИ BACK **************************************
    //func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        //   if let controller = viewController as? MainViewController
        //   {
        //       chosenTimeIndex       = timeBaraban.selectedRowInComponent(0)
        //
        //       //пполучаем доступ к переменным MainViewController'а - и передаем им данные
        //       //если была выбрана установка времени ДО, то меняем ее и наоборот
        //       if (fromOrTill == 0)
        //       {
        //           controller.myTimeFrom = availableTime[chosenTimeIndex]
        //           //сюда же загоним проверку
        //       }
        //       else
        //       {
        //           controller.myTimeTill = availableTime[chosenTimeIndex]
        //       }
        //    let myTime = availableTime[chosenTimeIndex]
        //    print("Я только что передал по нажатию на BACK BUTTON  \(myTime)")
        //}
        
        
        //====сейчас мы просто передаем установленное время в переменные класса Модели -  Cabinet======
        //====и затем MainViewController будет обновлять интерфейс, опираясь на это время        ======
        
    //    if( Cabinet.type == false )                         /*  РЕЖИМ ПАССАЖИРА */
    //    {
    //        if (Cabinet.fromOrTill == 0)                     /* ВРЕМЯ ОТ */
    //        {
    //            //****** ПРОВЕРКА ЧТО НЕ НУЛЬ ;;;;;;;;;;;;;;
    //            if (!availableTime.isEmpty){
    //                Cabinet.passengerTimeFrom = availableTime[chosenTimeIndex]
    //            } else {
    //                Cabinet.passengerTimeFrom = "00:01"
    //            }
    //
    //
    //            //===== проверка на то, чтобы время ДО было всегда больше времени ОТ
    //            if (  !(Cabinet.passengerTimeTill>Cabinet.passengerTimeFrom)  )
    //            {
    //                Cabinet.passengerTimeTill = Cabinet.passengerTimeFrom
    //                //ToDo:   НУЖНО НАПИСАТЬ ФУНКЦИЮ ПРИБАВЛЕНИЯ 30 МИНУТ
    //            }
    //            print("Передается по нажатию на BACK BUTTON время PassangerTimeFrom  \(Cabinet.passengerTimeFrom)")
    //        }
    //        else                                    /* ВРЕМЯ ДО */
    //        {
    //            Cabinet.passengerTimeTill = availableTime[chosenTimeIndex]
    //            //===== проверка на то, чтобы время ДО было всегда больше времени ОТ
    //            if (  !(Cabinet.passengerTimeTill>Cabinet.passengerTimeFrom)  )
    //            {
    //                Cabinet.passengerTimeTill = Cabinet.passengerTimeFrom
    //                //ToDo:   НУЖНО НАПИСАТЬ ФУНКЦИЮ ПРИБАВЛЕНИЯ 30 МИНУТ
    //            }
    //            print("Передается по нажатию на BACK BUTTON время passengerTimeTill  \(Cabinet.passengerTimeTill)")
    //        }
    //    }
    //    else                                                     /*  РЕЖИМ ВОДИТЕЛЯ  */
    //    {
    //        Cabinet.driverTimeFrom  =  availableTime[chosenTimeIndex]
    //        Cabinet.driverTimeTill  =  TimeModel.plusTenMinutes (  availableTime[chosenTimeIndex]  )
    //        print("Передается по нажатию на BACK BUTTON время DriverTimeTill  \(Cabinet.driverTimeTill)")
    //    }
    //}
    //**************************************************************************************************

    
    
    
    
    

}
