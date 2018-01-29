//
//  ELUserLoginViewController.swift
//  ELOrientationControllDemo
//
//  Created by 陈建立 on 2018/1/29.
//  Copyright © 2018年 emmet7life. All rights reserved.
//

import UIKit

class ELUserLoginViewController: BaseTableViewController {

    // 标识登录界面被 present 打开时，上一个界面(播放器)是不是处于横屏状态
    fileprivate var _isPreViewControllerAtLandscapeMode = false

    fileprivate var _loginActionResultBlock: ((Bool) -> Void)? = nil

    // 外部调用方式：
    // presentingViewController.present(UserLoginViewController.viewController(_isLandscape, animated: true)
    //
    class func viewController(_ isPreViewControllerAtLandscapeMode: Bool = false, loginActionResultBlock: ((Bool) -> Void)? = nil) -> BaseNavViewController {
        // 构建登录视图控制器的方式，自定，一般都是通过StoryBoard来布局。
        let loginController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC_Login") as! ELUserLoginViewController
        loginController._isPreViewControllerAtLandscapeMode = isPreViewControllerAtLandscapeMode
        loginController._loginActionResultBlock = loginActionResultBlock
        // 包装到BaseNavViewController中去
        let nav = BaseNavViewController(rootViewController: loginController)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .coverVertical
        return nav
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

    }

    override var _supportedInterfaceOrientations_: UIInterfaceOrientationMask? {
        return .portrait // 竖屏
    }

    override var _preferredInterfaceOrientationForPresentation_: UIInterfaceOrientation? {
        return .portrait // 竖屏
    }

    override var _preferredStatusBarStyle_: UIStatusBarStyle? {
        return .lightContent // 返回你自己需要的状态栏样式
    }

    // 关闭登录界面(不管在登录界面中是否调到了别的界面，注意，一定是返回到登录界面之后，再统一关闭，因为这里需要额外处理一下)
    fileprivate func closeController(_ isLoginSuccess: Bool) {
        // 关闭界面之前，处理一下旋转问题
        if _isPreViewControllerAtLandscapeMode {
            ELUIRotateUtils.shared.rotateToLandscape()
        }
        dismiss(animated: true) { [weak self] _ in
            self?._loginActionResultBlock?(isLoginSuccess)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    @IBAction func onBackBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
