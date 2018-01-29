//
//  ELPlayerViewController.swift
//  ELOrientationControllDemo
//
//  Created by 陈建立 on 2018/1/29.
//  Copyright © 2018年 emmet7life. All rights reserved.
//

import UIKit

class ELPlayerViewController: BaseViewController {

    class func viewController(isLandscape: Bool = false) -> ELPlayerViewController {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC_Player") as! ELPlayerViewController
        controller._isLandscape = isLandscape
        controller.hidesBottomBarWhenPushed = true
        return controller
    }

    // 此参数由外部传入，并且在要在构造控制器时传入
    fileprivate var _isLandscape = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateOrientationIfNeeded(true)// 刚启动时，强制执行
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        updateOrientationIfNeeded()// 后续的界面间跳转，不强制执行
    }

    // MARK: - 自定义配置
    override var _prefersStatusBarHidden_: Bool? {
        return true
    }

    override var _supportedInterfaceOrientations_: UIInterfaceOrientationMask? {
        return _isLandscape ? .landscapeRight: .portrait
    }

    override var _preferredInterfaceOrientationForPresentation_: UIInterfaceOrientation? {
        return _isLandscape ? .landscapeRight: .portrait
    }

    override var isForbidInteractivePopGesture: Bool {
        return _isLandscape
    }

    // MARK: - 控制旋转
    fileprivate func updateOrientationIfNeeded(_ force: Bool = false) {
        if _isLandscape {
            toLandscapeOrientation(force)
        } else {
            toPortraitOrientation(force)
        }
    }

    fileprivate func toLandscapeOrientation(_ force: Bool = false) {
        guard force || !_isLandscape else {
            return
        }
        ELUIRotateUtils.shared.rotateToLandscape()
    }

    fileprivate func toPortraitOrientation(_ force: Bool = false) {
        guard force || _isLandscape else {
            return
        }
        ELUIRotateUtils.shared.rotateToPortrait()
    }

    // 点击菜单的 “写评论” 按钮
    @IBAction func onWriteCommentBtnTapped(_ sender: Any) {
        let writeController = ELWriteCommentViewController.viewController(isLandscape: _isLandscape)
        self.present(writeController, animated: true, completion: nil)
    }

    // 点击菜单的 “旋转” 按钮
    @IBAction func onChangeOrientationBtnTapped(_ any: Any) {
        // 核心控制
        _isLandscape = !_isLandscape
        if _isLandscape {
            toLandscapeOrientation(true)
        } else {
            toPortraitOrientation(true)
        }
    }

    // 点击菜单的 “目录” 按钮
    @IBAction func onCategoryBtnTapped(_ sender: Any) {
        let categoryController = ELCategoryViewController.viewController(isLandscape: _isLandscape)
        navigationController?.pushViewController(categoryController, animated: true)
    }

    @IBAction func onBackBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
