module waterfall::waterfall {
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin};
    use sui::balance::Balance;
    use sui::transfer;

    /// Source object defining the token flow contract.
    /// Type: Transferrable, Owned.
    struct Source<phantom T> has key {
        id: UID,
        target: ID,
        // Wrapped balance of the flow contract.
        balance: Balance<T>,
        /// Flow rate of the token/s.
        flow: u64,
        // Duration of the contract's existense in seconds.
        duration: u64
    }

    /// Target object owned by the receiver. 
    /// Type: Transferrable, Owned.
    struct Target<phantom T> has key {
        id: UID,
        source: ID
    }

    public entry fun crete_waterfall <T: key> (
        receiver: address,
        coin: Coin<T>,
        flow: u64,
        duration: u64,
        ctx: &mut TxContext
    ){
        let sender = tx_context::sender(ctx);
        let target_id = object::new(ctx);
        
        let source = Source<T>{
            id: object::new(ctx),
            target: object::uid_to_inner(&target_id),
            balance: coin::into_balance(coin),
            flow: flow,
            duration: duration
        };

        let target = Target<T>{
            id: target_id,
            source: object::id(&source)
        };

        transfer::transfer(source, sender);
        transfer::transfer(target, receiver);
    }

    public entry fun terminate_waterfall <T: key>(
        source_object: Source<T>,
        current_timestamp: u64
    ){
        /*
        Unwrap source object and distrubute wrapped balance according to the current timestamp.
        */
        let Source {
            id: source_id,
            target: target,
            balance: balance,
            flow: flow,
            duration: duration
        } = source_object;
    }
}