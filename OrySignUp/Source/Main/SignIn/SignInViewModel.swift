import Foundation
import Swinject
import RxSwift

protocol SignInViewModelDelegate: AnyObject {
    func didSignIn()
    func didReceiveError()
    func updateUI()
}

class SignInViewModel {
    
    var sessionManager: SessionManager!
    weak var delegate: SignInViewModelDelegate?
    let disposeBag = DisposeBag()
    var jsonFlow: JSONFlow?
    var errorMessage: String?
    
    init() {
        sessionManager = Container.sharedContainer.resolve(SessionManager.self)
    }
    
    func signIn(parameters: [String: Any]) {
        let flowId: String = jsonFlow?.id ?? ""
        sessionManager.signIn(flowId: flowId, parameters: parameters)
            .subscribe(onSuccess: { [weak self] flow in
                self?.delegate?.didSignIn()
            }, onFailure: { error in
                self.errorMessage = parseError(error)
                self.delegate?.didReceiveError()
            })
            .disposed(by: disposeBag)
    }
    
    func getSignInFlow() {
        sessionManager.getLoginFlow()
            .subscribe(onSuccess: { [weak self] flow in
                self?.jsonFlow = flow
                self?.delegate?.updateUI()
            }, onFailure: { error in
                self.errorMessage = parseError(error)
                self.delegate?.didReceiveError()
            })
            .disposed(by: disposeBag)
    }
}
