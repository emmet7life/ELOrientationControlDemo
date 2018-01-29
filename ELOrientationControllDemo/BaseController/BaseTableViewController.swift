//
//  BaseTableViewController.swift
//  ELOrientationControllDemo
//
//  Created by 陈建立 on 2018/1/29.
//  Copyright © 2018年 emmet7life. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    // MARK: - 关于旋转的一些配置和说明

    // _xxx_ 系列方法，由子类自定义实现，未实现时，使用下面的默认参数
    var _preferredStatusBarStyle_: UIStatusBarStyle? { return nil }
    var _prefersStatusBarHidden_: Bool? { return nil }
    var _shouldAutorotate_: Bool? { return nil }
    var _supportedInterfaceOrientations_: UIInterfaceOrientationMask? { return nil }
    var _preferredInterfaceOrientationForPresentation_: UIInterfaceOrientation? { return nil }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let presentedController = presentedViewController, presentedController.isBeingPresented {
            return presentedController.preferredStatusBarStyle
        }
        if let presentedController = presentedViewController, presentedController.isBeingDismissed {
            return _preferredStatusBarStyle_ ?? kDefaultPreferredStatusBarStyle
        }
        if let presentedController = presentedViewController {
            return presentedController.preferredStatusBarStyle
        }
        return _preferredStatusBarStyle_ ?? kDefaultPreferredStatusBarStyle
    }

    override var prefersStatusBarHidden: Bool {
        if let presentedController = presentedViewController, presentedController.isBeingPresented {
            return presentedController.prefersStatusBarHidden
        }
        if let presentedController = presentedViewController, presentedController.isBeingDismissed {
            return _prefersStatusBarHidden_ ?? kDefaultPrefersStatusBarHidden
        }
        if let presentedController = presentedViewController {
            return presentedController.prefersStatusBarHidden
        }
        return _prefersStatusBarHidden_ ?? kDefaultPrefersStatusBarHidden
    }

    override var shouldAutorotate: Bool {
        if let presentedController = presentedViewController, presentedController.isBeingPresented {
            return presentedController.shouldAutorotate
        }
        if let presentedController = presentedViewController, presentedController.isBeingDismissed {
            return _shouldAutorotate_ ?? kDefaultShouldAutorotate
        }
        if let presentedController = presentedViewController {
            return presentedController.shouldAutorotate
        }
        return _shouldAutorotate_ ?? kDefaultShouldAutorotate
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let presentedController = presentedViewController, presentedController.isBeingPresented {
            return presentedController.supportedInterfaceOrientations
        }
        if let presentedController = presentedViewController, presentedController.isBeingDismissed {
            return _supportedInterfaceOrientations_ ?? kDefaultSupportedInterfaceOrientations
        }
        if let presentedController = presentedViewController {
            return presentedController.supportedInterfaceOrientations
        }
        return _supportedInterfaceOrientations_ ?? kDefaultSupportedInterfaceOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let presentedController = presentedViewController, presentedController.isBeingPresented {
            return presentedController.preferredInterfaceOrientationForPresentation
        }
        if let presentedController = presentedViewController, presentedController.isBeingDismissed {
            return _preferredInterfaceOrientationForPresentation_ ?? kDefaultPreferredInterfaceOrientationForPresentation
        }
        if let presentedController = presentedViewController {
            return presentedController.preferredInterfaceOrientationForPresentation
        }
        return _preferredInterfaceOrientationForPresentation_ ?? kDefaultPreferredInterfaceOrientationForPresentation
    }

}
