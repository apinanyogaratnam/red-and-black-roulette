// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract RedAndBlackRoulette {
    address private _admin;
    uint private _balance = 0;
    mapping (address => uint) private _playerToWins;
    mapping (address => bool) private _playerToExists;
    address[] private _players;
    mapping (string => uint8) private _colorToIntMapper;

    enum Color { RED, BLACK }

    constructor() {
        _admin = msg.sender;
    }

    function getAdmin() public view returns(address) {
        return _admin;
    }

    function setAdmin(address newAdmin) external {
        require(msg.sender == _admin);

        _admin = newAdmin;
    }

    function getBalance() public view returns(uint) {
        return _balance;
    }

    function getWins(address player) external view returns(uint) {
        return _playerToWins[player];
    }

    function _spin() internal view returns(Color) {
        uint randomNumber = _randomizer();

        if (randomNumber % 2 == 0) {
            return Color.BLACK;
        }

        return Color.RED;
    }

    function spin(Color color) external payable returns(bool) {
        uint betAmount = msg.value;

        require(msg.value <= getBalance());

        Color spinnedColor = _spin();

        address player = msg.sender;
        bool hasPlayerPlayedBefore = _playerToExists[player];
        _balance += betAmount;

        if (!hasPlayerPlayedBefore) {
            _players.push(player);
            _playerToExists[player] = true;
        }

        bool hasPlayerWon = spinnedColor == color;

        if (hasPlayerWon) {
            _playerToWins[player] += 1;
            payable(player).transfer(betAmount);
            _balance -= betAmount;
        }

        return hasPlayerWon;
    }

    function addEth() public payable {
        _balance += msg.value;
    }

    function _randomizer() internal view returns(uint) {
        uint epoch = block.timestamp;
        uint difficulty = block.difficulty;
        return uint(keccak256(abi.encode(difficulty, epoch, _players)));
    }

}
