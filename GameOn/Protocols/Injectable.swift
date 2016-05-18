//
//  Injectable.swift
//  GameOn
//
//  Created by Daniel on 5/15/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//

import UIKit

protocol Injectable {
    associatedtype T
    var viewModel: T! {get set}
    mutating func inject(viewModel: T)
    func assertDependencies()
}

extension Injectable {
    func assertDependencies() {
        assert(viewModel != nil)
    }
    
    mutating func inject(viewModel: T) {
        self.viewModel = viewModel
    }
}