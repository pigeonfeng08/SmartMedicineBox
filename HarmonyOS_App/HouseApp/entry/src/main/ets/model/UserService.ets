import { User } from './users';
import http from '@ohos.net.http';
import { ApiResponse, LoginApiResponse, UserResponse, StringResponse } from './ApiResponse';
import { LoginRequest, RegisterRequest, UpdateUserRequest, ChangePasswordRequest } from './users';

export class UserService {
  private static readonly API_URL: string = "http://192.168.1.107:5000/api/users"; // 替换为你的IP地址
  private static readonly AUTH_URL: string = "http://192.168.1.107:5000/api/auth"; // 认证相关接口

  // 获取用户列表
  static async getUsers(): Promise<User[]> {
    let httpRequest = http.createHttp();
    try {
      let response = await httpRequest.request(
        UserService.API_URL,
        { method: http.RequestMethod.GET }
      );

      // 检查响应对象是否存在
      if (!response) {
        throw new Error("网络请求无响应");
      }

      // 检查 HTTP 状态码
      if (response.responseCode !== 200) {
        throw new Error(`HTTP 错误: ${response.responseCode}`);
      }

      // 检查 result 是否存在
      if (typeof response.result === 'undefined') {
        throw new Error("响应数据为空");
      }

      // 安全解析 JSON
      let rawData: string;
      try {
        rawData = response.result.toString();
      } catch (e) {
        throw new Error("响应数据转换失败: " + e.message);
      }

      let data: ApiResponse;
      try {
        data = JSON.parse(rawData) as ApiResponse;
      } catch (e) {
        throw new Error("JSON 解析失败: " + e.message);
      }

      // 验证数据结构
      if (!Array.isArray(data?.data)) {
        throw new Error("数据格式错误: 非数组");
      }

      return data.data;
    } catch (error) {
      console.error("HTTP Request Error:", error);
      const safeError = error instanceof Error ? error : new Error(String(error));
      throw safeError;
    } finally {
      httpRequest.destroy();
    }
  }

  // 用户登录
  static async login(loginData: LoginRequest): Promise<LoginApiResponse> {
    let httpRequest = http.createHttp();
    try {
      let response = await httpRequest.request(
        `${UserService.AUTH_URL}/login`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(loginData)
        }
      );

      if (!response) {
        throw new Error("网络请求无响应");
      }

      if (response.responseCode !== 200) {
        throw new Error(`登录失败: ${response.responseCode}`);
      }

      if (typeof response.result === 'undefined') {
        throw new Error("响应数据为空");
      }

      let rawData: string;
      try {
        rawData = response.result.toString();
      } catch (e) {
        throw new Error("响应数据转换失败: " + e.message);
      }

      let data: LoginApiResponse;
      try {
        data = JSON.parse(rawData) as LoginApiResponse;
      } catch (e) {
        throw new Error("JSON 解析失败: " + e.message);
      }

      return data;
    } catch (error) {
      console.error("Login Error:", error);
      const safeError = error instanceof Error ? error : new Error(String(error));
      throw safeError;
    } finally {
      httpRequest.destroy();
    }
  }

  // 用户注册
  static async register(registerData: RegisterRequest): Promise<UserResponse> {
    let httpRequest = http.createHttp();
    try {
      let response = await httpRequest.request(
        `${UserService.AUTH_URL}/register`,
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(registerData)
        }
      );

      if (!response) {
        throw new Error("网络请求无响应");
      }

      if (response.responseCode !== 201) {
        throw new Error(`注册失败: ${response.responseCode}`);
      }

      if (typeof response.result === 'undefined') {
        throw new Error("响应数据为空");
      }

      let rawData: string;
      try {
        rawData = response.result.toString();
      } catch (e) {
        throw new Error("响应数据转换失败: " + e.message);
      }

      let data: UserResponse;
      try {
        data = JSON.parse(rawData) as UserResponse;
      } catch (e) {
        throw new Error("JSON 解析失败: " + e.message);
      }

      return data;
    } catch (error) {
      console.error("Register Error:", error);
      const safeError = error instanceof Error ? error : new Error(String(error));
      throw safeError;
    } finally {
      httpRequest.destroy();
    }
  }

  // 根据ID获取用户信息
  static async getUserById(userId: number): Promise<User> {
    let httpRequest = http.createHttp();
    try {
      let response = await httpRequest.request(
        `${UserService.API_URL}/${userId}`,
        { method: http.RequestMethod.GET }
      );

      if (!response) {
        throw new Error("网络请求无响应");
      }

      if (response.responseCode !== 200) {
        throw new Error(`获取用户信息失败: ${response.responseCode}`);
      }

      if (typeof response.result === 'undefined') {
        throw new Error("响应数据为空");
      }

      let rawData: string;
      try {
        rawData = response.result.toString();
      } catch (e) {
        throw new Error("响应数据转换失败: " + e.message);
      }

      let data: UserResponse;
      try {
        data = JSON.parse(rawData) as UserResponse;
      } catch (e) {
        throw new Error("JSON 解析失败: " + e.message);
      }

      if (!data?.data) {
        throw new Error("用户数据格式错误");
      }

      return data.data;
    } catch (error) {
      console.error("Get User Error:", error);
      const safeError = error instanceof Error ? error : new Error(String(error));
      throw safeError;
    } finally {
      httpRequest.destroy();
    }
  }

  // 更新用户信息
  static async updateUser(userId: number, updateData: UpdateUserRequest): Promise<User> {
    let httpRequest = http.createHttp();
    try {
      let response = await httpRequest.request(
        `${UserService.API_URL}/${userId}`,
        {
          method: http.RequestMethod.PUT,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(updateData)
        }
      );

      if (!response) {
        throw new Error("网络请求无响应");
      }

      if (response.responseCode !== 200) {
        throw new Error(`更新用户信息失败: ${response.responseCode}`);
      }

      if (typeof response.result === 'undefined') {
        throw new Error("响应数据为空");
      }

      let rawData: string;
      try {
        rawData = response.result.toString();
      } catch (e) {
        throw new Error("响应数据转换失败: " + e.message);
      }

      let data: UserResponse;
      try {
        data = JSON.parse(rawData) as UserResponse;
      } catch (e) {
        throw new Error("JSON 解析失败: " + e.message);
      }

      if (!data?.data) {
        throw new Error("用户数据格式错误");
      }

      return data.data;
    } catch (error) {
      console.error("Update User Error:", error);
      const safeError = error instanceof Error ? error : new Error(String(error));
      throw safeError;
    } finally {
      httpRequest.destroy();
    }
  }

  // 修改密码
  static async changePassword(userId: number, passwordData: ChangePasswordRequest): Promise<StringResponse> {
    let httpRequest = http.createHttp();
    try {
      let response = await httpRequest.request(
        `${UserService.API_URL}/${userId}/password`,
        {
          method: http.RequestMethod.PUT,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: JSON.stringify(passwordData)
        }
      );

      if (!response) {
        throw new Error("网络请求无响应");
      }

      if (response.responseCode !== 200) {
        throw new Error(`修改密码失败: ${response.responseCode}`);
      }

      if (typeof response.result === 'undefined') {
        throw new Error("响应数据为空");
      }

      let rawData: string;
      try {
        rawData = response.result.toString();
      } catch (e) {
        throw new Error("响应数据转换失败: " + e.message);
      }

      let data: StringResponse;
      try {
        data = JSON.parse(rawData) as StringResponse;
      } catch (e) {
        throw new Error("JSON 解析失败: " + e.message);
      }

      return data;
    } catch (error) {
      console.error("Change Password Error:", error);
      const safeError = error instanceof Error ? error : new Error(String(error));
      throw safeError;
    } finally {
      httpRequest.destroy();
    }
  }

  // 删除用户
  static async deleteUser(userId: number): Promise<StringResponse> {
    let httpRequest = http.createHttp();
    try {
      let response = await httpRequest.request(
        `${UserService.API_URL}/${userId}`,
        { method: http.RequestMethod.DELETE }
      );

      if (!response) {
        throw new Error("网络请求无响应");
      }

      if (response.responseCode !== 200) {
        throw new Error(`删除用户失败: ${response.responseCode}`);
      }

      if (typeof response.result === 'undefined') {
        throw new Error("响应数据为空");
      }

      let rawData: string;
      try {
        rawData = response.result.toString();
      } catch (e) {
        throw new Error("响应数据转换失败: " + e.message);
      }

      let data: StringResponse;
      try {
        data = JSON.parse(rawData) as StringResponse;
      } catch (e) {
        throw new Error("JSON 解析失败: " + e.message);
      }

      return data;
    } catch (error) {
      console.error("Delete User Error:", error);
      const safeError = error instanceof Error ? error : new Error(String(error));
      throw safeError;
    } finally {
      httpRequest.destroy();
    }
  }
}