// 用户数据模型
export class User {
  id: number = 0;                    // 用户ID
  username: string = '';             // 用户名
  password: string = '';             // 密码（实际应用中应存储哈希值）
  email: string = '';                // 邮箱地址
  createdAt: string = '';            // 创建时间
  updatedAt: string = '';            // 更新时间
  isActive: boolean = true;          // 用户状态（激活/禁用）
  avatar: string = '';               // 头像URL
  phone: string = '';                // 手机号码
  lastLoginTime: string = '';        // 最后登录时间
}

// 用户登录请求模型
export class LoginRequest {
  username: string = '';             // 用户名
  password: string = '';             // 密码
}

// 用户登录响应模型
export class LoginResponse {
  success: boolean = false;          // 登录是否成功
  message: string = '';              // 响应消息
  token: string = '';                // 认证令牌
  user: User = new User();           // 用户信息
}

// 用户注册请求模型
export class RegisterRequest {
  username: string = '';             // 用户名
  password: string = '';             // 密码
  email: string = '';                // 邮箱
  phone: string = '';                // 手机号
}

// 用户更新请求模型
export class UpdateUserRequest {
  email: string = '';                // 邮箱
  phone: string = '';                // 手机号
  avatar: string = '';               // 头像URL
}

// 修改密码请求模型
export class ChangePasswordRequest {
  oldPassword: string = '';          // 旧密码
  newPassword: string = '';          // 新密码
}

// 用户列表响应模型
export class UserListResponse {
  users: User[] = [];                // 用户列表
  total: number = 0;                 // 总数量
  page: number = 1;                  // 当前页码
  pageSize: number = 10;             // 每页数量
}