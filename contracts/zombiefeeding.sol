// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./zombiefactory.sol";

/** # コントラクトをイーサリアム上にデプロイすると、イミュータブルになる。
    → つまり編集も更新もできなくなる
    # コントラクトにデプロイした最初のコードは永久にブロックチェーン上に残る
    修正するには、問題点を直した別のスマートコントラクトを使用してもらうしかない。
    # 関数を実行するために必要なガスの量は、関数のロジックの複雑さによる
    その操作を実行するためにどれくらいの計算資源が必要になるのかを計算したものに基づいて、
    ガスのコストが決まる
    # ユーザーは実際にお金を使って関数を動かすことになるから、
    イーサリアムは他のプログラミング言語よりもずっとコードの最適化が重要
    # meomory → コピーを渡す 、 storage → 参照渡し
 */

/** インターフェース → 他人のコントラクトから呼び出し、呼び出されする関数。
    returnsステートメントの後ろに {} を付けない。
 */
interface KittyInterface {
    // external → ブロックの外からしか呼び出せない関数
    // Solidity では、複数のリターンを返して良い
    function getKitty(
        uint256 _id
    )
        external
        view
        returns (
            bool isGestating,
            bool isReady,
            uint256 cooldownIndex,
            uint256 nextActionAt,
            uint256 siringWithId,
            uint256 birthTime,
            uint256 matronId,
            uint256 sireId,
            uint256 generation,
            uint256 genes
        );
}

/** 継承
    ZombieFeeding は ZombieFactory
    ZombieFactory は Ownable
 */
contract ZombieFeeding is ZombieFactory {
    /**
        # 基本的にはハードコーディングしてはならない。 → バグが出た時に後から修正できないため。
        address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
        # インターフェースのメソッドの引数に同じ型の値を渡してインターフェースを作成する。
     */
    KittyInterface kittyContract; //  = KittyInterface(ckAddress);

    /**
     * @dev ゾンビIDがすでにオーナーが存在するものであれば処理を抜ける
     * @param _zombieId ゾンビのインデックス
     */
    modifier onlyOwnerOf(uint _zombieId) {
        require(msg.sender == zombieToOwner[_zombieId]);
        _;
    }

    /**
    @dev ハードコーディングではなく、関数を設定して後から修正できるようにする。
        external → 誰でも呼び出せる。 -> コントラクトをOwnableにして、所有者権限にする。
        Ownableコントラクトをコピーペーストして継承して使う.
    @param _address キティーのアドレスID
 */
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    /**
        @dev _zombie.readyTime に 1日のクールダウンを設定。
        @param _zombie Zombie storage  → 構造体の参照を渡す
     */
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(block.timestamp + cooldownTime);
    }

    /**
        @dev ゾンビの捕食から1日経ったかどうかを返す。
     */
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        // true false を評価して返す
        return (_zombie.readyTime <= block.timestamp);
    }

    /**
     * @dev ゾンビが人間を食べて、人間にDNAを感染させる。
     * @param _targetDna → 捕食する人間のDna
     * （クリプトキティインターフェースの、キティ→ genes値）
     */
    function feedAndMultiply(
        uint _zombieId,
        uint _targetDna,
        string memory _species
    ) internal onlyOwnerOf(_zombieId) {
        // 【不明点】zombies[_zombieId] で Zombie が取得できる？ IDで取得できる？
        // _zombieIdはインデックス？ → 参照を取得
        Zombie storage myZombie = zombies[_zombieId];

        // check cooldown < 1day
        require(_isReady(myZombie));

        _targetDna = _targetDna % dnaModulus;
        // 人間とゾンビの平均値のDnaを算出
        uint newDna = (myZombie.dna + _targetDna) / 2;
        // Stirringの比較はハッシュ化する。 → Kitty と同じなら、ゾンビを猫の特徴に変える。
        if (keccak256(bytes(_species)) == keccak256("kitty")) {
            // 334455 - 55 + 99 == 334499
            newDna = newDna - (newDna % 100) + 99;
        }
        // プライベート関数 → internal に変える → コンストラクト内部からでしか呼び出せなくなる。
        //   → Privateの少しゆるい版。
        _createZombie("NoName", newDna);
        // start cooldown after eat
        _triggerCooldown(myZombie);
    }

    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;
        // n 番目の引数だけを受け取る方法
        (, , , , , , , , , kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
