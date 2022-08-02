pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./ERC721A.sol";

interface IPCCore {

  function getIpc(uint256 ipcId)
    external view returns (
    string calldata name,
    bytes32 attributeSeed,
    bytes32 dna,
    uint128 experience,
    uint128 timeOfBirth);

  function totalSupply() external view returns (uint256);
  function setIpcPrice(uint ipcId, uint newPrice) external payable;
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId)
    external payable;
}

contract IPCV0Wrapper is IERC721Receiver, Ownable, ERC721A {

  struct t_token {
    uint tokenId;
    address owner;
  }

  address public immutable contractAddress;

  // set token limit...
  uint256 tokenLimit;
  mapping(uint256 => t_token) tokenList;
  mapping(uint256 => uint256) tokenIndexList;
  mapping(address => uint256[]) tokenOwnerList;

  event Wrapped(uint256, uint256, address);
  event Unwrapped(uint256, uint256, address);

  error TokenLimitReached();
  error TokenNotExist();
  error TokenNotOwner();

  constructor() ERC721A("Immortal Player Characters v0", "IPCV0") {
  
    contractAddress = address(0);
    tokenLimit = 1000;
  }

  function wrap(uint256 tokenId)
    external payable {

      if (tokenId > tokenLimit)
        revert TokenLimitReached();

      IPCCore(contractAddress).safeTransferFrom(
        msg.sender,
	address(this),
	tokenId
      );

      IPCCore(contractAddress).setIpcPrice{value: msg.value}(tokenId, 999999999);

      address owner = msg.sender;
      uint256 tokenIndex = _nextTokenId();

      tokenList[tokenIndex] = t_token(tokenId, owner);
      tokenIndexList[tokenId] = tokenIndex;
      tokenOwnerList[owner].push(tokenIndex);

      _safeMint(owner, 1);
      emit Wrapped(tokenIndex, tokenId, owner);
    }

  function unwrap(uint256 tokenId) public {

    uint256 tokenIndex = tokenIndexList[tokenId];

    if (tokenIndex == 0) {
      revert TokenNotExist();
    }

    address owner = msg.sender;

    if (tokenList[tokenIndex].owner != owner) {
      revert TokenNotOwner();
    }

    delete tokenIndexList[tokenId];   
    delete tokenList[tokenIndex];

    for (uint256 index = 0; index < tokenOwnerList[owner].length; index++) {

      if (tokenOwnerList[owner][index] == tokenId) {
        delete tokenOwnerList[owner][index];
      }
    }

    _burn(tokenIndex);

    IPCCore(contractAddress).safeTransferFrom(
      address(this),
      owner,
      tokenId
    );
   
    emit Unwrapped(tokenIndex, tokenId, owner);
  }

  function _startTokenId()
    internal view virtual override
    returns (uint256) { return 1; }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
      return IERC721Receiver.onERC721Received.selector;
  }
}
