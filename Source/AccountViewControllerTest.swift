//
//  AccountViewControllerTest.swift
//  edX
//
//  Created by Salman on 17/08/2017.
//  Copyright © 2017 edX. All rights reserved.
//

import XCTest
@testable import edX

private extension OEXConfig {
    
    convenience init(profileEnabled : Bool = false) {
        self.init(dictionary: [
            "USER_PROFILES_ENABLED": profileEnabled
            ]
        )
    }
}

class AccountViewControllerTest: SnapshotTestCase {

    var profile : UserProfile {
        return UserProfile(username: "Test Person", bio: "Hello I am a lorem ipsum dolor sit amet", parentalConsent: false, countryCode: "de", accountPrivacy: .Public)
    }
    
    func accountViewcontroller() -> AccountViewController {
        let config = OEXConfig(profileEnabled: true)
        let mockEnv = TestRouterEnvironment(config: config, interface: nil)
        let controller = AccountViewController(phoneStr: profile.phone!, environment: mockEnv)
        controller.view.setNeedsDisplay()
        
        return controller
    }
    
    func testScreenshot() {
        let controller = accountViewcontroller()
        inScreenNavigationContext(controller) { 
              assertSnapshotValidWithContent(controller.navigationController!)
        }
    }
    
}
