// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

contract GasContract is Ownable {

    uint private basicFlag = 0;

    uint public totalSupply; // cannot be updated
    uint public paymentCounter;
    uint public tradePercent = 12;
    address public contractOwner;
    uint public tradeMode;
    address [5] public administrators;
    enum PaymentType { Unknown, BasicPayment, Refund, Dividend, GroupPayment }
    PaymentType constant defaultPayment = PaymentType.Unknown;

    mapping(address => uint256) public balances;
    mapping(address => Payment[]) public payments;

    struct Payment {
      uint paymentID;
      PaymentType paymentType;
      address recipient;
      uint amount;
    }

    struct History {
      uint256 lastUpdate;
      address updatedBy;
      uint256 blockNumber;  
    }

    modifier onlyAdminOrOwner {
        require (checkForAdmin(msg.sender), "Gas Contract Only Admin Check-  Caller not admin" );
        _;
    }

    event Transfer(address recipient, uint256 amount);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        contractOwner  = msg.sender;
        totalSupply = _totalSupply;

        for (uint256 i = 0;i<administrators.length ;i++){
            if(_admins[i] != address(0)){ 
                administrators[i] = _admins[i];
                if(_admins[i]==msg.sender){
                    balances[msg.sender] = totalSupply;
                }
                else {
                    balances[_admins[i]] = 0;
                }
            } 
        }
    }

   function checkForAdmin(address _user) public view returns (bool) {
       for (uint256 ii = 0; ii< administrators.length;ii++ ){
          if(administrators[ii] ==_user){
              return true;
          }
       }
       return false;
   }
   
    function balanceOf(address _user) public view returns (uint balance_){
        return balances[_user];
    }

    function getTradingMode() public pure returns (bool){
        return true;
    }

   function getPayments(address _user) public view returns (Payment[] memory payments_) {
        return payments[_user];
   }

    function transfer(address _recipient, uint _amount, string calldata _name) public returns (bool) {
        require(balances[msg.sender] >= _amount,"Gas Contract - Transfer function - Sender has insufficient Balance");
        balances[msg.sender] -= _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        Payment memory payment;
        payment.paymentType = PaymentType.BasicPayment;
        payment.recipient = _recipient;
        payment.amount = _amount;
        payment.paymentID = ++paymentCounter;
        payments[msg.sender].push(payment);
        return (true);
    }

    function updatePayment(address _user, uint _ID, uint _amount,PaymentType _type ) public onlyAdminOrOwner {
        for (uint256 ii=0; ii < payments[_user].length;ii++){
            if(payments[_user][ii].paymentID==_ID){
                payments[_user][ii].paymentType = _type;
                payments[_user][ii].amount = _amount;
            }
        }
    }
}
