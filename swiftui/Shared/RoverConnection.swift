//
//  RoverConnection.swift
//  Rover
//
//  Created by Jakub Wolański on 04/02/2022.
//

import Combine
import Foundation
import MQTTNIO

class RoverConnection: ObservableObject {

    @Published public private(set) var isConnected: Bool = false
    @Published public private(set) var status: RoverStatus = .empty
    @Published public var ride: RoverStatus = .empty

    private var disposables = Set<AnyCancellable>()

    private var client = MQTTClient(
        configuration: .init(
            target: .host("192.168.1.253", port: 1883)
        ),
        eventLoopGroupProvider: .createNew
    )

    init() {
        client.connect()

        Publishers.Merge(
            client.connectPublisher.map { _ in true },
            client.disconnectPublisher.map { _ in false }
        )
            .replaceError(with: false)
            .assign(to: &$isConnected)

        client.messagePublisher
            .compactMap(\.payload.string)
            .print()
            .compactMap { $0.data(using: .utf8) }
            .decode(type: RoverStatus.self, decoder: JSONDecoder())
            .replaceError(with: .empty)
            .assign(to: &$status)

        $ride
            .debounce(for: .seconds(0.1), scheduler: DispatchQueue.global())
            .map { MQTTMessage(topic: "rover/ride/set", payload: $0.jsonString) }
            .sink(receiveValue: { [client] message in
                client.publish(message)
            })
            .store(in: &disposables)

        client.subscribe(to: [MQTTSubscription(topicFilter: "rover/ride")])
    }

}

struct RoverStatus: Codable {
    let speed: Int
    let turn: Int
    let distance: Int?

    static var empty: RoverStatus = RoverStatus(speed: 0, turn: 0, distance: 0)
    var jsonString: String {
        (try? String(data: JSONEncoder().encode(self), encoding: .utf8)) ?? ""
    }
}
