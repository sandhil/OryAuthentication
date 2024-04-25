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
}
