/**
 * @testcase_name Button4-Advanced
 * @description 使用全局 @Builder 更精确地模拟 Android XML include
 */
import { sms } from '@kit.TelephonyKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
// ========================================
// 定义 @Builder 参数的接口类型
// ========================================
interface ButtonLayoutParams {
  onSendClick: () => void;
  deviceId: string;
}
// ========================================
// 全局 @Builder - 类似独立的 XML 布局文件
// 相当于 button_layout.xml
// ========================================
@Builder
function IncludedButtonLayout(params: ButtonLayoutParams) {
  Column({ space: 15 }) {
    Text('这是一个独立的可复用组件')
      .fontSize(14)
      .fontColor(Color.Gray)
    Text(`设备ID: ${params.deviceId}`)
      .fontSize(12)
      .fontColor(Color.Blue)
    Button('发送消息')
      .fontSize(18)
      .width(200)
      .height(50)
      .backgroundColor('#2196F3')
      .onClick(() => {
        params.onSendClick(); // 调用传入的回调函数
      })
  }
  .width('100%')
  .padding(20)
  .backgroundColor('#E3F2FD')
  .borderRadius(10)
}
// ========================================
// 主组件 - 类似 activity_button4.xml
// ========================================
@Entry
@Component
struct Button4AdvancedDemo {
  private deviceId: string = '';
  aboutToAppear(): void {
    try {
      let manufacturer: string = deviceInfo.manufacture;
      let brand: string = deviceInfo.brand;
      let productModel: string = deviceInfo.productModel;
      let osFullName: string = deviceInfo.osFullName;
      let marketName: string = deviceInfo.marketName;
      this.deviceId = `${manufacturer}-${brand}-${productModel}-${marketName}-${osFullName}`;
      console.info('Device Info obtained: ' + this.deviceId);
    } catch (error) {
      console.error('Failed to get device info: ' + JSON.stringify(error));
      this.deviceId = 'unknown';
    }
  }
  private sendMessage(): void {
    promptAction.showToast({
      message: this.deviceId,
      duration: 3000
    });
    let sendCallback = (err: BusinessError, data: sms.ISendShortMessageCallback): void => {
      if (err) {
        console.error('Send SMS failed, error: ' + JSON.stringify(err));
        return;
      }
      console.info('Send SMS succeeded: ' + JSON.stringify(data));
    };
    let deliveryCallback = (err: BusinessError, data: sms.IDeliveryShortMessageCallback): void => {
      if (err) {
        console.error('Delivery callback failed, error: ' + JSON.stringify(err));
        return;
      }
      console.info('Delivery callback succeeded: ' + JSON.stringify(data));
    };
    let options: sms.SendMessageOptions = {
      slotId: 0,
      destinationHost: '+49',
      content: this.deviceId,
      sendCallback: sendCallback,
      deliveryCallback: deliveryCallback
    };
    sms.sendShortMessage(options);
  }
  build() {
    Column({ space: 20 }) {
      Text('Button4 Advanced Demo')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 50 })
      Text('使用全局 @Builder (更接近 XML include)')
        .fontSize(16)
        .fontColor(Color.Gray)
      // 使用全局 @Builder - 类似 <include layout="@layout/button_layout" />
      IncludedButtonLayout({
        onSendClick: () => { this.sendMessage(); },
        deviceId: this.deviceId
      })
      Text('⚠️ 警告: 此代码仅用于安全测试!')
        .fontSize(12)
        .fontColor(Color.Red)
        .margin({ top: 30 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}