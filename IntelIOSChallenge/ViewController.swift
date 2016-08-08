//
//  ViewController.swift
//  IntelIOSChallenge
//
//  Created by Matej Decky on 08.08.16.
//  Copyright © 2016 Inloop, s.r.o. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let request = APIService.volumes("apple") { (result) in
            print(result)
        }
//        can cancel request
//        request.cancel()
        
        
        let books = APIService.volumes("apple")
        print(books)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

