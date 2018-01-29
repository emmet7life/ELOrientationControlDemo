//
//  ELDetailViewController.swift
//  ELOrientationControllDemo
//
//  Created by 陈建立 on 2018/1/29.
//  Copyright © 2018年 emmet7life. All rights reserved.
//

import UIKit

class ELDetailViewController: BaseViewController {

    @IBOutlet weak var orientationSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "详情"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    @IBAction func onStartReadBtnTapped(_ sender: Any) {
        let playerController = ELPlayerViewController.viewController(isLandscape: orientationSwitch.isOn)
        navigationController?.pushViewController(playerController, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
