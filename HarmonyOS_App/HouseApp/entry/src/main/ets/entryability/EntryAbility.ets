import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import http from '@ohos.net.http';
import { IAMTokenPreferencesDataUtil } from '../utils/IAMTokenPreferencesDataUtil';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
    
    // 获取token
    this.getToken();
  }

  // 添加获取token的方法
  async getToken(): Promise<void> {
    let token: string = '';
    let tokenRes = http.createHttp();
    
    try {
      let data = await tokenRes.request(
        'https://iam.cn-north-4.myhuaweicloud.com/v3/auth/tokens',
        {
          method: http.RequestMethod.POST,
          header: {
            'Content-Type': 'application/json'
          },
          extraData: {
            "auth": {
              "identity": {
                "methods": [
                  "password"
                ],
                "password": {
                  "user": {
                    "domain": {
                      "name": "pigeon_feng"
                    },
                    "name": "test",
                    "password": "12345678!"
                  }
                }
              },
              "scope": {}
            }
          }
        }
      );

      if (data.responseCode >= 200 && data.responseCode < 300) {
        token = data.header['x-subject-token'];
        
        // 保存token到本地存储
        IAMTokenPreferencesDataUtil.init().setPreferencesData('token', token);
        
        // 通过Log打印获取到的token
        hilog.info(DOMAIN, 'testTag', 'Token获取成功并已保存: %{public}s', token);
        console.log('Token获取成功并已保存:', token);
      } else {
        hilog.error(DOMAIN, 'testTag', 'Token获取失败，响应码: %{public}d', data.responseCode);
        console.log('Token获取失败，响应码:', data.responseCode);
      }
    } catch (error) {
      hilog.error(DOMAIN, 'testTag', 'Token获取异常: %{public}s', JSON.stringify(error));
      console.log('Token获取异常:', JSON.stringify(error));
    } finally {
      tokenRes.destroy();
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}