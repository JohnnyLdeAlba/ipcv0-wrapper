pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

interface IPCCore {

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

contract IPCWrapper is Ownable, IERC721Receiver, ERC721 {

  using Strings for uint256;

  struct t_properties {

    address contractAdress;
    string tokenURI;
    string contractURI;
    uint256 maxPrice;
    uint256 tokenLimit;
    bool marketPlaceEnabled;
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
  bool marketPlaceEnabled;

  // mapping(uint256 => t_token) tokens;
  // mapping(uint256 => uint256) tokenIndexList;
  mapping(address => uint256[]) tokensOfOwner;

  event Wrapped(uint256 tokenId, address owner);
  event Unwrapped(uint256 tokenId, address owner);
  event nameChangeOK(uint256 tokenId, string name);

  constructor() ERC721("Immortal Player Characters v0", "IPCV0") {

    contractAddress = 0xACE8AA6699F1E71f07622135A93140cA296D610a;
    _tokenURI = "https://nexusultima.com/ipcv0/tokens/";
    _contractURI = "https://nexusultima.com/ipcv0/contract/";

    maxPrice = 1000000;
    tokenLimit = 1000;
    marketPlaceEnabled = true;
  }

  function _removeOwnersToken(address owner, uint256 tokenId) 
    private {

      uint256 total = tokensOfOwner[owner].length;
      for (uint256 index = 0; index < total; index++) {

        if (tokensOfOwner[owner][index] == tokenId) {

          tokensOfOwner[owner][index] = tokensOfOwner[owner][total - 1];
  	  tokensOfOwner[owner].pop();

	  break;
        }
      }
  }

  function _swapTokenOwner(address from, address to, uint256 tokenId)
    private {

      if (from == address(0))
        return;

      _removeOwnersToken(from, tokenId);
      tokensOfOwner[to].push(tokenId);
  }

  // Wrap function doesn't work without prior approval.
  function wrap(uint256 tokenId)
    external {

      if (tokenId > tokenLimit && _exists(tokenId) == false)
        revert("TOKEN_LIMIT_REACHED");

      address sender = msg.sender;

      // If the token was stolen _exists will not be equal to false. We want the function to wrap
      // reguardless, otherwise the database could get corrupted.

      if (_exists(tokenId)) {

        if (wOwnerOf(tokenId) != sender)
          revert("NOT_OWNERS_TOKEN");
	else
	  revert("TOKEN_ALREADY_WRAPPED");
      }

      address sourceOwner = uwOwnerOf(tokenId);
      if (sourceOwner != sender)
        revert("NOT_OWNERS_TOKEN");

      IPCCore(contractAddress).safeTransferFrom(
        sender,
	address(this),
	tokenId
      );

      if (marketPlaceEnabled)
        IPCCore(contractAddress).setIpcPrice(tokenId, maxPrice);


      _safeMint(sender, tokenId);

      emit Wrapped(tokenId, sender);
  }

  function unwrap(uint256 tokenId) public {

    if (_exists(tokenId) == false)
      revert("TOKEN_NOT_WRAPPED");

    address sourceOwner = uwOwnerOf(tokenId);

    if (wOwnerOf(tokenId) != msg.sender) {

      if (sourceOwner != msg.sender)
        revert("NOT_OWNERS_TOKEN");
    }

    _burn(tokenId);

    // If sourceOwner is not equal to contract then the token was stolen and the function will unwrap anyways. 
    if (sourceOwner == address(this)) {

      IPCCore(contractAddress).safeTransferFrom(
        address(this),
        msg.sender,
        tokenId
      );
    }

    emit Unwrapped(tokenId, msg.sender);
  }

  // changeIpcName only works on wrapped tokens.
  function changeIpcName(uint tokenId, string calldata newName)
    external payable {

      if (wOwnerOf(tokenId) != msg.sender)
        revert("TOKEN_NOT_OWNER");

      if (marketPlaceEnabled == false)
        revert("MARKETPLACE_DISABLED");

      IPCCore(contractAddress).changeIpcName{value: msg.value}(tokenId, newName);
      emit nameChangeOK(tokenId, newName);
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

      // consdier adding marketplaceinfo and more.

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

  // make a tokenIds function too
  function getTokensOfOwner(address owner, uint256 startIndex, uint256 total)
    public view
    returns(t_raw_ipc[] memory){

      uint256[] memory ownersTokens = tokensOfOwner[owner];
      uint256 totalTokens = ownersTokens.length;

      if (startIndex > totalTokens)
        startIndex = 0;

      if (totalTokens > 0) {

        if (total == 0 || total > totalTokens - startIndex)
          total = totalTokens - startIndex;
      }
      else {

        totalTokens = 0;
	total = 1;
      }

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

  function wOwnerOf(uint256 tokenId)
    public view returns (address) {
        return super.ownerOf(tokenId); 
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

      if (totalTokens > 0) {
        if (total == 0 || total > totalTokens + 1 - startIndex)
          total = totalTokens - startIndex;
      }
      else {

        totalTokens = 0;
	total = 1;
      }

      t_raw_ipc[] memory tokensList = new t_raw_ipc[](total);
      if (totalTokens == 0)
        return tokensList;

      uint256 index;
      for (index = 0; index < total; index++) {

        uint256 tokenId = startIndex + index;
        t_raw_ipc memory token = getIpc(tokenId);

        tokensList[index] = token;
      }

      return tokensList;
  }

  function uwBalanceOf(address owner)
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

      if (totalTokens > 0) {

        if (total == 0 || total > totalTokens - startIndex)
          total = totalTokens - startIndex;
     }
     else {

       totalTokens = 0;
       total = 1;
     }

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

  function setContractAddress(address _contractAddress) public onlyOwner {
    contractAddress = _contractAddress;
  }

  // need a set marketplaceenabled function
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
        tokenLimit,
	marketPlaceEnabled
      );

    return status;
  }

  function withdrawalVault()
    external
    onlyOwner {

    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "VAULT_TRANSFER_FAILED");
  }

  function _baseURI() internal view override returns (string memory) {
    return _tokenURI;
  }

  function contractURI() public view returns (string memory) {
    return _contractURI;
  }

  function totalSupply() public view returns (uint256) {
    return IPCCore(contractAddress).totalSupply();
  }

  function ownerOf(uint256 tokenId)
    public view override returns (address) {

      if (_exists(tokenId) == false) {
        return IPCCore(contractAddress).ownerOf(tokenId); 
      }

      return super.ownerOf(tokenId);
  }

  function _afterTokenTransfers(
    address from,
    address to,
    uint256 tokenId
  ) internal {

      // mint
      if (from == address(0))
        tokensOfOwner[msg.sender].push(tokenId);
      // burn
      else if (to == address(0))
        _removeOwnersToken(from, tokenId);
      // transfer
      else
        _swapTokenOwner(from, to, tokenId);
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
      return IERC721Receiver.onERC721Received.selector;
  }

  // Required by the IPC contract.
  function onERC721Received(
    address,
    uint256,
    bytes calldata
  ) external pure returns (bytes4) {
      return bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
  }

}
