// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./zombiehelper.sol";

/**
 * @title ゾンビを戦わせる
 * @author
 * @notice Solidityでは乱数の生成ができない。
 * → 複数人にトランザクションをマイニングしてもらう際に、中身が見れる。
 * → 乱数の生成でなにがでたか分かるので、乱数としての意味をなさない。
 * → コイントスに関しては無敵になれる。
 * Oracles の安全なブロックのデータをプルして使う。 → 正解ではない。
 * → 乱数の生成に関しては永遠の課題。
 */

contract ZombieBattle is ZombieHelper {
    uint randNonce = 0;
    // 勝率
    uint attackVictoryProbability = 70;

    /**
     * 0 ~99 の乱数を生成する。
     * @param _modulus 乱数生成用の数値 → %100 などをする用。
     */
    function randMod(uint _modulus) internal returns (uint) {
        randNonce++;
        return
            uint(
                keccak256(
                    // Solidity の仕様変更を反映するabi.encodePacked
                    abi.encodePacked(block.timestamp, msg.sender, randNonce)
                )
            ) % _modulus;
    }

    /**
     * 攻撃をする関数
     * @param _zombieId 自分のゾンビ
     * @param _targetId 相手のゾンビ
     */
    function attack(
        uint _zombieId,
        uint _targetId
    ) external onlyOwnerOf(_zombieId) {
        Zombie storage myZombie = zombies[_zombieId];
        Zombie storage enemyZombie = zombies[_targetId];

        uint rand = randMod(100);

        // 乱数の生成が70以下なら勝利する → 70％以上の確率で勝利する。
        if (rand <= attackVictoryProbability) {
            myZombie.winCount++;
            myZombie.level++;
            enemyZombie.lossCount++;
            feedAndMultiply(_zombieId, enemyZombie.dna, "zombie");
        } else {
            myZombie.lossCount++;
            enemyZombie.winCount++;
        }

        // cooldown timer on -> attack -> still 1 day
        _triggerCooldown(myZombie);
    }
}
