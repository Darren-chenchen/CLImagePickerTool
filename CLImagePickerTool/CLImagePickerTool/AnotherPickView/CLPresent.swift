
import UIKit

class CLPresent: NSObject,UIViewControllerTransitioningDelegate {
    
    static let instance = CLPresent()
    
    var customPresent: CoustomPresentationController?
    
    let animation = CLAnimatedTransitioning.share
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        self.customPresent = CoustomPresentationController.init(presentedViewController: presented,presenting: presenting)
        return self.customPresent
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animation.presented = true
        return animation
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animation.presented = false
        return animation
    }
}

