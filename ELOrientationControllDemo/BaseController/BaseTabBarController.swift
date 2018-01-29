//
//  BaseTabBarController.swift
//  ELOrientationControllDemo
//
//  Created by 陈建立 on 2018/1/29.
//  Copyright © 2018年 emmet7life. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {

    override var prefersStatusBarHidden: Bool {
        return selectedViewController?.prefersStatusBarHidden ?? kDefaultPrefersStatusBarHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return selectedViewController?.preferredStatusBarStyle ?? kDefaultPreferredStatusBarStyle
    }

    override var shouldAutorotate: Bool {
        return selectedViewController?.shouldAutorotate ?? kDefaultShouldAutorotate
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [selectedViewController?.supportedInterfaceOrientations ?? kDefaultSupportedInterfaceOrientations, preferredInterfaceOrientationForPresentation.orientationMask]
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return selectedViewController?.preferredInterfaceOrientationForPresentation ?? kDefaultPreferredInterfaceOrientationForPresentation
    }

}
