// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataStorage {

address dataFeedStore = 0xc04b335A75C5Fa14246152178f6834E3eBc2DC7C;

function getDataById(
  uint32 key
) external view returns (uint256 value, uint64 timestamp) {
  (bool success, bytes memory returnData) = dataFeedStore.staticcall(
    abi.encodePacked(0x80000000 | key)
  );
  require(success, "DataFeedStore: call failed");
 
  bytes32 data = bytes32(returnData);
  return (uint256(uint192(bytes24(data))), uint64(uint256(data)));
}

function getDataById2(
  uint32 key
) external view returns (uint64 data) {
  (bool success, bytes memory returnData) = dataFeedStore.staticcall(
    abi.encodePacked(0x80000000 | key)
  );
  require(success, "DataFeedStore: call failed");
 
  bytes32 data = bytes32(returnData);
  return uint64(uint256(data));
  //return (uint256(uint192(bytes24(data))), uint64(uint256(data)));
}

    // Define the struct for storing data
    struct DataType {
        bytes32 text;
        int value1;
        int value2;  // Second integer multiplied by 10 for calculation later use 
    }

    // Define the mapping from address to DataType
    mapping(address => DataType) public data;

    function bytes32ToString(bytes32 _data) public pure returns (string memory) {
        // Calculate the length of the string (up to 32 bytes)
        uint256 length = 0;
        for (uint256 i = 0; i < 32; i++) {
            // Check if the byte is non-zero
            if (_data[i] != 0) {
                length++;
            }
        }

        // Create a string with the determined length
        bytes memory result = new bytes(length);

        // Fill the string with the non-zero bytes
        for (uint256 i = 0; i < length; i++) {
            result[i] = _data[i];
        }

        return string(result);
    }


    // Function to store the data in the mapping
    function storeData(int _value, string memory _text) public {
        // Calculate the second integer (multiplied by 10)
        int secondValue = _value * 67621274133825; // conversion value gotten from the oracle

        bytes32 _hashed = keccak256(abi.encodePacked(_text));

        // Store the data in the mapping
        data[msg.sender] = DataType(_hashed, _value, secondValue);
    }

    // Function to retrieve data for a specific address
    function getData(address _addr) public view returns (bytes32, int, int) {
        DataType memory d = data[_addr];
        return (d.text, d.value1, d.value2);
    }
}
