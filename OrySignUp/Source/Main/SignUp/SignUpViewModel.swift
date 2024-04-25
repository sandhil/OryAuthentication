import Foundation
import Swinject
import RxSwift

protocol SignUpViewModelDelegate: AnyObject {
    func didSignUp()
    func didReceiveError()
    func updateUI()
}

class SignUpViewModel {
    
    var sessionManager: SessionManager!
    weak var delegate: SignUpViewModelDelegate?
    let disposeBag = DisposeBag()
    var jsonFlow: JSONFlow?
    var errorMessage: String?
    
    init() {
        sessionManager = Container.sharedContainer.resolve(SessionManager.self)
    }
    
    func signUp(parameters: [String: Any]) {
        let flowId: String = jsonFlow?.id ?? ""
        sessionManager.signUp(flowId: flowId, parameters: parameters)
            .subscribe(onSuccess: { [weak self] flow in
                self?.delegate?.didSignUp()
            }, onFailure: { error in
                self.errorMessage = parseError(error)
                self.delegate?.didReceiveError()
            })
            .disposed(by: disposeBag)
    }
    
    func getSignInFlow() {
        sessionManager.getRegistrationFlow()
            .subscribe(onSuccess: { [weak self] flow in
                self?.jsonFlow = flow
                self?.delegate?.updateUI()
            }, onFailure: { error in
                print("error", error)
            })
            .disposed(by: disposeBag)
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
