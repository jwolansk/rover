//
//  CircleImage.swift
//  Rover
//
//  Created by Jakub Wolański on 03/02/2022.
//

import SwiftUI

struct CircleImage: View {
    var body: some View {
        Image("walle")
            .resizable()
            .scaledToFill()
            .frame(width: 300, height: 300, alignment: .center)
            .clipShape(Circle())
            .overlay {
                Circle().stroke(.white, lineWidth: 4)
            }
            .shadow(radius: 7)
            .padding()

    }
}

struct CircleImage_Previews: PreviewProvider {
    static var previews: some View {
        CircleImage()
    }
}
