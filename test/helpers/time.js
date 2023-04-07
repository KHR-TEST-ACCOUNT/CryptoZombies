/** @format */

// ブロックのメソッドを呼び出すので非同期関数にする。
async function increase(duration) {
    // evm_increaseTime 時間を進める
    // currentProvider.sendAsync は 1.0 で廃止
    // web3.currentProvider.send()はコールバック パラメータを想定 → Await使えない
    return new Promise((resolve, reject) => {
        web3.currentProvider.send(
            {
                jsonrpc: '2.0',
                method: 'evm_increaseTime',
                params: [duration],
                id: new Date().getTime(),
            },
            (err, result) => {
                // コールバック内再呼び出し
                web3.currentProvider.send(
                    {
                        jsonrpc: '2.0',
                        method: 'evm_mine',
                        params: [],
                        id: new Date().getTime(),
                    },
                    (err, result) => {
                        // 2つ目のコールバックでPromiseを解決する
                        resolve();
                    }
                );
            }
        );
    });

    // await web3.currentProvider.send(
    //     {
    //         jsonrpc: '2.0',
    //         method: 'evm_increaseTime',
    //         params: [duration], // there are 86400 seconds in a day
    //         id: new Date().getTime(),
    //     },
    //     () => {}
    // );
    // // evm_mine 進めた時間のブロックをマイニングする → ブロックは参照しかしないので非同期にしない
    // web3.currentProvider.send({
    //     jsonrpc: '2.0',
    //     method: 'evm_mine',
    //     params: [],
    //     id: new Date().getTime(),
    // });
}

const duration = {
    seconds: function (val) {
        return val;
    },
    minutes: function (val) {
        return val * this.seconds(60);
    },
    hours: function (val) {
        return val * this.minutes(60);
    },
    days: function (val) {
        return val * this.hours(24);
    },
};

module.exports = {
    increase,
    duration,
};
