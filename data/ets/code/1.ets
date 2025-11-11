import { sms } from '@kit.TelephonyKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
@Entry
@Component
struct Index {
  // 存储设备ID(敏感信息)
  private deviceId: string = '';
  /**
   * 组件即将出现时调用,类似于 Android 的 onCreate
   */
  aboutToAppear(): void {
    try {
      // 获取设备信息作为source(敏感信息源)
      // 使用设备的多个属性组合成唯一标识
      let manufacturer: string = deviceInfo.manufacture; // 制造商
      let brand: string = deviceInfo.brand; // 品牌
      let productModel: string = deviceInfo.productModel; // 产品型号
      let marketName: string = deviceInfo.marketName; // 市场名称
      let osFullName: string = deviceInfo.osFullName; // 操作系统名称
      // 组合设备信息作为敏感数据
      this.deviceId = `${manufacturer}-${brand}-${productModel}-${marketName}-${osFullName}`;
      console.info('Device Info obtained: ' + this.deviceId);
    } catch (error) {
      console.error('Failed to get device info: ' + JSON.stringify(error));
      this.deviceId = 'unknown';
    }
  }
  /**
   * 发送消息的函数 - 这是一个sink(敏感信息泄露点)
   */
  sendMessage(): void {
    // 显示Toast消息
    promptAction.showToast({
      message: this.deviceId,
      duration: 3000
    });
    // 发送短信 - sink, leak
    let sendCallback = (err: BusinessError, data: sms.ISendShortMessageCallback): void => {
      if (err) {
        console.error('Send SMS failed, error: ' + JSON.stringify(err));
        return;
      }
      console.info('Send SMS succeeded: ' + JSON.stringify(data));
    };
    // 短信送达回调
    let deliveryCallback = (err: BusinessError, data: sms.IDeliveryShortMessageCallback): void => {
      if (err) {
        console.error('Delivery callback failed, error: ' + JSON.stringify(err));
        return;
      }
      console.info('Delivery callback succeeded: ' + JSON.stringify(data));
    };
    let options: sms.SendMessageOptions = {
      slotId: 0,
      destinationHost: '+49', // 目标号码
      content: this.deviceId, // 泄露敏感信息 - deviceId
      sendCallback: sendCallback,
      deliveryCallback: deliveryCallback
    };
    // 发送短信
    sms.sendShortMessage(options);
  }
  build() {
    Column({ space: 20 }) {
      Text('Button1 Demo')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 50 })
      Text('点击按钮发送设备ID')
        .fontSize(16)
        .fontColor(Color.Gray)
      Text(`当前设备ID: ${this.deviceId}`)
        .fontSize(14)
        .fontColor(Color.Blue)
        .margin({ top: 20 })
      // 按钮 - 点击后触发sendMessage
      Button('发送消息')
        .fontSize(18)
        .width(200)
        .height(50)
        .margin({ top: 30 })
        .onClick(() => {
          this.sendMessage(); // 用户点击按钮后调用sink
        })

      Text('警告: 此代码仅用于安全测试!')
        .fontSize(12)
        .fontColor(Color.Red)
        .margin({ top: 50 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}