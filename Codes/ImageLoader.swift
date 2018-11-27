// Don't marry your pod :D
// By using this approach you decoupled your code
// from being tightly coupled with POD code.
// This example for using any image loader pod (KingFisher, SDWebImage)

protocol ImageLoader: class {
    func loadImage(with url: String)
}

// Use POD code here .. you can change the pod easly and your
// code would never change in view controllers ;)
extension ImageLoader where Self: UIImageView {
    func loadImage(with url: String) {
        // Code for 3rd party library
    }
}

extension UIImageView: ImageLoader {}

let imageView = UIImageView()
imageView.loadImage("imageUrl.com")