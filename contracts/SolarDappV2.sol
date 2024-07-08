// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);    
}

interface IERC20Upgradeable {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20TransferProxy {
    function erc20safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) external;
}

interface IERC20Permit {
   
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

   
    function nonces(address owner) external view returns (uint256);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


interface IERC1155Permit {
      function permit(
        address owner,
        address operator,
        bool approved,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function mint(address account, uint256 id) external;
}

interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes calldata data) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;

    function mint(address account, uint256 id, uint256 amount, bytes memory data) external;
    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
    function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) external;
}


interface IERC6551Registry {
    event ERC6551AccountCreated(
        address account,
        address indexed implementation,
        bytes32 salt,
        uint256 chainId,
        address indexed tokenContract,
        uint256 indexed tokenId
    );
    error AccountCreationFailed();
    function createAccount(
        address implementation,
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external returns (address account);
    function account(
        address implementation,
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external view returns (address account);
}

interface IERC1155Receiver {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

interface IFactory {
    event CreateERC1155(address indexed contractAddress);
    function createERC1155(
        string calldata name_,
        string calldata symbol_,
        string calldata bURI_
    ) external view returns(address);
}


interface IMulticall3{
    struct Call3 {
        address target;
        bool allowFailure;
        bytes callData;
    }

    struct Result {
        bool success;
        bytes returnData;
    }

    function aggregate3(Call3[] calldata calls) external payable returns (Result[] memory returnData);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract SolarDappV2 is Context, Ownable, IERC1155Receiver {
    
    event ProjectAdded(uint256 indexed projectIndex, address contractAddress);
    event ProjectUpdated(uint256 indexed projectIndex, address contractAddress);
    event InvestAdded(address indexed account, uint256 indexed investIndex, uint256 projectIndex, address contractAddress, uint256 amount, uint256 nftValue); // amount是usdt数量 nftValue是nft 数量
    event ClaimReward(address indexed account, uint256 projectIndex, address contractAddress, uint256 nftId, uint256 nftValue, uint256 amount); // amount 是 收益usdt

    struct Project{
        bool enable; // enable project flag
        uint16 period; // months, the NFT ID count 
        uint32 startTime; 
        uint32 endTime;
        uint32 rewardStartTime;
        uint256 amount; // Total raising USDT amount 
        uint256 minInvestAmount; // Minimum investment USDT amount
        uint256 minMonthReward; // Minimum monthly return reward
        uint256 soldAmount; 
        address contractAddress; // project erc1155 contract address
    }

    struct Invest {
        uint32 projectIndex; // project index in _projectList
        uint32 nftValue; // nft id quantity
        uint256 amount; // invest amount
        address contractAddress; // project erc1155 contract address
    }

    uint constant SECONDS_PER_DAY = 86400;
    uint constant OFFSET1970 = 2440588;
    address constant REGISTER = 0x000000006551c19487814612e58FE06813775758;
    address constant ACCOUNT_PROXY = 0x55266d75D1a14E4572138116aF39863Ed6596E7F;
    address constant ACCOUNT_IMP = 0x41C8f39463A868d3A88af00cd0fe7102F30E44eC;
    address constant MULTI_CALL_3 = 0xcA1167915584462449EE5b4Ea51c37fE81eCDCCD;

    // USDT contract
    address private _paymentTokenAddress;    
    // TBA NFT contract
    address private _tbaNftAddress;
	// ERC1155 factory contract
    address private _erc1155FactoryAddress;
	// ERC20 token transfer contract, after the user authorizes this contract, dapp uses this contract to transfer erc20 token from user's account
    address private _erc20TransferProxy;

    uint _tbaNftIdStartFrom;

    mapping(address => Invest[]) private _userInvestList;
    Project[] private _projectList;
    address[] private _userList; // all invest addresses
    string _erc1155BaseUri = "https://powerlayer.org/erc1155/";

    constructor(address paymentTokenAddress, address tbaNftAddress, address erc1155FactoryAddress, address erc20TransferProxy, uint tbaNftIdStartFrom) {
        _paymentTokenAddress = paymentTokenAddress;
        _tbaNftAddress = tbaNftAddress;
        _erc1155FactoryAddress = erc1155FactoryAddress;
        _erc20TransferProxy = erc20TransferProxy;
        _tbaNftIdStartFrom = tbaNftIdStartFrom;
    }

    function getAllParam() external view returns(address paymentTokenAddress, address tbaNftAddress, address erc1155FactoryAddress, address erc20TransferProxy, uint tbaNftIdStartFrom,  string memory erc1155BaseUri){
        paymentTokenAddress = _paymentTokenAddress;
        tbaNftAddress = _tbaNftAddress;
        erc1155FactoryAddress = _erc1155FactoryAddress;
        erc20TransferProxy = _erc20TransferProxy;
        tbaNftIdStartFrom = _tbaNftIdStartFrom;
        erc1155BaseUri = _erc1155BaseUri;
    }

    function _createERC1155(string calldata name, string calldata symbol) internal returns(address contractAddress){
        IMulticall3.Call3[] memory call3=new IMulticall3.Call3[](1);
        bytes memory callData = abi.encodeWithSignature("createERC1155(string,string,string)",name,symbol,_erc1155BaseUri);
        call3[0]=IMulticall3.Call3(_erc1155FactoryAddress, false, callData);        // 低级调用
        IMulticall3.Result[] memory result = IMulticall3(MULTI_CALL_3).aggregate3(call3);
        require(result[0].success, "Call factory.createERC1155() failed");
        contractAddress = abi.decode(result[0].returnData, (address));
    }

    function addProject(uint256 minMonthReward, uint16 period, uint32 startTime, uint32 endTime, uint32 rewardStartTime, uint256 amount, uint256 minInvestAmount, string calldata name, string calldata symbol) public onlyOwner{
        uint projectIndex = _projectList.length;      
        address contractAddress = _createERC1155(name, symbol);  
        _projectList.push(Project(true, period, startTime, endTime, rewardStartTime, amount, minInvestAmount, minMonthReward, 0, contractAddress));
        emit ProjectAdded(projectIndex, contractAddress);
    }

    function updateProject(uint projectIndex, bool enable, uint256 minMonthReward, uint16 period, uint32 startTime, uint32 endTime, uint32 rewardStartTime, uint256 amount, uint256 minInvestAmount) external onlyOwner{
        Project storage project = _projectList[projectIndex];
        if(enable!=project.enable) project.enable = enable;
        if(minMonthReward!=project.minMonthReward) project.minMonthReward = minMonthReward;
        if(period!=project.period) project.period = period;
        if(startTime!=project.startTime) project.startTime = startTime;
        if(endTime!=project.endTime) project.endTime = endTime;
        if(rewardStartTime!=project.rewardStartTime) project.rewardStartTime = rewardStartTime;
        if(amount!=project.amount) project.amount = amount;
        if(minInvestAmount!=project.minInvestAmount) project.minInvestAmount = minInvestAmount;
        emit ProjectUpdated(projectIndex, project.contractAddress);
    }
    
    function getProjectList(uint offset, uint pageSize) external view returns (Project[] memory list){
        uint limit = _projectList.length < (offset + pageSize) ? _projectList.length : (offset + pageSize);
        list=new Project[](limit-offset);
        uint i;        
        uint j;  
        for(i=offset; i<limit; ++i){
            list[j++]=_projectList[i];
        }
    }

    function getUserTBA(address account) public view returns(uint tbaNftId, address tbaAddress){
        for(uint i=0; i<_userList.length; ++i){
            if(_userList[i]==account){
                tbaNftId = i+_tbaNftIdStartFrom;
                tbaAddress = IERC6551Registry(REGISTER).account(
                    ACCOUNT_PROXY,
                    0,
                    block.chainid,
                    _tbaNftAddress,
                    tbaNftId);
                break;
            }
        }
    }

    function _createTBA(address account, uint tbaNftId) internal returns(address tbaAccount){
        IERC721(_tbaNftAddress).mint(account, tbaNftId);
        tbaAccount = IERC6551Registry(REGISTER).account(
            ACCOUNT_PROXY,
            0,
            block.chainid,
            _tbaNftAddress,
            tbaNftId);

        // build call data
        IMulticall3.Call3[] memory call3=new IMulticall3.Call3[](2);
        bytes memory callData =  abi.encodeWithSignature("createAccount(address,bytes32,uint256,address,uint256)", ACCOUNT_PROXY, 0, block.chainid, _tbaNftAddress, tbaNftId);
        call3[0]=IMulticall3.Call3(REGISTER, false, callData);
        callData = abi.encodeWithSignature("initialize(address)", ACCOUNT_IMP);
        call3[1]=IMulticall3.Call3(tbaAccount, false, callData);
        // call
        IMulticall3(MULTI_CALL_3).aggregate3(call3);
    }

    function _mintBatch(address erc1155Address, address to, uint256 maxId, uint256 amount) internal{
        IMulticall3.Call3[] memory call3=new IMulticall3.Call3[](1);
        bytes memory callData = abi.encodeWithSelector(0x2e81aaea, to, maxId, amount); // "mintBatch(address,uint256,uint256)": "2e81aaea",
        call3[0]=IMulticall3.Call3(erc1155Address, false, callData);        
        IMulticall3.Result[] memory result = IMulticall3(MULTI_CALL_3).aggregate3(call3);
        require(result[0].success, "Call ERC1155.mintBatch() failed");
    }
    
    function _burnBatch(address erc1155Address, address account, uint256[] memory ids, uint256[] memory amounts) internal{
        IMulticall3.Call3[] memory call3=new IMulticall3.Call3[](1);
        bytes memory callData = abi.encodeWithSelector(0x6b20c454, account, ids, amounts); // "burnBatch(address,uint256[],uint256[])": "6b20c454"
        call3[0]=IMulticall3.Call3(erc1155Address, false, callData);        
        IMulticall3.Result[] memory result = IMulticall3(MULTI_CALL_3).aggregate3(call3);
        require(result[0].success, "Call ERC1155.burnBatch() failed");
    }

    function invest(uint32 projectIndex, uint amount) public returns(uint){  
        Project storage project = _projectList[projectIndex];
        require(project.enable, "Project is disable"); 
        require(block.timestamp>=project.startTime && block.timestamp<=project.endTime, "Project is not open");
        require(amount + project.soldAmount <= project.amount, "Exceed project amount");         
           
        uint nftValue = amount/project.minInvestAmount;

        require(amount == nftValue * project.minInvestAmount, "Invalid amount");  
        
        project.soldAmount += amount;
        IERC20TransferProxy(_erc20TransferProxy).erc20safeTransferFrom(IERC20Upgradeable(_paymentTokenAddress), msg.sender, address(this), amount);

        
        // update invest amount
        uint investIndex = _userInvestList[msg.sender].length;    
        address tbaAddress;
        if(investIndex==0){
            _userList.push(msg.sender);
            tbaAddress = _createTBA(msg.sender, _userList.length-1 + _tbaNftIdStartFrom); // nftId == user address index+1
            _mintBatch(project.contractAddress, tbaAddress, project.period, nftValue);
        }else{
            (, tbaAddress) = getUserTBA(msg.sender);
            _mintBatch(project.contractAddress, tbaAddress, project.period, nftValue);
            for(uint i=0;i<investIndex;++i){
                Invest storage _invest = _userInvestList[msg.sender][i];
                if(_invest.amount>0 && _invest.projectIndex == projectIndex){
                    _invest.amount += amount;
                    _invest.nftValue += uint32(nftValue);
                    emit InvestAdded(msg.sender, i, projectIndex, project.contractAddress, amount, nftValue);
                    return i;
                }
            } 
        }
        _userInvestList[msg.sender].push(Invest(projectIndex, uint32(nftValue), amount, project.contractAddress));
        emit InvestAdded(msg.sender, investIndex, projectIndex, project.contractAddress, amount, nftValue); 
        return investIndex;
    }
    
    function investWithPermit(
            uint32 projectIndex, uint amount,
            uint256 _deadline,
            uint8 _v,
            bytes32 _r,
            bytes32 _s
        ) external {

            // Permit logic to approve tokens for this contract
            IERC20Permit(_paymentTokenAddress).permit(
                msg.sender,
                address(this),
                amount,
                _deadline,
                _v,
                _r,
                _s
            );

            invest(projectIndex, amount);
    }
    
    function getProjectInfo(address contractAddress) public view returns(uint projectIndex, Project memory project){
        uint len = _projectList.length;
        for(uint i=0;i<len;++i){
            if(_projectList[i].contractAddress == contractAddress){
                projectIndex = i;
                project = _projectList[i];
            }
        }
    }

    function _claim(address account, address nftContractAddress, uint[] calldata nftIds, uint[] calldata nftValues) internal returns(uint totalClaimableAmount){ 
        (uint projectIndex, Project memory project) = getProjectInfo(nftContractAddress);
        require(project.rewardStartTime<block.timestamp, "!reward start time");
        uint months = monthsBetween(project.rewardStartTime, block.timestamp);

        uint nftId;
        uint nftValue;
        for(uint i=0; i < nftIds.length; ++i){
            nftId = nftIds[i];
            nftValue = nftValues[i];
            require(nftId<=months, "!claim start time");
            require(IERC1155(nftContractAddress).balanceOf(account,nftId)>=nftValue, "invalid nftValue");
        
            uint reward = project.minMonthReward*nftValue;  
            totalClaimableAmount += reward;  
            if(reward>0){
                emit ClaimReward(account, projectIndex, project.contractAddress, nftId, nftValue, reward);
            }
        }
        _burnBatch(nftContractAddress, account, nftIds, nftValues);
    }

    function claim(address nftContractAddress, uint[] calldata eoaNftIds, uint[] calldata eoaNftValues, uint[] calldata tbaNftIds, uint[] calldata tbaNftValues) external returns(uint totalClaimableAmount){ 
        
        if(eoaNftIds.length>0){
            totalClaimableAmount += _claim(msg.sender, nftContractAddress, eoaNftIds, eoaNftValues);
        }
        if(tbaNftIds.length>0){
            (uint tbaNftId, address tbaAddress) = getUserTBA(msg.sender);
            require(IERC721(_tbaNftAddress).ownerOf(tbaNftId)==msg.sender, "TBA bind NFT is not owner of you!");
            totalClaimableAmount += _claim(tbaAddress, nftContractAddress, tbaNftIds, tbaNftValues);
        }
        require(totalClaimableAmount>0, "Claimable amount is 0");

        IERC20(_paymentTokenAddress).transfer(msg.sender, totalClaimableAmount);  
    }

    function getClaimableAmount(address nftContractAddress, uint[] calldata nftIds, uint[] calldata nftValues) external view returns(uint totalClaimableAmount){ 
        (, Project memory project) = getProjectInfo(nftContractAddress);

        uint nowTime = block.timestamp;
        if(project.rewardStartTime>=nowTime) return 0;
        uint months = monthsBetween(project.rewardStartTime, nowTime);
        for(uint i=0; i < nftIds.length; ++i){
            if(nftIds[i]>months) continue;
            
            totalClaimableAmount += project.minMonthReward*nftValues[i];  
        }
    }

    function releaseERC20Token(address token, uint256 amount) external {
        IERC20(token).transfer(owner(), amount);
    }

    function releaseERC1155Token(address token, uint256 id, uint256 amount) external {
        IERC1155(token).safeTransferFrom(address(this), owner(), id, amount, bytes(""));
    }

    function setPaymentTokenAddress(address addr) external onlyOwner{
        _paymentTokenAddress = addr;
    }    

    function setTbaNftAddress(address addr) external onlyOwner{
        _tbaNftAddress = addr;
    }    

    function setFactoryAddress(address addr) external onlyOwner{
        _erc1155FactoryAddress = addr;
    }

    function setERC1155BaseUri(string calldata uri) external onlyOwner{
        _erc1155BaseUri = uri;
    }

    // 参与地址数
    function getUserCount() external view returns(uint256){
        return _userList.length;
    } 

    function getUserList(uint offset, uint pageSize) external view returns (address[] memory list){
        uint limit = _userList.length < (offset + pageSize) ? _userList.length : (offset + pageSize);
        list=new address[](limit-offset);
        uint i;  
        uint j;      
        for(i=offset; i<limit; ++i){
            list[j++]=_userList[i];
        }
    }
   
    function getUserInvestCount(address account) external view returns(uint256){
        return _userInvestList[account].length;
    } 

    function getUserInvestList(address account, uint offset, uint pageSize) external view returns (Invest[] memory list){
        Invest[] memory investList = _userInvestList[account];
        uint limit = investList.length < (offset + pageSize) ? investList.length : (offset + pageSize);
        list=new Invest[](limit-offset);
        uint i; 
        uint j;         
        for(i=offset; i<limit; ++i){
            list[j++]=investList[i];
        }
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external pure override returns (bytes4){
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external pure override returns (bytes4){
        return this.onERC1155BatchReceived.selector;
    }

    function getYearAndMonth(uint256 timestamp) public pure returns (uint256 year, uint256 month) {
        uint256 dayCount = timestamp / SECONDS_PER_DAY;

        uint256 L = dayCount + 68569 + OFFSET1970;
        uint256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        uint256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        uint256 _month = (80 * L) / 2447;
        L = _month / 11;
        year = 100 * (N - 49) + _year + L;
        month = _month + 2 - 12 * L;
    }

    // Calculate the number of natural months between two timestamps
    function monthsBetween(uint256 fromTimestamp, uint256 toTimestamp) public pure returns (uint256) {
        (uint256 fromYear, uint256 fromMonth) = getYearAndMonth(fromTimestamp);
        (uint256 toYear, uint256 toMonth) = getYearAndMonth(toTimestamp);

        return (toYear - fromYear) * 12 + toMonth - fromMonth;
    }
    
}