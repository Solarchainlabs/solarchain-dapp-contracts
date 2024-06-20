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

contract SolarDapp is Context, Ownable, IERC1155Receiver {
    
    event ProjectAdded(uint256 indexed projectIndex, uint256 amount, uint256 shares, uint256 apr, uint256 startTime, uint256 endTime);
    event ProjectUpdated(uint256 indexed projectIndex, bool enable, uint256 amount, uint256 shares, uint256 apr, uint256 startTime, uint256 endTime);
    event StakeAdded(address indexed account, uint256 indexed stakeIndex, uint256 nftId, uint256 shares, uint256 usdtAmount);
    event StakeRemoved(address indexed account, uint256 indexed stakeIndex, uint256 nftId, uint256 shares, uint256 usdtAmount);
    event ClaimReward(address indexed account, uint256 indexed stakeIndex, uint256 amount);

    struct Project{
        bool enable; // 是否开启
        uint32 apr;
        uint32 shares; // 股权份数
        uint32 soldShares; // 
        uint32 startTime; 
        uint32 endTime;
        uint256 amount; //募资总额
    }

    struct Stake {
        uint32 projectIndex; 
        uint32 claimedTime; // 最后一次领取时间
        uint32 nftId;
        uint32 shares;
        uint256 usdtAmount;
        uint256 reward; // 收益总额
        uint256 claimedReward; // 已经领取的收益
    }

    // USDT合约指针
    address private _paymentTokenAddress;    
    // NFT合约指针
    address private _nftAddress;
    mapping(address => Stake[]) private _userStakeList;
    Project[] private _projectList;
    address[] private _userList; // 方便之后遍历   

    constructor(address nftAddress, address paymentTokenAddress) {
        _nftAddress = nftAddress;
        _paymentTokenAddress = paymentTokenAddress;
    }

    function getAllParam() external view returns(address nftAddress, address paymentTokenAddress){
        nftAddress = _nftAddress;
        paymentTokenAddress = _paymentTokenAddress;
    }

    function addProject(uint32 apr, uint32 shares, uint32 startTime, uint32 endTime, uint256 amount) external onlyOwner{
        uint projectIndex = _projectList.length;
        _projectList.push(Project(true, apr, shares, 0, startTime, endTime, amount));
        emit ProjectAdded(projectIndex, amount, shares, apr, startTime, endTime);
    }

    function updateProject(uint projectIndex, bool enable, uint32 apr, uint32 shares, uint32 soldShares, uint32 startTime, uint32 endTime, uint256 amount) external onlyOwner{
        Project storage project = _projectList[projectIndex];
        if(enable!=project.enable) project.enable = enable;
        if(apr!=project.apr) project.apr = apr;
        if(shares!=project.shares) project.shares = shares;
        if(soldShares!=project.soldShares) project.soldShares = soldShares;
        if(startTime!=project.startTime) project.startTime = startTime;
        if(endTime!=project.endTime) project.endTime = endTime;
        if(amount!=project.amount) project.amount = amount;
        emit ProjectUpdated(projectIndex, enable, amount, shares, apr, startTime, endTime);
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

    function setNftAddress(address addr) external onlyOwner{
        _nftAddress = addr;
    }

    function setPaymentTokenAddress(address addr) external onlyOwner{
        _paymentTokenAddress = addr;
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
   
    function getUserStakeCount(address account) external view returns(uint256){
        return _userStakeList[account].length;
    } 

    function getUserStakeList(address account, uint offset, uint pageSize) external view returns (Stake[] memory list){
        Stake[] memory stakeList = _userStakeList[account];
        uint limit = stakeList.length < (offset + pageSize) ? stakeList.length : (offset + pageSize);
        list=new Stake[](limit-offset);
        uint i; 
        uint j;         
        for(i=offset; i<limit; ++i){
            list[j++]=stakeList[i];
        }
    }

    function _safeTransferFromEnsureExactAmount(
        address token,
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        uint256 oldRecipientBalance = IERC20(token).balanceOf(recipient);
        IERC20(token).transferFrom(sender, recipient, amount);
        uint256 newRecipientBalance = IERC20(token).balanceOf(recipient);
        require(
            newRecipientBalance - oldRecipientBalance == amount,
            "Not enough token was transfered"
        );
    }

    function getPaymentAmount(uint shares, uint usdtAmount, uint projectShares) internal pure returns(uint){
        return shares*usdtAmount/projectShares;
    }

    function invest(uint32 projectIndex, uint32 shares) public returns(bool){  
        Project storage project = _projectList[projectIndex];
        require(project.enable, "Project is disable"); 
        require(block.timestamp>=project.startTime && block.timestamp<=project.endTime, "Project is not open");
        require(shares + project.soldShares <= project.shares, "Exceed project max shares"); 
        project.soldShares += shares;
        uint paymentAmount = getPaymentAmount(shares,project.amount,project.shares);
        _safeTransferFromEnsureExactAmount(_paymentTokenAddress, msg.sender, address(this), paymentAmount);
        IERC1155(_nftAddress).mint(msg.sender, projectIndex, shares, bytes(""));
        return true;
    }
    
    function investWithPermit(
            uint32 projectIndex, uint32 shares,
            uint256 _deadline,
            uint8 _v,
            bytes32 _r,
            bytes32 _s
        ) external {
            Project memory project = _projectList[projectIndex];
            require(project.enable, "Project is disable"); 
            require(shares <= project.shares, "Exceed project max shares"); 
            uint paymentAmount = getPaymentAmount(shares,project.amount,project.shares);

            // Permit logic to approve tokens for this contract
            IERC20Permit(_paymentTokenAddress).permit(
                msg.sender,
                address(this),
                paymentAmount,
                _deadline,
                _v,
                _r,
                _s
            );

            invest(projectIndex, shares);
    }

    function stakeWithPermit(uint32 projectIndex, uint32 shares, 
            uint256 _deadline,
            uint8 _v,
            bytes32 _r,
            bytes32 _s) external returns(bool){  

        IERC1155Permit(_nftAddress).permit(
            msg.sender,
            address(this),
            true,
            _deadline,
            _v,
            _r,
            _s);

        return stakeNft(projectIndex, shares);
    }

    function stakeNft(uint32 projectIndex, uint32 shares) public returns(bool){  
        Project memory project = _projectList[projectIndex];
        IERC1155(_nftAddress).safeTransferFrom(msg.sender, address(this), projectIndex, shares, bytes(""));
        
        uint paymentAmount = getPaymentAmount(shares,project.amount,project.shares);
        uint stakeIndex = _userStakeList[msg.sender].length;    
        if(stakeIndex==0)_userList.push(msg.sender);
        else{
            for(uint i=0;i<stakeIndex;++i){
                Stake storage stake = _userStakeList[msg.sender][i];
                if(stake.claimedTime>0 && stake.projectIndex==projectIndex){                    
                    // 更新stake数据
                    stake.shares += shares; 
                    uint nowTime = block.timestamp;
                    uint duration = nowTime - stake.claimedTime;
                    stake.claimedTime = uint32(nowTime);
                    stake.reward += calcReward(duration, stake.usdtAmount, project.apr);       
                    stake.usdtAmount = getPaymentAmount(stake.shares,project.amount,project.shares); // 更新usdt数量 
                    emit StakeAdded(msg.sender, i, projectIndex, shares, paymentAmount);
                    return true;
                }
            }
        }
               
        _userStakeList[msg.sender].push(Stake(projectIndex, uint32(block.timestamp), projectIndex, shares, paymentAmount, 0, 0));
        emit StakeAdded(msg.sender, stakeIndex, projectIndex, shares, paymentAmount);        
        return true;
    }

    function unstakeNft(uint stakeIndex, uint32 shares) external returns(bool){ 
        Stake storage stake =  _userStakeList[msg.sender][stakeIndex];
        require(shares<=stake.shares, "Invalid shares");
        Project memory project = _projectList[stake.projectIndex];
        // 更新stake数据
        stake.shares -= shares; // 先更新股份数，避免重入攻击

        uint nowTime = block.timestamp;
        uint duration = nowTime - stake.claimedTime;
        stake.claimedTime = uint32(nowTime);
        stake.reward += calcReward(duration, stake.usdtAmount, project.apr);       
        stake.usdtAmount = getPaymentAmount(stake.shares,project.amount,project.shares); // 更新usdt数量         
        emit StakeRemoved(msg.sender, stakeIndex, stake.nftId, shares, getPaymentAmount(shares,project.amount,project.shares));
        IERC1155(_nftAddress).safeTransferFrom(address(this), msg.sender, stake.nftId, shares, bytes(""));    
        return true;
    }

    function calcReward(uint duration, uint usdtAmount, uint apr) internal pure returns(uint){
        return duration*usdtAmount*apr/10000/31556926; // 一年31556926秒
    }
    
    function claim(uint[] calldata stakeIndexs) external returns(uint totalClaimableAmount){ 
        Stake[] storage stakeList =  _userStakeList[msg.sender];
        for(uint i=0; i < stakeIndexs.length; ++i){
            require(stakeIndexs[i]<stakeList.length, "Invalid stakeIndex");
            Stake storage stake = stakeList[stakeIndexs[i]];
            Project memory project = _projectList[stake.projectIndex];
            
            // 更新stake数据
            uint nowTime = block.timestamp;
            uint duration = nowTime - stake.claimedTime;
            stake.claimedTime = uint32(nowTime);
            stake.reward += calcReward(duration, stake.usdtAmount, project.apr);        
            uint claimableAmount = stake.reward - stake.claimedReward;  
            stake.claimedReward += claimableAmount;
            totalClaimableAmount += claimableAmount;  
            if(claimableAmount>0){
                emit ClaimReward(msg.sender, stakeIndexs[i], claimableAmount);
            }
        }
        require(totalClaimableAmount>0, "Claimable amount is 0");
        IERC20(_paymentTokenAddress).transfer(msg.sender, totalClaimableAmount);  
    }

    function getClaimableAmount(address account, uint[] calldata stakeIndexs) external view returns(uint totalClaimableAmount){ 
        Stake[] memory stakeList =  _userStakeList[account];
        for(uint i=0; i < stakeIndexs.length; ++i){
            if(stakeIndexs[i]<stakeList.length){
                Stake memory stake = stakeList[stakeIndexs[i]];
                Project memory project = _projectList[stake.projectIndex];

                uint nowTime = block.timestamp;
                uint duration = nowTime - stake.claimedTime;      
                uint claimableAmount = calcReward(duration, stake.usdtAmount, project.apr) + stake.reward - stake.claimedReward;  
                totalClaimableAmount += claimableAmount;  
            }
        }
    }

    function releaseERC20Token(address token, uint256 amount) external {
        IERC20(token).transfer(owner(), amount);
    }

    function releaseERC1155Token(address token, uint256 id, uint256 amount) external {
        IERC1155(token).safeTransferFrom(address(this), owner(), id, amount, bytes(""));
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
}