//
//  TabRouter.swift
//  Grumble
//
//  Created by Allen Chang on 4/3/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import Foundation

//MARK: - Enumerations
public enum Tab: String {
    case list = "List"
    case settings = "Settings"
}

//MARK: - Views
public class TabRouter: ObservableObject {
    private static var instance: TabRouter?
    @Published private var currentTab: Tab = .list

    //MARK: Getter Methods
    public static func tr() -> TabRouter {
        if TabRouter.instance == nil {
            TabRouter.instance = TabRouter()
        }
        return TabRouter.instance!
    }

    public func tab() -> Tab {
        return self.currentTab
    }
    
    //MARK: Setter Methods
    public func changeTab(_ tab: Tab) {
        if self.currentTab != tab {
            self.currentTab = tab
        }
    }
}
