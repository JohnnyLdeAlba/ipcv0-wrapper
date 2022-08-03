pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./ERC721A.sol";

interface IPCCore {

  event Logging(address sender);

  function getIpc(uint256 ipcId)
    external view returns (
    string calldata name,
    bytes32 attributeSeed,
    bytes32 dna,
    uint128 experience,
    uint128 timeOfBirth);

  function ownerOf(uint256 tokenId) external view returns (address);
  function totalSupply() external view returns (uint256);
  function setIpcPrice(uint tokenId, uint newPrice) external;
  function changeIpcName(uint tokenId, string calldata newName) external payable;

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId)
    external payable;
}

// add name changer
// multi searches
// display contract stats to admin

contract IPCV0Wrapper is Ownable, ERC721A__IERC721Receiver, ERC721A {

  struct t_token {
    uint tokenId;
    address owner;
  }

  address contractAddress;

  string _tokenURI;
  string _contractURI;

  // add money drainer!
  // set these!
  uint256 maxPrice;
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

    contractAddress = 0xE902e1aE262DCf161d6a2F1Be71fc16CC9AFDDD6;
    _tokenURI = "";
    _contractURI = "";

    maxPrice = 100000000;
    tokenLimit = 1000;
  }

  // Wrap function doesn't work without prior approval.
  function wrap(uint256 tokenId)
    external {

      if (tokenId > tokenLimit)
        revert TokenLimitReached();

      address owner = msg.sender;

      IPCCore(contractAddress).safeTransferFrom(
        owner,
	address(this),
	tokenId
      );

      IPCCore(contractAddress).setIpcPrice(tokenId, maxPrice);

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

  function changeIpcName(uint tokenId, string calldata newName)
    external payable {
      IPCCore(contractAddress).changeIpcName{value: msg.value}(tokenId, newName);
  }

  function _startTokenId()
    internal view virtual override
    returns (uint256) { return 1; }

  function _baseURI() internal view override returns (string memory) {
    return _tokenURI;
  }

  function setContractAddress(address _contractAddress) public onlyOwner {
    contractAddress = _contractAddress;
  }

  function setMaxPrice(uint256 _maxPrice) public onlyOwner {
    maxPrice = _maxPrice;
  }

  function setTokenLimit(uint256 _tokenLimit) public onlyOwner {
    tokenLimit = _tokenLimit;
  }

  function setTokenURI(string calldata __tokenURI) public onlyOwner {
    _tokenURI = __tokenURI;
  }

  function tokenURI(uint256 tokenId)
    public view override returns (string memory) {

      if (tokenId > tokenLimit || tokenId == 0)
        revert URIQueryForNonexistentToken();

      string memory baseURI = _baseURI();
      return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : '';
  }

  function setContractURI(string calldata __contractURI) public onlyOwner {
     _contractURI = __contractURI;
  }

  function contractURI() public view returns (string memory) {
    return _contractURI;
  }

  function getIpc(uint256 tokenId)
    external view returns (
      string memory name,
      bytes32 attributeSeed,
      bytes32 dna,
      uint128 experience,
      uint128 timeOfBirth
    ) {
      return IPCCore(contractAddress).getIpc(tokenId);
  }

  function ownerOf(uint256 tokenId)
    public view override returns (address) {

      uint256 tokenIndex = tokenIndexList[tokenId];
      if (tokenIndex == 0) {
        return IPCCore(contractAddress).ownerOf(tokenId); 
      }

      address owner = tokenList[tokenIndex].owner;
      return owner;
  }

  function getTokenIndex(uint256 tokenId)
    public view returns (uint256) {
      return tokenIndexList[tokenId];
  }

  function getTokenOwnership(uint256 tokenId)
    public view returns (address) {
        return IPCCore(contractAddress).ownerOf(tokenId); 
  }

/*
  function getAllTokens(uint256 startIndex, uint256 total)
    public view returns(memory) {

      uint256 totalTokens = totalSupply();
  }
*/
  function totalSupply() public view override returns (uint256) {
    return IPCCore(contractAddress).totalSupply();
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
      return ERC721A__IERC721Receiver.onERC721Received.selector;
  }

  function onERC721Received(
    address,
    uint256,
    bytes calldata
  ) external pure returns (bytes4) {
      return bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
  }
}
