import UIKit

class UploadViewController: UIViewController {

    @IBOutlet weak var uploadAvatarLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadAvatarLabel.textColor = .white
        uploadAvatarLabel.font = Font.body
        progressView.tintColor = .white
        progressView.trackTintColor = .lightGray
        view.backgroundColor = .white.withAlphaComponent(0)
        let blueEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blueEffect)
        visualEffectView.frame = view.bounds
        view.addSubview(visualEffectView)
        view.sendSubviewToBack(visualEffectView)  // отобразится поверх основного вида
        
    }
    

    

}
