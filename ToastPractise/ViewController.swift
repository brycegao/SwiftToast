//
//  ViewController.swift
//  ToastPractise
//
//  Created by 高瑞 on 2017/1/8.
//  Copyright © 2017年 brycegao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func clickButton1(_ sender: Any) {
        let toast = ToastView()
        toast.showLoadingView()
    }
   
    
    @IBAction func clickButton2(_ sender: Any) {
        let toast = ToastView()
        toast.showLoadingDlg()
    }
    
    @IBAction func clickButton3(_ sender: Any) {
        let toast = ToastView()
        toast.showToast(text: "网络连接异常，请稍候再试", pos: .Bottom)
    }
    
    
    @IBAction func showToastTop(_ sender: Any) {
        let toast = ToastView()
        toast.showToast(text: "您的申请已受理，请耐心等待", pos: .Top)
    }
    
    
    @IBAction func showNoModal(_ sender: Any) {
        let toast = ToastView()
        toast.showToastExt(text: "非模态toast", pos: .Bottom)

    }
    
}

