// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

contract SafeRemotePurchase {
    uint public value;
    address payable public seller;
    address payable public buyer;

    enum State { Created, Locked, Release, Inactive }

    State public state;

    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    error OnlyBuyer();
    error OnlySeller();
    error InvalidState();
    error ValueNotEven();

    modifier onlyBuyer() {
        if (msg.sender != buyer)
            revert OnlyBuyer();
        _;
    }
    modifier onlySeller() {
        if (msg.sender != seller)
            revert OnlySeller();
        _;
    }
    modifier inState(State _state) {
        if (state != _state)
            revert InvalidState();
        _;
    }

    event Aborted();
    event PurchaseConfirmed();
    // event ItemReceived();
    // event SellerRefunded();
    event PurchaseCompleted();

    constructor() payable {
        seller = payable(msg.sender);
        value = msg.value / 2;
        if ((2 * value) != msg.value)
            revert ValueNotEven();
    }

    function abort() external onlySeller inState(State.Created) {
        emit Aborted();

        state = State.Inactive;

        seller.transfer(address(this).balance);
    }
    function confirmPurchase() external inState(State.Created) condition(msg.value == (2 * value)) payable {
        emit PurchaseConfirmed();

        buyer = payable(msg.sender);
        state = State.Locked;
    }
    // function confirmReceived() external onlyBuyer inState(State.Locked) {
    //     emit ItemReceived();

    //     state = State.Release;

    //     buyer.transfer(value);
    // }
    // function refundSeller() external onlySeller inState(State.Release) {
    //     emit SellerRefunded();

    //     state = State.Inactive;

    //     seller.transfer(3 * value);
    // }
    function completePurchase() external onlyBuyer inState(State.Locked) {
        emit PurchaseCompleted();

        state = State.Inactive;

        buyer.transfer(value);
        seller.transfer(3 * value);
    }
}
