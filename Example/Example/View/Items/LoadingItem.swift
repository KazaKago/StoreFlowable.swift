//
//  LoadingItem.swift
//  Example
//
//  Created by Kensuke Tamura on 2020/12/26.
//

import SwiftUI

struct LoadingItem: View {

    var body: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding()
    }
}

struct LoadingItem_Previews: PreviewProvider {
    static var previews: some View {
        LoadingItem()
    }
}
