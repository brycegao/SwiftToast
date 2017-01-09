//
//  ExtensionToast.swift
//  ToastPractise
//
//  Created by 高瑞 on 2017/1/8.
//  Copyright © 2017年 brycegao. All rights reserved.
//

//http://www.jianshu.com/p/3d3230d9983f

import UIKit

extension String {
    /**
     * 查询lable高度
     * @param fontSize, 字体大小
     * @param width, lable宽度
    */
    func getLableHeightByWidth(_ fontSize: CGFloat,
                               width: CGFloat,
                               font: UIFont) -> CGFloat {
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributes = [NSFontAttributeName:font,
                          NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }
    
}

extension UILabel {
    //根据最大宽度计算宽高
    func getLableSize(text: String, maxWidth: CGFloat) -> CGRect {
        let maxSize = CGSize(width: maxWidth, height: 0)   //注意高度是0
        //    size = text.boundingRectWithSize(size2, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes , context: nil);
        let size = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin,
                                     attributes: [NSFontAttributeName:self.font], context: nil)
        return size
        
    }
}

class ToastView: NSObject {
    var delay: Double = 5.0  //延迟时间
    
    var bufWindows: [UIWindow] = []    //缓存window
    
    //显示位置
    enum Position: Int {
        case Top
        case Mid
        case Bottom
    }

    //显示loading框
    func showLoadingView() {
        let rootRect = UIApplication.shared.windows.first?.frame
        //let frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        
        let container = UIView()   //父容器
        container.layer.cornerRadius = 10   //弧度
        container.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)  //半透明黑色背景
        
        //转圈
        let indicatorLength: CGFloat = 30.0   //正方形
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicatorView.frame = CGRect(x: (rootRect?.width)!/2-indicatorLength/2, y: (rootRect?.height)!/2-indicatorLength/2, width: indicatorLength, height: indicatorLength)
        indicatorView.startAnimating()
        
        container.addSubview(indicatorView)
        
        let window = UIWindow()
        window.backgroundColor = UIColor.clear   //全透明
        window.frame = rootRect!   //全屏大小
        window.windowLevel = UIWindowLevelAlert
        let rootView = (UIApplication.shared.keyWindow?.subviews.first) as UIView!
        window.center = CGPoint(x: (rootView?.center.x)!, y: (rootView?.center.y)!)
        window.isHidden = false
        window.addSubview(container)
        
        container.frame = rootRect!
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(sender:))))
        
        bufWindows.append(window)
        perform(#selector(showFinished(sender:)), with: window, afterDelay: delay)
    }
    
    //测试全屏文字、图片的loading框
    func showLoadingDlg() {
        let rootRect = UIApplication.shared.windows.first?.frame   //应用屏幕大小
        
        let container = UIView()   //全屏且透明，盖在最上面， 可以自定义点击事件， 从而实现模态和非模态框效果。
        container.backgroundColor = UIColor.clear
        container.frame = rootRect!
        
        //添加中间矩形黑色区域, 80*80
        let bgLength = 90
        let bgView = UIView()  //黑色半透明方形区域
        bgView.frame = CGRect(x: Int((rootRect?.width)!/2) - bgLength/2,
                              y: Int((rootRect?.height)!/2) - bgLength/2,
                              width: bgLength,
                              height: bgLength)
        bgView.layer.cornerRadius = 10   //黑色矩形区域的角弧度
        bgView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.8)
        
        container.addSubview(bgView)   //全屏透明背景在中心位置添加矩形黑色区域
        
        //添加圈圈
        let indicatorLength: CGFloat = 50  //黑色矩形区域里的旋转
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicatorView.frame = CGRect(x: (rootRect?.width)!/2 - indicatorLength/2,
                                     y: (rootRect?.height)!/2 - indicatorLength/2 - 10,
                                     width: indicatorLength,
                                     height: indicatorLength)
        indicatorView.startAnimating()   //动画
        
        container.addSubview(indicatorView)  //添加旋转动画view
        
        //添加文字
        let lableX = (rootRect?.width)!/2 - CGFloat(bgLength/2) + 5
        let lableY = (rootRect?.height)!/2 + indicatorLength/2 - 10
        let lableView = UILabel(frame: CGRect(x: Int(lableX),
                                              y: Int(lableY),
                                              width: bgLength-10,
                                              height: bgLength/2-Int(indicatorLength)/2-5))
        lableView.font = UIFont.systemFont(ofSize: 15)    //设置系统字体和字号
        lableView.textColor = UIColor.white
        lableView.text = "加载中"
        lableView.textAlignment = .center
        container.addSubview(lableView)
        
        //-------------测试代码-------------
        //let size = lableView.getLableSize(text: "网络异常，请稍候再试", maxWidth: 100)
        //-------------测试代码-------------
        
        
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        window.frame = rootRect!    //全屏大小
        window.center = CGPoint(x: (rootRect?.width)!/2, y: (rootRect?.height)!/2)
        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.addSubview(container)
        
        //添加点击事件
        container.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(sender:))))
        
        bufWindows.append(window)
        perform(#selector(showFinished(sender:)), with: window, afterDelay: delay)
    }
    
    //显示toast
    func showToast(text: String, pos: Position) {
        let rootRect = UIApplication.shared.windows.first?.frame   //应用屏幕大小
        
        let container = UIView()   //全屏且透明，盖在最上面， 可以自定义点击事件， 从而实现模态和非模态框效果。
        container.backgroundColor = UIColor.clear
        container.frame = rootRect!
        
        let lableView = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        lableView.font = UIFont.systemFont(ofSize: 15)
        lableView.textColor = UIColor.white
        lableView.text = text
        lableView.textAlignment = .center
        lableView.numberOfLines = 1
        
        let rect = lableView.getLableSize(text: text, maxWidth: 300)
        
        print("\(rect.width)  \(rect.height)")
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.8)
        bgView.layer.cornerRadius = 10
        var bgRect: CGRect    //黑色半透明背景
        
        switch pos {
        case .Bottom:
            lableView.frame = CGRect(x: (rootRect?.width)!/2 - rect.width/2,
                                     y: (rootRect?.height)! - rect.height - 30 ,
                                     width: rect.width,
                                     height: rect.height)
            bgRect = CGRect(x: lableView.frame.minX - 5,
                            y: lableView.frame.minY - 5,
                            width: rect.width + 10,
                            height: rect.height + 10)
        case .Mid:
            lableView.frame = CGRect(x: (rootRect?.width)!/2 - rect.width/2,
                                     y: (rootRect?.height)!/2 - rect.height/2 ,
                                     width: rect.width,
                                     height: rect.height)
            bgRect = CGRect(x: lableView.frame.minX - 5,
                            y: lableView.frame.minY - 5,
                            width: rect.width + 10,
                            height: rect.height + 10)
        case .Top:
            lableView.frame = CGRect(x: (rootRect?.width)!/2 - rect.width/2,
                                     y: 80,
                                     width: rect.width,
                                     height: rect.height)

            bgRect = CGRect(x: lableView.frame.minX - 5,
                            y: lableView.frame.minY - 5,
                            width: rect.width + 10,
                            height: rect.height + 10)
        }
        bgView.frame = bgRect
        
        container.addSubview(bgView)
        container.addSubview(lableView)  //添加lableView
        
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        window.frame = rootRect!
        window.center = container.center
        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.addSubview(container)
        
        //添加点击事件
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(sender:))))
        
        bufWindows.append(window)
        perform(#selector(showFinished(sender:)), with: window, afterDelay: delay)
    }
    
    
    //显示toast，非模态
    func showToastExt(text: String, pos: Position) {
        let rootRect = UIApplication.shared.windows.first?.frame   //应用屏幕大小
        
        let lableView = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        lableView.font = UIFont.systemFont(ofSize: 15)
        lableView.textColor = UIColor.white
        lableView.text = text
        lableView.textAlignment = .center
        lableView.numberOfLines = 1
        
        let rectLable = lableView.getLableSize(text: text, maxWidth: 300)  //行高
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.8)
        bgView.layer.cornerRadius = 10
        var bgRect: CGRect    //黑色半透明背景
        var windowRect: CGRect //window的位置
        var windowCenter: CGPoint
        
        bgRect = CGRect(x: 0, y: 0, width: rectLable.width + 10, height: rectLable.height + 10)
        switch pos {
        case .Bottom:
            windowRect = CGRect(x: (rootRect?.width)!/2 - rectLable.width/2 - 10,
                                y: (rootRect?.height)! - rectLable.height - 30,
                                width: rectLable.width + 10,
                                height: rectLable.height + 10)
            windowCenter = CGPoint(x: (rootRect?.width)!/2, y: (rootRect?.height)! - 30 - rectLable.height/2 - 5)
        case .Mid:
            windowRect = CGRect(x: (rootRect?.width)!/2 - rectLable.width/2 - 5,
                                y: (rootRect?.height)!/2 - rectLable.height/2 - 5,
                                width: rectLable.width + 10,
                                height: rectLable.height + 10)
            windowCenter = CGPoint(x: (rootRect?.width)!/2, y: (rootRect?.height)!/2)
        case .Top:
            windowRect = CGRect(x: (rootRect?.width)!/2 - rectLable.width/2 - 5,
                                y: 50,
                                width: rectLable.width + 10,
                                height: rectLable.height + 10)
            windowCenter = CGPoint(x: (rootRect?.width)!/2, y: 50 + 5 + rectLable.height/2)
        }
        bgView.frame = CGRect(x: 0,
                              y: 0,
                              width: bgRect.width + 10,
                              height: bgRect.height + 10)
        lableView.frame = CGRect(x: bgView.frame.width/2 - rectLable.width/2,
                                 y: bgView.frame.height/2 - rectLable.height/2,
                                 width: rectLable.width,
                                 height: rectLable.height)
        
        bgView.addSubview(lableView)  //添加lableView
        
        
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        window.frame = windowRect
        window.center = windowCenter
        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.addSubview(bgView)
        
        //添加点击事件
        bgView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(sender:))))
        
        bufWindows.append(window)
        perform(#selector(showFinished(sender:)), with: window, afterDelay: delay)
    }
    
    //添加点击事件
    func tapGesture(sender: UITapGestureRecognizer) {
        print("点击uiview")
        
        //移除最后一个
        if bufWindows.count > 0 {
            bufWindows.removeLast()
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    //toast超时关闭
    func showFinished(sender: AnyObject) {
        if let window = sender as? UIWindow {
            if let index = bufWindows.index(of: window) {
                bufWindows.remove(at: index)  //删除
            }
        } else {
            //do nothing
        }
    }
    

}
