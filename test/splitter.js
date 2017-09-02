const Splitter = artifacts.require("./Splitter.sol")
const sequentialPromise = require("../util/sequentialPromise.js")

contract('Splitter', accounts => {
  const admin = accounts[0];
  const alice = accounts[1];
  const bob = accounts[2];
  const carol = accounts[3];

  beforeEach(() => {
    return Splitter.new({from: admin}).then(_instance => {instance = _instance})
  })

  it("should anyone to split funds two different people updating their ballance in the contract", function() {
    return instance.split(
      bob,
      carol,
      {from: alice, value: 51, gas: 3000000}
    )
    .then(() => {
      return sequentialPromise([
        () => instance.balances(alice),
        () => instance.balances(bob),
        () => instance.balances(carol)
      ])
    })
    .then(balances => {
      const aliceBalance = balances[0].toString(10)
      const bobBalance = balances[1].toString(10)
      const carolBalance = balances[2].toString(10)

      assert.equal(aliceBalance, "1", "Did not handle the remainder correctly. (ie division of odd number by 2)")
      assert.equal(bobBalance, "25", "Bob recieved the incorect amoun from the split.")
      assert.equal(carolBalance, "25", "Carol recieved the incorect amoun from the split.")
    })
  })
})
