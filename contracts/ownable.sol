// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev The Ownable contract は所有者アドレスを持ち、
 *      基本的な権限制御を提供する使用することで、"ユーザー権限 "の実装を簡略化する。
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Ownableコンストラクタは、契約の元の`所有者`を送信者のアカウントに設定します。
     * Visibility (public / external) is not needed for constructors anymore:
     * → Visibility 可視性 の修飾子(public / external) は、古いのでコンストラクタには必要ない。
     */
    constructor() {
        owner = msg.sender;
    }

    /**
   * @dev オーナー以外のアカウントから呼び出された場合、スローされます。
        onlyOwnerの_;ステートメントにたどり着いた時に,戻ってコードを実行
   */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev 現在の所有者が、契約の支配権をnewOwnerに譲渡することを可能にする。
     * @param newOwner 所有権を移転するためのアドレスです。
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
