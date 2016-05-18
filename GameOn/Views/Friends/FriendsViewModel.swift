//
//  FriendsViewModel.swift
//  GameOn
//
//  Created by Daniel on 5/17/16.
//  Copyright © 2016 danieljvdm. All rights reserved.
//
import RxSwift

struct FriendsViewModel: ViewModelType {
    let friends: Observable<[User]>
}