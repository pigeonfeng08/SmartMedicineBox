import { User } from './users';

// 定义 API 响应结构
export interface ApiResponse {
  code: number;        // 响应状态码
  data: User[];        // 用户数据数组
}

// 定义单个用户的 API 响应结构
export interface UserApiResponse {
  code: number;        // 响应状态码
  data: User;          // 单个用户数据
}

// 定义通用 API 响应结构（泛型版本）
export interface BaseApiResponse<T> {
  code: number;        // 响应状态码
  message: string;     // 响应消息
  data?: T;            // 泛型数据类型
}

// 定义登录数据结构
export interface LoginData {
  token: string;       // 认证令牌
  user: User;          // 用户信息
}

// 定义登录 API 响应结构
export interface LoginApiResponse {
  code: number;        // 响应状态码
  message: string;     // 响应消息
  data: LoginData;     // 登录数据
}

// 定义分页数据结构
export interface PaginatedData {
  users: User[];       // 用户列表
  total: number;       // 总数量
  page: number;        // 当前页码
  pageSize: number;    // 每页数量
}

// 定义分页 API 响应结构
export interface PaginatedApiResponse {
  code: number;        // 响应状态码
  message: string;     // 响应消息
  data: PaginatedData; // 分页数据
}

// 为了向后兼容，定义一些常用的类型别名
export type UserResponse = BaseApiResponse<User>;
export type StringResponse = BaseApiResponse<string>;
export type NumberResponse = BaseApiResponse<number>;
export type BooleanResponse = BaseApiResponse<boolean>;