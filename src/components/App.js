import { Container } from 'react-bootstrap';
import { ethers } from 'ethers';
import { useEffect, useState } from 'react';

//Imported Containers
import Navigation from './Navigation';
import Info from './Info';
import Progress from './Progress';
import Loading from './Loading';
import Buy from './Buy';

// ABIs
import TOKEN_ABI from '../abis/Token.json'
import CROWDSALE_ABI from '../abis/Crowdsale.json'

// Import Configs
import config from '../config.json'

function App() {
  const [provider, setProvider] = useState(null);
  const [crowdsale, setCrowdsale] = useState(null);
  const [account, setAccount] = useState(null);
  const [accountBalance, setAccountBalance] = useState(0);

  const [price, setPrice] = useState(0);
  const [maxTokens, setMaxTokens] = useState(0);
  const [tokensSold, setTokensSold] = useState(0);

  const [isLoading, setIsLoading] = useState(true);

  const loadBlockchainData = async () => {
    // Initiate Provider
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    setProvider(provider);
    //const { chainID } = await provider.getNetwork();

    // Initiate Contracts
    const token = new ethers.Contract(config[31337].token.address, TOKEN_ABI, provider)
    const crowdsale = new ethers.Contract(config[31337].crowdsale.address, CROWDSALE_ABI, provider)
    //console.log(chainID)
    setCrowdsale(crowdsale)


    // Fetch account
    const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });  
    const account = ethers.utils.getAddress(accounts[0]);
    setAccount(account)

    //Fetch accounts balance
    const accountBalance = ethers.utils.formatUnits( await token.balanceOf(account), 18);
    setAccountBalance(accountBalance);
    console.log(accountBalance);
    
    // Fetch price
    const price = ethers.utils.formatUnits(await crowdsale.price(), 18);
    setPrice(price)

    //Fetch max tokens
    const maxTokens = ethers.utils.formatUnits(await crowdsale.maxTokens(), 18); 
    setMaxTokens(maxTokens)
    
    //Fetch tokens sold
    const tokensSold = ethers.utils.formatUnits(await crowdsale.tokensSold(), 18);
    setTokensSold(tokensSold);

    setIsLoading(false)
  };

  useEffect(() => {
    if (isLoading) {
      loadBlockchainData()
    }
  },[isLoading]);

  return(
    <Container>
      <Navigation />

      <h1 className='text-center my-4'>Introducing the DApp Token!</h1>

      {isLoading ? (
        <Loading />
        ):(
          <>
          <p className='text-center'><strong>Current Price:</strong> {price} ETH</p>
          <Buy provider={provider} price={price} crowdsale={crowdsale} setIsLoading={setIsLoading} />
          <Progress maxTokens={maxTokens} tokensSold={tokensSold}/>
          </>          
        )}

      <hr />
      {account && (
        <Info account = {account} accountBalance={accountBalance}/>
      )}
    </Container>
  );
}

export default App;
