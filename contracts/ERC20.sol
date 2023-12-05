// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract ERC20 {
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    string public name;
    string public symbol;
    uint256 immutable decimals;
    address public feeReceiver;
    uint8 public feePercent;
    uint256 public totalSupply;
    address public owner;
    uint256 public constant MAX_SUPPLY = 1e27;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _decimals,
        uint8 _feesPercent,
        address _feeReceiver,
        uint256 _totalSupply,
        address _owner
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        feePercent = _feesPercent;
        feeReceiver = _feeReceiver;
        totalSupply = _totalSupply;
        owner = _owner;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) private returns (bool) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        uint256 fees = (_value * feePercent) / 100;
        uint256 valueAfterFees = _value - fees;
        balanceOf[_from] -= _value;
        if (fees > 0) {
            balanceOf[feeReceiver] += fees;
            emit Transfer(_from, feeReceiver, fees);
        }
        balanceOf[_to] += valueAfterFees;
        emit Transfer(_from, _to, valueAfterFees);
        return true;
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(
            allowance[_from][msg.sender] >= _value,
            "Insufficient allowance"
        );
        allowance[_from][msg.sender] -= _value;
        emit Approval(_from, msg.sender, allowance[_from][msg.sender]);
        return _transfer(_from, _to, _value);
    }

    function changeFeeReceiver(address _newFeeReceiver) external onlyOwner {
        address oldFeeReceiver = feeReceiver;
        uint256 amountToTransfer = balanceOf[oldFeeReceiver];
        balanceOf[oldFeeReceiver] = 0;
        feeReceiver = _newFeeReceiver;
        balanceOf[feeReceiver] = amountToTransfer;
        emit Transfer(oldFeeReceiver, _newFeeReceiver, amountToTransfer);
    }

    function _mint(address to, uint256 amount) internal returns (bool) {
        require(totalSupply + amount <= MAX_SUPPLY, "Max supply exceeded");
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner returns (bool) {
        return _mint(to, amount);
    }

    // Decentralized burn
    function burn(uint256 amount) external {
        require(
            balanceOf[msg.sender] >= amount,
            "Insufficient balance to burn"
        );

        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

    // Centralized burn
    // function burn(address _from, uint256 _value) external onlyOwner {
    //     totalSupply -= _value;
    //     balanceOf[_from] -= _value;
    //     emit Transfer(_from, address(0), _value);
    // }

    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        uint256 tokensToMint = msg.value;
        _mint(msg.sender, tokensToMint);
    }

    function withdrawEther(
        address payable recipient,
        uint256 amount
    ) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        recipient.transfer(amount);
    }

    function _burn(address from, uint256 amount) internal {
        require(
            balanceOf[from] >= amount,
            "Insufficient token balance to burn"
        );
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function redeem(uint256 amount) external {
        require(
            transferFrom(msg.sender, msg.sender, amount),
            "Token transfer failed"
        );
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}
