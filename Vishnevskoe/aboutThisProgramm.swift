//
//  aboutThisProgramm.swift
//  Vishnevskoe
//
//  Created by Chingiz Bayshurin on 07.07.16.
//  Copyright © 2016 Chingiz Bayshurin. All rights reserved.
//

import UIKit

class aboutThisProgramm: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var aboutLable: UILabel!
    
    //*************************************************************************************************************//
    //**********************  viewDidLoad *************************************************************************//
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        var aboutText:String =  "Пользуясь приложением \"Вишневое\" Вы соглашаетесь с нижеперечисленными правилами ипользования:"
        
        aboutText += "\r\r"
        
        aboutText += "Приложение \"Вишневое\" не является средством коммуникации таксистов и пассажиров, т.е не может быть средством заработка ни одной из сторон."
        
        aboutText += "\r\r"
        
        aboutText += "Правило № 1 Фиксированная стоимость проезда - 50 рублей."
        
        aboutText += "\r\r"
        
        aboutText += "Правило № 2 Что входит в эту сумму? \rВ 50 рублей гарантированно входит путь из отправного пункта ( Казань) до нового автовокзала ( Зеленодольск, Мирный), дальнейший маршрут оговаривается во время поездки."
        
        aboutText += "\r\r"
        
        aboutText += "Правило № 3 Пунктуальность. Прибывать в выбранный вами пункт отправки без опозданий!"
        
        aboutText += "\r\r"
        
        aboutText += "Правило № 4 Во время поездки просим быть доброжелательными и вежливыми к попутчикам. Беседы приветствуются при явном обоюдном одобрении."
        
        aboutText += "\r\r\r\r"
        
        aboutText += "Следующая информация несет рекомендательный характер:"
        
        aboutText += "\r\r"
        
        aboutText += "1) Отправляйте заявку заранее, так как заявки обрабатываются автоматически, и в порядке \"живой\" очереди, то больше шансов набрать пассажиров или отправиться домой у тех кто воспользовался приложением раньше."
        
        aboutText += "\r\r"
        
        aboutText += "2) Старайтесь реально оценивать свои возможности по прибытию и отправке с пункта назначения."
        
        aboutText += "\r\r"
        
        aboutText += "3) На одного приглашенного водителя , советуем пригласить трёх заинтересованных пассажиров (баланс между пассажирами и водителями нарушен)"
        
        aboutText += "\r\r"
        
        aboutText += "4) Указывайте предельно просто и понятно данные об авто, не все могут отличить марки автомобилей и сложные названия цветов ( например цвета у ВАЗа: мурена, чайная роз,мокрый асфальт и т.д)"
        
        aboutText += "\r\r"
        
        aboutText += "5) Жалобы и предложения можно отправлять на cherrydol@yandex.ru"
        
        aboutText += "\r\r"
        
        aboutText += "6) ждем всех в нашей группе vk.com/cherrydol"
        
        
        
       
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Justified
        
        let attributedString = NSAttributedString(string: aboutText,
                                                  attributes: [
                                                    NSParagraphStyleAttributeName: paragraphStyle,
                                                    NSBaselineOffsetAttributeName: NSNumber(float: 0)
            ])
        
        //let label = UILabel()
        aboutLable.attributedText = attributedString
        //aboutLable.numberOfLines = 0
        aboutLable.sizeToFit()
        
        //aboutLable.frame = CGRectMake(0, 0, 400, 400)
        
        
        //let view = UIView()
        //view.frame = CGRectMake(0, 0, 400, 400)
        //view.addSubview(aboutLable)
        
        
        
        
        
        //self.aboutLable.text = aboutText
        //aboutLable.sizeToFit()
        
        
       
        
      
       
       
        
        
        
        //--------------инициализация меню SWRevealView для открытия личного кабинета ----------------------
        if (self.revealViewController() != nil)
        {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        //--------------------------------------------------------------------------------------------------
        
        
        
    }//*************************************************************************************************************//
    //**********************  viewDidLoad *************************************************************************//
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}//=== конец функции

