import UIKit

class HomeViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ProfileSegue", sender: nil)
    }
    
}
