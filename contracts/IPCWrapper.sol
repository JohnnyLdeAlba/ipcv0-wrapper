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
  function changeIpcName(uint tokenId, string calldata newName) external payable;

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId)
    external payable;
}

contract IPCWrapper is Ownable, ERC721A__IERC721Receiver, ERC721A {

  using Strings for uint256;

  struct t_debug {
    uint256 d1;
    uint256 d2;
    uint256 d3;
    uint256 d4;
    address a1;
    string buffer;
  }

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

  t_debug debug;
  address contractAddress;

  string _tokenURI;
  string _contractURI;


  uint256 maxPrice;
  uint256 tokenLimit;

  mapping(uint256 => t_token) tokens;
  mapping(uint256 => uint256) tokenIndexList;
  mapping(address => uint256[]) tokensOfOwner;

  event Wrapped(uint256, uint256, address);
  event Unwrapped(uint256, uint256, address);
  event nameChangeOK(uint256, string);

  constructor() ERC721A("Immortal Player Characters v0", "IPCV0") {

    contractAddress = 0xf3a8BB61d607c5Fa0a9FBd995c16D412F639731F;
    _tokenURI = "https://website.com/token/";
    _contractURI = "https://website.com/contract/";

    maxPrice = 0;
    tokenLimit = 1000;
  }

  function setDebugger(
    uint256 d1,
    uint256 d2,
    uint256 d3,
    uint256 d4,
    address a1,
    string calldata buffer
  )
    internal
    returns (t_debug memory) {

      debug.d1 = d1;
      debug.d2 = d2;
      debug.d3 = d3;
      debug.d4 = d4;
      debug.a1 = a1;

      debug.buffer = buffer;
 }

 function getDebugger()
   external view
   returns (
     uint256 d1,
     uint256 d2,
     uint256 d3,
     uint256 d4,
     address a1,
     string memory buffer
   ) { return (debug.d1, debug.d2, debug.d3, debug.d4, debug.a1, debug.buffer); }

  // Wrap function doesn't work without prior approval.
  function wrap(uint256 tokenId)
    external {

      uint256 tokenIndex = tokenIndexList[tokenId];

      if (tokenId > tokenLimit && tokenIndex == 0)
        revert("TOKEN_LIMIT_REACHED");

      address owner = msg.sender;

      // If the token was stolen tokenIndex will not be equal to 0. We want the function to wrap
      // reguardless, otherwise the database could get corrupted.

      if (tokenIndex != 0) {

        if (tokens[tokenIndex].owner != owner) {
          revert("NOT_OWNERS_TOKEN");
        }
	else {
	  revert("TOKEN_ALREADY_WRAPPED");
	}
      }
      else {
        tokenIndex = _nextTokenId();
      }

      IPCCore(contractAddress).safeTransferFrom(
        owner,
	address(this),
	tokenId
      );

      IPCCore(contractAddress).setIpcPrice(tokenId, maxPrice);

      tokens[tokenIndex] = t_token(tokenId, owner);
      tokenIndexList[tokenId] = tokenIndex;
      tokensOfOwner[owner].push(tokenIndex);

      _safeMint(owner, 1);
      emit Wrapped(tokenIndex, tokenId, owner);
  }

  function unwrap(uint256 tokenId) public {

    uint256 tokenIndex = tokenIndexList[tokenId];

    if (tokenIndex == 0) {
      revert("TOKEN_DOES_NOT_EXIST");
    }

    address owner = msg.sender;

    if (tokens[tokenIndex].owner != owner) {
      revert("NOT_OWNERS_TOKEN");
    }

    delete tokenIndexList[tokenId];
    delete tokens[tokenIndex];

    for (uint256 index = 0; index < tokensOfOwner[owner].length; index++) {

      if (tokensOfOwner[owner][index] == tokenId) {
        delete tokensOfOwner[owner][index];
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

  // changeIpcName only works on wrapped tokens.
  function changeIpcName(uint tokenId, string calldata newName)
    external payable {

      uint256 tokenIndex = tokenIndexList[tokenId];

      if (tokens[tokenIndex].owner != msg.sender)
        revert("TOKEN_NOT_OWNER");

      IPCCore(contractAddress).changeIpcName{value: msg.value}(tokenId, newName);
      emit nameChangeOK(tokenId, newName);
  }

  function setContractAddress(address _contractAddress) public onlyOwner {
    contractAddress = _contractAddress;
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

      address owner = tokens[tokenIndex].owner;
      return owner;
  }

  function getTokenIndex(uint256 tokenId)
    public view returns (uint256) {
      return tokenIndexList[tokenId];
  }

  function getOwnerTokenTotals(address owner)
    public view
    returns(uint256){
      return tokensOfOwner[owner].length;
  }

  function getTokensOfOwner(address owner, uint256 startIndex, uint256 total)
    public view
    returns(t_raw_ipc[] memory){

      uint256[] memory ownersTokens = tokensOfOwner[owner];
      uint256 totalTokens = ownersTokens.length;
  
      if (startIndex > totalTokens)
        startIndex = 0;

      if (total == 0 || total > totalTokens - startIndex)
        total = totalTokens - startIndex;

      t_raw_ipc[] memory tokensList = new t_raw_ipc[](total);
      if (totalTokens == 0)
        return tokensList;

      uint256 index;
      uint256 tokenId;

      t_raw_ipc memory token;

      for (index = 0; index < total; index++) {

        tokenId = ownersTokens[startIndex + index];
        token = getIpc(tokenId);

	tokensList[index] = token;
      }

      return tokensList;
  }

  function uwOwnerOf(uint256 tokenId)
    public view returns (address) {
        return IPCCore(contractAddress).ownerOf(tokenId); 
  }

  function uwGetAllTokens(uint256 startIndex, uint256 total)
    public view
    returns(t_raw_ipc[] memory) {

      uint256 totalTokens = totalSupply();

      if (startIndex == 0 || startIndex > totalTokens)
        startIndex = 1;

      if (total == 0 || total > totalTokens + 1 - startIndex)
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

  function uwGetOwnerTokenTotals(address owner)
    public view
    returns(uint256){

      uint256[] memory ownersTokens = IPCCore(contractAddress).tokensOfOwner(owner);
      return ownersTokens.length;
  }

  function uwGetTokensOfOwner(address owner, uint256 startIndex, uint256 total)
    public view
    returns(t_raw_ipc[] memory){

      uint256[] memory ownersTokens = IPCCore(contractAddress).tokensOfOwner(owner);
      uint256 totalTokens = ownersTokens.length;
  
      if (startIndex > totalTokens)
        startIndex = 0;

      if (total == 0 || total > totalTokens - startIndex)
        total = totalTokens - startIndex;

      t_raw_ipc[] memory tokensList = new t_raw_ipc[](total);
      if (totalTokens == 0)
        return tokensList;

      uint256 index;
      uint256 tokenId;
      t_raw_ipc memory token;

      for (index = 0; index < total; index++) {

        tokenId = ownersTokens[startIndex + index];
        token = getIpc(tokenId);

	tokensList[index] = token;
      }

      return tokensList;
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


  function withdrawalVault()
    external
    onlyOwner {

    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "VAULT_TRANSFER_FAILED");
  }

  function _startTokenId()
    internal view virtual override
    returns (uint256) { return 1; }

  function contractURI() public view returns (string memory) {
    return _contractURI;
  }

  function _baseURI() internal view override returns (string memory) {
    return _tokenURI;
  }

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

  function _afterTokenTransfers(
    address from,
    address to,
    uint256 startTokenId,
    uint256 quantity
  ) internal virtual override {

    uint256 tokenIndex = tokenIndexList[startTokenId]; 
    tokens[tokenIndex].owner = to;

    for (uint256 index = 0; index < tokensOfOwner[from].length; index++) {

      if (tokensOfOwner[from][index] == startTokenId) {
      
        tokensOfOwner[from][tokenIndex] = tokensOfOwner[from][tokensOfOwner[from].length - 1];
	tokensOfOwner[from].pop();

      }
    }

    tokensOfOwner[to].push(startTokenId);
  }
}
