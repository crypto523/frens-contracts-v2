// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

//import "hardhat/console.sol";
// import "./FrensBase.sol";
import "./interfaces/IFrensPoolShareTokenURI.sol";
import "./interfaces/IFrensArt.sol";
import "./interfaces/IFrensPoolShare.sol";
import "./interfaces/IStakingPool.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//should ownable be replaces with an equivalent in storage/base? (needs to interface with opensea properly)
contract FrensPoolShare is
    IFrensPoolShare,
    ERC721Enumerable,
    AccessControl,
    Ownable
{
    // Counters.Counter private _tokenIds;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    IFrensPoolShareTokenURI frensPoolShareTokenURI;
    mapping(uint => address) public poolByIds;

    constructor() ERC721("FRENS Share", "FRENS") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setFrensPoolShareTokenURI(
        IFrensPoolShareTokenURI _frensPoolShareTokenURI
    ) public {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender));
        frensPoolShareTokenURI = _frensPoolShareTokenURI;
    }

    function mint(address userAddress) public {
        require(hasRole(MINTER_ROLE, msg.sender), "you are not allowed to mint");
        uint256 _id = totalSupply();
        poolByIds[_id] = address(msg.sender);
        _safeMint(userAddress, _id);
    }

    function exists(uint _id) public view returns (bool) {
        return _exists(_id);
    }

    function getPoolById(uint _id) public view returns (address) {
        return (poolByIds[_id]);
    }

    function tokenURI(
        uint256 id
    ) public view override(ERC721, IFrensPoolShare) returns (string memory) {
        return frensPoolShareTokenURI.tokenURI(id);
    }

    function renderTokenById(uint256 id) public view returns (string memory) {
        IStakingPool pool = IStakingPool(getPoolById(id));
        IFrensArt frensArt = pool.artForPool();
        return frensArt.renderTokenById(id);
    }

    // function _beforeTokenTransfer(
    //     address from,
    //     address to,
    //     uint tokenId
    // ) internal override {
    //     super._beforeTokenTransfer(from, to, tokenId);
    //     IStakingPool pool = IStakingPool(poolByIds(id));
    //     if (from != address(0) && to != address(0)) {
    //         require(pool.transferLocked() == false, "not transferable");
    //     }
    // }

    function burn(uint tokenId) public {
        require(
            msg.sender == address(poolByIds[tokenId]),
            "cannot burn shares from other pools"
        );
        _burn(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721Enumerable, AccessControl, IERC165)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
