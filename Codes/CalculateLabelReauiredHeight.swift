// Extension to UILabel to calculate required height 
// needed for text to fit in.

import UIKit

extension UILabel {
    // Calculate required height for a label
    var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0, 
                                          width: frame.width, 
                                          height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }
}