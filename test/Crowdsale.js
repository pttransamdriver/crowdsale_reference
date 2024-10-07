const {expect} = require("chai");
const {ethers} = require("hardhat");

const tokens = function (n){
    return ethers.utils.parseUnits(n.toString(), 'ether');
}

describe("Crowdsale", function() {
    let crowdsale
    let token

    beforeEach(async function() {
        const Crowdsale = await await ethers.getContractFactory("Crowdsale");
        const Token = await ethers.getContractFactory('Token');
        token = await Token.deploy('My Hardhat Token', 'MHT', '1000000');
        crowdsale = await Crowdsale.deploy(token.address);

    })

    describe("Deployment", function() {

        it('returns token address', async function() {
            expect(await crowdsale.token()).equal(token.address)
        })
    });
});
