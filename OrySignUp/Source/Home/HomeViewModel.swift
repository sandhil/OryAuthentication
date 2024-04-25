import Foundation
import Swinject
import RxSwift

class HomeViewModel {
    
    var sessionManager: SessionManager!
    
    init() {
        sessionManager = Container.sharedContainer.resolve(SessionManager.self)
    }
}
