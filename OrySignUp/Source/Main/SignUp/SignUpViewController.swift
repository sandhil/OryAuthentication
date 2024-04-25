import Foundation
import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var elementsStackView: UIStackView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUpLabel: UILabel!
    
    var viewModel: SignUpViewModel = SignUpViewModel()
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        getValuesFromFormFields()
    }
    
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
    
    func renderUIElements() {
        viewModel.jsonFlow?.ui?.nodes?.forEach { node in
            switch node?.attributes?.type {
            case .email,.text, .password :
                addTextField(node: node)
            case .checkbox:
                addCheckBox(node: node)
            default: break
            }
        }
        signInButton.isHidden = false
        signUpButton.isHidden = false
        signUpLabel.isHidden = false
    }
    
    func addTextField(node: Node?) {
        let textField = UITextField()
        textField.placeholder = node?.meta?.label?.text
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry = node?.attributes?.type == .password
        textField.tag = node?.meta?.label?.tag ?? -1
        elementsStackView.addArrangedSubview(textField)
    }
    
    func addCheckBox(node: Node?) {
        
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
    
    func getValuesFromFormFields() {
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
                handleTextualField(components: components, text: text, traits: &traits)
                
            case .checkbox:
                guard let uiSwitch = elementsStackView.viewWithTag(node?.meta?.label?.tag ?? -99) as? UISwitch else { return }
                handleCheckbox(components: components, uiSwitch: uiSwitch, traits: &traits)
                
            default: break
            }
        }
        
        payload["traits"] = traits
        payload["csrf_token"] = ""
        payload["method"] = "password"
        viewModel.signUp(parameters: payload)
    }
    
    func handleTextualField(components: [String], text: String, traits: inout [String: Any]) {
        if components.count > 2 {
            let key = components[1]
            let lastKey = components[2]
            createNestedDictionary(key: key, lastKey: lastKey, value: text, in: &traits)
        } else if components.count == 2 {
            let key = components[1]
            traits[key] = text
        } else if components.count == 1 {
            let key = components[0]
            traits[key] = text
        }
    }
    
    func handleCheckbox(components: [String], uiSwitch: UISwitch, traits: inout [String: Any]) {
        if components.count == 2 {
            let key = components[1]
            traits[key] = uiSwitch.isOn
        } else if components.count == 1 {
            let key = components[0]
            traits[key] = uiSwitch.isOn
        }
    }
    
    func createNestedDictionary(key: String, lastKey: String, value: Any, in dictionary: inout [String: Any]) {
        if dictionary.keys.contains(key) {
            var newDict = dictionary[key] as? [String: Any] ?? [:]
            newDict[lastKey] = value
            dictionary[key] = newDict
        } else {
            let dict = [lastKey: value]
            dictionary[key] = dict
        }
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
