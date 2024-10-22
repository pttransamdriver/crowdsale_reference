const Info = function ({ account, accountBalance }) {
    return (
        <div className="my-3">
            <p><strong>Your Account:</strong> {account}</p>
            <p><strong>Tokens Owned:</strong> {accountBalance}</p>
        </div>
    );
}

export default Info;
