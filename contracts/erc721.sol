// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title 抽象的なコンストラクトを定義する ERC721トークン のコントラクト
 * @notice
 */
abstract contract ERC721 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 _tokenId
    );

    /**
     * 実装のない関数には、virtual を付けて、オーバーライドすることを宣言しなければならない。
     */
    function balanceOf(
        address _owner
    ) public view virtual returns (uint256 _balance);

    function ownerOf(
        uint256 _tokenId
    ) public view virtual returns (address _owner);

    /**
     * @dev オーナーから指定のアドレスへトークンを送る。
     * @param _to オーナーから送る指定のアドレス
     * @param _tokenId トークンID
     */
    function transfer(address _to, uint256 _tokenId) public virtual;

    /**
     * @dev approve + takeOwnership
     * @param _to トークンの受け取り許可をする指定のアドレス → Mapに格納する
     * @param _tokenId トークンのID
     */
    function approve(address _to, uint256 _tokenId) public virtual;

    /**
     * @dev approve　で許可された人が呼び出す関数
     * @param _tokenId 移管するトークン → 関数の呼び出しもとが所有者からの認可をえているかをチェック
     *                  → 承認済みなら、呼び出した人にトークンを移転する。
     */
    function takeOwnership(uint256 _tokenId) public virtual;
}
