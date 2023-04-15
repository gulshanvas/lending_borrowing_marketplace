// // SPDX-License-Identifier: MIT
// // OpenZeppelin Contracts (last updated v4.7.0) (utils/structs/EnumerableMap.sol)

// pragma solidity ^0.8.18;

// import "hardhat/console.sol";

// // import "./EnumerableSet.sol";

// library StructuredLinkedList {
//     // EnumerableMap.Node public head;
//     struct UserInfo {
//         address user;
//         uint256 amount;
//         bytes32 next;
//     }

//     struct Node {
//         uint256 data;
//         uint256 count;
//         bytes32 next;
//         UserInfo userInfo;
//         // mapping(uint256 => Node) nodeList;
//     }

//     function insert(
//         Node memory _newNode,
//         mapping(bytes32 => StructuredLinkedList.Node) storage _listNodes,
//         bytes32 key,
//         bytes32 _interestRate,
//         uint256 data,
//         uint256 _newInterestRate,
//         uint256 _headInterestRate
//     ) internal returns (uint256, uint256, bytes32) {
//         console.log("inside insert");
//         Node storage head = _listNodes[bytes32(_headInterestRate)];
//         UserInfo memory userInfo = UserInfo({
//             user: address(0),
//             amount: 10,
//             next: bytes32(0)
//         });
//         console.log("yahan aaya 2 ");
//         if (head.count == 0) {
//             head.count += 1;
//             _listNodes[bytes32(_headInterestRate)] = Node({
//                 data: data,
//                 count: 1,
//                 next: bytes32(0),
//                 userInfo: userInfo
//             });
//         } else {
//             console.log("yahan aaya 1 ");
//             // consider if the liquidity is being added on head
//             Node storage nextNode = _listNodes[bytes32(_headInterestRate)];
//             console.log("nextNode data ", nextNode.data);
//             console.log("nextNode count ", nextNode.count);
//             // console.log("nextNode next ", nextNode.next);
//             // nextNode

//             // 1 node already present
//             if ((nextNode.next & bytes32(0)) == 0) {
//                 if (_newInterestRate == nextNode.data) {
//                     nextNode.count += 1;
//                     head.count += 1;
//                     return (head.data, head.count, head.next);
//                 } else if (_newInterestRate < nextNode.data) {
//                     head.count += 1;
//                     _listNodes[bytes32(_newNode.data)] = Node({
//                         data: data,
//                         count: 1,
//                         next: bytes32(nextNode.data),
//                         userInfo: userInfo
//                     });

//                     nextNode.next = bytes32(type(uint).max);
//                 } else {
//                     head.count += 1;
//                     _listNodes[bytes32(_newNode.data)] = Node({
//                         data: data,
//                         count: 1,
//                         next: bytes32(type(uint).max),
//                         userInfo: userInfo
//                     });

//                     nextNode.next = bytes32(_newNode.data);
//                 }

//                 return (head.data, head.count, head.next);
//             }

//             while (nextNode.next != bytes32(type(uint).max)) {
//                 console.log("_newInterestRate ", _newInterestRate);
//                 if (nextNode.data == _newInterestRate) {
//                     console.log("yahan aaya");
//                     nextNode.count += 1;
//                     return (head.data, head.count, head.next);
//                 } else {
//                     Node storage nextNextNode = _listNodes[nextNode.next];
//                     console.log("after next next node");
//                     if (
//                         nextNode.data < _newInterestRate &&
//                         nextNextNode.data > _newInterestRate &&
//                         nextNextNode.next != bytes32(type(uint).max)
//                     ) {
//                         console.log("inside if after next next node");
//                         // simply add node and change pointing
//                         // bytes32 nextNodeKey = nextNode.next;
//                         // uint256 nextNodeData = nextNode.data;
//                         // uint256 nextNodeCount = nextNode.count;
//                         nextNode.next = bytes32(_newInterestRate);

//                         _newNode.next = bytes32(nextNextNode.data);
//                         _newNode.count = 1;
//                         _listNodes[bytes32(_newNode.data)] = _newNode;
//                         return (head.data, head.count, head.next);
//                     }

//                     // last node
//                     if (nextNode.next == bytes32(type(uint).max)) {
//                         if (nextNode.data < _newInterestRate) {
//                             _newNode.next = bytes32(type(uint).max);
//                             _newNode.count = 1;
//                             _listNodes[nextNode.next] = _newNode;
//                         }
//                     }

//                     nextNode = _listNodes[nextNode.next];
//                     // else if(nextNextNode.next == bytes32(type(uint).max)) {
//                     //     if(nextNode.data < _newNode.data && nextNextNode.data > _newNode.data) {
//                     //     nextNode.next = bytes32(_newNode.data);
//                     //     _newNode.next = bytes32(nextNextNode.data);
//                     //     _newNode.count = 1;
//                     //     _listNodes[bytes32(_newNode.data)] = _newNode;

//                     //     }
//                     // }
//                 }
//             }
//         }
//     }
// }

// /**
//  * @dev Library for managing an enumerable variant of Solidity's
//  * https://solidity.readthedocs.io/en/latest/types.html#mapping-types[`mapping`]
//  * type.
//  *
//  * Maps have the following properties:
//  *
//  * - Entries are added, removed, and checked for existence in constant time
//  * (O(1)).
//  * - Entries are enumerated in O(n). No guarantees are made on the ordering.
//  *
//  * ```
//  * contract Example {
//  *     // Add the library methods
//  *     using EnumerableMap for EnumerableMap.UintToAddressMap;
//  *
//  *     // Declare a set state variable
//  *     EnumerableMap.UintToAddressMap private myMap;
//  * }
//  * ```
//  *
//  * The following map types are supported:
//  *
//  * - `uint256 -> address` (`UintToAddressMap`) since v3.0.0
//  * - `address -> uint256` (`AddressToUintMap`) since v4.6.0
//  * - `bytes32 -> bytes32` (`Bytes32ToBytes32`) since v4.6.0
//  * - `uint256 -> uint256` (`UintToUintMap`) since v4.7.0
//  * - `bytes32 -> uint256` (`Bytes32ToUintMap`) since v4.7.0
//  *
//  * [WARNING]
//  * ====
//  *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
//  *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
//  *
//  *  In order to clean an EnumerableMap, you can either remove all elements one by one or create a fresh instance using an array of EnumerableMap.
//  * ====
//  */
// library EnumerableMap {
//     using EnumerableSet for EnumerableSet.Bytes32Set;
//     using StructuredLinkedList for StructuredLinkedList.Node;

//     // To implement this library for multiple types with as little code
//     // repetition as possible, we write it in terms of a generic Map type with
//     // bytes32 keys and values.
//     // The Map implementation uses private functions, and user-facing
//     // implementations (such as Uint256ToAddressMap) are just wrappers around
//     // the underlying Map.
//     // This means that we can only create new EnumerableMaps for types that fit
//     // in bytes32.

//     struct UintToLinkedListStruct {
//         EnumerableSet.Bytes32Set _keys;
//         mapping(bytes32 => StructuredLinkedList.Node) _values;
//     }

//     /**
//      * @dev Adds a key-value pair to a map, or updates the value for an existing
//      * key. O(1).
//      *
//      * Returns true if the key was added to the map, that is if it was not
//      * already present.
//      */
//     function set(
//         UintToLinkedListStruct storage map,
//         // StructuredLinkedList.Node storage _head,
//         bytes32 key,
//         uint256 decimals,
//         // uint256 value,
//         bytes32 baseKey,
//         uint256 data,
//         uint256 _headInterestRate
//     )
//         internal
//         returns (
//             bool,
//             UintToLinkedListStruct storage,
//             uint256,
//             uint256,
//             bytes32
//         )
//     {
//         // StructuredLinkedList.Node memory node = StructuredLinkedList.Node({
//         //     data: decimals,
//         //     count: 0,
//         //     next: 0
//         // });
//         // StructuredLinkedList.Node storage allValues = map._values[key];
//         // allValues.insert();
//         console.log("in set");
//         (uint256 data1, uint256 count, bytes32 next) = map._values[key].insert(
//             map._values,
//             key,
//             baseKey,
//             data,
//             decimals,
//             _headInterestRate
//         );
//         return (map._keys.add(key), map, data1, count, next);
//     }

//     struct Bytes32ToBytes32Map {
//         // Storage of keys
//         EnumerableSet.Bytes32Set _keys;
//         mapping(bytes32 => bytes32) _values;
//     }

//     /**
//      * @dev Adds a key-value pair to a map, or updates the value for an existing
//      * key. O(1).
//      *
//      * Returns true if the key was added to the map, that is if it was not
//      * already present.
//      */
//     function set(
//         Bytes32ToBytes32Map storage map,
//         bytes32 key,
//         bytes32 value
//     ) internal returns (bool) {
//         map._values[key] = value;
//         return map._keys.add(key);
//     }

//     /**
//      * @dev Removes a key-value pair from a map. O(1).
//      *
//      * Returns true if the key was removed from the map, that is if it was present.
//      */
//     function remove(
//         Bytes32ToBytes32Map storage map,
//         bytes32 key
//     ) internal returns (bool) {
//         delete map._values[key];
//         return map._keys.remove(key);
//     }

//     /**
//      * @dev Returns true if the key is in the map. O(1).
//      */
//     function contains(
//         Bytes32ToBytes32Map storage map,
//         bytes32 key
//     ) internal view returns (bool) {
//         return map._keys.contains(key);
//     }

//     /**
//      * @dev Returns the number of key-value pairs in the map. O(1).
//      */
//     function length(
//         Bytes32ToBytes32Map storage map
//     ) internal view returns (uint256) {
//         return map._keys.length();
//     }

//     /**
//      * @dev Returns the key-value pair stored at position `index` in the map. O(1).
//      *
//      * Note that there are no guarantees on the ordering of entries inside the
//      * array, and it may change when more entries are added or removed.
//      *
//      * Requirements:
//      *
//      * - `index` must be strictly less than {length}.
//      */
//     function at(
//         Bytes32ToBytes32Map storage map,
//         uint256 index
//     ) internal view returns (bytes32, bytes32) {
//         bytes32 key = map._keys.at(index);
//         return (key, map._values[key]);
//     }

//     /**
//      * @dev Tries to returns the value associated with `key`.  O(1).
//      * Does not revert if `key` is not in the map.
//      */
//     function tryGet(
//         Bytes32ToBytes32Map storage map,
//         bytes32 key
//     ) internal view returns (bool, bytes32) {
//         bytes32 value = map._values[key];
//         if (value == bytes32(0)) {
//             return (contains(map, key), bytes32(0));
//         } else {
//             return (true, value);
//         }
//     }

//     /**
//      * @dev Returns the value associated with `key`.  O(1).
//      *
//      * Requirements:
//      *
//      * - `key` must be in the map.
//      */
//     function get(
//         Bytes32ToBytes32Map storage map,
//         bytes32 key
//     ) internal view returns (bytes32) {
//         bytes32 value = map._values[key];
//         require(
//             value != 0 || contains(map, key),
//             "EnumerableMap: nonexistent key"
//         );
//         return value;
//     }

//     /**
//      * @dev Same as {_get}, with a custom error message when `key` is not in the map.
//      *
//      * CAUTION: This function is deprecated because it requires allocating memory for the error
//      * message unnecessarily. For custom revert reasons use {_tryGet}.
//      */
//     function get(
//         Bytes32ToBytes32Map storage map,
//         bytes32 key,
//         string memory errorMessage
//     ) internal view returns (bytes32) {
//         bytes32 value = map._values[key];
//         require(value != 0 || contains(map, key), errorMessage);
//         return value;
//     }

//     // UintToUintMap

//     struct UintToUintMap {
//         Bytes32ToBytes32Map _inner;
//     }

//     /**
//      * @dev Adds a key-value pair to a map, or updates the value for an existing
//      * key. O(1).
//      *
//      * Returns true if the key was added to the map, that is if it was not
//      * already present.
//      */
//     function set(
//         UintToUintMap storage map,
//         uint256 key,
//         uint256 value
//     ) internal returns (bool) {
//         return set(map._inner, bytes32(key), bytes32(value));
//     }

//     /**
//      * @dev Removes a value from a set. O(1).
//      *
//      * Returns true if the key was removed from the map, that is if it was present.
//      */
//     function remove(
//         UintToUintMap storage map,
//         uint256 key
//     ) internal returns (bool) {
//         return remove(map._inner, bytes32(key));
//     }

//     /**
//      * @dev Returns true if the key is in the map. O(1).
//      */
//     function contains(
//         UintToUintMap storage map,
//         uint256 key
//     ) internal view returns (bool) {
//         return contains(map._inner, bytes32(key));
//     }

//     /**
//      * @dev Returns the number of elements in the map. O(1).
//      */
//     function length(UintToUintMap storage map) internal view returns (uint256) {
//         return length(map._inner);
//     }

//     /**
//      * @dev Returns the element stored at position `index` in the set. O(1).
//      * Note that there are no guarantees on the ordering of values inside the
//      * array, and it may change when more values are added or removed.
//      *
//      * Requirements:
//      *
//      * - `index` must be strictly less than {length}.
//      */
//     function at(
//         UintToUintMap storage map,
//         uint256 index
//     ) internal view returns (uint256, uint256) {
//         (bytes32 key, bytes32 value) = at(map._inner, index);
//         return (uint256(key), uint256(value));
//     }

//     /**
//      * @dev Tries to returns the value associated with `key`.  O(1).
//      * Does not revert if `key` is not in the map.
//      */
//     function tryGet(
//         UintToUintMap storage map,
//         uint256 key
//     ) internal view returns (bool, uint256) {
//         (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
//         return (success, uint256(value));
//     }

//     /**
//      * @dev Returns the value associated with `key`.  O(1).
//      *
//      * Requirements:
//      *
//      * - `key` must be in the map.
//      */
//     function get(
//         UintToUintMap storage map,
//         uint256 key
//     ) internal view returns (uint256) {
//         return uint256(get(map._inner, bytes32(key)));
//     }

//     /**
//      * @dev Same as {get}, with a custom error message when `key` is not in the map.
//      *
//      * CAUTION: This function is deprecated because it requires allocating memory for the error
//      * message unnecessarily. For custom revert reasons use {tryGet}.
//      */
//     function get(
//         UintToUintMap storage map,
//         uint256 key,
//         string memory errorMessage
//     ) internal view returns (uint256) {
//         return uint256(get(map._inner, bytes32(key), errorMessage));
//     }

//     // UintToAddressMap

//     struct UintToAddressMap {
//         Bytes32ToBytes32Map _inner;
//     }

//     /**
//      * @dev Adds a key-value pair to a map, or updates the value for an existing
//      * key. O(1).
//      *
//      * Returns true if the key was added to the map, that is if it was not
//      * already present.
//      */
//     function set(
//         UintToAddressMap storage map,
//         uint256 key,
//         address value
//     ) internal returns (bool) {
//         return set(map._inner, bytes32(key), bytes32(uint256(uint160(value))));
//     }

//     /**
//      * @dev Removes a value from a set. O(1).
//      *
//      * Returns true if the key was removed from the map, that is if it was present.
//      */
//     function remove(
//         UintToAddressMap storage map,
//         uint256 key
//     ) internal returns (bool) {
//         return remove(map._inner, bytes32(key));
//     }

//     /**
//      * @dev Returns true if the key is in the map. O(1).
//      */
//     function contains(
//         UintToAddressMap storage map,
//         uint256 key
//     ) internal view returns (bool) {
//         return contains(map._inner, bytes32(key));
//     }

//     /**
//      * @dev Returns the number of elements in the map. O(1).
//      */
//     function length(
//         UintToAddressMap storage map
//     ) internal view returns (uint256) {
//         return length(map._inner);
//     }

//     /**
//      * @dev Returns the element stored at position `index` in the set. O(1).
//      * Note that there are no guarantees on the ordering of values inside the
//      * array, and it may change when more values are added or removed.
//      *
//      * Requirements:
//      *
//      * - `index` must be strictly less than {length}.
//      */
//     function at(
//         UintToAddressMap storage map,
//         uint256 index
//     ) internal view returns (uint256, address) {
//         (bytes32 key, bytes32 value) = at(map._inner, index);
//         return (uint256(key), address(uint160(uint256(value))));
//     }

//     /**
//      * @dev Tries to returns the value associated with `key`.  O(1).
//      * Does not revert if `key` is not in the map.
//      *
//      * _Available since v3.4._
//      */
//     function tryGet(
//         UintToAddressMap storage map,
//         uint256 key
//     ) internal view returns (bool, address) {
//         (bool success, bytes32 value) = tryGet(map._inner, bytes32(key));
//         return (success, address(uint160(uint256(value))));
//     }

//     /**
//      * @dev Returns the value associated with `key`.  O(1).
//      *
//      * Requirements:
//      *
//      * - `key` must be in the map.
//      */
//     function get(
//         UintToAddressMap storage map,
//         uint256 key
//     ) internal view returns (address) {
//         return address(uint160(uint256(get(map._inner, bytes32(key)))));
//     }

//     /**
//      * @dev Same as {get}, with a custom error message when `key` is not in the map.
//      *
//      * CAUTION: This function is deprecated because it requires allocating memory for the error
//      * message unnecessarily. For custom revert reasons use {tryGet}.
//      */
//     function get(
//         UintToAddressMap storage map,
//         uint256 key,
//         string memory errorMessage
//     ) internal view returns (address) {
//         return
//             address(
//                 uint160(uint256(get(map._inner, bytes32(key), errorMessage)))
//             );
//     }

//     // AddressToUintMap

//     struct AddressToUintMap {
//         Bytes32ToBytes32Map _inner;
//     }

//     /**
//      * @dev Adds a key-value pair to a map, or updates the value for an existing
//      * key. O(1).
//      *
//      * Returns true if the key was added to the map, that is if it was not
//      * already present.
//      */
//     function set(
//         AddressToUintMap storage map,
//         address key,
//         uint256 value
//     ) internal returns (bool) {
//         return set(map._inner, bytes32(uint256(uint160(key))), bytes32(value));
//     }

//     /**
//      * @dev Removes a value from a set. O(1).
//      *
//      * Returns true if the key was removed from the map, that is if it was present.
//      */
//     function remove(
//         AddressToUintMap storage map,
//         address key
//     ) internal returns (bool) {
//         return remove(map._inner, bytes32(uint256(uint160(key))));
//     }

//     /**
//      * @dev Returns true if the key is in the map. O(1).
//      */
//     function contains(
//         AddressToUintMap storage map,
//         address key
//     ) internal view returns (bool) {
//         return contains(map._inner, bytes32(uint256(uint160(key))));
//     }

//     /**
//      * @dev Returns the number of elements in the map. O(1).
//      */
//     function length(
//         AddressToUintMap storage map
//     ) internal view returns (uint256) {
//         return length(map._inner);
//     }

//     /**
//      * @dev Returns the element stored at position `index` in the set. O(1).
//      * Note that there are no guarantees on the ordering of values inside the
//      * array, and it may change when more values are added or removed.
//      *
//      * Requirements:
//      *
//      * - `index` must be strictly less than {length}.
//      */
//     function at(
//         AddressToUintMap storage map,
//         uint256 index
//     ) internal view returns (address, uint256) {
//         (bytes32 key, bytes32 value) = at(map._inner, index);
//         return (address(uint160(uint256(key))), uint256(value));
//     }

//     /**
//      * @dev Tries to returns the value associated with `key`.  O(1).
//      * Does not revert if `key` is not in the map.
//      */
//     function tryGet(
//         AddressToUintMap storage map,
//         address key
//     ) internal view returns (bool, uint256) {
//         (bool success, bytes32 value) = tryGet(
//             map._inner,
//             bytes32(uint256(uint160(key)))
//         );
//         return (success, uint256(value));
//     }

//     /**
//      * @dev Returns the value associated with `key`.  O(1).
//      *
//      * Requirements:
//      *
//      * - `key` must be in the map.
//      */
//     function get(
//         AddressToUintMap storage map,
//         address key
//     ) internal view returns (uint256) {
//         return uint256(get(map._inner, bytes32(uint256(uint160(key)))));
//     }

//     /**
//      * @dev Same as {get}, with a custom error message when `key` is not in the map.
//      *
//      * CAUTION: This function is deprecated because it requires allocating memory for the error
//      * message unnecessarily. For custom revert reasons use {tryGet}.
//      */
//     function get(
//         AddressToUintMap storage map,
//         address key,
//         string memory errorMessage
//     ) internal view returns (uint256) {
//         return
//             uint256(
//                 get(map._inner, bytes32(uint256(uint160(key))), errorMessage)
//             );
//     }

//     // Bytes32ToUintMap

//     struct Bytes32ToUintMap {
//         Bytes32ToBytes32Map _inner;
//     }

//     /**
//      * @dev Adds a key-value pair to a map, or updates the value for an existing
//      * key. O(1).
//      *
//      * Returns true if the key was added to the map, that is if it was not
//      * already present.
//      */
//     function set(
//         Bytes32ToUintMap storage map,
//         bytes32 key,
//         uint256 value
//     ) internal returns (bool) {
//         return set(map._inner, key, bytes32(value));
//     }

//     /**
//      * @dev Removes a value from a set. O(1).
//      *
//      * Returns true if the key was removed from the map, that is if it was present.
//      */
//     function remove(
//         Bytes32ToUintMap storage map,
//         bytes32 key
//     ) internal returns (bool) {
//         return remove(map._inner, key);
//     }

//     /**
//      * @dev Returns true if the key is in the map. O(1).
//      */
//     function contains(
//         Bytes32ToUintMap storage map,
//         bytes32 key
//     ) internal view returns (bool) {
//         return contains(map._inner, key);
//     }

//     /**
//      * @dev Returns the number of elements in the map. O(1).
//      */
//     function length(
//         Bytes32ToUintMap storage map
//     ) internal view returns (uint256) {
//         return length(map._inner);
//     }

//     /**
//      * @dev Returns the element stored at position `index` in the set. O(1).
//      * Note that there are no guarantees on the ordering of values inside the
//      * array, and it may change when more values are added or removed.
//      *
//      * Requirements:
//      *
//      * - `index` must be strictly less than {length}.
//      */
//     function at(
//         Bytes32ToUintMap storage map,
//         uint256 index
//     ) internal view returns (bytes32, uint256) {
//         (bytes32 key, bytes32 value) = at(map._inner, index);
//         return (key, uint256(value));
//     }

//     /**
//      * @dev Tries to returns the value associated with `key`.  O(1).
//      * Does not revert if `key` is not in the map.
//      */
//     function tryGet(
//         Bytes32ToUintMap storage map,
//         bytes32 key
//     ) internal view returns (bool, uint256) {
//         (bool success, bytes32 value) = tryGet(map._inner, key);
//         return (success, uint256(value));
//     }

//     /**
//      * @dev Returns the value associated with `key`.  O(1).
//      *
//      * Requirements:
//      *
//      * - `key` must be in the map.
//      */
//     function get(
//         Bytes32ToUintMap storage map,
//         bytes32 key
//     ) internal view returns (uint256) {
//         return uint256(get(map._inner, key));
//     }

//     /**
//      * @dev Same as {get}, with a custom error message when `key` is not in the map.
//      *
//      * CAUTION: This function is deprecated because it requires allocating memory for the error
//      * message unnecessarily. For custom revert reasons use {tryGet}.
//      */
//     function get(
//         Bytes32ToUintMap storage map,
//         bytes32 key,
//         string memory errorMessage
//     ) internal view returns (uint256) {
//         return uint256(get(map._inner, key, errorMessage));
//     }
// }

// pragma solidity ^0.8.0;

// /**
//  * @dev Library for managing
//  * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
//  * types.
//  *
//  * Sets have the following properties:
//  *
//  * - Elements are added, removed, and checked for existence in constant time
//  * (O(1)).
//  * - Elements are enumerated in O(n). No guarantees are made on the ordering.
//  *
//  * ```
//  * contract Example {
//  *     // Add the library methods
//  *     using EnumerableSet for EnumerableSet.AddressSet;
//  *
//  *     // Declare a set state variable
//  *     EnumerableSet.AddressSet private mySet;
//  * }
//  * ```
//  *
//  * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
//  * and `uint256` (`UintSet`) are supported.
//  *
//  * [WARNING]
//  * ====
//  *  Trying to delete such a structure from storage will likely result in data corruption, rendering the structure unusable.
//  *  See https://github.com/ethereum/solidity/pull/11843[ethereum/solidity#11843] for more info.
//  *
//  *  In order to clean an EnumerableSet, you can either remove all elements one by one or create a fresh instance using an array of EnumerableSet.
//  * ====
//  */
// library EnumerableSet {
//     // To implement this library for multiple types with as little code
//     // repetition as possible, we write it in terms of a generic Set type with
//     // bytes32 values.
//     // The Set implementation uses private functions, and user-facing
//     // implementations (such as AddressSet) are just wrappers around the
//     // underlying Set.
//     // This means that we can only create new EnumerableSets for types that fit
//     // in bytes32.

//     struct Set {
//         // Storage of set values
//         bytes32[] _values;
//         // Position of the value in the `values` array, plus 1 because index 0
//         // means a value is not in the set.
//         mapping(bytes32 => uint256) _indexes;
//     }

//     /**
//      * @dev Add a value to a set. O(1).
//      *
//      * Returns true if the value was added to the set, that is if it was not
//      * already present.
//      */
//     function _add(Set storage set, bytes32 value) private returns (bool) {
//         if (!_contains(set, value)) {
//             set._values.push(value);
//             // The value is stored at length-1, but we add 1 to all indexes
//             // and use 0 as a sentinel value
//             set._indexes[value] = set._values.length;
//             return true;
//         } else {
//             return false;
//         }
//     }

//     /**
//      * @dev Removes a value from a set. O(1).
//      *
//      * Returns true if the value was removed from the set, that is if it was
//      * present.
//      */
//     function _remove(Set storage set, bytes32 value) private returns (bool) {
//         // We read and store the value's index to prevent multiple reads from the same storage slot
//         uint256 valueIndex = set._indexes[value];

//         if (valueIndex != 0) {
//             // Equivalent to contains(set, value)
//             // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
//             // the array, and then remove the last element (sometimes called as 'swap and pop').
//             // This modifies the order of the array, as noted in {at}.

//             uint256 toDeleteIndex = valueIndex - 1;
//             uint256 lastIndex = set._values.length - 1;

//             if (lastIndex != toDeleteIndex) {
//                 bytes32 lastValue = set._values[lastIndex];

//                 // Move the last value to the index where the value to delete is
//                 set._values[toDeleteIndex] = lastValue;
//                 // Update the index for the moved value
//                 set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
//             }

//             // Delete the slot where the moved value was stored
//             set._values.pop();

//             // Delete the index for the deleted slot
//             delete set._indexes[value];

//             return true;
//         } else {
//             return false;
//         }
//     }

//     /**
//      * @dev Returns true if the value is in the set. O(1).
//      */
//     function _contains(
//         Set storage set,
//         bytes32 value
//     ) private view returns (bool) {
//         return set._indexes[value] != 0;
//     }

//     /**
//      * @dev Returns the number of values on the set. O(1).
//      */
//     function _length(Set storage set) private view returns (uint256) {
//         return set._values.length;
//     }

//     /**
//      * @dev Returns the value stored at position `index` in the set. O(1).
//      *
//      * Note that there are no guarantees on the ordering of values inside the
//      * array, and it may change when more values are added or removed.
//      *
//      * Requirements:
//      *
//      * - `index` must be strictly less than {length}.
//      */
//     function _at(
//         Set storage set,
//         uint256 index
//     ) private view returns (bytes32) {
//         return set._values[index];
//     }

//     /**
//      * @dev Return the entire set in an array
//      *
//      * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
//      * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
//      * this function has an unbounded cost, and using it as part of a state-changing function may render the function
//      * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
//      */
//     function _values(Set storage set) private view returns (bytes32[] memory) {
//         return set._values;
//     }

//     // Bytes32Set

//     struct Bytes32Set {
//         Set _inner;
//     }

//     /**
//      * @dev Add a value to a set. O(1).
//      *
//      * Returns true if the value was added to the set, that is if it was not
//      * already present.
//      */
//     function add(
//         Bytes32Set storage set,
//         bytes32 value
//     ) internal returns (bool) {
//         return _add(set._inner, value);
//     }

//     /**
//      * @dev Removes a value from a set. O(1).
//      *
//      * Returns true if the value was removed from the set, that is if it was
//      * present.
//      */
//     function remove(
//         Bytes32Set storage set,
//         bytes32 value
//     ) internal returns (bool) {
//         return _remove(set._inner, value);
//     }

//     /**
//      * @dev Returns true if the value is in the set. O(1).
//      */
//     function contains(
//         Bytes32Set storage set,
//         bytes32 value
//     ) internal view returns (bool) {
//         return _contains(set._inner, value);
//     }

//     /**
//      * @dev Returns the number of values in the set. O(1).
//      */
//     function length(Bytes32Set storage set) internal view returns (uint256) {
//         return _length(set._inner);
//     }

//     /**
//      * @dev Returns the value stored at position `index` in the set. O(1).
//      *
//      * Note that there are no guarantees on the ordering of values inside the
//      * array, and it may change when more values are added or removed.
//      *
//      * Requirements:
//      *
//      * - `index` must be strictly less than {length}.
//      */
//     function at(
//         Bytes32Set storage set,
//         uint256 index
//     ) internal view returns (bytes32) {
//         return _at(set._inner, index);
//     }

//     /**
//      * @dev Return the entire set in an array
//      *
//      * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
//      * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
//      * this function has an unbounded cost, and using it as part of a state-changing function may render the function
//      * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
//      */
//     function values(
//         Bytes32Set storage set
//     ) internal view returns (bytes32[] memory) {
//         return _values(set._inner);
//     }

//     // AddressSet

//     struct AddressSet {
//         Set _inner;
//     }

//     /**
//      * @dev Add a value to a set. O(1).
//      *
//      * Returns true if the value was added to the set, that is if it was not
//      * already present.
//      */
//     function add(
//         AddressSet storage set,
//         address value
//     ) internal returns (bool) {
//         return _add(set._inner, bytes32(uint256(uint160(value))));
//     }

//     /**
//      * @dev Removes a value from a set. O(1).
//      *
//      * Returns true if the value was removed from the set, that is if it was
//      * present.
//      */
//     function remove(
//         AddressSet storage set,
//         address value
//     ) internal returns (bool) {
//         return _remove(set._inner, bytes32(uint256(uint160(value))));
//     }

//     /**
//      * @dev Returns true if the value is in the set. O(1).
//      */
//     function contains(
//         AddressSet storage set,
//         address value
//     ) internal view returns (bool) {
//         return _contains(set._inner, bytes32(uint256(uint160(value))));
//     }

//     /**
//      * @dev Returns the number of values in the set. O(1).
//      */
//     function length(AddressSet storage set) internal view returns (uint256) {
//         return _length(set._inner);
//     }

//     /**
//      * @dev Returns the value stored at position `index` in the set. O(1).
//      *
//      * Note that there are no guarantees on the ordering of values inside the
//      * array, and it may change when more values are added or removed.
//      *
//      * Requirements:
//      *
//      * - `index` must be strictly less than {length}.
//      */
//     function at(
//         AddressSet storage set,
//         uint256 index
//     ) internal view returns (address) {
//         return address(uint160(uint256(_at(set._inner, index))));
//     }

//     /**
//      * @dev Return the entire set in an array
//      *
//      * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
//      * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
//      * this function has an unbounded cost, and using it as part of a state-changing function may render the function
//      * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
//      */
//     function values(
//         AddressSet storage set
//     ) internal view returns (address[] memory) {
//         bytes32[] memory store = _values(set._inner);
//         address[] memory result;

//         /// @solidity memory-safe-assembly
//         assembly {
//             result := store
//         }

//         return result;
//     }

//     // UintSet

//     struct UintSet {
//         Set _inner;
//     }

//     /**
//      * @dev Add a value to a set. O(1).
//      *
//      * Returns true if the value was added to the set, that is if it was not
//      * already present.
//      */
//     function add(UintSet storage set, uint256 value) internal returns (bool) {
//         return _add(set._inner, bytes32(value));
//     }

//     /**
//      * @dev Removes a value from a set. O(1).
//      *
//      * Returns true if the value was removed from the set, that is if it was
//      * present.
//      */
//     function remove(
//         UintSet storage set,
//         uint256 value
//     ) internal returns (bool) {
//         return _remove(set._inner, bytes32(value));
//     }

//     /**
//      * @dev Returns true if the value is in the set. O(1).
//      */
//     function contains(
//         UintSet storage set,
//         uint256 value
//     ) internal view returns (bool) {
//         return _contains(set._inner, bytes32(value));
//     }

//     /**
//      * @dev Returns the number of values on the set. O(1).
//      */
//     function length(UintSet storage set) internal view returns (uint256) {
//         return _length(set._inner);
//     }

//     /**
//      * @dev Returns the value stored at position `index` in the set. O(1).
//      *
//      * Note that there are no guarantees on the ordering of values inside the
//      * array, and it may change when more values are added or removed.
//      *
//      * Requirements:
//      *
//      * - `index` must be strictly less than {length}.
//      */
//     function at(
//         UintSet storage set,
//         uint256 index
//     ) internal view returns (uint256) {
//         return uint256(_at(set._inner, index));
//     }

//     /**
//      * @dev Return the entire set in an array
//      *
//      * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
//      * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
//      * this function has an unbounded cost, and using it as part of a state-changing function may render the function
//      * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
//      */
//     function values(
//         UintSet storage set
//     ) internal view returns (uint256[] memory) {
//         bytes32[] memory store = _values(set._inner);
//         uint256[] memory result;

//         /// @solidity memory-safe-assembly
//         assembly {
//             result := store
//         }

//         return result;
//     }
// }

// contract OrderBook {
//     using EnumerableMap for EnumerableMap.UintToLinkedListStruct;

//     // mapping (uint256 => uint256) public orders;
//     mapping(uint256 => EnumerableMap.UintToLinkedListStruct) internal orders;
//     mapping(uint256 => StructuredLinkedList.Node) public linkedListOrders;

//     StructuredLinkedList.Node public head;

//     uint256 public headInterestRate;

//     function add(uint256 _interestRate, uint256 key, uint256 value) public {
//         // orders.s
//         // orders[key].set();
//         // EnumerableMap.set
//         // orders[key].set();

//         //         UintToLinkedListStruct storage map,
//         // StructuredLinkedList.Node storage _head,
//         // bytes32 key,
//         // uint256 decimals,
//         // uint256 value,
//         // bytes32 baseKey
//         EnumerableMap.UintToLinkedListStruct storage _localOrder;
//         console.log("in add");
//         (, _localOrder, head.data, head.count, head.next) = orders[
//             _interestRate
//         ].set(
//                 // head,
//                 bytes32(key),
//                 key,
//                 // value,
//                 bytes32(_interestRate),
//                 _interestRate,
//                 head.data
//             );

//         orders[_interestRate]._values[bytes32(key)] = _localOrder._values[
//             bytes32(key)
//         ];

//         if (_interestRate < headInterestRate) {
//             headInterestRate = _interestRate;
//         }
//     }

//     function getDetails(
//         uint256 _key,
//         uint256 _loopKey
//     ) public view returns (uint256, uint256, bytes32) {
//         EnumerableMap.UintToLinkedListStruct storage linkedList = orders[_key];

//         StructuredLinkedList.Node storage key = orders[_key]._values[
//             bytes32(_key)
//         ];

//         uint256 i = 0;

//         while (i < _loopKey) {
//             bytes32 nextNode = key.next;
//             key = orders[_key]._values[nextNode];
//             i++;
//         }

//         // StructuredLinkedList.Node storage list = linkedList._values[bytes32(_key)];
//         return (key.count, key.data, key.next);
//     }

//     function getKey(uint256 _key) public pure returns (bytes32) {
//         return bytes32(_key);
//     }
// }
