# 1.如何运行
1.在本地启动ganache应用
2.在 ./contracts 中安装依赖，运行如下命令：
```
npm install
```
3.在ganache中复制自己的账户地址，在./contracts/contracts/BorrowYourCar.sol中的createCars函数中和，粘贴自己的账户地址
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699671242887-eda83e09-1923-422e-b659-7fefe3623698.png#averageHue=%23dfdbd8&clientId=ud69c2427-6143-4&from=paste&height=713&id=KldAz&originHeight=891&originWidth=1469&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=201511&status=done&style=none&taskId=uc8bc2df9-334c-402c-bda5-1c57aa976e8&title=&width=1175.2)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699671230693-1e0290ae-eb62-4235-83ff-5f70a1f8ec80.png#averageHue=%23302e2d&clientId=ud69c2427-6143-4&from=paste&height=324&id=i4dih&originHeight=405&originWidth=896&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=99266&status=done&style=none&taskId=uca68f473-b675-4183-897a-9391fd31cac&title=&width=716.8)
4.在ganache中复制账户密钥，粘贴到.\contracts\hardhat.config.ts中：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699671368738-7544c8be-a132-4351-99fe-e86f645ff6b4.png#averageHue=%232c2b2b&clientId=ud69c2427-6143-4&from=paste&height=326&id=u9e60da10&originHeight=407&originWidth=1059&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=70854&status=done&style=none&taskId=ufadb1ed3-122f-4bdc-947c-145b8ffee87&title=&width=847.2)
5.在 ./contracts 中编译合约，运行如下命令：
```
npx hardhat run ./scripts/deploy.ts --network ganache
```
6.复制打印出来的合约地址到 ./fronted/src/utils/contract-addresses.json 中
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699667593933-b197768e-3a55-4a31-b824-8929ecd74a61.png#averageHue=%23262322&clientId=ud69c2427-6143-4&from=paste&height=110&id=u0e220f63&originHeight=137&originWidth=724&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=13465&status=done&style=none&taskId=u07edcce3-0b47-4f96-b8c6-a29a373d9e0&title=&width=579.2)
7.在 ./fronted 中安装依赖，运行如下命令：
```
npm install
```
8.在 ./ fronted 中启动前端程序，运行如下命令：
```
npm run dev
```
# 2.功能实现分析
## 2.1查看自己拥有的汽车列表
在合约中实现了getOwnedCar函数：
```solidity
function getOwnedCars(address owner) external view returns (uint256[] memory) {
        // Get the list of car token IDs owned by a specific user
        uint256 counter = 0;
        for (uint256 i = 0; i < totalCars; i++) {
            if (ownerOf(i) == owner) {

                counter++;
            }
        }
        uint256[] memory ownedCars=new uint256[](counter) ;
        counter=0;
        for (uint256 i = 0; i < totalCars; i++) {
            if (ownerOf(i) == owner) {
                ownedCars[counter] = i;
                counter++;
            }
        }
        return ownedCars;
    }
```
在前端中通过按钮触发并且调用它，渲染数据到listOfResult中：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699668105093-9d55e4cf-62e1-48b9-99f3-5b61be819aee.png#averageHue=%23f9f9f9&clientId=ud69c2427-6143-4&from=paste&height=467&id=ufdd4da01&originHeight=584&originWidth=1752&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=90856&status=done&style=none&taskId=u4d2c5761-35c5-4024-87b3-17f3f0245ee&title=&width=1401.6)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699668030643-2502efa6-624f-4d7c-866f-5c4d6a3e06c6.png#averageHue=%231f1f1f&clientId=ud69c2427-6143-4&from=paste&height=349&id=ue256db2d&originHeight=436&originWidth=1176&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=55163&status=done&style=none&taskId=u73bf774a-fc95-4741-802d-f8645ca64d0&title=&width=940.8)
## 2.2查看自己已经借用的车辆
在合约中实现了getMyBorrowedCars函数：
```solidity
function getMyBorrowedCars(address borrower1) external view returns (uint256[] memory) {

            uint256 count = 0;

            for (uint256 i = 0; i < totalCars; i++) {
                 if (cars[i].borrower == borrower1&&cars[i].isBorrowed) {
                 count++;
            }}
             uint256[] memory MyBorrowedCars = new uint256[](count);
             count =0;
             for (uint256 i = 0; i < totalCars; i++) {
                  if (cars[i].borrower == borrower1 && cars[i].isBorrowed) {
                  MyBorrowedCars[count] = i;
                   count++;
             }

        }
        return MyBorrowedCars;
```
在前端中通过按钮触发并且调用它，渲染数据到listOfResult中：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699668738664-1f64aa01-9648-4fc7-81b1-6faad3ba3803.png#averageHue=%23f7f6f6&clientId=ud69c2427-6143-4&from=paste&height=527&id=u1cb8cb6d&originHeight=659&originWidth=1775&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=93076&status=done&style=none&taskId=uc1713885-ff3a-413d-aaf8-94cca981be2&title=&width=1420)![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699668798625-0204ba0c-6c92-462d-9e15-164f7a3bc7a3.png#averageHue=%231f1f1f&clientId=ud69c2427-6143-4&from=paste&height=345&id=u745ba072&originHeight=431&originWidth=1226&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=53957&status=done&style=none&taskId=u641bcca1-cc08-40cc-9509-73c791d81cd&title=&width=980.8)
## 2.3查看当前还没有被借用的汽车列表
在合约中实现了getAvailableCars函数：
```solidity
  function getAvailableCars() external view returns (uint256[] memory) {
        // Get the list of available car token IDs (not currently borrowed)
        uint256[] memory availableCars = new uint256[](totalCars - totalRentedCars);
        uint256 counter = 0;
        for (uint256 i = 0; i < totalCars; i++) {
            if (ownerOf(i) != address(0) && !cars[i].isBorrowed) {
                availableCars[counter] = i;
                counter++;
            }
        }
        return availableCars;
    }
```
在前端中通过按钮触发并且调用它，渲染数据到listOfResult中：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699668970581-f8cba2e8-d772-4427-ac1c-00d1da1e09b2.png#averageHue=%23fafafa&clientId=ud69c2427-6143-4&from=paste&height=709&id=u60893094&originHeight=886&originWidth=1761&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=131524&status=done&style=none&taskId=ue4ade648-7c22-4b4b-be86-be12e24a0d1&title=&width=1408.8)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699668945671-6f230d7a-5642-4d72-bb06-2c2c9b7a0f42.png#averageHue=%231f1f1f&clientId=ud69c2427-6143-4&from=paste&height=349&id=u5758abc7&originHeight=436&originWidth=1152&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=53822&status=done&style=none&taskId=uf91de85a-1da2-4b58-81ed-a23e040d06e&title=&width=921.6)
## 2.4显示所有的汽车列表
在合约中getAllCars函数：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669352293-a54302b5-b62e-498c-b2a2-f70fffa66656.png#averageHue=%23faf9f8&clientId=ud69c2427-6143-4&from=paste&height=665&id=u8fa4dce5&originHeight=831&originWidth=1776&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=142342&status=done&style=none&taskId=u7ae3e554-abf7-4644-aec3-e3c5d5256d4&title=&width=1420.8)
```solidity
function getAllCars() external view returns (uint256[] memory) {
        uint256[] memory allCars = new uint256[](totalCars);
        for (uint256 i = 0; i < totalCars; i++) {
            allCars[i] = i;
        }
        return allCars;
    }
```
在前端中通过按钮触发并且调用它，渲染数据到listOfResult中：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669113027-2228b486-645a-4c5f-9ce1-cdf4123c2cd9.png#averageHue=%231f1f1f&clientId=ud69c2427-6143-4&from=paste&height=332&id=u980748ec&originHeight=415&originWidth=1084&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=48056&status=done&style=none&taskId=ud1f874f5-0267-4629-9e7d-e2749ab8f16&title=&width=867.2)
## 2.5查询一辆汽车的主人，以及该汽车当前的借用者
通过输入需要查询的汽车的ID号，在汽车列表中查找并且返回它，最后渲染到listOfResult中：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669331840-8ce72f07-9e01-4282-b6b8-34220d91811c.png#averageHue=%231f1f1f&clientId=ud69c2427-6143-4&from=paste&height=414&id=uedb74bf9&originHeight=517&originWidth=860&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=48446&status=done&style=none&taskId=uadb6a891-fb0a-4cad-8f5b-62c20f9689f&title=&width=688)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669380517-7c44ae50-b8ef-4a0c-a794-3979d4efee23.png#averageHue=%238c8c8c&clientId=ud69c2427-6143-4&from=paste&height=602&id=u133769ed&originHeight=752&originWidth=1714&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=129846&status=done&style=none&taskId=u428b9856-0c19-45b4-a91d-f08c5c51132&title=&width=1371.2)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669396479-1c087fba-e655-4f96-9ff9-d37f7904e23d.png#averageHue=%23dbceac&clientId=ud69c2427-6143-4&from=paste&height=375&id=u6304e3bc&originHeight=469&originWidth=1752&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=62114&status=done&style=none&taskId=ucbed61de-c77d-4c85-ae42-777c0c1611e&title=&width=1401.6)![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669424291-25f16a20-c150-4069-81c9-d62726f46c40.png#averageHue=%23858584&clientId=ud69c2427-6143-4&from=paste&height=717&id=u6183168a&originHeight=896&originWidth=1870&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=172238&status=done&style=none&taskId=u0e3fcd9b-5c34-4a0b-ac10-132a603a015&title=&width=1496)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669436369-d62b0cc7-ca4f-491e-bb92-a1877c1cb591.png#averageHue=%23e9d6b4&clientId=ud69c2427-6143-4&from=paste&height=299&id=u936fd67b&originHeight=374&originWidth=1647&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=49867&status=done&style=none&taskId=ub72ffc98-8358-4de2-9820-eb29e1d2c45&title=&width=1317.6)
## 2.6选择并借用某辆还没有被租借的汽车一段时间，使用自己发行的ERC20积分支付
在合约中实现了borrowCar函数：
```solidity
function borrowCar(uint256 carTokenId, uint256 duration) external {
        require(ownerOf(carTokenId) != address(0), "Car does not exist");
        require(cars[carTokenId].borrower == address(0), "Car is already borrowed");

        address borrower = msg.sender;
        uint256 startTime = block.timestamp;
        uint256 borrowUntil = startTime + duration;
        calculateBorrowCost(duration);
        // Update the car's information
        cars[carTokenId].borrower = borrower;
        cars[carTokenId].borrowUntil = borrowUntil;
        cars[carTokenId].isBorrowed = true;
        totalRentedCars++;
        myERC20.transferFrom(msg.sender,address(this) , tokenAmount);
        myERC20.transfer(cars[carTokenId].owner, myERC20.balanceOf(address(this)));
        // emit CarBorrowed(carTokenId, borrower, startTime, duration);
    }
```
在前端中通过按钮触发并调用它：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669593231-e6346a1c-d324-4967-9a65-74b1d84e10da.png#averageHue=%23f0f3f8&clientId=ud69c2427-6143-4&from=paste&height=76&id=uba96dd3d&originHeight=95&originWidth=1626&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=13389&status=done&style=none&taskId=u1793ee13-c198-4788-98eb-85a2c8b70f9&title=&width=1300.8)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669651519-300d75c2-e1ed-4826-b13e-9d29865058a1.png#averageHue=%23e2deda&clientId=ud69c2427-6143-4&from=paste&height=34&id=ue630ab0f&originHeight=42&originWidth=191&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=2455&status=done&style=none&taskId=u6b8dbc6c-10af-4837-ae50-cb717f93f1b&title=&width=152.8)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669619712-9b5f3fb8-8e0b-4298-a49d-66390bc11303.png#averageHue=%23a8a7a7&clientId=ud69c2427-6143-4&from=paste&height=281&id=u1a6509ed&originHeight=351&originWidth=1611&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=66814&status=done&style=none&taskId=uada2c8ae-0a9c-4d00-a258-c0b488571a1&title=&width=1288.8)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669721360-ea184439-a743-4525-92c3-f2fb55c43bd1.png#averageHue=%23fdf9f8&clientId=ud69c2427-6143-4&from=paste&height=56&id=u748e98f1&originHeight=70&originWidth=1566&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=17071&status=done&style=none&taskId=ud37a93b0-369b-401f-8e69-2bbb0d1f6dd&title=&width=1252.8)![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669766565-bae598ce-71da-4228-8fb0-efee3fa95115.png#averageHue=%23e5e2e1&clientId=ud69c2427-6143-4&from=paste&height=41&id=uf810b000&originHeight=51&originWidth=209&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=2677&status=done&style=none&taskId=uaa98dd1b-bef7-4490-b7a2-3b33a0ce744&title=&width=167.2)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669802112-3dc31a13-5c1f-480b-87d8-5c9483ab23b4.png#averageHue=%23201f1f&clientId=ud69c2427-6143-4&from=paste&height=245&id=uc0b32950&originHeight=306&originWidth=1110&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=45347&status=done&style=none&taskId=ua32461eb-24a4-4e2f-b2e6-95848b6c429&title=&width=888)
## 2.7归还汽车
在合约中实现了returunCar函数：
```solidity
 function returnCar(uint256 carTokenId) external {

            // Update the car's information
            cars[carTokenId].borrower = address(0);
            cars[carTokenId].borrowUntil = 0;
            cars[carTokenId].isBorrowed = false;
            totalRentedCars--;
        }
```
在前端中通过按钮触发并调用它：
![](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670790688-4a28896b-12d1-4112-9cdd-9decf86f8399.png?x-oss-process=image%2Fresize%2Cw_937%2Climit_0#averageHue=%23d9af7a&from=url&id=kHVoa&originHeight=401&originWidth=937&originalType=binary&ratio=1.25&rotation=0&showTitle=false&status=done&style=none&title=)
![](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699671110097-e433607a-4f24-4ef7-9c81-38e37ff29165.png#averageHue=%23f8f7f7&from=url&id=Okw3o&originHeight=282&originWidth=1694&originalType=binary&ratio=1.25&rotation=0&showTitle=false&status=done&style=none&title=)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699671762127-6ac3f946-1098-41b8-b1a9-78f70e69fc79.png#averageHue=%23201f1f&clientId=ud69c2427-6143-4&from=paste&height=64&id=u9685a90d&originHeight=80&originWidth=859&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=8906&status=done&style=none&taskId=u7ec6e30d-fa5c-4b29-a2bf-2c08d335fe7&title=&width=687.2)
## 2.8发行汽车
在合约中实现createCars函数：
```solidity
function createCars() external {
        // Create and distribute NFTs representing cars to test users
        // For example, give NFTs to certain addresses for testing purposes
        address[] memory users = new address[](10);
        users[0] = address(uint160(0x71842261af79D9640cC9f72f1e76eff49d653624));
        users[1] = address(uint160(0x2e4892Ec35A41695Cf95bf20F2b500a048D605b0));
        users[2] = address(uint160(0xF957C6bbB01b0611e800335F8b8f80ABeCfe6C13));
        users[3] = address(uint160(0xB306854d7e77516413DB350E73890a4C2507A170));
        users[4] = address(uint160(0xbd4850fF5692dF75c8f78B47732AD0EaABEc2fee));
        users[5] = address(uint160(0x8A6A3e2F007157A1665dFdCD916A4B5fe054C87B));
        users[6] = address(uint160(0xF891eAe8C49AaC400364d9F2e906de240E51E311));
        users[7] = address(uint160(0x8798bB05cC335615b8bF56bae3DE3FC907d7fF97));
        users[8] = address(uint160(0xc64BAc49A643140B11A9C69EeB5E3F14FFDFA303));
        users[9] = address(uint160(0x70f66b58BdfB582a22cfc301a14c13c65a40DC66));
        //[address(0x30f270d7dc5a03391b3d9098116d78c419dc185bf7e4b58b4fc14fa0b583d57b), address(0xf13d4b0ab910c8d78bb22629c858ea73ee22d9b0a5e8bd462d48190c49bd14b3)];
        for (uint256 i = 0; i < 2; i++) {
            // Mint a car NFT and assign it to the user
            uint256 tokenId = mintCar(users[i]);
            // Update the car's owner in the cars mapping
            cars[tokenId].owner = users[i];
        }
        for (uint256 i = 0; i < 5; i++) {
                    // Mint a car NFT and assign it to the user
                    uint256 tokenId = mintCar(users[i]);
                    // Update the car's owner in the cars mapping
                    cars[tokenId].owner = users[i];
                }
        for (uint256 i = 0; i < 7; i++) {
                    // Mint a car NFT and assign it to the user
                    uint256 tokenId = mintCar(users[i]);
                    // Update the car's owner in the cars mapping
                    cars[tokenId].owner = users[i];
                }
         for (uint256 i = 0; i < 10; i++) {
                             // Mint a car NFT and assign it to the user
                             uint256 tokenId = mintCar(users[i]);
                             // Update the car's owner in the cars mapping
                             cars[tokenId].owner = users[i];
                         }
    }
```
在前端中通过按钮触发并调用它：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669890709-08b56231-29fa-4f0d-a4e5-e63f20511318.png#averageHue=%238ec3f9&clientId=ud69c2427-6143-4&from=paste&height=60&id=uec660da0&originHeight=75&originWidth=329&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=2915&status=done&style=none&taskId=u0b1369ca-1675-4af0-b108-09712e9c9f7&title=&width=263.2)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699669941803-0ca3c5b7-1ae6-4a8d-a221-e23d8adadc80.png#averageHue=%23201f1f&clientId=ud69c2427-6143-4&from=paste&height=58&id=u45120633&originHeight=72&originWidth=864&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=8456&status=done&style=none&taskId=ua31ac0a6-4a1d-4724-b4ae-d5d072fbcc5&title=&width=691.2)
# 3.项目运行截图
按照以下流程操作：编译部署合约，启动前端，连接钱包，发行汽车，显示所有汽车，显示自己拥有的汽车，获得空投积分，借用一些汽车，显示已借用的汽车，显示未借用的汽车，归还汽车，显示已经借用的汽车，查询一辆汽车
下面是按照此流程运行的截图：
编译部署合约：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670302110-a4957cf3-d172-45d8-bbb9-464311ab2086.png#averageHue=%2332302e&clientId=ud69c2427-6143-4&from=paste&height=67&id=u441c102e&originHeight=84&originWidth=1387&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=28277&status=done&style=none&taskId=u67ce9604-b03a-46b3-8011-75f48c6b514&title=&width=1109.6)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670356085-94a0fb7d-be69-443b-ac35-6e9542acfcac.png#averageHue=%23232120&clientId=ud69c2427-6143-4&from=paste&height=144&id=uca326a4d&originHeight=180&originWidth=766&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=12174&status=done&style=none&taskId=u40dcd988-462d-41a4-bbf3-28d3cb4fb4b&title=&width=612.8)
启动前端：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670366449-2e934d07-5848-4daa-ad51-6ab077c6d8b1.png#averageHue=%23181818&clientId=ud69c2427-6143-4&from=paste&height=175&id=u928ae4b2&originHeight=219&originWidth=972&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=13506&status=done&style=none&taskId=u815a8892-1acc-45f6-a651-962a9f50b80&title=&width=777.6)
连接钱包：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670383825-a0310acc-7a74-4f2e-b307-d8353af96540.png#averageHue=%23fafafa&clientId=ud69c2427-6143-4&from=paste&height=630&id=u35f4f4f4&originHeight=787&originWidth=1800&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=61634&status=done&style=none&taskId=uac3b1aaa-379e-4165-bd7f-9af71f196c3&title=&width=1440)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670397412-b5c406da-c028-49b6-ac0d-4ae434154e0e.png#averageHue=%23f5f5f5&clientId=ud69c2427-6143-4&from=paste&height=292&id=ua7feb09a&originHeight=365&originWidth=1800&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=53402&status=done&style=none&taskId=ua8109a9f-ed1f-4757-8990-2bbc5c99932&title=&width=1440)
发行汽车：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670415172-590e595c-dee9-49e0-a176-b67d7fbb734e.png#averageHue=%23d7a769&clientId=ud69c2427-6143-4&from=paste&height=623&id=u076196b2&originHeight=779&originWidth=1862&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=125953&status=done&style=none&taskId=u23775f51-dcd8-49b0-9ff2-c48c5392a70&title=&width=1489.6)
显示所有汽车：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670463627-9c516882-9cfa-43f8-9c34-fdf94fc7d4f2.png#averageHue=%23fafaf9&clientId=ud69c2427-6143-4&from=paste&height=706&id=uf516bf96&originHeight=882&originWidth=1776&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=135097&status=done&style=none&taskId=u415b7e46-27fd-48ca-bfb0-2bee5ebcae4&title=&width=1420.8)
显示自己拥有的汽车：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670486502-fd48bc72-54b8-4133-94a0-436eb961bb9c.png#averageHue=%23f9f8f8&clientId=ud69c2427-6143-4&from=paste&height=490&id=u2eaa774e&originHeight=612&originWidth=1756&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=92467&status=done&style=none&taskId=u8473b649-83e9-436e-8f24-f838f6db109&title=&width=1404.8)
获得空投积分：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670553838-205db401-01e8-4d0d-a9f3-5f21ca4312bd.png#averageHue=%23e0d9b6&clientId=ud69c2427-6143-4&from=paste&height=553&id=u85bac98b&originHeight=691&originWidth=1834&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=141327&status=done&style=none&taskId=u94ea98dc-e686-4349-b5ac-ee555e6801f&title=&width=1467.2)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670564151-d4b6a1e3-003e-4ac2-9ecd-58a5d3dd4afc.png#averageHue=%23bbbbba&clientId=ud69c2427-6143-4&from=paste&height=157&id=u962120f4&originHeight=196&originWidth=1816&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=32824&status=done&style=none&taskId=u9b74e78b-bb64-44de-8d1e-15ea36969a2&title=&width=1452.8)
借用一些汽车（一共借了两辆，因为操作一样，只放了借用其中一辆时的截图）：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670596651-6afa1065-6c20-4c2f-b4d9-0e54baa2d831.png#averageHue=%23929191&clientId=ud69c2427-6143-4&from=paste&height=511&id=ua505ec80&originHeight=639&originWidth=1812&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=112272&status=done&style=none&taskId=u9649c9f1-8319-4249-bdff-3d945d779bc&title=&width=1449.6)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670639298-f69e1088-5836-4338-af1f-ca9e903e62db.png#averageHue=%23dfd8b8&clientId=ud69c2427-6143-4&from=paste&height=634&id=u64a7f5c1&originHeight=792&originWidth=1856&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=165569&status=done&style=none&taskId=uddb9a6e1-707c-43d6-a6a4-c9ea04a3fb1&title=&width=1484.8)
显示我已借用汽车列表：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670725608-6eea6e06-aa7d-4fcd-bdfd-7d8e636ec812.png#averageHue=%23f6f4f4&clientId=ud69c2427-6143-4&from=paste&height=366&id=u2078d612&originHeight=457&originWidth=1774&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=82937&status=done&style=none&taskId=ub7a9c6c6-16b9-4286-b58c-1bdb06c9275&title=&width=1419.2)
显示所有未借用汽车
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670772020-d49b7b5f-9c07-4793-bbcc-6e2fdaa34e70.png#averageHue=%23fafafa&clientId=ud69c2427-6143-4&from=paste&height=652&id=u4a68829a&originHeight=815&originWidth=1729&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=124954&status=done&style=none&taskId=ued9548fe-a39c-4f87-ad0f-a1242b3ee01&title=&width=1383.2)
归还汽车：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670790688-4a28896b-12d1-4112-9cdd-9decf86f8399.png#averageHue=%23d9af7a&clientId=ud69c2427-6143-4&from=paste&height=648&id=u582bdc13&originHeight=810&originWidth=1895&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=169219&status=done&style=none&taskId=u8d683f53-fd16-414d-a0ef-a2c28dad431&title=&width=1516)
显示我已借用汽车列表：
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699671110097-e433607a-4f24-4ef7-9c81-38e37ff29165.png#averageHue=%23f8f7f7&clientId=ud69c2427-6143-4&from=paste&height=226&id=ue545ef62&originHeight=282&originWidth=1694&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=47371&status=done&style=none&taskId=u7c9ca70e-8155-4fec-b3ea-ad0c4ca0a03&title=&width=1355.2)
查询一辆汽车：![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670870045-8c586aa6-f166-4282-aee9-afce29236a37.png#averageHue=%238f8f8e&clientId=ud69c2427-6143-4&from=paste&height=480&id=u4d482307&originHeight=600&originWidth=1790&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=77528&status=done&style=none&taskId=u164b4238-dd7a-49c0-a875-3d9431bcf25&title=&width=1432)
![image.png](https://cdn.nlark.com/yuque/0/2023/png/35447189/1699670879596-24d67514-2ec7-4433-9757-803ef5e3037f.png#averageHue=%23f7f6f6&clientId=ud69c2427-6143-4&from=paste&height=417&id=ud875270d&originHeight=521&originWidth=1796&originalType=binary&ratio=1.25&rotation=0&showTitle=false&size=67833&status=done&style=none&taskId=u5b3197ac-5cbd-4078-897e-ab5f2eefe30&title=&width=1436.8)


