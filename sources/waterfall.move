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
        duration: u64,
        // Creation timestamp of the waterfall.
        created_at: u64
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
        current_timestamp: u64, // Will be replaced by on-chain timestamp.
        ctx: &mut TxContext
    ){
        assert!(flow >= 0 && duration >= 0, 1);

        let sender = tx_context::sender(ctx);
        let target_id = object::new(ctx);
        
        let source = Source<T>{
            id: object::new(ctx),
            target: object::uid_to_inner(&target_id),
            balance: coin::into_balance(coin),
            flow: flow,
            duration: duration,
            created_at: current_timestamp
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
        current_timestamp: u64, // Will be replaced by on-chain timestamp.
        ctx: &mut TxContext
    ){
        /*
        Unwrap source object and distrubute wrapped balance according to the current timestamp.
        */
        let Source {
            id: source_id,
            target: target,
            balance: balance,
            flow: flow,
            duration: duration,
            created_at: created_at
        } = source_object;

        assert!(current_timestamp >= created_at, 1);
        let amount_flowed = (current_timestamp - created_at + 1) * flow;
        
        let coins_to_target = coin::take(&mut balance, amount_flowed, ctx);
        transfer::transfer(coins_to_target, target);
    }
}