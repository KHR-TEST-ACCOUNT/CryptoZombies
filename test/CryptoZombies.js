/**
 * 各コントラクトに対して個別のテストファイルを作成し、
 * スマートコントラクトの名前を与えるのがベストプラクティス
 * これはコントラクトの抽象化を行っている。
 * @format
 */
const CryptoZombies = artifacts.require('CryptoZombies');
// テスト用のTry Catch Util
const utils = require('./helpers/utils');
// for test. 100件でもFor文で対応できるように。
const zombieNames = ['koya-v1', 'koya-v2'];
// テスト前のインスタンス生成用 → 初期化しないので、Let で生成
let cryptoZombies;

//test code → CryptoZombies は テストするコントラクト（ビルド）
contract('CryptoZombies', (accounts) => {
    // Ganash のアカウントを格納する  alice→０, bob→１
    // accountsアドレスがそれぞれに格納されている。
    let [alice, bob] = accounts;

    // Hooks → ITの前に、インスタンスを生成する
    beforeEach(async () => {
        // create instance → ブロックチェーンと対話するので Await を使う
        cryptoZombies = await CryptoZombies.new();
    });

    // test start → 非同期関数として呼び出す。
    //   → ブロックチェーンと会話するため。 → BCは、非同期関数。
    it('新しいゾンビを生成できるようにする', async () => {
        // alice -> 0 が関数を呼び出したとして実行 → Alice の残高が引かれる。
        //  Result → トランザクションの結果を格納している。 await を忘れない。
        const result = await cryptoZombies.createRandomZombie(zombieNames[0], {
            from: alice,
        });
        /**
         * Result -> Truffleがスマートコントラクトによって生成されたイベントログを自動的に提供
         * result.logs[0].args.nameのように、アリスの新しく作ったゾンビの名前を取得できる
         * idと_dna も取得できる
         * result.tx：トランザクションハッシュ
         * result.receipt: トランザクションのレシートを含むオブジェクト。
         * result.receipt.status が true の場合、トランザクションが成功したことを意味する
         */
        assert.equal(result.receipt.status, true);
        assert.equal(result.logs[0].args.name, zombieNames[0]);
    });

    it('2体目のゾンビを許してはならない', async () => {
        await cryptoZombies.createRandomZombie(zombieNames[0], { from: alice });
        // Try Catch を実行 → Await は Utils の関数につける。→ あくまでもブロックと協調するため
        await utils.shouldThrow(
            cryptoZombies.createRandomZombie(zombieNames[1], {
                from: alice,
            })
        );
    });

    /**
     * グループ化する → Contextで分ける。
     *  → グループを、シナリオという。 → 保守性が高くなるので、グルーピングする。
     *  → シナリオ１，２ に分けてテストすることで、他のコーダーに伝える事ができる。
     * Transfer 関数（移動）が、２種類のメソッドを提供しているのでそれをテストする。
     *
     * x を前につけることによってテストをスキップできる。 → xcontext
     */
    context('1ステップ目の転送シナリオをテスト', async () => {
        it('ゾンビをAからBに転送させる', async () => {
            // ゾンビを生成
            const result = await cryptoZombies.createRandomZombie(
                zombieNames[0],
                {
                    from: alice,
                }
            );
            // 生成したゾンビのIDを数値に変換して格納 → ブロックを参照しないので非同期じゃない。
            const zombieId = result.logs[0].args.zombieId;
            // AliceのアドレスとゾンビのID を、アリスの名前で関数に渡す
            await cryptoZombies.transfer(bob, zombieId, { from: alice });
            // ゾンビの新しいオーナーを取得（移管を確認）
            const newOwner = await cryptoZombies.ownerOf(zombieId);
            // Bob のアドレスが新しいオーナーと等しいかどうかをアサート
            assert.equal(bob, newOwner);
        });
    });

    xcontext('2ステップ目の転送シナリオをテスト', async () => {
        it('承認されたアドレスがtransferFromを呼び出したら、ゾンビを承認して転送を許可する。', async () => {});

        it('オーナーがtransferFromを呼び出したら、承認してゾンビを転送する。', async () => {});
    });
});
