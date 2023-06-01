#[abi]
trait StarknetId {

    fn owner_of(starknet_id: felt252) -> starknet::ContractAddress;

    // write large data to the verifier
    fn set_extended_verifier_data(starknet_id: felt252, field: felt252, data: Array<felt252>);

    // read large data from the verifier
    fn get_extended_verifier_data(starknet_id: felt252, field : felt252, length: felt252, address: felt252) -> Array<felt252>;
}