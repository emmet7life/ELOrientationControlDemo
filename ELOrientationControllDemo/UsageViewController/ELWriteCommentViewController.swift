//
//  ELWriteCommentViewController.swift
//  ELOrientationControllDemo
//
//  Created by 陈建立 on 2018/1/29.
//  Copyright © 2018年 emmet7life. All rights reserved.
//

import UIKit

class ELWriteCommentViewController: BaseViewController {

    class func viewController(isLandscape: Bool = false) -> ELWriteCommentViewController {
        let writeController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VC_WriteComment") as! ELWriteCommentViewController
        writeController._isLandscape = isLandscape
        return writeController
    }

    // MARK: - View

    // 遮罩视图
    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var commentTextFiled: UITextField!
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!

    // MARK: - Data

    // 此参数由外部传入，并且在要在构造控制器时传入
    fileprivate var _isLandscape = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Add Keyboard Hide&Show Action Notification Listener
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShowNotify(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillShowNotify(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHideNotify(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        commentTextFiled.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showMaskViewAnimate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        commentTextFiled.resignFirstResponder()
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

    // MARK: - 业务逻辑
    @IBAction func onSendCommentBtnTapped(_ sender: Any) {

        hideMaskViewAnimate()

        let loginController = ELUserLoginViewController.viewController(_isLandscape) { (isLoginSuccess) in
            print("isLoginSuccess >> \(isLoginSuccess)")
        }
        present(loginController, animated: true, completion: nil)
    }

    @IBAction func onMaskViewTapped(_ sender: Any) {
        closeController()
    }

    private func closeController() {
        hideMaskViewAnimate { [unowned self] (_) in
            self.dismiss(animated: false, completion: nil)
        }
    }

    private func showMaskViewAnimate() {

        guard maskView.alpha <= 0.0 else { return }

        maskView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.36, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.maskView.alpha = 0.36
        }, completion: nil)
    }

    private func hideMaskViewAnimate(_ completion: ((Bool) -> Void)? = nil) {
        maskView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.36, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.maskView.alpha = 0.0
        }) { (finished) in
            completion?(finished)
        }
    }

    // MARK: - 处理键盘隐藏和显示事件
    @objc private func onKeyboardWillShowNotify(_ notification: Notification) {
        if let keyboardEndFrame = notification.keyboardEndFrame {
            animateBottomConstraint(notification: notification, constant: keyboardEndFrame.height)
        }
    }

    @objc private func onKeyboardWillHideNotify(_ notification: Notification) {
        animateBottomConstraint(notification: notification)
    }

    private func animateBottomConstraint(notification: Notification, constant: CGFloat = 0.0) {
        let _duration = notification.keyboardAnimationDuration ?? 0.25
        let _curve = notification.keyboardAnimationCurve ?? .easeInOut

        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationCurve(_curve)
        UIView.setAnimationDuration(_duration)

        contentViewBottomConstraint.constant = constant
        view.layoutIfNeeded()

        UIView.commitAnimations()
    }
}
