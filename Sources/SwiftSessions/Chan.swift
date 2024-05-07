import Foundation
import AsyncAlgorithms

class Chan<A, B> {
    let channel: AsyncChannel<AnyObject>
    
    init(channel: AsyncChannel<AnyObject>) {
        self.channel = channel
    }
}

extension Chan {
    static func create() -> (Chan<A, B>, Chan<B, A>) {
        let channel: AsyncChannel<AnyObject> = AsyncChannel()
        let c1 = Chan<A, B>(channel: channel)
        let c2 = Chan<B, A>(channel: channel)
        return (c1, c2)
    }
    
    static func send(_ payload: A, on channel: consuming Chan<A, B>) async {
        await channel.channel.send(payload as AnyObject)
        channel.channel.finish()
    }
    
    static func recv(from channel: consuming Chan<B, A>) async -> AnyObject {
        return await channel.channel.first(where: { _ in true })!
    }
    
    static func close(channel: consuming Chan<A, B>) async {
        return
    }
}
