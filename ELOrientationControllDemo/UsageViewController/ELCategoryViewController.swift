//
//  ELCategoryViewController.swift
//  ELOrientationControllDemo
//
//  Created by 陈建立 on 2018/1/29.
//  Copyright © 2018年 emmet7life. All rights reserved.
//

import UIKit

class ELCategoryViewController: BaseViewController {

    class func viewController(isLandscape: Bool = false) -> ELCategoryViewController {
        let categoryController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC_Category") as! ELCategoryViewController
        categoryController._isLandscape = isLandscape
        return categoryController
    }

    // 此参数由外部传入，并且在要在构造控制器时传入
    fileprivate var _isLandscape = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override var _supportedInterfaceOrientations_: UIInterfaceOrientationMask? {
        return _isLandscape ? .landscapeRight : .portrait
    }

    override var _preferredInterfaceOrientationForPresentation_: UIInterfaceOrientation? {
        return _isLandscape ? .landscapeRight : .portrait
    }

    override var _prefersStatusBarHidden_: Bool? {
        return true
    }

}
