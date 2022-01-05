// SPDX-License-Identifier: MIT
/*
 * JuiceBox.sol
 *
 * Created: October 27, 2021
 *
 * Price: FREE
 * Rinkeby: 0xc8280Ddb3De9463210544C49096905A1f28097b0
 * Mainnet:
 *
 * Description: An ERC-721 token that will be claimable by anyone who owns 'the Plug'
 *
 *  - There will be 4 variations, each with a different rarity (based on how likely it is
 *    to receive, i.e. v1:60%, v2:20%, v3:15%, v4:5%)
 *  - Owners with multiple Plugs will benefit through a distribution scheme that shifts 
 *    the probability of minting each variation towards 25%
 */

pragma solidity >=0.5.16 <0.9.0;

import "./Kasbeer721.sol";

//@title Juice Box
//@author Jack Kasbeer (gh:@jcksber, tw:@satoshigoat, ig:overprivilegd)
contract JuiceBox is Kasbeer721 {

	// -------------
	// EVENTS & VARS
	// -------------

	event JuiceBoxMinted(uint256 indexed a);
	event JuiceBoxBurned(uint256 indexed a);

	//@dev This is how we'll keep track of who has already minted a JuiceBox
	mapping (address => bool) internal _boxHolders;

	//@dev Keep track of which token ID is associated with which hash
	mapping (uint256 => string) internal _tokenToHash;

	//@dev Initial production hashes
	string [NUM_ASSETS] boxHashes = ["QmeiegMwsbZbaV8NXMkzSAQh86NYDty2L6spgHq8yYtpNf", 
									 "QmYrWUYmzr2BzeUTXQuzWDVZWyAp4QBcUe9K9Y2xzKDEcm", 
									 "QmYwFgSkafPN6eTPw8ge6dbbTVQ7zooPiX9jubXD9Xbyqy", 
									 "QmW2fhH3KqbQNK7dqB8FrgD29DQfe31sbnZzi1AF1JXRGA"];
									 //cherry, berry, kiwi, lemon

	//@dev Associated weights of probability for hashes
	uint16 [NUM_ASSETS] boxWeights = [60, 20, 15, 5];//cherry, berry, kiwi, lemon

	constructor() Kasbeer721("Juice Box", "") {
		_whitelistActive = true;
	}

	// -----------
	// RESTRICTORS
	// -----------

	modifier boxAvailable()
	{
		require(getCurrentId() < MAX_NUM_TOKENS, "JuiceBox: no JuiceBox's left to mint");
		_;
	}

	modifier tokenExists(uint256 tokenId)
	{
		require(_exists(tokenId), "JuiceBox: nonexistent token");
		_;
	}

	// ---------------
	// JUICE BOX MAGIC 
	// ---------------

	//@dev Override 'tokenURI' to account for asset/hash cycling
	function tokenURI(uint256 tokenId) 
		public view virtual override tokenExists(tokenId) 
		returns (string memory) 
	{	
		return string(abi.encodePacked(_baseURI(), _tokenToHash[tokenId]));
	}

	//// ----------------------
    //// IPFS HASH MANIPULATION
    //// ----------------------

    //@dev Get the hash stored at `idx` 
	function getHashByIndex(uint8 idx) public view hashIndexInRange(idx)
	  returns (string memory)
	{
		return boxHashes[idx];
	}

	//@dev Allows us to update the IPFS hash values (one at a time)
	// 0:cherry, 1:berry, 2:kiwi, 3:lemon
	function updateHashForIndex(uint8 idx, string memory str) 
		public isSquad hashIndexInRange(idx)
	{
		boxHashes[idx] = str;
	}

    // ------------------
    // MINTING & CLAIMING
    // ------------------

    //@dev Allows owners to mint for free
    function mint(address to) public virtual override isSquad boxAvailable
    	returns (uint256)
    {
    	return _mintInternal(to);
    }

    //@dev Claim a JuiceBox if you're a Plug holder
    function claim(address payable to, uint16 numPlugs) 
    	public payable whitelistEnabled onlyWhitelist(to) boxAvailable 
    	returns (uint256 tid, string memory hash)
    {
    	require(!_boxHolders[to], "JuiceBox: cannot claim more than 1");
    	require(!_isContract(to), "JuiceBox: silly rabbit :P");

    	tid = _mintInternal(to);
    	hash = _assignHash(tid, numPlugs);
    }

	//@dev Mints a single Juice Box & updates `_boxHolders` accordingly
	function _mintInternal(address to) internal virtual returns (uint256)
	{
		_incrementTokenId();

		newId = getCurrentId();

		_safeMint(to, newId);
		_markAsClaimed(to);

		emit JuiceBoxMinted(newId);

		return newId;
	}

	//@dev Based on the number of Plugs owned by the sender, randomly select 
	// a JuiceBox hash that will be associated with their token id
	function _assignHash(uint256 tokenId, uint8 numPlugs) private tokenExists(tokenId)
		returns (string memory hash)
	{
		uint8[] memory weights = new uint8[](NUM_ASSETS);
		//calculate new weights based on `numPlugs`
		if (numPlugs > 10) numPlugs = 10;
		weights[0] = uint8(boxWeights[0] - 35*((numPlugs-1)/10));//cherry: 60% -> 25%
		weights[1] = uint8(boxWeights[1] +  5*((numPlugs-1)/10));//berry:  20% -> 25%
		weights[2] = uint8(boxWeights[2] + 10*((numPlugs-1)/10));//kiwi:   15% -> 25%
		weights[3] = uint8(boxWeights[3] + 20*((numPlugs-1)/10));//lemon:   5% -> 25%

		uint16 rnd = random() % 100;//should be b/n 0 & 100
		//randomly select a juice box hash
		uint8 i;
		for (i = 0; i < NUM_ASSETS; i++) {
			if (rnd < weights[i]) {
				hash = boxHashes[i];
				break;
			}
			rnd -= weights[i];
		}
		//assign the selected hash to this token id
		_tokenToHash[tokenId] = hash;

		return hash;
	}

	//@dev Update `_boxHolders` so that `a` cannot claim another juice box
	function _markAsClaimed(address a) private
	{
		_boxHolders[a] = true;
	}

	function getHashForTid(uint256 tid) public view tokenExists(tid) 
		returns (string memory)
	{
		return _tokenToHash[tid];
	}

	//@dev Pseudo-random number generator
	function random() public view returns (uint16 rnd)
	{
		return uint16(uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, boxWeights))));
	}
}
