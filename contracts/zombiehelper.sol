// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./zombiefeeding.sol";

/**
    # 可視性修飾詞
    private修飾詞はコントラクト内の別の関数からのみ呼び出される.
    external修飾詞はコントラクト外からだけ呼び出す事ができて、
    最後にpublic修飾詞だが、これはコントラクト内部・外部どちらからでも呼び出せる

    # 状態修飾詞
    view修飾詞は関数が動作しても、なんのデータも保存または変更されないということだ。
    pure修飾詞は、関数がブロックチェーンにデータを保存しないだけでなく、
    ブロックチェーンからデータを読み込むこともない
    + カスタムのmodifier 
    onlyOwner や aboveLevel などの、定義できる修飾子
    EX) function test() external view onlyOwner anotherModifier {......}
    payable -> Etherを受け取ることができる特別なタイプの関数.
    valueは、コントラクトにどのくらいEtherが送られたかを見るやり方で、etherは組み込み単位.
    ex) -> JS からの関数の呼び出しと同時に、イーサを送金している。
    OnlineStore.buySomething({from: web3.eth.defaultAccount, value: web3.utils.toWei(0.001)})
    ↓
    コントラクトに送られたEthは、コントラクトのイーサリアム・アカウントに貯められる。
    コントラクトからEtherを引き出す関数を追加しない限りはそこに閉じ込められたままになってしまう
        owner.transfer(this.balance);
    transfer関数でEtherをあるアドレスに送る。 → この場合はOwnerのアドレス
    this.balanceはコントラクトに溜まっている残高（100人 １etherなら 100ether）の総量を返す。

    購入者と販売者間のコントラクトにおいて、販売者のアドレスをストレージに保存しておいて、
    誰かが販売者のアイテムを購入する際に、購入者が支払った料金を販売者に送金することも可能となる。
    やり方はこうだ。seller.transfer(msg.value)
    こんな感じで、誰にもコントロールされない分散型マーケットプレイスが持てる。
 */

/**
    @dev  ゾンビが一定のレベルに達したら、何か特別な能力を身につけるようにする
 */
contract ZombieHelper is ZombieFeeding {
    uint levelUpFee = 0.001 ether;

    /**
        @param _zombieId -> ゾンビのインデックス
        zombiefactory.sol の zombies配列から、Zomibie構造体をGetし、レベルを取り出す
     */
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }

    /**
     * payable の自分のアドレスに、現在のコントラクトの残高を送る。
     */
    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    /**
     *  オーナーからしか呼び出せない関数
     * @param _fee レベルアップの料金に設定する金額 → etherの高騰対策
     */
    function setLevelUpFee(uint _fee) external onlyOwner {
        levelUpFee = _fee;
    }

    /**
     * @dev ユーザーがETHを支払って自分のゾンビをレベルアップできる機能
     * @param _zombieId レベルアップの対象のインデックス → 配列から取り出して使う。
     *  payable に、送金されたイーサが格納されて呼び出される。 → mag.value で取り出し
     */
    function levelUp(uint _zombieId) external payable {
        require(msg.value == levelUpFee);
        zombies[_zombieId].level++;
    }

    function changeName(
        uint _zombieId,
        string memory _newName
    ) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].name = _newName;
    }

    function changeDna(
        uint _zombieId,
        uint _newDna
    ) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
        zombies[_zombieId].dna = _newDna;
    }

    /**
        @dev オーナーの所持しているゾンビの一覧を返す。 → マップでやるとガスコストが高くなるので、配列。
            マップを作ってownerToZombies[owner].push(zombieId) をやると
            配列に順次格納するので、配列内のゾンビの移動があった場合に 1つ動かすと 19個動かしたり
            しなくちゃならない。 → ガスコストが大幅にかかる。

            view関数は外部から呼び出した時にガスコストがかからないから、
            getZombiesByOwner内でforループを使ってそのオーナーのゾンビ軍団の配列を
            作ってしまえばいい。 そうすればtransfer関数はstorage内の配列を並び替える
            必要がないため安く抑えられるし、直感的ではないにしろ全体のコストも抑えられる。
     */
    function getZombiesByOwner(
        address _owner
    ) external view returns (uint[] memory) {
        uint[] memory result = new uint[](ownerZombieCount[_owner]);

        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            // owner == address
            if (zombieToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }

        return result;
    }
}
