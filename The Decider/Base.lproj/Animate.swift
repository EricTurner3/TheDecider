import Foundation


/*
 A starter animation library for swift.
 These abstractions make it easier to chain multiple behaviors (eg: anticpate, then slam, then fade)
 because you can use them as single liners and reason only about the actions.
 Usage:
 Animate.show.bySpringing.fromAbove(alert)
 Example Complex Usage:
 // 1.
 Animate.slam.right(startingStep) {
 // 2.
 Animate.show.byGrowing.right(spanningLine) {
 // 3.
 Animate.absorb.right(endingStep)
 // 4.
 Timing.delayBy(Animate.transitionSpeed.fast.rawValue, fn: updateFillColors)
 // 5.
 Timing.delayBy(Animate.transitionSpeed.normal.rawValue) {
 Animate.hide.byShrinking.right(spanningLine)
 }
 }
 }
 Behaviors:
 Animate.shimmer     // A persistent shimmer animation
 Animate.hide
 .byShrinking      // Collapse width or height to 0
 .bySliding        // A smooth, mechanical animation
 .bySpringing      // A physical, springing force animation
 Animate.absorb      // Gently absorb and react to a force
 Animate.slam        // "slamming" animations include anticipation.
 // A Slam right, for example, slowly pulls left, then springs right energetically,
 //   bouncing against an invisible wall at its identity location.
 */

class Animate {
    
    enum transitionSpeed: TimeInterval {
        case fast = 0.15
        case normal = 0.3
        case slow = 0.5
        case glacial = 1.5
    }
    
    enum animationSpeed: TimeInterval {
        case fast = 0.5
        case normal = 1.5
        case slow = 4
    }
    
    // Spring animations take longer to settle. As a result, longer times are needed for similar visual appearance of speed
    enum springSpeed: TimeInterval {
        case fast   = 0.23
        case normal = 0.45
        case slow   = 0.75
    }
    
    class cfg {
        static var damping:CGFloat = 0.6
        static var initialVelocity: CGFloat = 1
        static var shimmerTransparency: CGFloat = 0.6 // a smaller number is more transparent (and dramatic)
        static var growAmount:CGFloat = 1.1
    }
    
    static func clear(_ view: UIView?) {
        guard let view = view else { return }
        UIView.animate(withDuration: 0) { view.transform = CGAffineTransform.identity }
        view.layer.removeAllAnimations()
    }
    
    static func breathe(_ view: UIView, completion: (()->())? = nil) {
        view.transform = CGAffineTransform.identity
        UIView.animate(withDuration: animationSpeed.normal.rawValue, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            view.transform = CGAffineTransform(scaleX: Animate.cfg.growAmount, y: Animate.cfg.growAmount)
        }, completion: { finished in
            view.transform = CGAffineTransform.identity
            completion?()
        })
    }
    
    
    
    // ------------------------------------------------------ MARK: repeating animations
    
    /// Add a persistent shimmer animation. Usage: `Animate.shimmer(myView)`
    static func shimmer(_ view: UIView, alpha:CGFloat = Animate.cfg.shimmerTransparency, duration:animationSpeed = .slow ) {
        
        let solid = UIColor(white: 1, alpha: 1).cgColor
        let clear = UIColor(white: 1, alpha: alpha).cgColor
        
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0.01) // angled down slightly
        gradient.frame = CGRect(x: -20, y: -view.bounds.size.height/2, width: view.bounds.width*4, height: view.bounds.size.height * 2) // really wide (so we have plenty of room to shimmer) and a bit taller so that if we want to grow-animate contents it won't get clipped by this mask
        gradient.colors     = [ solid, clear, solid ]
        gradient.locations  = [ 0.4,   0.45,   0.5  ]
        
        let theAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        theAnimation.duration = duration.rawValue
        theAnimation.repeatCount = Float.infinity
        theAnimation.isRemovedOnCompletion = true
        theAnimation.fromValue = -(gradient.frame.width - view.bounds.width) // right edge of mask touching right edge of view
        theAnimation.toValue = -20 // left edge of masking touching left edge of view, with overshoot for safety
        gradient.add(theAnimation, forKey: "animateLayer")
        
        view.layer.mask = gradient
    }
    static func removeShimmer(_ view: UIView) {
        view.layer.mask = nil
    }
    
    
    
    // ------------------------------------------------------ MARK: show
    class show {
        
        class byGrowing {
            static func right(_ view: UIView?, completion: (()->())? = nil) {
                guard let view = view else { return }
                let full = view.frame
                view.frame = CGRect(x: full.origin.x, y: full.origin.y, width: 0, height: full.height)
                view.isHidden = false
                UIView.animate(withDuration: springSpeed.fast.rawValue, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .beginFromCurrentState, animations: {
                    view.frame = full
                }, completion: nil)
                
                // Custom callback delay to time with the visual end of the spring animation, rather than when it completely settles
                if let fn = completion { Timing.delayBy(0.1, fn: fn) }
            }
        }
        
        static func byFading(_ view: UIView?, duration:transitionSpeed = .fast, completion: (()->())? = nil) {
            guard let view = view else { return }
            view.alpha = 0
            view.isHidden = false
            UIView.animate(withDuration: duration.rawValue, animations: {
                view.alpha = 1
            }, completion: { finished in
                view.isHidden = false
                if finished { completion?() }
            })
        }
        
        class bySpringing {
            
            static func fromAbove(_ view: UIView, completion: (()->())? = nil) {
                // 1. Position it up and out of frame
                let originalPosition = view.frame
                let frame = originalPosition.offsetBy(dx: 0, dy: -view.frame.height)
                view.frame = frame
                // 2. Make sure it's visible
                view.isHidden = false
                // 3. Animate
                UIView.animate(withDuration: springSpeed.fast.rawValue, delay: 0, usingSpringWithDamping: Animate.cfg.damping, initialSpringVelocity: Animate.cfg.initialVelocity, options: .beginFromCurrentState, animations:
                    {
                        view.frame = originalPosition
                }, completion: { did in
                    if did { completion?() }
                })
            }
            
        }
    }
    
    
    
    // ------------------------------------------------------ MARK: hide
    class hide {
        
        /// Shrinking means to collapse width or height to 0
        class byShrinking {
            static func right(_ view: UIView?, completion: (()->())? = nil) {
                guard let view = view else { return }
                
                let full = view.frame
                view.isHidden = false
                UIView.animate(withDuration: transitionSpeed.normal.rawValue, delay: 0, options: .curveEaseOut, animations: {
                    view.frame = CGRect(x: full.origin.x + full.width, y: full.origin.y, width: 0, height: full.height)
                }, completion: { finished in
                    view.isHidden = true
                    view.frame = full
                    completion?()
                })
            }
        }
        
        static func byFading(_ view: UIView?, duration:transitionSpeed = .fast, completion: (()->())? = nil) {
            guard let view = view else { return }
            let originalAlpha = view.alpha
            view.isHidden = false
            UIView.animate(withDuration: duration.rawValue, animations: {
                view.alpha = 0
            }, completion: { finished in
                view.isHidden = true
                view.alpha = originalAlpha
                if finished { completion?() }
            })
        }
        
        class bySliding {
            
            static func up(_ view: UIView?, alsoFade:Bool = false, duration:transitionSpeed = .fast, completion: (()->())? = nil) {
                guard let view = view else { return }
                // 1. Plan target position
                let originalFrame = view.frame
                let originalAlpha = view.alpha
                let targetFrame = originalFrame.offsetBy(dx: 0, dy: -view.frame.height)
                // 2. Make sure it's visible
                view.isHidden = false
                // 3. Animate
                UIView.animate(withDuration: duration.rawValue, delay: 0, options: UIViewAnimationOptions(), animations: {
                    view.frame = targetFrame
                    if alsoFade { view.alpha = 0 }
                }, completion: { did in
                    view.frame = originalFrame // put it back in the original position for re-use later
                    view.isHidden = true
                    view.alpha = originalAlpha
                    if did { completion?() }
                })
            }
            
        }
        
        class bySpringing {
            
            static func up(_ view: UIView?, velocity:CGFloat = Animate.cfg.initialVelocity, completion: (()->())? = nil) {
                guard let view = view else { return }
                // 1. Plan target position
                let originalPosition = view.frame
                let targetPosition = originalPosition.offsetBy(dx: 0, dy: -view.frame.height)
                // 2. Make sure it's visible
                view.isHidden = false
                
                // 3. Animate
                UIView.animate(withDuration: springSpeed.fast.rawValue, delay: 0, usingSpringWithDamping: Animate.cfg.damping, initialSpringVelocity: velocity, options: .beginFromCurrentState, animations:
                    {
                        view.frame = targetPosition
                }, completion: { did in
                    view.frame = originalPosition // put it back in the original position for re-use later
                    if did {
                        view.isHidden = true
                        completion?()
                    }
                })
            }
        }
        
    }
    
    
    
    // ------------------------------------------------------ MARK: Property Changes
    
    /// For tweening basic property changes. Arcane differences in UIKit mean different properties must be animated in different ways, this should abstract over that.
    class change {
        
        static func textColor(_ label: UILabel?, color: UIColor, duration:transitionSpeed = .slow) {
            guard let label = label else { return }
            if label.textColor == color { return } // no need to animate to the same color
            UIView.transition(with: label, duration: duration.rawValue, options: .transitionCrossDissolve, animations: {
                label.textColor = color
            }, completion: nil)
        }
        
    }
    
    
    
    // ------------------------------------------------------ MARK: movement
    
    /// This class does "slamming" animations that include anticipation. A Slam right, for example, slowly pulls left, then springs right energetically, bouncing against an invisible wall at its identity location.
    class slam {
        
        static func right(_ view: UIView?, completion: (()->())? = nil) {
            guard let view = view else { return }
            
            // 1. Anticipate motion by taking a step back
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                view.transform = CGAffineTransform(translationX: -5, y: 0)
            }, completion: { finished in
                
                // 2. Slam right with springy force
                UIView.animate(withDuration: springSpeed.fast.rawValue, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 10, options: .beginFromCurrentState, animations: {
                    view.transform = CGAffineTransform.identity
                }, completion: nil)
                
                // 3. Callback. There's a custom delay on this because spring animations take so long to settle
                if let fn = completion { Timing.delayBy(0.1, fn: fn) }
            })
        }
        
    }
    
    /// Gently absorb and react to a force
    class absorb {
        
        static func right(_ view: UIView?) {
            guard let view = view else { return }
            
            UIView.animate(withDuration: 0.07, delay: 0, options: .curveEaseOut, animations: {
                view.transform = CGAffineTransform(translationX: 3, y: 0)
            }, completion: { finished in
                UIView.animate(withDuration: 0.25) { view.transform = CGAffineTransform.identity }
            })
        }
        
    }
    
}
