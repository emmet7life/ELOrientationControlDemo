# ELOrientationControlDemo
### Control your View Controller`s Orientation, whatever present it or push it by UINavigationController.
### 精准控制各个视图控制器的横竖屏方向，无论你是想present以模态视图的形式弹出，还是在导航控制器中push进去。

[私有API]: http://blog.sunnyxx.com/2015/06/07/fullscreen-pop-gesture "孙源同学解释了\`关于私有API\`的解释"
[孙源微博]: https://weibo.com/u/1364395395?is_all=1
[唐巧博客]: http://blog.devtang.com/
[唐巧_转场动画]: http://blog.devtang.com/2016/03/13/iOS-transition-guide/
[我的微博]: https://weibo.com/2012246061/profile?topnav=1&wvr=6
[抓狂]: https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1852892277,1770843990&fm=200&gp=0.jpg
[UIViewController]: https://developer.apple.com/documentation/uikit/uiviewcontroller

##### __本文基于 Swift 3.x，由于 Swift 4.x 在语法规则上有较大变动，后续出一个 Swift 4.x 版本__

### 前言

我相信iOS的屏幕旋转问题一直困扰着大多数的APP开发者，遇到界面需要旋转，特别是界面之间的关联性很强，几个视图控制器又是Push又是Present，然后又交叉Push、Present...说到这里，脑海里就浮现出未找到解决方案时，想拍案而起抓狂的场景。


![][抓狂]

### 案例场景
![场景案例图示.png](http://upload-images.jianshu.io/upload_images/887887-e54ef874bb0097c8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

图有点大，可以打开一个新标签放大查看，我们项目APP的一个大概的结构图，主要指示了一下涉及到旋转屏的视图控制器，以及各个控制器之间的关系，是Push出来的还是Present出来的。

简单描述一下场景：

1. 主视图控制器是一个继承自 *UITabBarController* 的视图控制器。
2. 底部有四个Tab，四个Tab分别指向继承自 *UINavigationController* 的视图控制器作为根视图。
3. 通常情况下，都是竖屏，四个Tab的部分界面中都有跳播放器视图控制器的入口。
4. 进播放器时，有两种方式进入，*竖屏* or *横屏*。
5. 第一次是默认竖屏，之后进入时，由用户最后退出播放器时的阅读方向来决定。
6. 播放器中有四个菜单和一个评论输入框。
7. 点击 *评论输入框*，弹出一个可输入评论的视图控制器，以 *present* 的形式弹出，会覆盖在播放器之上，并且能看到后面的播放器内容。方向与当前阅读器的方向一致。
8. 点击 *目录*，以 *push* 的方式打开目录页。目录页方向与播放器方向一致。(之前的需求是目录页要以竖屏的方式出现，当然，这个也可以实现，下面会说解决方案)
9. 点击 *旋转* 菜单，切换播放器方向，*竖屏* -> *横屏*，or *横屏* -> *竖屏*。
10. 用户在输入评论之后，点击右边或者键盘的的 *发送* 按钮，会先判断当前用户的登录状态，如果未登录或者登录信息失效，会 *present* 一个 **竖屏** 的 *登录界面*。
11. *登录界面* 同样包装在一个 *UINavigationController* 之中，用户未注册时还可以 *push* 到一个 *注册* 界面，同样也是竖屏，第三方登录方式有 *微信*，*QQ*，*微博* 等。
12. 播放器可以被外部APP调起，诸如 *Safari浏览器* 或者 *QQ浏览器*。（为什么要说到这一点，是因为当用在在这些外部APP中调起播放器时，用户手持手机的方向会直接影响到调起之后，播放器的方向，处理不好的话就会错乱，比如之前播放器时横屏，从外部APP调起时，手机又是竖屏。）


### 了解一点基础知识

在讲解我的处理方案之前，我想先跟大家介绍一下Apple的官方文档关于旋转屏时的处理机制。
在Apple Documentation 中 关于 [UIViewController][] 的介绍中，简要提到过旋转屏时，UIKit会干一些什么事以及你该怎么处理。我提取其中的部分简单翻译了一下。如下：

> Handling View Rotations
>
> As of iOS 8, all rotation-related methods are deprecated. Instead, rotations are treated as a change in the size of the view controller’s view and are therefore reported using the viewWillTransition(to:with:) method. When the interface orientation changes, UIKit calls this method on the window’s root view controller. That view controller then notifies its child view controllers, propagating the message throughout the view controller hierarchy.
>
> *从iOS8开始，所有旋转相关的方法都被废弃。旋转被视为是视图控制器的view的大小的改变并在viewWillTransition(to:with:) 方法中反馈给视图控制器。当界面方向发生改变，UIKit会在窗口的根视图控制器中调用此方法，然后根视图控制器再通知它所管理的其他子视图控制器。此消息将在整个视图控制器栈中传播贯穿。*
> 
> In iOS 6 and iOS 7, your app supports the interface orientations defined in your app’s Info.plist file.
> 
> *在iOS6和iOS7中，你的程序所支持的界面方向由程序的info.plist文件中定义的参数决定。*
> 
> A view controller can override the supportedInterfaceOrientationsmethod to limit the list of supported orientations.Typically, the system calls this method only on the root view controller of the window or a view controller presented to fill the entire screen; 
> 
> *一个视图可以通过重写 supportedInterfaceOrientations 来控制支持的方向。通常情况下，系统只在window的rootViewController和一个充满全屏的模态(presented view controller)视图中调用此方法。*
>
> child view controllers use the portion of the window provided for them by their parent view controller and no longer participate directly in decisions about what rotations are supported. 
> 
> *子视图不直接参与旋转方向的决策，直接由它们的父视图决定。*
> 
> The intersection of the app's orientation mask and the view controller's orientation mask is used to determine which orientations a view controller can be rotated into.
> 
> *程序支持的方向和视图控制器支持的方向的交集被用来决定视图控制器应该旋转到哪个方向。*
> 
> You can override the preferredInterfaceOrientationForPresentation for a view controller that is intended to be presented full screen in a specific orientation.
> 
> *你可以为一个准备present成一个全屏的模态视图控制器通过重写 preferredInterfaceOrientationForPresentation 来指定特定的方向。*
>
> When a rotation occurs for a visible view controller, the willRotate(to:duration:), willAnimateRotation(to:duration:), and didRotate(from:) methods are called during the rotation. The viewWillLayoutSubviews() method is also called after the view is resized and positioned by its parent. If a view controller is not visible when an orientation change occurs, then the rotation methods are never called. However, the viewWillLayoutSubviews() method is called when the view becomes visible. Your implementation of this method can call the statusBarOrientation method to determine the device orientation.
> 
> *对于一个可见的视图控制器，当旋转发生时，这些方法willRotate(to:duration:), willAnimateRotation(to:duration:), 和 didRotate(from:) 会在旋转过程中被调用，当视图控制器的view被重新拉伸并被父视图定位完成时，viewWillLayoutSubviews() 将被调用。如果一个视图控制器在旋转过程中处于不可见状态，那么上面提到的三个方法不会被调用。然而，在视图重新可见时，viewWillLayoutSubviews() 会被调用。你可以重写此方法并在该方法中调用 statusBarOrientation 方法来决定设备的方向。*
>
> > Note
> > 
> At launch time, apps should always set up their interface in a portrait orientation. After the application(_:didFinishLaunchingWithOptions:) method returns, the app uses the view controller rotation mechanism described above to rotate the views to the appropriate orientation prior to showing the window.
> >
> > *注意*
> >
> *在程序应该在启动时保持竖屏，等到application(_:didFinishLaunchingWithOptions:) 方法返回之后，程序再使用上面提到过的旋转机制来合理的处理窗口视图的旋转。*
>
>  **额外说一下 *statusBarOrientation* 这个属性：**
> 
> The value of this property is a constant that indicates an orientation of the receiver's status bar. See UIInterfaceOrientation for details. Setting this property rotates the status bar to the specified orientation without animating the transition. If your app has rotatable window content, however, you should not arbitrarily set status-bar orientation using this method. The status-bar orientation set by this method does not change if the device changes orientation. For more on rotatable window views, see View Controller Programming Guide for iOS.
> 
> 1. *通过 `UIApplication.shared.statusBarOrientation` 获取和设置，还有另外一个方法来设置这个属性的值，可以传递动画与否的参数，`UIApplication.shared.setStatusBarOrientation(:, animated: )`,直接设置这个属性值，相当于调用了该方法时传入了 `animated: false`,即不使用任何动画形式来改变状态栏的方向。*
> 2. *如果你的程序中的某个视图控制器的界面是可旋转的，那么你不应该随意的去设置这个属性，意图改变状态栏的方向，因为这将可能无效。（我就曾遇到过，逻辑都是从另外一个项目中照搬过来的，但是调用此方法时，死活不改变方向。当然，这跟你是否正确的返回 `shouldAutorotate`有关系，下面会讲到。）*
> 3. *作为总结，如果你的当前视图控制器的 `shouldAutorotate`返回 `true`,则尽量不要再去调用 `UIApplication.shared.statusBarOrientation` 了, 一是可能无效，二是 `statusBarOrientation`的方向会随着你返回的`supportedInterfaceOrientation` 改变而自动改变。*


### 正题

按照官方的说法，我打算一步一步的告诉大家，如何配置，如何编写代码，从最根部，到最外层。

1. 首先，配置程序的info.plist配置文件，只勾选竖屏，这样可以保证竖屏启动界面 (即 *LaunchScreen.storyboard* 配置的程序默认启动界面在任何情况下都竖屏启动)。
   ![程序Info.plist的配置](http://upload-images.jianshu.io/upload_images/887887-223d7f0db54068ce.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
2. 在 `AppDelegate` 中的配置：
   
		@UIApplicationMain
		class AppDelegate: UIResponder, UIApplicationDelegate {
   			...
			func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
				return .allButUpsideDown
    		}
    		...
		}
		
	* 当然，如果你的程序支持 iPad ，可以返回 `.all` 来支持所有的方向。
	* 一般情况下，返回 `.allButUpsideDown` 就够了。
	* 前面讲到过，`UIKit` 会取视图控制器返回的值和当前返回的值，做一个交叉，取交叉值，所有这里返回最大范围的支持方向。
3. 自定义五个基类，分别是：
	* `BaseTabBarController`,继承自 `UITabBarControlelr`
	* `BaseNavViewController`,继承自 `UINavigationController`
	* `BaseViewController`,继承自 `UIViewController`
	* `BaseTableViewController`,继承自 `UITableViewController`
	* `BaseCollectionViewController`,继承自 `UICollectionViewController`
	
	这五个基类基本上覆盖了程序的大部分需要的视图控制器，如果您的程序中还有其他类型的视图控制器，照着下面我所描述的原理，配置一下即可。
	
	* 先写上一个 swift 文件，为程序配置几个默认配置的属性，供全局使用，并配置一些相关拓展，下面会用到。

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
			
4. 再来添加另外一个 swift 文件，起名 `UIViewController+Extension.swift`, 为 `UIViewController` 添加一些通用配置。

		extension UIViewController {
		
			// 是否禁用导航栏的左滑手势，默认不禁用
	    	var isForbidInteractivePopGesture: Bool {
	        	return false
			}
			
		}
  额呵，只有这么一个简单的配置，为的是在播放器处于横屏时，禁用导航控制器的左滑返回手势，竖屏时正常可用。
	
  **为什么要禁用！！！<br>
  因为上一个界面是竖屏！！而播放器也是被 Push 进来的。so！要么禁用，要么一触发滑动，界面就立刻关闭了，体验不好。**
	
5. 配置 `BaseTabBarController `:

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
 BaseTabBarController 作为根视图，需要把参数传递给它的子视图。
 > 注意：上面的代码，重写 `supportedInterfaceOrientations` 时，也取了 `preferredInterfaceOrientationForPresentation` 的值并做了一个转换，之所以这么处理，是因为很多情况下，我们会无意间返回与 `supportedInterfaceOrientations` 不一致的方向，导致这种错误：
 > > UIApplicationInvalidInterfaceOrientation: preferredInterfaceOrientationForPresentation 'landscapeRight' must match a supported interface orientation: 'portrait'!
 >
 > 可以看出，系统要求我们返回的 `supportedInterfaceOrientations` 与 `preferredInterfaceOrientationForPresentation` 至少要有可交叉的值，`UIInterfaceOrientation` 只能定义一个值，`UIInterfaceOrientationMask` 支持 `OptionSet` 协议 可返回一个数组，因此可以是多个值，所以可做如上处理，避免你没有重写 `preferredInterfaceOrientationForPresentation` 由系统返回的默认值 或者 你重写了，但是由于代码逻辑错误，返回了一个与 `supportedInterfaceOrientations` 方向不一致的值。
5. 配置 `BaseNavViewController`:

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

	这里这么多代码，其实都是一个处理逻辑，原则如下：
	
	**如果你不了解导航控制器的 `topViewController ` 、`visibleViewController ` 、视图控制器的 `presentedViewController ` 、`presentingViewController ` 是什么概念，那么建议百度 or Google 一下再看下面的内容，这里就不做普及了，以免篇幅过长。**
	
	1. 判断导航控制器栈顶的视图控制器 `topViewController` 是否有 `presentedViewController`，如果有，并且正在被 present 当中，则优先使用该 `presentedViewController` 的配置参数。
	2. 判断导航控制器栈顶的视图控制器 `topViewController` 是否有 `presentedViewController`，如果有，并且正在被 dismiss 当中，则优先使用该 `topViewController` 的配置参数。
	3. 剩下的是默认配置，不再判断有没有 `presentedViewController` ,也不再判断 `presentedViewController` 的状态，由系统决定。是使用 `presentedViewController` 还是使用 `topViewController `。
	4. 左滑返回手势是否开启由两个原则，一是如果视图控制器返回的 `isForbidInteractivePopGesture` 为 `true` 时禁用，二是 默认判断 视图控制器的堆栈中视图控制器的数量，大于 1 时可用。

5. 两大容器类型的视图控制器重写完了，接下来我们来写其他三个。
6. 配置 `BaseViewController`:

		class BaseViewController: UIViewController {
			
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


	又是一堆代码... 真的不想贴这么多，但是有些人就知道复制黏贴...怕大家漏写又来一通问，一通骂，怎么不行呀！片纸!!!!片纸!!!! ...，下面还是说一下处理逻辑：

	1. 如果存在 `presentedViewController` ，并且正在被 `present`，则优先使用 `presentedViewController` 的配置参数。
	2. 如果存在 `presentedViewController` ，并且正在被 `dismiss`，则优先使用当前控制器的参数配置，如果子类没有重写对应的系列 `_xxx_` 方法，则使用默认参数。
	3. 如果存在 `presentedViewController` （说明它当前正在被显示），则优先使用 `presentedViewController` 的配置参数。
	4. 最后，使用子类自定义(如果子类有重写对应的系列 `_xxx_` 方法)或默认配置。
7. 配置 `BaseTableViewController`:
	
		class BaseTableViewController: UITableViewControlelr {
			
			// 和 BaseViewController 中一模一样的代码，直接黏贴过来即可。
		
		}
8. 配置 `BaseCollectionViewController`:
	
		class BaseTableViewController: UITableViewControlelr {
			
			// 和 BaseViewController 中一模一样的代码，直接黏贴过来即可。
		
		}
9. 五大基础类重写完毕，在介绍具体的使用场景之前，需要再写一个类，拿来控制旋转方向的，其实就是调用 `UIDevice.current.setValue(UIInterfaceOrientation.xxx.rawValue: forKey:"orientation")` 来设置方向的，因为这个方法涉及到了`运行时`、`kvc`等黑魔法概念，所以我做了一个包装，其实最终的结果还是 `kvc`，只是不那么明显而已，有点自娱自乐的 style 😓，关于 私有API，[孙源][孙源微博] 大大这他的 [这篇文章][私有API] 中，说过他的理解，感兴趣的朋友可以去看看。下面直接贴代码：

		// MARK: - 专门负责旋转屏的工具类
		class UIRotateUtils {
		
			static let shared = UIRotateUtils()
				
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
	**有一点需要注意的是，设置实际所需方向之前，需要先设置一次方向为 `unknown`, 因为可能会出现意外情况，导致你设置指定方向时，当前的设备方向已经就是这个方向了，UIKit就不会触发相关事件，并不会重绘界面，进而导致调用无效的情况。**
10. 播放器视图控制器 `PlayerViewController`:

		class PlayerViewController: BaseViewController {
		
			// 此参数由外部传入，并且在要在构造控制器时传入
			fileprivate var _isLandscape = false
			
			init(isLandscape: Bool = false) {
				...
				_isLandscape = isLandscape
				...
			}
			
			override func viewDidLoad() {
				super.viewDidLoad()
				updateOrientationIfNeeded(true)// 刚启动时，强制执行
			}
			
			override func viewWillAppear(_ animated: Bool) {
				super.viewWillAppear(animated)
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
				UIRotateUtils.shared.rotateToLandscape()
			}
				
			fileprivate func toPortraitOrientation(_ force: Bool = false) {
				guard force || _isLandscape else {
				    return
				}
				UIRotateUtils.shared.rotateToPortrait()
			}
			
			// 点击菜单的 “旋转” 按钮
			@objc fileprivate func onChangeOrientationBtnTapped(_ any: Any?) {
				...
				...
				
				// 核心控制
				_isLandscape = !_isLandscape
				if _isLandscape {
					toLandscapeOrientation(true)
				} else {
					toPortraitOrientation(true)
				}
				
				...
				...
			}
		
		}
	
	播放器大概的配置就这些，也很简单，主要的注意点在于：
	
	1. 控制好变量 `_isLandscape` 的传入时机，一定要在视图控制器进入之前传入，建议是构造视图控制器时就传入。
	2. `viewDidLoad` 和 `viewWillAppear` 都执行 `updateOrientationIfNeeded` 方法。
	3. 通过 `_isLandscape` 控制 `_supportedInterfaceOrientations_` 和 `_preferredInterfaceOrientationForPresentation_` 的返回值。

11. 评论输入框界面 `WriteCommentViewController`:
	
	*场景案例* 中提到过，一般这种界面像是悬浮在上一个界面之上，存在半透明的界面部分，可以看到上一界面的视图，而且，在不重写转场动画的情况下，一般使用 `present` 的形式，以模态视图的形式呈现。更多关于 **[转场动画][唐巧_转场动画]** 的相关知识，请看 [唐巧][唐巧博客] 大大的 [这篇文章][唐巧_转场动画] ，你一定会收益匪浅。
	
		class WriteCommentViewController: BaseViewController {
		
			// 此参数由外部传入，并且在要在构造控制器时传入
			fileprivate var _isLandscape = false
			
			init(isLandscape: Bool = false) {
				...
				_isLandscape = isLandscape
			   modalPresentationStyle = .overFullScreen
			   modalTransitionStyle = .crossDissolve
				...
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
	
	基础配置和 `PlayerViewController` 差不多，需要注意的一点是：
	
	1. 因为界面是 `present` 出来的，并且不自定义转场动画时，需要配置 `modalPresentationStyle` 和 `modalTransitionStyle`，转场样式可以自己指定，`modalPresentationStyle	` 目前我没有使用 `.custom` 模式，使用 `overFullScreen` 问题相对少一点。
	2. 如果你的界面中也存在需要半透明或者透明度的部分，则需要把视图控制器的 `view` 的 `backgroundColor` 设置成透明，然后自己加一层黑色背景的控件，用一个 `alpha` 动画渐变到小于1.0的某个值。
12. 目录 `CategoryViewController`: 

		class CategoryViewController: BaseViewController {
		
			// 此参数由外部传入，并且在要在构造控制器时传入
			fileprivate var _isLandscape = false
			
			init(isLandscape: Bool = false) {
				...
				_isLandscape = isLandscape
				...
			}
			
			override var _supportedInterfaceOrientations_: UIInterfaceOrientationMask? {
				return _isLandscape ? .landscapeRight : .portrait
			}
				
			override var _preferredInterfaceOrientationForPresentation_: UIInterfaceOrientation? {
			    return _isLandscape ? .landscapeRight : .portrait
			}
	    
	    }
	    
	基本和上面的两个类的配置一致。
13. 登录 `UserLoginViewController`:

	*场景案例* 中描述过，*登录* 界面是被 `present` 出来的，并且还能 `push` 到 *注册* 界面，因此 *登录* 界面是被包裹在 *导航控制器* 中的。
	
		class UserLoginViewController: BaseTableViewController {
		
			// 标识登录界面被 present 打开时，上一个界面(播放器)是不是处于横屏状态
			fileprivate var _isPreViewControllerAtLandscapeMode = false
			
			filepriate var _loginActionResultBlock: ((Bool) -> Void)? = nil
		
			// 外部调用方式：
			// presentingViewController.present(UserLoginViewController.viewController(_isLandscape, animated: true)
			// 
			class func viewController(_ isPreViewControllerAtLandscapeMode: Bool = false, loginActionResultBlock: ((Bool) -> Void)? = nil, ...) -> BaseNavViewController {
				// 构建登录视图控制器的方式，自定，一般都是通过StoryBoard来布局。
				let loginController = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "Login_VC") as! UserLoginViewController
				loginController._isPreViewControllerAtLandscapeMode = isPreViewControllerAtLandscapeMode
				loginController._loginActionResultBlock = loginActionResultBlock
				...
				...
				// 包装到BaseNavViewController中去
				let nav = BaseNavViewController(rootViewController: loginController)
				nav.modalPresentationStyle = .fullScreen
				nav.modalTransitionStyle = .coverVertical
				return nav
			}
			
			...
			...
			
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
					UIRotateUtils.shared.rotateToLandscape()
				}
				dismiss(animated: true) { [weak self] _ in
					self?._loginActionResultBlock?(isLoginSuccess)
				}
			}
			
			...
			...
		
		}
		
	基本配置就这些，至于 *注册* 界面想支持什么类型的方向，可以随意定制。因为五个基础类已经做了大部分的工作，如果想支持特定方向，就需要自己重写几个 `_xxx_` 系列方法来自定义了，默认只支持竖屏。
	
	> 需要注意的是包装 *登录* 界面的导航控制器的 `modalPresentationStyle` 和 `modalTransitionStyle` 的配置。`modalPresentationStyle` 一定设置成 `.fullScreen`, 不过这个是系统默认设置，这里只是保险起见。`modalTransitionStyle` 一般情况下，*登录* 界面都是以 `.coverVertical` 的形式出现的。

----

### 最后

最后的最后，做一个简单的总结。

1. 五个跟旋转屏，状态栏样式有关系的属性，从根视图控制器一路传到最顶级视图。分别是：
	* prefersStatusBarHidden
	* preferredStatusBarStyle
	* shouldAutorotate
	* supportedInterfaceOrientations
	* preferredInterfaceOrientationForPresentation
2. 确保返回的 `supportedInterfaceOrientations` 的相关值总类型 *包含于* `preferredInterfaceOrientationForPresentation` 返回的对应类型值。
3. 处理好 `UINavigationController` 中的上述五个属性，理清 `topViewController` `visibleViewController` 以及 被 `present`出来的模态视图控制器的 `isBeingPresented` 和 `isBeingDismissed` 属性的含义。
4. 处理好 *基础视图控制器* 中的 `presentedViewController` 及 理清其对应的 `isBeingPresented` 和 `isBeingDismissed` 属性的含义。
5. 【一个很重要的点忘记提及了】键盘弹出的布局方向和视图控制器返回的supportedInterfaceOrientation是一致的，与你的状态栏方向无关。

### Happy 2018. Happy New Year!

有问题请在简书中发送私信或者关注我的个人 [微博][我的微博]，给我留言。谢谢关注，如果您有更多的想法，请联系互相交流。

-----

	
TODO_List:

1. 第三方APP调起时的相关配置稍后补上。

