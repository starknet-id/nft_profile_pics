#[contract]
mod HelloStarknet {

    use nft_profile_pics::interfaces::{erc721::ERC721Dispatcher, starknetid::StarknetIdDispatcher};
    use nft_profile_pics::interfaces::{erc721::ERC721DispatcherTrait, starknetid::StarknetIdDispatcherTrait};
    use starknet::ContractAddress;
    use array::ArrayTrait;
    use starknet::{info::{get_caller_address, get_contract_address}, contract_address::Felt252TryIntoContractAddress};
    use integer::Felt252TryIntoU128;
    use traits::{Into, TryInto};

    struct Storage {
        starketid_contract: ContractAddress,
    }


    #[external]
    fn initializer(starketid_contract: ContractAddress) {
        if starketid_contract::read().into() == 0 {
            starketid_contract::write(starketid_contract);
        }
    }

    #[external]
    fn set_profile_pic(starknet_id: felt252, nft_contract: ContractAddress, token_id: u256) {

        let starknetid_dispatcher = StarknetIdDispatcher{
            contract_address: starketid_contract::read()
        };

        // check starknet_id ownership
        let caller_address = get_caller_address();
        assert(starknetid_dispatcher.owner_of(starknet_id) == caller_address, 'you must own the starknet_id');

        // check nft ownership
        let nft_owner = ERC721Dispatcher{
            contract_address: nft_contract
        }.ownerOf(token_id);
        assert(nft_owner == caller_address, 'you must own the nft');


        let mut data = ArrayTrait::new();
        data.append(nft_contract.into());
        data.append(token_id.low.into());
        data.append(token_id.high.into());
        starknetid_dispatcher.set_extended_verifier_data(starknet_id, 'profile_pic', data);
    }

    #[view]
    fn get_profile_pic(starknet_id: felt252) -> Option<(ContractAddress, u256)> {
        let contract_address = get_contract_address();
        let data = StarknetIdDispatcher{
             contract_address: starketid_contract::read()
        }.get_extended_verifier_data(starknet_id, 'profile_pic', 3, contract_address.into());

        let nft_contract_opt: Option<ContractAddress> = (*data[0]).try_into();
        let low: Option<u128> = (*data[1]).try_into();
        let high: Option<u128> = (*data[2]).try_into();

        // todo: make this code not terrible

        match nft_contract_opt {
            Option::Some(nft_contract) => {
                match low {
                    Option::Some(x) => {
                        match high {
                            Option::Some(y) => {
                                return Option::Some((nft_contract, u256 { low: x, high: y }));
                            },
                            Option::None(_) => {}
                        }
                    },
                    Option::None(_) => {}
                }
            },
            Option::None(_) => {}
        }

        return Option::None(());
    }

}
