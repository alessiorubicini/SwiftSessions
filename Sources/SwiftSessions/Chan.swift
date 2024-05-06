import Foundation
import AsyncAlgorithms

class Chan<A, B> {
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
    
    static func send(payload: A, on chan: consuming Chan<A, B>) async {
        // Invio il messaggio sul canale
        await chan.channel.send(payload as AnyObject)
        chan.channel.finish()
        // Ritorno il canale di continuazione
        // return ...
    }
    
    static func recv(from chan: consuming Chan<B, A>) async {
        // Leggo il messaggio dal canale
        for await res in chan.channel {
            print("Result: \(res)")
            break
        }
        // Ritorno il canale di continuazione
        // return ...
    }
    
    static func close(channel: consuming Chan<A, B>) async {
        
    }
}
