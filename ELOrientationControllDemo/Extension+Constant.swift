//
//  Extension+Constant.swift
//  ELOrientationControllDemo
//
//  Created by 陈建立 on 2018/1/29.
//  Copyright © 2018年 emmet7life. All rights reserved.
//

import UIKit

// 基础视图控制器的默认配置，涵盖了跟旋转屏、present时屏幕方向和状态栏样式有关系的常用配置
let kDefaultPreferredStatusBarStyle: UIStatusBarStyle = .default // 状态栏样式，默认使用系统的
let kDefaultPrefersStatusBarHidden: Bool = false // 状态栏是否隐藏，默认不隐藏
let kDefaultShouldAutorotate: Bool = true // 是否支持屏幕旋转，默认支持
let kDefaultSupportedInterfaceOrientations: UIInterfaceOrientationMask = .portrait // 支持的旋转方向，默认竖屏
let kDefaultPreferredInterfaceOrientationForPresentation: UIInterfaceOrientation = .portrait // present时，打开视图控制器的方向，默认竖屏

extension UIInterfaceOrientation {
    var orientationMask: UIInterfaceOrientationMask {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return .all
        }
    }
}

extension UIInterfaceOrientationMask {

    var isLandscape: Bool {
        switch self {
        case .landscapeLeft, .landscapeRight, .landscape: return true
        default: return false
        }
    }

    var isPortrait: Bool {
        switch self {
        case . portrait, . portraitUpsideDown: return true
        default: return false
        }
    }

}

extension Notification {

    var keyboardAnimationCurve: UIViewAnimationCurve? {
        return userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UIViewAnimationCurve
    }

    var keyboardAnimationDuration: TimeInterval? {
        return userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval
    }

    var keyboardEndFrame: CGRect? {
        return (userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
    }

}
