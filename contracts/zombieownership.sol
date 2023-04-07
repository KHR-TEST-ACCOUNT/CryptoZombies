// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./zombieattack.sol";
// トークンのコントラクトの実装 → コントラクトを継承して、オーバーライドして使用する。
import "./erc721.sol";

/**
 *  Ethereumのトークン
 *  トークンとは、残高表示や送金などの関数が実装されたスマートコントラクトのこと（ ≠ ユーザー）
 *  ERC20 トークンというものが最近注目を集めている。
 *  → 理由は、このERC20 トークンは、実装されている関数が全て一緒だから。
 *      → トークンのアドレスを、現在のスマートコントラクトで指定するだけで、
 *          トークン間の送金などのやり取りが簡単に行える。
 *      → スマートコントラクトで、トークンを使えるようにするのも、上記でできて非常に簡単。
 *          → 送金ロジックを実現したい時、トークンのアドレスをDBに追加するだけで済むということ。
 *      通貨のような働きをする、素晴らしいトークン
 *
 *  ERC721 トークン
 *  レベル３のゾンビと、レベル１００のゾンビは、対等ではない。
 *   → ゾンビによって、付加価値がある。
 *   → そのような、それぞればユニークで、相互交換できないような トークンの規格をいう。
 *  ERC721 クリプト資産として数えられるので、そういう場合にとても便利 → ナイキのスニーカーなど。
 *      → これは、独自の付加価値をつけたトークン（ゾンビやスニーカーなど）を
 *          第三者の介入しないエスクローサービスで、ブロックチェーンを使うことで
 *          手数料無しで取引できるプラットフォームの実現を可能にしている。
 *      → Solidity で実装できる。
 *      → ERC20 と違い、トークンのメソッドを自分たちで定義する。 → 付加価値の定義 → 取引で重量
 */

/**
 * @title ゾンビのオーナシップ、 トークン → ゾンビ
 * @author koya
 * @dev ERC721トークン の実装 メソッドの実装を行う。
 *          → 抽象メソッドをオーバーライドするので、abstract をつける。
 */
contract ZombieOwnership is ZombieBattle, ERC721 {
    /** @dev 許可されたゾンビのIDとアドレスをマッピングする */
    mapping(uint => address) zombieApprovals;

    /**
     *  @dev ゾンビの所有者の、保有ゾンビ数を返す
     * @param _owner owever's address
     */
    function balanceOf(
        address _owner
    ) public view override returns (uint256 _balance) {
        return ownerZombieCount[_owner];
    }

    /**
     * @dev ゾンビIDを保有するオーナーのアドレスを返す
     * @param _tokenId ZombieId
     */
    function ownerOf(
        uint256 _tokenId
    ) public view override returns (address _owner) {
        return zombieToOwner[_tokenId];
    }

    /**
     *  トークンを A → B に移管する
     * @param _from 移管元アドレス
     * @param _to 移管先アドレス
     * @param _tokenId 移管するトークンID
     */
    function _transfer(address _from, address _to, uint256 _tokenId) private {
        // オーバーフロー、アンダーフロー対策
        // ownerZombieCount[_to]++
        ownerZombieCount[_to]++;
        ownerZombieCount[_from]--;
        // マッピングが To を指すように変更
        zombieToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    /**
     * @dev オーナーから指定のアドレスへトークンを送る。
     * @param _to オーナーから送る指定のアドレス
     * @param _tokenId トークンID(Zombie)
     */
    function transfer(
        address _to,
        uint256 _tokenId
    ) public override onlyOwnerOf(_tokenId) {
        _transfer(msg.sender, _to, _tokenId);
    }

    /**
     * @dev approve + takeOwnership オーナーから相手先にトークンを送ることを許可する
     * @param _to トークンの受け取り許可をする指定のアドレス → Mapに格納する
     * @param _tokenId トークンのID
     */
    function approve(
        address _to,
        uint256 _tokenId
    ) public override onlyOwnerOf(_tokenId) {
        zombieApprovals[_tokenId] = _to;
        // メソッドが呼ばれて、トークンを相手に送る許可をしたことをイベントで通知
        //  → オーナーが送りてとして引数に渡される。
        emit Approval(msg.sender, _to, _tokenId);
    }

    /**
     * @dev approve　で許可された人が呼び出す関数 → 関数を呼び出した人が Sender
     * @param _tokenId 移管するトークン → 関数の呼び出しもとが所有者からの認可をえているかをチェック
     *                  → 承認済みなら、呼び出した人にトークンを移転する。
     */
    function takeOwnership(uint256 _tokenId) public override {
        require(msg.sender == zombieApprovals[_tokenId]);
        // ownerOf(_tokenId) -> 現在のトークンの所持者を、移管する前に取得して関数に渡す。
        address owner = ownerOf(_tokenId);
        // Sender -> 関数を呼び出した人
        _transfer(owner, msg.sender, _tokenId);
    }
}
