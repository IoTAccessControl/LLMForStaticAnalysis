import { sms } from '@kit.TelephonyKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
@Entry
@Component
struct Button2Demo {
  // 存储设备ID(敏感信息)
  private deviceId: string = '';
  /**
   * Button1 的点击处理 - 发送敏感信息
   * 只有在 button3 被点击后(deviceId已获取),才会真正泄露数据
   */
  private onButton1Click(): void {
    // 发送短信 - sink, potential leak
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
      destinationHost: '+49 1234', // 目标号码
      content: this.deviceId, // sink, potential leak
      sendCallback: sendCallback,
      deliveryCallback: deliveryCallback
    };
    // 发送短信
    sms.sendShortMessage(options);
    // 日志输出 - sink, potential leak
    hilog.info(0x0000, 'TAG', 'sendDeviceId: %{public}s', this.deviceId);
    console.info('TAG', 'sendDeviceId: ' + this.deviceId);
    // 清空敏感信息
    this.deviceId = '';
  }
  /**
   * Button2 的点击处理 - 清空数据
   */
  private onButton2Click(): void {
    // 清空敏感信息
    this.deviceId = '';
    // 日志输出 - sink, no leak (因为已经清空)
    hilog.info(0x0000, 'TAG', 'Button 2: %{public}s', this.deviceId);
    console.info('TAG', 'Button 2: ' + this.deviceId);
    promptAction.showToast({
      message: 'Button 2 clicked - 数据已清空',
      duration: 2000
    });
  }
  /**
   * Button3 的点击处理 - 获取敏感信息
   * 这是 source,获取设备信息
   */
  private onButton3Click(): void {
    try {
      // 获取设备信息作为source(敏感信息源)
      let manufacturer: string = deviceInfo.manufacture; // 制造商
      let brand: string = deviceInfo.brand; // 品牌
      let productModel: string = deviceInfo.productModel; // 产品型号
      let osFullName: string = deviceInfo.osFullName; // 操作系统名称
      let marketName: string = deviceInfo.marketName; // 市场名称
      // 组合设备信息作为敏感数据 - source
      this.deviceId = `${manufacturer}-${brand}-${productModel}-${marketName}-${osFullName}`;
      // 日志输出 - sink, leak (获取后立即泄露到日志)
      hilog.info(0x0000, 'TAG', 'Button3: %{public}s', this.deviceId);
      console.info('TAG', 'Button3: ' + this.deviceId);
      promptAction.showToast({
        message: 'Button 3 clicked - 设备信息已获取',
        duration: 2000
      });
    } catch (error) {
      console.error('Failed to get device info: ' + JSON.stringify(error));
      this.deviceId = '';
    }
  }
  build() {
    Column({ space: 30 }) {
      // 标题
      Text('Button2 Demo')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 50 })
      Text('多按钮数据流测试')
        .fontSize(16)
        .fontColor(Color.Gray)
      // 显示当前设备ID
      Text(`当前设备ID: ${this.deviceId || '(未获取)'}`)
        .fontSize(14)
        .fontColor(Color.Blue)
        .margin({ top: 20 })
        .padding(10)
        .backgroundColor('#F0F0F0')
        .borderRadius(5)
      // 说明文字
      Column({ space: 10 }) {
        Text('数据泄露场景:')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Orange)
        Text('1️⃣ 先点击 Button 3 获取设备信息')
          .fontSize(12)
          .fontColor(Color.Gray)
        Text('2️⃣ 再点击 Button 1 发送信息(泄露)')
          .fontSize(12)
          .fontColor(Color.Gray)
        Text('3️⃣ Button 2 会清空数据')
          .fontSize(12)
          .fontColor(Color.Gray)
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')
      .padding(15)
      .backgroundColor('#FFF8E1')
      .borderRadius(8)
      .margin({ top: 20 })
      // 按钮组
      Column({ space: 15 }) {
        // Button 1 - 发送信息
        Button('Button 1 - 发送设备ID')
          .fontSize(16)
          .width('80%')
          .height(50)
          .backgroundColor('#FF5722')
          .onClick(() => {
            this.onButton1Click(); // sink, potential leak
          })
        // Button 2 - 清空数据
        Button('Button 2 - 清空数据')
          .fontSize(16)
          .width('80%')
          .height(50)
          .backgroundColor('#4CAF50')
          .onClick(() => {
            this.onButton2Click(); // sink, no leak
          })
        // Button 3 - 获取设备信息
        Button('Button 3 - 获取设备信息')
          .fontSize(16)
          .width('80%')
          .height(50)
          .backgroundColor('#2196F3')
          .onClick(() => {
            this.onButton3Click(); // source
          })
      }
      .margin({ top: 30 })
      // 警告提示
      Text('⚠️ 警告: 此代码仅用于安全测试!')
        .fontSize(12)
        .fontColor(Color.Red)
        .margin({ top: 40 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }
}