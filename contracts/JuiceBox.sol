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
 *  - There will be 3 variations, each with a different rarity (based on how likely it is
 *    to receive, i.e. v1:85%, v2:10%, v3:5%)
 *  - Owners with multiple Plugs will benefit through a distribution scheme that shifts 
 *    the probability of minting each variation towards 33%
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

	//@dev Associated weights of probability for hashes
	uint16 [NUM_ASSETS] boxWeights = [85, 10, 5];
	uint16 [NUM_ASSETS] boxWeightModifiers = [52, 23, 28];

	//@dev Initial production hashes
	string [NUM_ASSETS] boxHashes = ["FILL_ME_IN", "FILL_ME_IN", "FILL_ME_IN"];

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
		returns (string memory uri) 
	{	
		uri = string(abi.encodePacked(_baseURI(), _tokenToHash[tokenId]));
		return uri;
	}

	function _beforeTokenTransfer(address from, address to, uint256 tokenId)
		internal virtual override
	{
		// DO WE WANT TO PREVENT PEOPLE FROM HAVING MORE THAN ONE IN THEIR WALLET?
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
	function updateHash(uint8 idx, string memory str) 
		public isSquad hashIndexInRange(idx)
	{
		boxHashes[idx] = str;
	}

	//@dev Determine if '_assetHash' is one of the IPFS hashes in asset hashes
	function _hashExists(string memory assetHash) internal view returns (bool) 
	{
		uint8 i;
		for (i = 0; i < NUM_ASSETS; i++) {
			if (_stringsEqual(assetHash, boxHashes[i])) {
				return true;
			}
		}
		return false;
	}

    // ------------------
    // MINTING & CLAIMING
    // ------------------

    //@dev Allows owners to mint for free
    function mint(address to) public virtual override isSquad boxAvailable
    	returns (uint256 tid)
    {
    	tid = _mintInternal(to);

    	return tid;
    }

    //@dev Claim a JuiceBox if you're a Plug holder
    function claim(address payable to, uint16 numPlugs) 
    	public payable whitelistEnabled onlyWhitelist(to) boxAvailable 
    	returns (uint256 tid, string memory hash)
    {
    	require(!_boxHolders[to], "JuiceBox: cannot claim more than 1");
    	require(!_isContract(to), "JuiceBox: contracts cannot mint");

    	tid = _mintInternal(to);
    	hash = _assignHash(tid, numPlugs);

    	return (tid, hash);
    }

	//@dev Mints a single Juice Box & updates `boxHolders` accordingly
	function _mintInternal(address to) internal virtual returns (uint256 newId)
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
	function _assignHash(uint256 tokenId, uint16 numPlugs) private tokenExists(tokenId)
		returns (string memory hash)
	{
		uint8[] memory weights = new uint8[](NUM_ASSETS);
		/*
		85 - 52*((owned-1)/total) //85% -> 33%
		10 + 23*((owned-1)/total) //10% -> 33%
		5 +  28*((owner-1)/total) // 5% -> 33%
		*/
		//calculate new weights based on `numPlugs` 
		weights[0] = uint8(boxWeights[0] - boxWeightModifiers[0]*((numPlugs-1)/NUM_PLUGS));
		weights[1] = uint8(boxWeights[1] + boxWeightModifiers[1]*((numPlugs-1)/NUM_PLUGS));
		weights[2] = uint8(boxWeights[2] + boxWeightModifiers[2]*((numPlugs-1)/NUM_PLUGS));

		uint8 i;
		uint16 rnd = random() % 100;//should be b/n 0 & 100
		//randomly select a juice box hash
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

	//@dev Pseudo-random number generator
	function random() public view returns (uint16 rnd)
	{
		return uint16(uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, boxWeights))));
	}//NOTE: should we use boxWeights or something else...?
}
