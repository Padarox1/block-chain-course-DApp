<template>
  <div class="dashboard-container">
    <div class="header">
      <el-button type="primary" @click="connectWallet">连接钱包 💰</el-button>
      <p class="current-user">当前用户: {{ currentUser }}</p>
      <p class="user-score">当前用户积分: {{ userScore }}</p>
    </div>
    <div class="app-container">
      <div class="button-container">
        <el-button type="primary" @click="showUnborrowedVehicles">刷新并显示未借用车辆</el-button>
        <el-button type="primary" @click="showOwnedVehicles">刷新并显示我已拥有的车辆</el-button>
        <el-button type="primary" @click="showBorrowedCars">刷新并显示我已租借的车辆</el-button>
        <el-button type="primary" @click="showAllCars">刷新并显示所有车辆</el-button>
        <el-button type="primary" @click="showSearchDialog">查询</el-button>
        <el-button type="primary" @click="createCars">发行汽车</el-button>
        <el-button type="primary" @click="refresh">刷新</el-button>
        <el-button type="primary" @click="onClaimTokenAirdrop">获得空投积分</el-button>
      </div>
      <el-table

        :data="listOfResult"
      >
        <el-table-column align="center" label="汽车ID" width="120">
          <template slot-scope="scope">
            {{ scope.row.tokenId }}
          </template>
        </el-table-column>
        <el-table-column label="汽车拥有者" width="250" align="center">
          <template slot-scope="scope">
            {{ scope.row.owner }}
          </template>
        </el-table-column>
        <el-table-column label="汽车借用者" width="250" align="center">
          <template slot-scope="scope">
            <span v-if="scope.row.borrower==0">无</span>
            <span v-else>{{ scope.row.borrower }}</span>
          </template>
        </el-table-column>
        <el-table-column class-name="是否被借用" label="是否被借用" width="220" align="center">
          <template slot-scope="scope">
            <el-tag :type="scope.row.isBorrowed ? 'danger' : 'success'">
              {{ scope.row.isBorrowed ? '已被借用' : '未被借用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column align="center" label="归还时间" width="250">
          <template slot-scope="scope">
            <i class="el-icon-time" />
            <span v-if="scope.row.borrowUntil == 0">无</span>
            <span v-else>{{ formatDate(scope.row.borrowUntil) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" align="center">
          <template slot-scope="scope">
            <el-button
              v-if="scope.row.isBorrowed"
              type="danger"
              size="mini"
              @click="returnCar(scope.row.tokenId)"
            >
              归还
            </el-button>
            <el-button
              v-else
              type="primary"
              size="mini"
              @click="openDialog(scope.row)"
            >
              借用
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-dialog title="输入借用时长" :visible.sync="dialogVisible" width="30%">
        <div class="dialog-input-container">
          <el-input-number v-model="borrowDays" :controls="false" :min="0" placeholder="天数" />
          <span>天</span>
          <el-input-number v-model="borrowHours" :controls="false" :min="0" :max="23" placeholder="小时数" />
          <span>小时</span>
          <el-input-number v-model="borrowMinutes" :controls="false" :min="0" :max="59" placeholder="分钟数" />
          <span>分</span>
          <el-input-number v-model="borrowSeconds" :controls="false" :min="0" :max="59" placeholder="秒数" />
          <span>秒</span>
        </div>
        <span slot="footer" class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="calculateBorrowDuration(selectedRow.tokenId)">确认</el-button>
        </span>
      </el-dialog>
      <el-dialog title="输入需要查询的汽车ID" :visible.sync="searchDialogVisible" width="30%">
        <el-input v-model="searchValue" placeholder="请输入汽车ID" />
        <span slot="footer" class="dialog-footer">
          <el-button @click="closeSearchDialog">取消</el-button>
          <el-button type="primary" @click="performSearch">查询</el-button>
        </span>
      </el-dialog>
    </div>
    <!-- Add your content here -->
  </div>
</template>

<script>
import { BorrowYourCarContract, myERC20Contract, web3 } from '../../utils/contracts'
export default {
  filters: {
    statusFilter(status) {
      const statusMap = {
        published: 'success',
        draft: 'gray',
        deleted: 'danger'
      }
      return statusMap[status]
    }
  },
  data() {
    return {
      listData: [], // 要渲染的数据列表
      listLoading: false, // 控制表格加载状态的变量
      currentUser: null,
      userScore: 0,
      GanacheTestChainId: '0x539', // Ganache默认的ChainId = 0x539 = Hex(1337)
      GanacheTestChainName: 'Ganache Test Chain',
      GanacheTestChainRpcUrl: 'HTTP://127.0.0.1:7545',
      searchDialogVisible: false,
      searchValue: '',
      borrowDuration: '',
      borrowDays: 0,
      borrowHours: 0,
      borrowMinutes: 0,
      borrowSeconds: 0,
      listOfAllCars: [],
      listOfUnborrowedCars: [],
      listOfMyOwnedCars: [],
      listOfMyBorrowedCars: [],
      listOfResult: [],
      dialogVisible: false, // 对话框的显示状态
      selectedRow: null // 选中行的数据
      // Add more data properties if needed
    }
  },
  methods: {
    async connectWallet() {
      const { ethereum } = window
      if (!(ethereum && ethereum.isMetaMask)) {
        alert('MetaMask is not installed!')
        return
      }

      try {
        // 如果当前小狐狸不在本地链上，切换Metamask到本地测试链
        if (ethereum.chainId !== this.GanacheTestChainId) {
          const chain = {
            chainId: this.GanacheTestChainId, // Chain-ID
            chainName: this.GanacheTestChainName, // Chain-Name
            rpcUrls: [this.GanacheTestChainRpcUrl] // RPC-URL
          }

          try {
            // 尝试切换到本地网络
            await ethereum.request({ method: 'wallet_switchEthereumChain', params: [{ chainId: chain.chainId }] })
          } catch (error) {
            // 如果本地网络没有添加到Metamask中，添加该网络
            if (error.code === 4902) {
              await ethereum.request({ method: 'wallet_addEthereumChain', params: [chain]
              })
            }
          }
        }

        // 小狐狸成功切换网络了，接下来让小狐狸请求用户的授权
        await ethereum.request({ method: 'eth_requestAccounts' })
        // 获取小狐狸拿到的授权用户列表
        const accounts = await ethereum.request({ method: 'eth_accounts' })
        // 如果用户存在，展示其account，否则显示错误信息
        this.currentUser = accounts[0]
        this.userScore = await myERC20Contract.methods.balanceOf(this.currentUser).call()
        // setAccount(accounts[0] || 'Not able to get accounts')
      } catch (error) {
        alert(error.message)
      }
    },
    // Add more methods if needed
    async showUnborrowedVehicles() {
      // 处理显示未借用车辆的逻辑
      const tempList = Object.assign([], await BorrowYourCarContract.methods.getAvailableCars().call())
      // console.log(tempList3)
      this.listOfUnborrowedCars = this.getCarDetailsArray(tempList)
      // console.log(this.listOfMyOwnedCars)
      this.listData = Object.assign([], this.listOfUnborrowedCars)
      // console.log(this.listData)
      Promise.all(this.listData)
        .then((result) => {
          // 将结果存储在一个同步数组中
          this.listOfResult = result
          console.log(this.listOfResult) // 输出同步数组
        })
        .catch((error) => {
          console.error(error) // 处理错误情况
        })
    },
    async createCars() {
      await BorrowYourCarContract.methods.createCars().send({ from: this.currentUser })
    },
    async showBorrowedVehicles() {
      const tempList3 = Object.assign([], await BorrowYourCarContract.methods.getMyBorrowedCars(this.currentUser).call())
      // console.log(tempList3)
      this.listOfMyBorrowedCars = this.getCarDetailsArray(tempList3)
      // console.log(this.listOfMyOwnedCars)
      this.listData = Object.assign([], this.listOfMyBorrowedCars)
      // console.log(this.listData)
      Promise.all(this.listData)
        .then((result) => {
          // 将结果存储在一个同步数组中
          this.listOfResult = result
          console.log(this.listOfResult) // 输出同步数组
        })
        .catch((error) => {
          console.error(error) // 处理错误情况
        })
    },
    async showOwnedVehicles() {
      // 处理显示自己已拥有车辆的逻辑
      const tempList = Object.assign([], await BorrowYourCarContract.methods.getOwnedCars(this.currentUser).call())
      // console.log(tempList3)
      this.listOfMyOwnedCars = this.getCarDetailsArray(tempList)
      // console.log(this.listOfMyOwnedCars)
      this.listData = Object.assign([], this.listOfMyOwnedCars)
      // console.log(this.listData)
      Promise.all(this.listData)
        .then((result) => {
          // 将结果存储在一个同步数组中
          this.listOfResult = result
          console.log(this.listOfResult) // 输出同步数组
        })
        .catch((error) => {
          console.error(error) // 处理错误情况
        })
    },
    async showBorrowedCars() {
      // console.log('1')
      const tempList3 = Object.assign([], await BorrowYourCarContract.methods.getMyBorrowedCars(this.currentUser).call())
      // console.log(tempList3)
      this.listOfMyBorrowedCars = this.getCarDetailsArray(tempList3)
      // console.log(this.listOfMyOwnedCars)
      this.listData = Object.assign([], this.listOfMyBorrowedCars)
      // console.log(this.listData)
      Promise.all(this.listData)
        .then((result) => {
          // 将结果存储在一个同步数组中
          this.listOfResult = result
          console.log(this.listOfResult) // 输出同步数组
        })
        .catch((error) => {
          console.error(error) // 处理错误情况
        })
    },

    async onClaimTokenAirdrop() {
      if (this.currentUser === '') {
        alert('You have not connected wallet yet.')
        return
      }

      if (myERC20Contract) {
        try {
          console.log(myERC20Contract)
          console.log(this.currentUser)
          console.log('1')
          await myERC20Contract.methods.airdrop().send({
            from: this.currentUser
          })
          alert('You have claimed ZJU Token.')
        } catch (error) {
          alert(error.message)
        }
      } else {
        alert('Contract not exists.')
      }
      this.userScore = await myERC20Contract.methods.balanceOf(this.currentUser).call()
      console.log(this.userScore)
    },

    showSearchDialog() {
      this.searchDialogVisible = true
    },

    closeSearchDialog() {
      this.searchDialogVisible = false
    },

    formatDate(timestamp) {
      const date = new Date(timestamp * 1000) // 将秒数转换为毫秒数
      const year = date.getFullYear()
      const month = (date.getMonth() + 1).toString().padStart(2, '0')
      const day = date.getDate().toString().padStart(2, '0')
      const hours = date.getHours().toString().padStart(2, '0')
      const minutes = date.getMinutes().toString().padStart(2, '0')
      const seconds = date.getSeconds().toString().padStart(2, '0')
      return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`
    },

    openDialog(row) {
    // 打开对话框，并传递选中行的相关信息
      this.dialogVisible = true
      this.selectedRow = row
    },
    async returnCar(id) {
      BorrowYourCarContract.methods.returnCar(id).send({ from: this.currentUser })
    },
    async confirmBorrow(id, duration) {
    // 在这里处理借用时间的逻辑，例如发送请求或更新数据等
      // console.log(this.selectedRow.borrowUntil)
      // 关闭对话框
      const costAmount = parseInt(+duration / 3600 + 1)
      await myERC20Contract.methods.approve(BorrowYourCarContract.options.address, costAmount).send({
        from: this.currentUser
      })
      console.log('3')
      await BorrowYourCarContract.methods.borrowCar(id, duration).send({ from: this.currentUser })
      this.userScore = await myERC20Contract.methods.balanceOf(this.currentUser).call()
      this.dialogVisible = false
    },
    async calculateBorrowDuration(id) {
      this.borrowDuration = (this.borrowDays * 24 * 60 * 60) + (this.borrowHours * 60 * 60) + (this.borrowMinutes * 60) + this.borrowSeconds
      this.confirmBorrow(id, this.borrowDuration)
      this.userScore = await myERC20Contract.methods.balanceOf(this.currentUser).call()
      this.dialogVisible = false
    },
    async performSearch() {
      // 处理查询逻辑
      // 使用 this.searchValue 获取查询内容
      // console.log('Perform search:', this.searchValue)
      const tokenId = +this.searchValue
      // console.log(tempList3)
      const tempList = [tokenId]

      this.listOfMyBorrowedCars = this.getCarDetailsArray(tempList)
      // console.log(this.listOfMyOwnedCars)
      this.listData = Object.assign([], this.listOfMyBorrowedCars)
      // console.log(this.listData)
      Promise.all(this.listData)
        .then((result) => {
          // 将结果存储在一个同步数组中
          this.listOfResult = result
          console.log(this.listOfResult) // 输出同步数组
        })
        .catch((error) => {
          console.error(error) // 处理错误情况
        })
      this.searchDialogVisible = false
    },

    async showAllCars() {
      const tempList = Object.assign([], await BorrowYourCarContract.methods.getAllCars().call())
      // console.log(tempList3)
      this.listOfAllCars = this.getCarDetailsArray(tempList)
      // console.log(this.listOfMyOwnedCars)
      this.listData = Object.assign([], this.listOfAllCars)
      // console.log(this.listData)
      Promise.all(this.listData)
        .then((result) => {
          // 将结果存储在一个同步数组中
          this.listOfResult = result
          console.log(this.listOfResult) // 输出同步数组
        })
        .catch((error) => {
          console.error(error) // 处理错误情况
        })
    },
    async getCarDetails(tokenId) {
      const carInfo = await BorrowYourCarContract.methods.cars(tokenId).call() // 调用智能合约的 cars 方法获取车辆信息
      return {
        tokenId: tokenId,
        owner: carInfo.owner,
        borrower: carInfo.borrower,
        isBorrowed: carInfo.isBorrowed,
        borrowUntil: carInfo.borrowUntil
      }
    },
    getCarDetailsArray(tempList) {
      const carDetailsArray = []

      for (let i = 0; i < tempList.length; i++) {
        const tokenId = tempList[i]
        const carDetails = this.getCarDetails(tokenId)
        carDetailsArray.push(carDetails)
      }

      return carDetailsArray
    },
    async refresh() {
      const { ethereum } = window
      if (!(ethereum && ethereum.isMetaMask)) {
        alert('MetaMask is not installed!')
        return
      }

      try {
        // 如果当前小狐狸不在本地链上，切换Metamask到本地测试链
        if (ethereum.chainId !== this.GanacheTestChainId) {
          const chain = {
            chainId: this.GanacheTestChainId, // Chain-ID
            chainName: this.GanacheTestChainName, // Chain-Name
            rpcUrls: [this.GanacheTestChainRpcUrl] // RPC-URL
          }

          try {
            // 尝试切换到本地网络
            await ethereum.request({ method: 'wallet_switchEthereumChain', params: [{ chainId: chain.chainId }] })
          } catch (error) {
            // 如果本地网络没有添加到Metamask中，添加该网络
            if (error.code === 4902) {
              await ethereum.request({ method: 'wallet_addEthereumChain', params: [chain]
              })
            }
          }
        }

        // 小狐狸成功切换网络了，接下来让小狐狸请求用户的授权
        await ethereum.request({ method: 'eth_requestAccounts' })
        // 获取小狐狸拿到的授权用户列表
        const accounts = await ethereum.request({ method: 'eth_accounts' })
        // 如果用户存在，展示其account，否则显示错误信息
        this.currentUser = accounts[0]
        // setAccount(accounts[0] || 'Not able to get accounts')
      } catch (error) {
        alert(error.message)
      }

      // await BorrowYourCarContract.methods.createCars().send({ from: this.currentUser })

      await BorrowYourCarContract.methods.refreshAllCarStatus().send({ from: this.currentUser })
      const tempList1 = Object.assign([], await BorrowYourCarContract.methods.getAllCars().call())
      // console.log(tempList1)
      this.listOfAllCars = this.getCarDetailsArray(tempList1)
      // console.log(this.listOfAllCars)
      // this.listOfAllCars = await BorrowYourCarContract.methods.getAllCars().call()
      // this.listOfUnborrowedCars = await BorrowYourCarContract.methods.getAvailableCars().call()
      // console.log(this.listOfAllCars)
      const tempList2 = Object.assign([], await BorrowYourCarContract.methods.getOwnedCars(this.currentUser).call())
      // console.log(tempList2)
      this.listOfMyOwnedCars = this.getCarDetailsArray(tempList2)
      // console.log(this.listOfMyOwnedCars)
      const tempList3 = Object.assign([], await BorrowYourCarContract.methods.getMyBorrowedCars(this.currentUser).call())
      // console.log(tempList3)
      this.listOfMyBorrowedCars = this.getCarDetailsArray(tempList3)
      // console.log(this.listOfMyOwnedCars)
      const tempList4 = Object.assign([], await BorrowYourCarContract.methods.getAvailableCars().call())
      // console.log(tempList3)
      this.listOfUnborrowedCars = this.getCarDetailsArray(tempList4)
    },
    mounted() {
    // 初始化检查用户是否已经连接钱包
    // 查看window对象里是否存在ethereum（metamask安装后注入的）对象
      const savedCurrentUser = localStorage.getItem('currentUser')
      if (savedCurrentUser) {
        this.currentUser = savedCurrentUser
        this.userScore = myERC20Contract.methods.balanceOf(this.currentUser).call()
      }
      const initCheckAccounts = async() => {
        const { ethereum } = window

        if (ethereum && ethereum.isMetaMask) {
          // 尝试获取连接的用户账户
          try {
            const accounts = await web3.eth.getAccounts()
            if (accounts && accounts.length) {
              this.currentUser = accounts[0]

              localStorage.setItem('currentUser', this.currentUser)
            }
          } catch (error) {
            console.error(error)
          }
        }
      }

      initCheckAccounts()
    }
  }
}
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
  background-color: #f0f0f0;
  border-radius: 6px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.current-user {
  font-size: 18px;
  font-weight: bold;
}
</style>
