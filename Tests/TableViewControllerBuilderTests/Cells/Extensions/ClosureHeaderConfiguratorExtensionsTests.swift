//
//  ClosureHeaderConfiguratorExtensionsTests.swift
//  Copyright © 2018 Dolfn. All rights reserved.
//

import XCTest
@testable import TableViewControllerBuilder

class ClosureHeaderConfiguratorExtensionsTests: XCTestCase {
    
    func test_GivenClouseHeaderConfigurator_IsReturnedAsErased() {
        let uuid = UUID().uuidString
        let configurator = ClosureHeaderConfigurator<Any, UITableViewHeaderFooterViewSpy>(reuseIdentifier: uuid) { (_, _) in
            
        }
        let erased = configurator.erased
        XCTAssertEqual(erased.reuseIdentifier, "UITableViewHeaderFooterViewSpy")
    }
    
}
