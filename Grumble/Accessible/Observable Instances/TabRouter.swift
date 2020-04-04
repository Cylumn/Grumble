//
//  TabRouter.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation

public enum Tab {
    case list
    case settings
}

public class TabRouter: ObservableObject {
    private static var instance: TabRouter?
    @Published private var currentTab: Tab = .list

    //Getter Methods
    public static func tr() -> TabRouter {
        if TabRouter.instance == nil {
            TabRouter.instance = TabRouter()
        }
        return TabRouter.instance!
    }

    public func tab() -> Tab {
        return self.currentTab
    }
    
    //Setter Methods
    public func changeTab(_ tab: Tab) {
        self.currentTab = tab
    }
}
