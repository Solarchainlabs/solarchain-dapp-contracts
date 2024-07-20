// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./EnumerableSet.sol";

interface ISolarERC1155{
    function initialize(string memory name_, string memory symbol_, string memory bURI, address[] memory dappAddress) external;
    function transferOwnership(address newOwner) external;
}
interface IExchangeV2{
    function __ExchangeV2_init(
        address nftTransferProxy,
        address erc20TransferProxy,
        address solarDapp
    ) external;
    function transferOwnership(address newOwner) external;
}




library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SolarFactory is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public erc1155Implementation;
    address public exchangeV2Implementation;

    EnumerableSet.AddressSet private _dappSet;
    address constant TBA_MULTICALL_ADDRESS = 0xcA1167915584462449EE5b4Ea51c37fE81eCDCCD;

    event CreateERC1155(address indexed contractAddress);
    event CreateExchangeV2(address indexed contractAddress);

    constructor(address solarERC1155, address solarExchange) {
        erc1155Implementation = solarERC1155;
        exchangeV2Implementation = solarExchange;
    }

    function setDappAddress(address addr, bool enable) external onlyOwner {
        if(enable){
            _dappSet.add(addr);
        }else{
            _dappSet.remove(addr);
        }
    }

    function getDappAddress() public view returns(address[] memory addrs){
        addrs = new address[](_dappSet.length());
        for(uint i=0;i<_dappSet.length();++i){
            addrs[i]=_dappSet.at(i);
        }
    }

    function createERC1155(
        string memory name_,
        string memory symbol_,
        string memory bURI_
    ) external returns(address)  {
         if(isContract(_msgSender())){            
            require(msg.data.length >= 20, "Invalid data length");
            address originalSender = address(bytes20(msg.data[msg.data.length - 20:]));
            require(_dappSet.contains(originalSender) && TBA_MULTICALL_ADDRESS==_msgSender(), "!owner");
            
        }else{
            require(tx.origin==owner(), "!owner");
        }
        
        address clonedContract = Clones.clone(erc1155Implementation);
        ISolarERC1155(clonedContract).initialize(name_, symbol_, bURI_, getDappAddress());
        ISolarERC1155(clonedContract).transferOwnership(owner());
        emit CreateERC1155(clonedContract);
        return clonedContract;
    }

    function createExchangeV2(
        address nftTransferProxy,
        address erc20TransferProxy,
        address solarDapp
    ) external returns(address)  {
         if(isContract(_msgSender())){            
            require(msg.data.length >= 20, "Invalid data length");
            address originalSender = address(bytes20(msg.data[msg.data.length - 20:]));
            require(_dappSet.contains(originalSender) && TBA_MULTICALL_ADDRESS==_msgSender(), "!owner");
            
        }else{
            require(tx.origin==owner(), "!owner");
        }
        
        address clonedContract = Clones.clone(exchangeV2Implementation);
        IExchangeV2(clonedContract).__ExchangeV2_init(nftTransferProxy, erc20TransferProxy, solarDapp);
        IExchangeV2(clonedContract).transferOwnership(owner());
        emit CreateExchangeV2(clonedContract);
        return clonedContract;
    }

    function changeERC1155Implementation(address newImplementationAddress) external onlyOwner {
        erc1155Implementation = newImplementationAddress;
    }    

    function changeExchangeV2Implementation(address newImplementationAddress) external onlyOwner {
        exchangeV2Implementation = newImplementationAddress;
    }    

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}
