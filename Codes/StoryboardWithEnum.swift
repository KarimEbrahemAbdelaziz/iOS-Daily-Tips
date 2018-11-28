// Different way to instantiate view controller. Inspired by iOS-OSS application.
// what you only need to set viewController id in storyboard as it's class name. 

public enum Storyboard: String {
    // Storyboards available and it's name MUST match the case
    case Login
    
    // Instantiate your view controller ;)
    public func instantiate<VC: UIViewController>(_ viewController: VC.Type) -> VC {
        guard let viewController = UIStoryboard(name: self.rawValue, bundle: nil)
            .instantiateViewController(withIdentifier: VC.storyboardIdentifier) as? VC
        else { 
            fatalError("Couldn't instantiate \(VC.storyboardIdentifier) from \(self.rawValue)") 
        }
        return viewController
    }
}

let loginViewController = Storyboard.Login.instantiate(LoginViewController.self)