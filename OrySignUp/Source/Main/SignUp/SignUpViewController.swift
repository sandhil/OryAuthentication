import Foundation
import UIKit

class SignUpViewController: UIViewController {
    
    var viewModel: SignUpViewModel = SignUpViewModel()
    
    @IBOutlet weak var elementsStackView: UIStackView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUpLabel: UILabel!
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
    
    private func renderUIElements() {
        viewModel.jsonFlow?.ui?.nodes?.forEach { node in
            switch node?.attributes?.type {
            case .email,.text, .password :
                addTextField(node: node)
            case .checkbox:
                addCheckBox(node: node)
            case .submit:
                addSubmitButton(node: node)
            default: break
            }
        }
        signInButton.isHidden = false
//        signUpButton.isHidden = false
        signUpLabel.isHidden = false
    }
    
    private func addTextField(node: Node?) {
        let textField = UITextField()
        textField.placeholder = node?.meta?.label?.text
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = node?.attributes?.type == .password
        textField.tag = node?.meta?.label?.tag ?? -1
        elementsStackView.addArrangedSubview(textField)
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func addCheckBox(node: Node?) {
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.spacing = 8
        horizontalStackView.alignment = .center
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let mySwitch = UISwitch()
        mySwitch.tag = node?.meta?.label?.tag ?? -1
        
        let label = UILabel()
        label.text = node?.meta?.label?.text
        
        horizontalStackView.addArrangedSubview(mySwitch)
        horizontalStackView.addArrangedSubview(label)
        
        elementsStackView.addArrangedSubview(horizontalStackView)
    }
    
    private func addSubmitButton(node: Node?) {
        let button = UIButton()
        button.setTitle(node?.meta?.label?.text, for: .normal)
        button.backgroundColor = UIColor(named: "AccentColor")
        button.tag = node?.meta?.label?.tag ?? -1
        button.layer.cornerRadius = 8
        elementsStackView.addArrangedSubview(button)
        
        NSLayoutConstraint.activate([
          button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        button.addTarget(self, action: #selector(submitButtonPressed(_:)), for: .touchUpInside)
    }
    
    @objc func submitButtonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()
        getValuesFromFormFields()
    }
    
    private func getValuesFromFormFields() {
        var payload: [String: Any] = [:]
        var traits: [String: Any] = [:]
        
        viewModel.jsonFlow?.ui?.nodes?.forEach { node in
            guard let nodeName = node?.attributes?.name else { return }
            let components = nodeName.components(separatedBy: ".")
            
            switch node?.attributes?.type {
            case .password:
                guard let textField = elementsStackView.viewWithTag(node?.meta?.label?.tag ?? -999) as? UITextField else { return }
                let password = textField.text ?? ""
                payload["password"] = password
            case .email, .text:
                guard let textField = elementsStackView.viewWithTag(node?.meta?.label?.tag ?? -999) as? UITextField else { return }
                let text = textField.text ?? ""
                viewModel.handleTextualField(components: components, text: text, traits: &traits)
                
            case .checkbox:
                guard let uiSwitch = elementsStackView.viewWithTag(node?.meta?.label?.tag ?? -99) as? UISwitch else { return }
                viewModel.handleCheckbox(components: components, uiSwitch: uiSwitch, traits: &traits)
                
            default: break
            }
        }
        
        payload["traits"] = traits
        payload["csrf_token"] = ""
        payload["method"] = "password"
        viewModel.signUp(parameters: payload)
    }

}


extension SignUpViewController: SignUpViewModelDelegate {
    func updateUI() {
        DispatchQueue.main.async {
            self.renderUIElements()
            self.activityIndicator.stopAnimating()
        }
    }
    
    func didSignUp() {
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
