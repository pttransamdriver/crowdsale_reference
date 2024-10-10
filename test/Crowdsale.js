const {expect} = require("chai");
const {ethers} = require("hardhat");

const tokens = function (n){
    return ethers.utils.parseUnits(n.toString(), 'ether');
}

const ether = tokens;

describe("Crowdsale Contract Test", function() {
    let crowdsale
    let token
    let deployer
    let user1

    beforeEach(async function() {
        // Load Crontracts
        const Crowdsale = await ethers.getContractFactory("contracts/Crowdsale.sol:Crowdsale");
        const Token = await ethers.getContractFactory('Token');

        token = await Token.deploy('My Hardhat Token', 'MHT', '1000000');

        accounts = await ethers.getSigners();
        deployer = accounts[0];
        user1 = accounts[1];

        crowdsale = await Crowdsale.deploy(token.address, ether(1), '1000000');

        let transaction = await token.connect(deployer).transfer(crowdsale.address, tokens(1000000));
        await transaction.wait();

    })

    describe("Deployment", function() {

        it('sends token to the Crowdsale contract', async function () {
            expect(await token.balanceOf(crowdsale.address)).to.equal(tokens(1000000));
        });

        it('returns the price', async function() {
            expect(await crowdsale.price()).to.equal(ether(1));
        });

        it('returns token address', async function(){
            expect(await crowdsale.token()).to.equal(token.address)
        });
    });

    describe("Buying Tokens", function() {
        let transaction, result;
        let amount = tokens(10);

        describe('Success', function() {
            beforeEach(async function (){
            transaction = await crowdsale.connect(user1).buyTokens(amount, { value: ether(10)});
            result = await transaction.wait();
            })

            it('transfers tokens', async function() {
                expect(await token.balanceOf(crowdsale.address)).to.equal(tokens(999990));
                expect(await token.balanceOf(user1.address)).to.equal(amount);
            });

            it('updates contract ether balance', async function(){
                expect(await ethers.provider.getBalance(crowdsale.address)).to.equal(amount)
            });

            it('updates tokensSold', async function() {
                expect(await crowdsale.tokensSold()).to.equal(amount);
            });

            it('emits a buy event', async function(){
                //console.log(result)
                await expect(transaction).to.emit(crowdsale, "Buy").withArgs(amount, user1.address)
            })

            
        });
        describe('Failure', function() {
            it('rejects insufficent ETH', async function() {
                await expect(crowdsale.connect(user1).buyTokens(tokens(10), { value: 0})).to.be.reverted
            });
        });   
    });

    describe('Sending ETH', function(){
        let transaction, result;
        let amount = ether(10);

        describe('Success', function() {

            beforeEach(async function() {
                transaction = await user1.sendTransaction({to: crowdsale.address, value: amount});
                result = await transaction.wait()
            });

            it('updates contracts ether balance', async function() {
                expect(await ethers.provider.getBalance(crowdsale.address)).to.equal(amount);
            });

            it('user token balance', async function() {
                expect(await token.balanceOf(user1.address)).to.equal(amount)
            })
        })
    })
    describe('Changing the price', async function(){
        let transaction, result
        let price = ether(2);

        describe('Success', function(){

            beforeEach(async function(){
                transaction = await crowdsale.connect(deployer).setPrice(ether(2));
                result = await transaction.wait();
            });

            it('updates the price', async function(){
                expect(await crowdsale.price()).to.equal(ether(2));
            });

        });

        describe('Failure', async function(){

        });
    });

    describe('Finalizing the sale', function() {
        let transaction, result;
        let amount = tokens(10);
        let value = ether(10);

        describe('success', function(){
            beforeEach(async function(){
                transaction = await crowdsale.connect(user1).buyTokens(amount, {value: value});
                result = await transaction.wait();

                transaction = await crowdsale.connect(deployer).finalize();
                result = await transaction.wait();
            })

            it('transfers remaining to contract owner', async function(){
                expect(await token.balanceOf(crowdsale.address)).to.equal(0)
                expect(await token.balanceOf(deployer.address)).to.equal(tokens(999990));
            })

            it('transfers ETH balance to', async function(){
                expect(await ethers.provider.getBalance(crowdsale.address)).to.equal(0)
            })

            it('emits Finalized event', async function() {
                await expect(transaction).to.emit(crowdsale, "Finalize").withArgs(amount, value);
            })


        })

        describe('Faiure', function(){

            it('prevents non-owner from finalizing', async function() {
                await expect(crowdsale.connect(user1).finalize()).to.be.reverted;
            });
        })

    })

});
