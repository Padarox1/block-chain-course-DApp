<template>
  <div class="app-container">
    <div class="button-container">
      <el-button type="primary" @click="showUnborrowedVehicles">显示未借用车辆</el-button>
      <el-button type="primary" @click="showOwnedVehicles">显示自己已拥有车辆</el-button>
      <el-button type="primary" @click="showSearchDialog">查询</el-button>
    </div>
    <el-table
      v-loading="listLoading"
      :data="list"
      element-loading-text="Loading"
      border
      fit
      highlight-current-row
    >
      <el-table-column align="center" label="ID" width="95">
        <template slot-scope="scope">
          {{ scope.$index }}
        </template>
      </el-table-column>
      <el-table-column label="Title">
        <template slot-scope="scope">
          {{ scope.row.title }}
        </template>
      </el-table-column>
      <el-table-column label="Author" width="110" align="center">
        <template slot-scope="scope">
          <span>{{ scope.row.author }}</span>
        </template>
      </el-table-column>
      <el-table-column label="Pageviews" width="110" align="center">
        <template slot-scope="scope">
          {{ scope.row.pageviews }}
        </template>
      </el-table-column>
      <el-table-column class-name="status-col" label="Status" width="110" align="center">
        <template slot-scope="scope">
          <el-tag :type="scope.row.status | statusFilter">{{ scope.row.status }}</el-tag>
        </template>
      </el-table-column>
      <el-table-column align="center" prop="created_at" label="Display_time" width="200">
        <template slot-scope="scope">
          <i class="el-icon-time" />
          <span>{{ scope.row.display_time }}</span>
        </template>
      </el-table-column>
    </el-table>
    <div class="button-container">
      <el-button type="primary" @click="showUnborrowedVehicles">显示未借用车辆</el-button>
      <el-button type="primary" @click="showOwnedVehicles">显示自己已拥有车辆</el-button>
      <el-button type="primary" @click="showSearchDialog">查询</el-button>
    </div>
    <el-dialog title="查询" :visible.sync="searchDialogVisible" width="30%">
      <el-input v-model="searchValue" placeholder="请输入查询内容" />
      <span slot="footer" class="dialog-footer">
        <el-button @click="closeSearchDialog">取消</el-button>
        <el-button type="primary" @click="performSearch">查询</el-button>
      </span>
    </el-dialog>
  </div>
</template>

<script>
import { getList } from '@/api/table'

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
      list: null,
      listLoading: true,
      searchDialogVisible: false,
      searchValue: ''
    }
  },
  created() {
    this.fetchData()
  },
  methods: {
    fetchData() {
      this.listLoading = true
      getList().then(response => {
        this.list = response.data.items
        this.listLoading = false
      })
    },
    showUnborrowedVehicles() {
      // 处理显示未借用车辆的逻辑
    },

    showOwnedVehicles() {
      // 处理显示自己已拥有车辆的逻辑
    },
    showSearchDialog() {
      this.searchDialogVisible = true
    },

    closeSearchDialog() {
      this.searchDialogVisible = false
    },

    performSearch() {
      // 处理查询逻辑
      // 使用 this.searchValue 获取查询内容
      // 可以根据具体需求进行处理
      console.log('Perform search:', this.searchValue)
      this.searchDialogVisible = false
    }
  }
}
</script>

