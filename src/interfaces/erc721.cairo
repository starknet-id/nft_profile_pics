#[abi]
trait ERC721 {

    fn ownerOf(tokenId: u256) -> starknet::ContractAddress;

}