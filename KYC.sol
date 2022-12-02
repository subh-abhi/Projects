//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.10;

contract KYC{

    uint256 bankCount = 0;
    address public adminAddress;

    //constructor to assign msg.sender address to admin address
    constructor (){
        adminAddress = msg.sender;

        addCustomer("Abhi", "PAN");
        addCustomer("Abhijeet", "Aadhar");
        addBank("Bank1", "REG12345", 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    } 

    struct Customer{
        string userName;
        string customerData;
        bool kycStatus;
        uint256 upVotes;
        uint256 downVotes;
        address bankAddress;
    }

    struct Bank{
        string bankName;
        address ethAddress;
        uint256 complaintsReported;
        uint256 KYC_count;
        bool isAllowedToVote;
        string regNumber;
        
    }

    struct KYCrequest{
        string userName;
        address bankAddress;
        string customerData;
    }

    mapping ( string => Customer) customers;
    mapping ( address => Bank) banks;
    mapping ( string => Bank ) bankStr;
    mapping ( string => KYCrequest) kycs;

    //Customer related Interface

    //To check if the customer is an existing customer or not
    modifier customerPresent(string memory _userName){
        require(customers[_userName].bankAddress != address(0), "Customer does not exist. Use Add function to add new customer.");
        _;
    }

    //This function will add a customer to the customer list.
    function addCustomer (string memory _userName, string memory _customerData) public{
        //To check if the customer is already existing or not
        require(customers[_userName].bankAddress == address(0), "Customer is already present. Use Modify function to edit customer details.");
        
        //assigning the new customer Details
        customers[_userName].userName = _userName;
        customers[_userName].customerData = _customerData;
        customers[_userName].bankAddress = msg.sender;
        customers[_userName].kycStatus = false;
        customers[_userName].upVotes = 0;
        customers[_userName].downVotes = 0;
    }

    //This function allows a bank to view a customer's data. 
    function viewCustomer (string memory _userName) public customerPresent(_userName) view returns (string memory, string memory, address, bool, uint256, uint256) {
        
        //returning the details of the customer
        return(customers[_userName].userName, customers[_userName].customerData, customers[_userName].bankAddress,customers[_userName].kycStatus, customers[_userName].upVotes, customers[_userName].downVotes);
    }

    //This function allows a bank to modify  the details of a customer. 
    function modifyCustomer (string memory _userName, string memory _customerData) public customerPresent(_userName){
    
        //chaging the customerData value
        customers[_userName].customerData = _customerData;
        
    }

    //Bank Interface 

    

    //This function is used to add the KYC request to the requests list.
    function addRequst (string memory _userName, string memory _customerData) public customerPresent(_userName){
        // require(customers[_userName].bankAddress != address(0), "Customer does not exist. Use Add function to add new customer.");
        require(kycs[_userName].bankAddress == address(0), "KYC request is already available in the list");
        require(banks[msg.sender].ethAddress != address(0), "Bank doesn't exist. Ask admin to create it");
        require(banks[msg.sender].isAllowedToVote == true, " Bank is restricted to vote due to more than 1/3rd bank reported.");
        
        kycs[_userName].userName = _userName;
        kycs[_userName].customerData = _customerData;
        kycs[_userName].bankAddress = msg.sender;
        banks[msg.sender].KYC_count++; 

    }

    // function verifyRequest(string memory _userName) public{
    //     require(customers[_userName].bankAddress != address(0), "Customer does not exist. Use Add function to add new customer.");
    //     require(customers[_userName].upVotes > customers[_userName].downVotes && customers[_userName].downVotes < bankCount/3 , "DownVotes is greater than one third hence kycStatus is set as false"); 
        
    //     customers[_userName].kycStatus = true; 
        

    // }

    function viewRequest (string memory _userName) public view returns (string memory, string memory, address, bool) {

        //To check if the customer is already existing or not
        require(kycs[_userName].bankAddress != address(0), "Request doesn't exist in the list.");

        //returning the details of the customer
        return(kycs[_userName].userName, kycs[_userName].customerData, kycs[_userName].bankAddress, customers[_userName].kycStatus);
    }

    //This function will remove the request from the requests list.
    function removeRequest (string memory _userName)  public{
        require(kycs[_userName].bankAddress != address(0), "Request doesn't exist in the list.");
        require(customers[_userName].upVotes > customers[_userName].downVotes && customers[_userName].downVotes <= bankCount/3 , "DownVotes is greater than one third hence kycStatus is set as false"); 
        require(banks[kycs[_userName].bankAddress].isAllowedToVote == true, " Bank is restricted to vote due to more than 1/3rd bank reported.");

        customers[_userName].kycStatus = true;
        kycs[_userName].bankAddress = address(0);

    }

    //This function allows a bank to cast an upvote for a customer.
    function upVote (string memory _userName) public customerPresent(_userName){
        //To check if the customer is already existing or not
        // require(customers[_userName].bankAddress != address(0), "Customer does not exist. Use Add function to add new customer.");

        customers[_userName].upVotes++;        

    }

    //This function allows a bank to cast a downvote for a customer.
    function downVote (string memory _userName) public customerPresent(_userName){
        //To check if the customer is already existing or not
        // require(customers[_userName].bankAddress != address(0), "Customer does not exist. Use Add function to add new customer.");

        customers[_userName].downVotes++;
    }

    //function to display upVotes and downVotes
    //This function allows a bank to cast an upvote for a customer.
    function viewVote (string memory _userName) public customerPresent(_userName) view returns(uint256, uint256, bool){
        //To check if the customer is already existing or not
        // require(customers[_userName].bankAddress != address(0), "Customer does not exist. Use Add function to add new customer.");

        return(customers[_userName].upVotes, customers[_userName].downVotes, banks[customers[_userName].bankAddress].isAllowedToVote );      

    }

    //This function is used to fetch the bank details.
    function viewBankDetails(address _ethAddress) public view returns (string memory, address, string memory,  uint256, uint256, bool){
        require(banks[_ethAddress].ethAddress != address(0), "Bank doesn't exist. Ask admin to create it");
        return(banks[_ethAddress].bankName, banks[_ethAddress].ethAddress, banks[_ethAddress].regNumber, banks[_ethAddress].complaintsReported, banks[_ethAddress].KYC_count, banks[_ethAddress].isAllowedToVote );

    }

    //This function is used to report a complaint against any bank in the network.
    function reportBank (address _ethAddress) public{
        require(banks[_ethAddress].ethAddress != address(0), "Bank doesn't exist. Ask admin to create it");
        // require(banks[_ethAddress].complaintsReported < bankCount/3, "Bank is reported more than 1/3rd of total banks");
        banks[_ethAddress].complaintsReported++;

        if(banks[_ethAddress].complaintsReported > bankCount/3)
        {
            banks[_ethAddress].isAllowedToVote = false;
        }

    }

    //This function will be used to fetch bank complaints from the smart contract.
    function getBankComplaints(address _ethAddress) public view returns(uint256){
        require(banks[_ethAddress].ethAddress != address(0), "Bank doesn't exist. Ask admin to create it");

        return (banks[_ethAddress].complaintsReported);

    }

    //Admin Interface

    //restricting functionality access only to Admin
    modifier onlyAdmin {
      require(msg.sender == adminAddress, "User is not Admin");
      _;
   }

    //This function is used by the admin to add a bank to the KYC Contract.
    function addBank(string memory _bankName, string memory _regNumber, address _ethAddress) public onlyAdmin{
       require(banks[_ethAddress].ethAddress == address(0), "Bank already exist."); 

       banks[_ethAddress].bankName = _bankName;
       banks[_ethAddress].regNumber = _regNumber;
       banks[_ethAddress].ethAddress = _ethAddress;
       banks[_ethAddress].isAllowedToVote = true;
       banks[_ethAddress].KYC_count = 0;
       banks[_ethAddress].complaintsReported = 0;
       bankCount++;

    }

    //This function can only be used by the admin to change the status of isAllowedToVote of any of the banks at any point in time.
    function isAllowedToVote (address _ethAddress, bool _isAllowedToVote) public onlyAdmin{
        require(banks[_ethAddress].ethAddress != address(0), "Bank doesn't exist. Add new bank");

        banks[_ethAddress].isAllowedToVote = _isAllowedToVote;
        banks[_ethAddress].complaintsReported = 0;

    }

    //This function is used by the admin to remove a bank from the KYC Contract.
    function removeBank (address _ethAddress) public onlyAdmin{
        require(banks[_ethAddress].ethAddress != address(0), "Bank doesn't exist. Add new bank");

        banks[_ethAddress].ethAddress = address(0);

        bankCount--;
        
    }

    function viewBankCount() public view returns(uint256){
        return(bankCount);
    }

}