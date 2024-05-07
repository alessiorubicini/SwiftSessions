import Foundation
import AsyncAlgorithms

final class Chan<A, B> {
    let channel: AsyncChannel<AnyObject>
    
    init(channel: AsyncChannel<AnyObject>) {
        self.channel = channel
    }
    
    static func create() -> (Chan<A, B>, Chan<B, A>) {
        let channel: AsyncChannel<AnyObject> = AsyncChannel()
        let c1 = Chan<A, B>(channel: channel)
        let c2 = Chan<B, A>(channel: channel)
        return (c1, c2)
    }
    
    static func send<A, B, C>(_ payload: A, on chan: consuming Chan<(A, Chan<B, C>), Empty>) async -> Chan<C, B> {
        // Invio il payload sul canale
        await chan.channel.send(payload as AnyObject)
        chan.channel.finish()
        // Restituisco la continuazione, cioè il canale originale ma con tipo aggiornato
        return chan as! Chan<C, B>
    }

    static func recv<A, B, C>(from chan: consuming Chan<Empty, (A, Chan<B, C>)>) async -> (A, Chan<B, C>) {
        // Ricevo il messaggio dal canale
        let msg = await chan.channel.first(where: { _ in true })!
        // Restituisco il messaggio e la continuazione, cioè il canale originale con tipo aggiornato
        return (msg as! A, chan as! Chan<B, C>)
    }
    
    static func close(channel: consuming Chan<Empty, Empty>) async {
        return
    }
}
