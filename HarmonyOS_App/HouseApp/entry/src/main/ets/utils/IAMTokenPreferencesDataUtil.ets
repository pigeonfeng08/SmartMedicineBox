import { preferences } from '@kit.ArkData';

export class IAMTokenPreferencesDataUtil{
  private static initObject: IAMTokenPreferencesDataUtil = new IAMTokenPreferencesDataUtil();
  private constructor() {
  }
  static init(): IAMTokenPreferencesDataUtil{
    return IAMTokenPreferencesDataUtil.initObject;
  }

  private getPreferencesObject(): preferences.Preferences {
    const preferencesObject = preferences.getPreferencesSync(getContext(), {name: 'iamToken'});
    return preferencesObject;
  }

  getPreferencesData(name: string) {
    const obj: preferences.Preferences = this.getPreferencesObject();
    const token = obj.getSync(name, '') as string;
    return token;
  }
  setPreferencesData(name: string, value: string) {
    const obj: preferences.Preferences = this.getPreferencesObject();
    obj.put(name, value)
  }
}
