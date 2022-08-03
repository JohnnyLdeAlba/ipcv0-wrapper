pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
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
  function tokensOfOwner(address owner) external view returns (uint256[] memory);
  function totalSupply() external view returns (uint256);
  function setIpcPrice(uint tokenId, uint newPrice) external;
  function changeIpcName(uint tokenId, string memory newName) external payable;

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId)
    external payable;
}

contract IPCWrapper is Ownable, ERC721A__IERC721Receiver, ERC721A {

  using Strings for uint256;

  struct t_properties {

    address contractAdress;
    string tokenURI;
    string contractURI;
    uint256 maxPrice;
    uint256 tokenLimit;
  }

  struct t_token {
    uint tokenId;
    address owner;
  }

  struct t_raw_ipc {
    uint256 tokenId;
    string name;
    bytes32 attributeSeed;
    bytes32 dna;
    uint128 experience;
    uint128 timeOfBirth;
    address owner;
  }

  address contractAddress;

  string _tokenURI;
  string _contractURI;


  uint256 maxPrice;
  uint256 tokenLimit;

  mapping(uint256 => t_token) tokenList;
  mapping(uint256 => uint256) tokenIndexList;
  mapping(address => uint256[]) tokenOwnerList;

  event Wrapped(uint256, uint256, address);
  event Unwrapped(uint256, uint256, address);

  error TokenLimitReached();
  error TokenDoesntExist();
  error TokenNotOwner();

  constructor() ERC721A("Immortal Player Characters v0", "IPCV0") {

    contractAddress = 0xEd0bC1F0A364e4e4fd275D663397268ce88610ff;
    _tokenURI = "https://website.com/token/";
    _contractURI = "https://website.com/contract/";

    maxPrice = 1000000;
    tokenLimit = 1000;
  }

  // Wrap function doesn't work without prior approval.
  function wrap(uint256 tokenId)
    external {

      uint256 tokenIndex = tokenIndexList[tokenId];

      if (tokenId > tokenLimit && tokenIndex == 0)
        revert TokenLimitReached();

      address owner = msg.sender;

      IPCCore(contractAddress).safeTransferFrom(
        owner,
	address(this),
	tokenId
      );

      IPCCore(contractAddress).setIpcPrice(tokenId, maxPrice);

      // If the token was stolen tokenIndex will not be equal to 0. We want the function to wrap
      // reguardless, otherwise the database could get corrupted.
      if (tokenIndex == 0)
        tokenIndex = _nextTokenId();

      tokenList[tokenIndex] = t_token(tokenId, owner);
      tokenIndexList[tokenId] = tokenIndex;
      tokenOwnerList[owner].push(tokenIndex);

      _safeMint(owner, 1);
      emit Wrapped(tokenIndex, tokenId, owner);
    }

  function unwrap(uint256 tokenId) public {

    uint256 tokenIndex = tokenIndexList[tokenId];

    if (tokenIndex == 0) {
      revert TokenDoesntExist();
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

    address sourceOwner = ownerOf(tokenId);
    _burn(tokenIndex);

    // If sourceOwner is not equal to contract then the token was stolen and the function will unwrap anyways. 
    if (sourceOwner == address(this)) {

      IPCCore(contractAddress).safeTransferFrom(
        address(this),
        owner,
        tokenId
      );
    }
   
    emit Unwrapped(tokenIndex, tokenId, owner);
  }

  function changeIpcName(uint tokenId, string calldata newName)
    external payable {

      uint256 tokenIndex = tokenIndexList[tokenId];

      if (tokenList[tokenIndex].owner != msg.sender)
        revert TokenNotOwner();

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

  function setProperties(
    uint256 _maxPrice,
    uint256 _tokenLimit,
    string calldata __tokenURI,
    string calldata __contractURI
  ) public onlyOwner {

      maxPrice = _maxPrice;
      tokenLimit = _tokenLimit;

      _tokenURI = __tokenURI;
      _contractURI = __contractURI;
  }

  function getProperties()
    public view onlyOwner
    returns (t_properties memory) {

      t_properties memory status = t_properties(
        contractAddress,
        _tokenURI,
        _contractURI,
        maxPrice,
        tokenLimit
      );

    return status;
  }

  function tokenURI(uint256 tokenId)
    public view override returns (string memory) {

      if (tokenId > tokenLimit || tokenId == 0)
        revert URIQueryForNonexistentToken();

      string memory baseURI = _baseURI();
      return bytes(baseURI).length != 0 ? string(abi.encodePacked(baseURI, _toString(tokenId))) : '';
  }

  function contractURI() public view returns (string memory) {
    return _contractURI;
  }

  function getIpc(uint256 tokenId)
    public view
    returns (t_raw_ipc memory) {
        
      (
        string memory name,
        bytes32 attributeSeed,
	bytes32 dna,
	uint128 experience,
	uint128 timeOfBirth
      ) = IPCCore(contractAddress).getIpc(tokenId);

      address owner = ownerOf(tokenId);
      t_raw_ipc memory token = t_raw_ipc(	  
        tokenId,
        name,
        attributeSeed,
        dna,
        experience,
        timeOfBirth,
        owner
      );

      return token;
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

  function getAllTokens(uint256 startIndex, uint256 total)
    public view
    returns(t_raw_ipc[] memory) {

      uint256 totalTokens = totalSupply();

      if (startIndex == 0 || startIndex > totalTokens)
        startIndex = 1;

      if (total == 0 || total > totalTokens - startIndex)
        total = totalTokens - startIndex;

      t_raw_ipc[] memory tokensList = new t_raw_ipc[](total);

      if (totalTokens == 0)
        return tokensList;

      uint256 index;
      for (index = 0; index <= total; index++) {

        uint256 tokenId = startIndex + index;
        t_raw_ipc memory token = getIpc(tokenId);

        tokensList[index] = token;
      }

      return tokensList;
   }

  function getTokensOfOwner(address owner, uint256 startIndex, uint256 total)
    public view
    returns(t_raw_ipc[] memory){

      uint256[] memory tokensOfOwner = IPCCore(contractAddress).tokensOfOwner(owner);
      uint256 totalTokens = tokensOfOwner.length;

      if (startIndex > totalTokens)
        startIndex = 0;

      if (total == 0 || total > totalTokens - startIndex)
        total = (totalTokens - 1) - startIndex;

      t_raw_ipc[] memory tokensList = new t_raw_ipc[](total);

      if (totalTokens == 0)
        return tokensList;

      uint256 index;
      uint256 tokenId;
      t_raw_ipc memory token;

      for (index = 0; index < total; index++) {

        tokenId = tokensOfOwner[startIndex + index];
        token = getIpc(tokenId);

	tokensList[index] = token;
      }

      return tokensList;
  }

  function totalSupply() public view override returns (uint256) {
    return IPCCore(contractAddress).totalSupply();
  }

  function withdrawalVault()
    external
    onlyOwner {

    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "VAULT_TRANSFER_FAILED");
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
