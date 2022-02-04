//
//  ContentView.swift
//  Shared
//
//  Created by Jakub Wolański on 03/02/2022.
//

import Combine
import SwiftUI

struct ContentView: View {

    // how far the circle has been dragged
    @State private var offset = CGSize.zero
    // whether it is currently being dragged or not
    @State private var isDragging = false

    private var speedTurn: CGSize {
        get {
            var data = offset
            data.width = -1 * 1024 * offset.height / 100
            data.height = 1024 * offset.width / 100
            return data
        }
    }

    @ObservedObject private var rover = RoverConnection()

    var body: some View {
        let dragGesture = DragGesture()
            .onChanged { value in
                offset = value.translation
                rover.ride = RoverStatus(speed: Int(speedTurn.width), turn: Int(speedTurn.height), distance: nil)
            }
            .onEnded { _ in
                withAnimation {
                    offset = .zero
                    rover.ride = .empty
                    isDragging = false
                }
            }

        // a long press gesture that enables isDragging
        let pressGesture = LongPressGesture()
            .onEnded { value in
                withAnimation {
                    isDragging = true
                }
            }

        // a combined gesture that forces the user to long press then drag
        let combined = pressGesture.sequenced(before: dragGesture)
        
        VStack {
            HStack {
                Text("Speed:Turn")
                Text("\(rover.status.speed):\(rover.status.turn)")
                    .font(.body)
                    .foregroundColor(Color.purple)
                Spacer()
            }
            HStack {
                Text("Distance: \(rover.status.distance ?? 0)")
                Spacer()
            }
            .padding()
            ZStack {
                CircleImage()
                Circle()
                    .fill(rover.isConnected ? .green : .red)
                    .frame(width: 14, height: 14)
                    .scaleEffect(isDragging ? 1.5 : 1)
                    .offset(offset)
                    .gesture(combined)
            }

            .padding()
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
