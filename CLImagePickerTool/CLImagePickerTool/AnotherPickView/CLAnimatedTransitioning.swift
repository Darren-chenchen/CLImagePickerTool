
import UIKit

class CLAnimatedTransitioning: NSObject,UIViewControllerAnimatedTransitioning {
    
    static let share = CLAnimatedTransitioning()
    
    var presented = true
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if self.presented {
            
            // 第二个控制器
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
            toView?.cl_y = KScreenHeight
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                toView?.cl_y = KScreenHeight-280
            }, completion: { (com) in
                transitionContext.completeTransition(true)
            })
        } else {
            
            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                fromView?.cl_y = KScreenHeight
            }, completion: { (com) in
                transitionContext.completeTransition(true)
            })
        }
    }
}

