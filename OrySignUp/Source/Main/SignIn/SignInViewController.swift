import Foundation
import UIKit

class SignInViewController: UIViewController {
    
    var viewModel: SignInViewModel = SignInViewModel()
    
    @IBOutlet weak var elementsStackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInLabel: UILabel!
    
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        getValuesFromFormFields()
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let signUpController = storyboard.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(signUpController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.getSignInFlow()
    }
    
    private func navigateToHomeScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabbarController = storyboard.instantiateViewController(withIdentifier: "TabbarController") as! TabbarController
        tabbarController.modalPresentationStyle = .fullScreen
        tabbarController.navigationController?.isNavigationBarHidden = true
        self.navigationController?.present(tabbarController, animated: false)
    }
    
    private func renderUIElementsFromJSONSchema() {
        viewModel.jsonFlow?.ui?.nodes?.forEach { node in
            switch node?.attributes?.type {
            case .email,.text, .password :
                addTextField(node: node)
            default: break
            }
        }
        signInButton.isHidden = false
        signUpButton.isHidden = false
        signInLabel.isHidden = false
    }
    
    private func addTextField(node: Node?) {
        let textField = UITextField()
        textField.placeholder = node?.meta?.label?.text
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = node?.attributes?.type == .password
        textField.tag = node?.meta?.label?.tag ?? -1
        elementsStackView.addArrangedSubview(textField)
    }
    
    private func getValuesFromFormFields() {
        var payload: [String: Any] = [:]
        
        viewModel.jsonFlow?.ui?.nodes?.forEach { node in
            switch node?.attributes?.type {
            case .password:
                guard let textField = elementsStackView.viewWithTag(node?.meta?.label?.tag ?? -999) as? UITextField else { return }
                let password = textField.text ?? ""
                payload["password"] = password
            case .email, .text:
                guard let textField = elementsStackView.viewWithTag(node?.meta?.label?.tag ?? -999) as? UITextField else { return }
                let text = textField.text ?? ""
                payload["password_identifier"] = text
                
            default: break
            }
        }
        
        payload["csrf_token"] = ""
        payload["method"] = "password"
        viewModel.signIn(parameters: payload)
    }
}


extension SignInViewController: SignInViewModelDelegate {
    func updateUI() {
        DispatchQueue.main.async {
            self.renderUIElementsFromJSONSchema()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func didSignIn() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigateToHomeScreen()
        }
    }
    
    func didReceiveError() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.showAlert(title: "Error", message: self.viewModel.errorMessage)
        }
    }
}
