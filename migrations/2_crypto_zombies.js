/** @format */

/**
 * Truffle compile
 * コントラクトのコードをコンパイルして、ビルドフォルダに保存する。
 * ビルドフォルダには、書き換えられたコードと、ABIが保存される。
 *
 * Migrations.sol → 変更の履歴を保存している
 *  → ２回目のデプロイをしなくて良いようにする。
 * デプロイ→ 1,2,3 の順で実行される。
 * マイグレーションをして、コントラクトの状態をどのように変更するかを
 * Truffleに伝える。  → コントラクトごとにMigration ファイルを分ける。
 * おそらく、アーティファクトで宣言したコントラクトのABIを取得している。
 *
 * メインネット → truffle migrate --network mainnet
 */
const CryptoZombies = artifacts.require('./CryptoZombies.sol');

module.exports = function (deployer) {
    deployer.deploy(CryptoZombies);
};
