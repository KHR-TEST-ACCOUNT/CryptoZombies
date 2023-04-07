/**
 * 各コントラクトに対して個別のテストファイルを作成し、
 * スマートコントラクトの名前を与えるのがベストプラクティス
 * これはコントラクトの抽象化を行っている。
 * @format
 */
const CryptoZombies = artifacts.require('CryptoZombies');
// for test. 100件でもFor文で対応できるように。
const zombieNames = ['koya-v1', 'koya-v2'];

//test code → CryptoZombies は テストするコントラクト（ビルド）
contract('CryptoZombies', (accounts) => {
    // Ganash のアカウントを格納する  alice→０, bob→１
    let [alice, bob] = accounts;
    // test start → 非同期関数として呼び出す。
    //   → ブロックチェーンと会話するため。 → BCは、非同期関数。
    it('新しいゾンビを生成できるようにする', async () => {
        // create instance → ブロックチェーンと対話するので Await を使う
        const cryptoZombies = await CryptoZombies.new();
        // alice -> 0 が関数を呼び出したとして実行 → Alice の残高が引かれる。
        //  Result → トランザクションの結果を格納している。 await を忘れない。
        const result = await cryptoZombies.createRandomZombie(zombieNames[0], {
            from: alice,
        });
        /**
         * result.logs[0].args.nameのように、アリスの新しく作ったゾンビの名前を取得できる
         * result.tx：トランザクションハッシュ
         * result.receipt: トランザクションのレシートを含むオブジェクト。
         * result.receipt.status が true の場合、トランザクションが成功したことを意味する
         */
        assert.equal(result.receipt.status, true);
        assert.equal(result.logs[0].args.name, zombieNames[0]);
    });
});
