/** @format */

// コントラクトへアクセス ############
var abi; //コントラクトをJson形式で表したファイル
var ZombieFeedingContract = web3.eth.contract(abi);
var contractAddress; // Ethereumにデプロイした、コントラクトのアドレス
// ZombieFactory変数で、上記コントラクトの Public関数・event にアクセスできるようにする。
var ZombieFeeding = ZombieFeedingContract.at(contractAddress);

// ゾンビのIDと捕食したい子猫のIDをすでに持っているものとする。
let zombieId = 1;
let kittyId = 1;

// クリプトキティの画像を取得するにはweb APIに照会する必要がある。
// この情報はブロックチェーンにはない。ウェブサーバーにあるだけだ。
// もし全ての情報がブロックチェーン上に格納されていれば、サーバーの
// 障害を心配することはなくなるがな。まぁこのゾンビゲームを気に入ってもらえなければ、
// APIを変更するか我々のアクセスをブロックするだけだ。問題ない ;)
let apiUrl = 'https://api.cryptokitties.co/kitties/' + kittyId;
$.get(apiUrl, function (data) {
    let imgUrl = data.image_url;
    // 画像を表示する部分だ
});

// ユーザーが子猫をクリックししたときの処理だ：
$('.kittyImage').click(function (e) {
    // コントラクトの`feedOnKitty` メソッドを呼び出す
    ZombieFeeding.feedOnKitty(zombieId, kittyId);
});

// コントラクトのNewZombieイベントをリッスンして表示できるようにする部分だ：
ZombieFactory.NewZombie(function (error, result) {
    if (error) return;
    // この関数はレッスン1でやったのと同じようにゾンビを表示するものだ：
    generateZombie(result.zombieId, result.name, result.dna);
});
