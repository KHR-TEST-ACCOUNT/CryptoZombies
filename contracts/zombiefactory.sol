// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ownable.sol";

contract ZombieFactory is Ownable {
    // オーバーフロー対策 → 0.8.0 では、デフォルトでコンパイラに組み込まれるようになった。
    // using SafeMath for uint256;

    // イベントを用意 → Gorutine のチャネルの送信みたいなもの。
    event NewZombie(uint zombieId, string name, uint dna);

    uint dnaDigits = 16;
    /** 10 ** dnaDigits -> 10 ** 16  */
    uint dnaModulus = 10 ** dnaDigits;
    /** 1 day  */
    uint cooldownTime = 1 days;

    /**
        structの中に複数の uintがある場合、できる限り小さい単位の uintを使うことで、
        Solidityが複数の変数をまとめて、ストレージを小さくすることが可能
        -> 複数の変数がまとめられるため -> ex) 2つのuint32変数
        @param readyTime ”冷却期間”を追加してネットワークの負荷を下げる
                1 minutes は 60になり、1 hours は 3600 (60 秒 x 60 分)になり、
                1 days は86400 (24時間 x 60 分 x 60 秒)
     */
    struct Zombie {
        string name;
        uint dna;
        uint32 level;
        uint32 readyTime;
        uint16 winCount;
        uint16 lossCount;
    }

    // Public → GetterをSolidityが自動作成する。
    Zombie[] public zombies;

    // uint => id マップ。ゾンビのオーナーをトラックするマッピング
    /** ゾンビオーナーのアドレスを返す */
    mapping(uint => address) public zombieToOwner;
    /** ゾンビの所持数を返す。 → Addressで所有者をKeyにとる */
    mapping(address => uint) ownerZombieCount;

    // _で始める引数が、通例。
    // Private にしないと、誰でも関数を見れる様になる
    //   → _で関数を始めるのが通例。基本的にはPrivateにする
    // 関数修飾子 → view → 読み取り専用
    //          → pure → アプリ内のデータにすらアクセス不可
    // internal -> ブロック内部からしか実行できない -> internal > private
    function _createZombie(string memory _name, uint _dna) internal {
        // 注：2038年問題を防止しないことを選択しました。そのため、以下のものは必要ありません。
        // readyTimeのオーバーフローを心配する。どうせ2038年には我々のアプリはダメになっているのだから ;)
        // uint id = zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime))) -1;
        zombies.push(
            Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0)
        );
        uint id = zombies.length - 1;
        // msg.sender は、その関数を呼び出したユーザーのアカウントを取得する
        // マップのキーを指定して、キーに対してValueを格納する。
        zombieToOwner[id] = msg.sender;
        // ++ で、 ownerZombieCount の初期値 uint を uint = uint + 1;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }

    function _generateRandomDna(
        string memory _str
    ) private view returns (uint) {
        // keccak256() を使用してString をハッシュ化して比較やキャストしないとエラーになる。
        // keccak256 にはバイトのみ格納可能
        uint rand = uint(keccak256(bytes(_str)));
        return rand % dnaModulus;
    }

    function createRandomZombie(string memory _name) public {
        //  ゾンビのDNA乱数を16桁になるように変換
        require(ownerZombieCount[msg.sender] == 0);
        uint randDna = _generateRandomDna(_name);
        // ゾンビを作成 ＋ DNAの乱数を格納
        _createZombie(_name, randDna);
    }
}
