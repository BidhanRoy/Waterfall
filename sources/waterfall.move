module waterfall::waterfall {
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
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
        // The timestamp when the contract expires.
        expiry: u64
    }

    /// Targed object owned by the receiver. 
    /// Type: Transferrable, Owned.
    struct Target<phantom T> has key {
        id: UID,
        source: ID
    }

    public entry fun crete_waterfall<T: key>(
        receiver: address,
        rate: u64,
        coin: Coin<T>,
        flow: u64,
        expiry: u64,
        ctx: &mut TxContext
    ){
        let sender = tx_context::sender(ctx);
        let source_id = object::new(ctx);
        let target_id = object::new(ctx);

        let source = Source{
            id: source_id,
            target: target_id,
            balance: coin::into_balance(coin),
            flow: flow,
            expiry: expiry
        };

        let target = Target{
            id: target_id,
            source: source_id
        };

        transfer::transfer(source, sender);
        transfer::transfer(target, receiver);
    }
}