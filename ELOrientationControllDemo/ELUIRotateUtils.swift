//
//  ELUIRotateUtils.swift
//  ELOrientationControllDemo
//
//  Created by 陈建立 on 2018/1/29.
//  Copyright © 2018年 emmet7life. All rights reserved.
//

import UIKit

// MARK: - 专门负责旋转屏的工具类
class ELUIRotateUtils {

    static let shared = ELUIRotateUtils()

    private var appOrientation: UIDevice {
        return UIDevice.current
    }

    /// 方向枚举
    enum Orientation {

        case portrait
        case portraitUpsideDown
        case landscapeRight
        case landscapeLeft
        case unknown

        var mapRawValue: Int {
            switch self {
            case .portrait: return UIInterfaceOrientation.portrait.rawValue
            case .portraitUpsideDown: return UIInterfaceOrientation.portraitUpsideDown.rawValue
            case .landscapeRight: return UIInterfaceOrientation.landscapeRight.rawValue
            case .landscapeLeft: return UIInterfaceOrientation.landscapeLeft.rawValue
            case .unknown: return UIInterfaceOrientation.unknown.rawValue
            }
        }

    }

    private let unicodes: [UInt8] =
        [
            111,// o -> 0
            105,// i -> 1
            101,// e -> 2
            116,// t -> 3
            114,// r -> 4
            110,// n -> 5
            97  // a -> 6
    ]

    private lazy var key: String = {
        return [
            self.unicodes[0],// o
            self.unicodes[4],// r
            self.unicodes[1],// i
            self.unicodes[2],// e
            self.unicodes[5],// n
            self.unicodes[3],// t
            self.unicodes[6],// a
            self.unicodes[3],// t
            self.unicodes[1],// i
            self.unicodes[0],// o
            self.unicodes[5] // n
            ].map {
                return String(Character(Unicode.Scalar ($0)))
            }.joined(separator: "")
    }()

    /// 旋转到竖屏
    ///
    /// - Parameter orientation: 方向枚举
    func rotateToPortrait(_ orientation: Orientation = .portrait) {
        rotate(to: orientation)
    }

    /// 旋转到横屏
    ///
    /// - Parameter orientation: 方向枚举
    func rotateToLandscape(_ orientation: Orientation = .landscapeRight) {
        rotate(to: orientation)
    }

    /// 旋转到指定方向
    ///
    /// - Parameter orientation: 方向枚举
    func rotate(to orientation: Orientation) {
        appOrientation.setValue(Orientation.unknown.mapRawValue, forKey: key) // 👈 需要先设置成 unknown 哟
        appOrientation.setValue(orientation.mapRawValue, forKey: key)
    }
}
