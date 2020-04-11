//
//  Test.swift
//  Grumble
//
//  Created by Allen Chang on 4/9/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import SwiftUI

struct Test: View {
    @State private var showTagSearch: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 100) {
            ZStack(alignment: .center) {
                ZStack(alignment: .top) {
                    Color(white: self.showTagSearch ? 0.98 : 0.9)
                    
                    SearchTag(Binding.constant([]), self.$showTagSearch)
                }.frame(width: sWidth(), height: sHeight() - tabHeight)
                
                if !self.showTagSearch {
                    Button(action: {
                        withAnimation(gAnim(.easeOut)) {
                            self.showTagSearch.toggle()
                        }
                    }, label: {
                        Image(systemName: "plus")
                            .foregroundColor(Color(white: 0.2))
                            .font(.system(size: 15, weight: .black))
                    })
                }
            }.frame(width: self.showTagSearch ? sWidth() : sWidth() * 0.1, height: self.showTagSearch ? sHeight() - tabHeight : sWidth() * 0.08)
            .cornerRadius(200)
        }
    }
}

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        Test()
    }
}
