pragma solidity ^0.4.15;
contract VehicleDataManagement {
    
    event Creation(
        address indexed from,
        string indexed vin
    );

    
    event Transfer(
        address indexed from,
        address indexed to,
        string indexed vin
    );

    //an event is emitted  , it stores the arguments passed in transaction log

    
    
    struct Car { 
        string vin;
        address owner;
	string brand_name;
        string model_name;
        string purchase_date;
        string owner_name;
        bool isFirstHandOwner;
    }

    struct Maintenance {
        string vin;
        string vehicleCondition;
        uint currentOdometer;
        uint currentEngineHours;
        string lastService;
        string ServiceType;
        bool partsReplaced;
        uint cost;
        bool isUnderInsurance;
        string Message;
        
    }

    struct Auther {  
           
            string id; //id is same as vin of a car
            address owner; 
            address[] auth_address; //array will contain all account address addedd by a particular car owner
    }


    address[] users_address;//array to store user address by admin



    address[] mech_address;//array to store mechanic address by admin


    mapping(string =>Auther) Auth_address; // id is mapped to Auther struct (key -> value pair)
    mapping (string => Maintenance) maintenance;
    mapping (string => Car) cars;
    
   constructor() public {} //constructor
    
    
     address addOwn = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4; //address of owner

     function addUser(address add) public { //admin can add a user to the system
         assert(msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
         //users_gmail.push(gmail);
         users_address.push(add); //pusing address of user to array
         
     }

 function addMechanic(address add) public {//admin can add a mechanic to the system
         assert(msg.sender == 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
       
         mech_address.push(add);//pusing address of mechanic to array
         
     }

      function addAuther(string id ) internal { 
        Auth_address[id].id = id;
        Auth_address[id].owner = msg.sender;
        Auth_address[id].auth_address.push(msg.sender);
        
         
     }

     function GrantViewPermission(string id , address add) onlyUser() { //users can add authorized users who can view their maintenance report
         Auther storage transferObject = Auth_address[id];
         assert(Auth_address[id].owner == msg.sender);
      
        transferObject.auth_address.push(add);
        
         
     }

       
     function viewAllowed(string id) public view returns (address[] memory) {//users can view users who can view their maintenance report
          Auther storage transferObject = Auth_address[id];
         assert(transferObject.owner == msg.sender);
     return transferObject.auth_address;
    }


  function RevokeViewPermission(string id , uint256 index) onlyUser() {//users can remove authorized users who can view their maintenance report
         Auther storage transferObject = Auth_address[id];
         assert(Auth_address[id].owner == msg.sender);
         assert(index!=0);
         address element = transferObject.auth_address[index];
transferObject.auth_address[index] = transferObject.auth_address[transferObject.auth_address.length - 1];
delete transferObject.auth_address[transferObject.auth_address.length - 1];

        
         
     }

     


    function addCar(string vin,string brand_name, string model_name, string purchase_date, string owner_name, bool isFirstHandOwner) public onlyUser() {
        //to add a car to the system..only for users whose are added into system by admin

        assert(cars[vin].owner == 0x0);// assert that owner value is not defined already
       
        cars[vin].vin = vin;
        cars[vin].owner = msg.sender;
	cars[vin].brand_name = brand_name;
	cars[vin].model_name = model_name;
	cars[vin].purchase_date = purchase_date;
    cars[vin].owner_name = owner_name;
        cars[vin].isFirstHandOwner = isFirstHandOwner;

        maintenance[vin].vin = vin; 
        // maintenace report also created with id==vin but other value of struct maintenace will be default initially
        
        addAuther(vin); //so that car owner can view his maintenace report

	emit Creation(msg.sender, vin);//calling the event creation
    }
    
    
   function updateMaintenanceReport(string vin , string vehicleCondition, uint currentOdometer, uint currentEngineHours, string lastService, string ServiceType,bool partsReplaced,uint cost,bool isUnderInsurance, string Message ) public onlyMechanic() {
       //to update maintenance report ...only accessible by mechanic who has been added into system by admin
       
       if(onlyAllowed(vin) == true){ //if condition specified so that only authorized mechanic can update maintenace report

        Maintenance storage transferObject = maintenance[vin];
        transferObject.vehicleCondition = vehicleCondition;
        transferObject.currentOdometer = currentOdometer;
        transferObject.currentEngineHours = currentEngineHours;
       transferObject.lastService = lastService ;
       transferObject.ServiceType = ServiceType;
       transferObject.partsReplaced = partsReplaced;
       transferObject.cost = cost;
        transferObject.isUnderInsurance = isUnderInsurance;
         transferObject.Message = Message;
    }
    }
    
   
    function transferOwnership(string vin, address owner , string new_owner_name) public onlyUser() { 
        //to tranfer ownership of a car to another user in the system

        Car storage transferObject = cars[vin];
        assert(transferObject.owner == msg.sender); 
        transferObject.owner = owner;
        transferObject.owner_name = new_owner_name;//new owner name
        transferObject.isFirstHandOwner = false; //after the tranfer of ownership this variable value will become false

        Auther storage transferObject2 = Auth_address[vin];
        assert(transferObject2.owner == msg.sender);
        transferObject2.owner = owner;
        transferObject2.auth_address[0] = owner;
        emit Transfer(msg.sender, owner, vin);//call event Transfer


    }
    
   
    function viewCar(string vin) onlyUser() view returns(address owner,  string brand_name, string model_name , string purchase_date,  string owner_name , bool isFirstHandOwner)  {
        //only users added into system can view a car detail

        Car storage transferObject = cars[vin];
        //assert(transferObject.owner == msg.sender); 
        owner = cars[vin].owner;
        brand_name = cars[vin].brand_name;
        model_name = cars[vin]. model_name ;
        purchase_date = cars[vin].purchase_date;
        owner_name = cars[vin].owner_name;
        isFirstHandOwner = cars[vin].isFirstHandOwner;
    }

     function viewMaintenaceReport(string vin)  public view returns( string vehicleCondition, uint currentOdometer, uint currentEngineHours, string lastService, string ServiceType,bool partsReplaced,uint cost,bool isUnderInsurance, string Message)  {
        

           if(onlyAllowed(cars[vin].vin) == true){ //if condition specified so that only authorized user/mechanic can view maintenance report

        Maintenance storage transferObject = maintenance[vin];
        vehicleCondition = maintenance[vin].vehicleCondition;
        currentOdometer = maintenance[vin].currentOdometer;
        currentEngineHours = maintenance[vin].currentEngineHours;
       lastService = maintenance[vin].lastService ;
        ServiceType = maintenance[vin].ServiceType;
       partsReplaced = maintenance[vin].partsReplaced;
        cost = maintenance[vin].cost;
        isUnderInsurance = maintenance[vin].isUnderInsurance;
         Message = maintenance[vin].Message;
    }
    }


    modifier onlyMechanic(){ //modifier 
        uint flag = 0;
        for(uint256 j=0;j<mech_address.length;j++){
            if(mech_address[j] == msg.sender){
                flag = 1;
                break;
            }
        }
        require(flag == 1);
        _;
        }

        modifier onlyUser(){ //modifier
        uint flag = 0;
             for(uint256 j=0;j<users_address.length;j++){
            if(users_address[j] == msg.sender){
                flag = 1;
                break;
            }
        }
        require(flag == 1);
        _;
        }

    function onlyAllowed(string id) internal returns (bool){ //function to restrict access...used internal keyword
        uint flag = 0;
             for(uint256 j=0;j<Auth_address[id].auth_address.length;j++){
                 //id is same as vin for car for a particular owner
                 //auth_address is array which contain all users allowed by car owner to view mainteanace report
            if(Auth_address[id].auth_address[j] == msg.sender){
                flag = 1;
                break;
            }
        }
        if(flag==1)
        return true;
        else
        return false;
        }
        
    
}
