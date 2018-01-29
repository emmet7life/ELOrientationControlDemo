//
//  BaseNavViewController.swift
//  ELOrientationControllDemo
//
//  Created by 陈建立 on 2018/1/29.
//  Copyright © 2018年 emmet7life. All rights reserved.
//

import UIKit

class BaseNavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self // 切记不要放在构造方法中配置，因为那时的 interactivePopGestureRecognizer 可能是 nil
    }

    override var shouldAutorotate: Bool {
        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingPresented {
            return presentedViewController?.shouldAutorotate ?? kDefaultShouldAutorotate
        }

        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingDismissed {
            return topViewController?.shouldAutorotate ?? kDefaultShouldAutorotate
        }

        return visibleViewController?.shouldAutorotate ?? kDefaultShouldAutorotate
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingPresented {
            return presentedViewController?.supportedInterfaceOrientations ?? kDefaultSupportedInterfaceOrientations
        }

        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingDismissed {
            return topViewController?.supportedInterfaceOrientations ?? kDefaultSupportedInterfaceOrientations
        }

        return visibleViewController?.supportedInterfaceOrientations ?? kDefaultSupportedInterfaceOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingPresented {
            return presentedViewController?.preferredInterfaceOrientationForPresentation ?? kDefaultPreferredInterfaceOrientationForPresentation
        }

        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingDismissed {
            return topViewController?.preferredInterfaceOrientationForPresentation ?? kDefaultPreferredInterfaceOrientationForPresentation
        }

        return visibleViewController?.preferredInterfaceOrientationForPresentation ?? kDefaultPreferredInterfaceOrientationForPresentation
    }

    override var prefersStatusBarHidden: Bool {
        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingPresented {
            return presentedViewController?.prefersStatusBarHidden ?? kDefaultPrefersStatusBarHidden
        }

        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingDismissed {
            return topViewController?.prefersStatusBarHidden ?? kDefaultPrefersStatusBarHidden
        }

        return visibleViewController?.prefersStatusBarHidden ?? kDefaultPrefersStatusBarHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingPresented {
            return presentedViewController?.preferredStatusBarStyle ?? kDefaultPreferredStatusBarStyle
        }

        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingDismissed {
            return topViewController?.preferredStatusBarStyle ?? kDefaultPreferredStatusBarStyle
        }

        return visibleViewController?.preferredStatusBarStyle ?? kDefaultPreferredStatusBarStyle
    }

}

extension BaseNavViewController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let controller = topViewController, controller.isForbidInteractivePopGesture {
            return false // 播放器处于横屏时，禁用左滑手势
        }
        return viewControllers.count > 1
    }

}
