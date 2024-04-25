import Foundation
import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var viewModel: SignInViewModel = SignInViewModel()
    
    override func viewDidLoad() {
        let userName = viewModel.sessionManager.user?.userId ?? viewModel.sessionManager.user?.email ?? ""
        titleLabel.text = "Hi \(userName) !!"
    }
}
