/** @format */

/**
 * @dev 関数がエラーならエラーをアサートする。 それ以外はTrueをアサート
 * @param promise -> 関数を渡す。
 */
async function shouldThrow(promise) {
    try {
        await promise;
        assert(true);
    } catch (err) {
        return;
    }
    assert(false, 'コントラクトの実行に失敗');
}

/**
 * エクスポートする関数を選択
 */
module.exports = {
    shouldThrow,
};
