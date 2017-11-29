

import UIKit

class CoustomPresentationController: UIPresentationController {
    
    override func presentationTransitionWillBegin() {
        self.presentedView?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-280,width: UIScreen.main.bounds.width, height: 280)
        self.containerView?.backgroundColor = UIColor(white: 0, alpha: 0.2)
        self.containerView?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(clickBgView)))
        
        self.containerView?.addSubview(self.presentedView!)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        
    }
    
    @objc func clickBgView() {
        
    }
    
    override func dismissalTransitionWillBegin() {
        
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
    }
}

