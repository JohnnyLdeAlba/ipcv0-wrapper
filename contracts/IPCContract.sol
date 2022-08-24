pragma solidity 0.8.9;

import "./ERC721.sol";

contract IPCContract is ERC721 {

  struct IpcMarketInfo {

    uint32 sellPrice;
    uint32 beneficiaryPrice;
    address beneficiaryAddress;
    address approvalAddress;
  }

  uint256 _nextTokenIndex;
  uint256 _totalSupply;

  constructor() ERC721("ImmortalPlayerCharacters", "IPC") {

    _nextTokenIndex = 1;
    _totalSupply = 1000;
  }

  function mint()
    external {

      if (_nextTokenIndex > _totalSupply)
        revert("MINTED_OUT");

      _safeMint(msg.sender, _nextTokenIndex);
      _nextTokenIndex++;
  }

  function getIpc(uint256 ipcId)
    external view returns (

    string memory,
    bytes32,
    bytes32,
    uint128,
    uint128) {

    string memory name = "Adam";
    bytes32 attributeSeed = keccak256(abi.encodePacked(block.timestamp, block.number % 3 * ipcId, msg.sender));
    bytes32 dna = keccak256(abi.encodePacked(block.timestamp, block.number % 5 * ipcId, msg.sender));
    uint128 experience = 0;
    uint128 timeOfBirth = 0;

    return (name, attributeSeed, dna, experience, timeOfBirth);
  }

  function ipcToMarketInfo(uint key)
    external view
    returns (IpcMarketInfo memory) {

    IpcMarketInfo memory marketInfo = IpcMarketInfo(0, 0, address(0), address(0));
    return marketInfo;
  }

  function setIpcPrice(uint tokenId, uint newPrice) external {}
  function changeIpcName(uint tokenId, string calldata newName) external payable {}

  function tokensOfOwner(address owner)
    external view
    returns (uint256[] memory){

      uint256 total = balanceOf(owner);
      uint256[] memory ownersTokens = new uint256[](total);
      for (uint256 index = 0; index < total; index++)
        ownersTokens[index] = index + 1;
 
      return ownersTokens;
  }

  function totalSupply()
    external view returns (uint256) {
    return _totalSupply;
  }
}
