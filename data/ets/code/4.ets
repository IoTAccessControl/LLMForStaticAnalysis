/**
 * @testcase_name Button-Object-Allocation
 *
 * @description 测试按钮组件状态的正确建模。按钮组件在运行时由单个对象表示,
 *  该对象在多次点击事件中保持状态。
 * @number_of_leaks 1
 * @challenges 必须正确建模:按钮在运行时由单个对象表示,
 *  该对象的状态在多次 onClick 调用之间保持,第二次点击时会泄露敏感信息
 */

import { deviceInfo } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct ButtonObjectAllocationDemo {
  // 存储设备ID(敏感信息)
  private deviceId: string = '';

  // 按钮的 hint 状态 - 模拟 Android Button 的 hint 属性
  // 这个状态在多次点击之间会保持
  @State private buttonHint: string = '';

  /**
   * 组件即将出现时调用
   */
  aboutToAppear(): void {
    try {
      // 获取设备信息作为source(敏感信息源)
      let manufacturer: string = deviceInfo.manufacture;
      let brand: string = deviceInfo.brand;
      let productModel: string = deviceInfo.productModel;
      let osFullName: string = deviceInfo.osFullName;
      let marketName: string = deviceInfo.marketName;

      // 组合设备信息作为敏感数据 - source
      this.deviceId = `${manufacturer}-${brand}-${productModel}-${marketName}-${osFullName}`;

      hilog.info(0x0000, 'DroidBench', 'Device Info obtained: %{public}s', this.deviceId);
      console.info('Device Info obtained: ' + this.deviceId);
    } catch (error) {
      console.error('Failed to get device info: ' + JSON.stringify(error));
      this.deviceId = 'unknown';
    }
  }

  /**
   * 发送消息的函数 - 模拟 Android 的 sendMessage(View view)
   *
   * 关键逻辑:
   * 第1次点击: buttonHint 为空,设置为 deviceId
   * 第2次点击: buttonHint 已有值(deviceId),输出到日志 - LEAK!
   *
   * 这测试静态分析工具能否理解:
   * 1. 按钮状态在多次点击之间保持
   * 2. 第一次点击不泄露,第二次点击才泄露
   */
  private sendMessage(): void {
    // 第2次及以后点击: 读取 buttonHint (包含敏感信息)
    // sink on second call to sendMessage(), second click of button
    if (this.buttonHint !== '') {
      hilog.info(0x0000, 'DroidBench', 'Button hint: %{public}s', this.buttonHint);
      console.info('DroidBench: ' + this.buttonHint); // sink, leak on 2nd+ click
    }

    // 第1次点击: 将敏感信息存储到 buttonHint
    // 模拟 Android 的 view.setHint(imei)
    this.buttonHint = this.deviceId;

    console.info('Button hint has been set to device ID');
  }

  build() {
    Column({ space: 30 }) {
      // 标题
      Text('Button Object Allocation Demo')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 50 })

      Text('测试按钮对象状态保持')
        .fontSize(16)
        .fontColor(Color.Gray)

      // 显示当前设备ID
      Text(`当前设备ID: ${this.deviceId}`)
        .fontSize(14)
        .fontColor(Color.Blue)
        .padding(10)
        .backgroundColor('#F0F0F0')
        .borderRadius(5)

      // 显示按钮当前的 hint 状态
      Text(`按钮 Hint: ${this.buttonHint || '(未设置)'}`)
        .fontSize(14)
        .fontColor(this.buttonHint ? Color.Red : Color.Gray)
        .padding(10)
        .backgroundColor('#FFF3E0')
        .borderRadius(5)

      // 说明文字
      Column({ space: 10 }) {
        Text('🔍 测试场景:')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Orange)

        Text('1️⃣ 第1次点击: 将设备ID存储到按钮状态')
          .fontSize(12)
          .fontColor(Color.Gray)

        Text('2️⃣ 第2次点击: 读取按钮状态并输出(泄露!)')
          .fontSize(12)
          .fontColor(Color.Red)

        Text('3️⃣ 后续点击: 继续泄露')
          .fontSize(12)
          .fontColor(Color.Red)
      }
      .alignItems(HorizontalAlign.Start)
      .width('90%')
      .padding(15)
      .backgroundColor('#E8F5E9')
      .borderRadius(8)
      .margin({ top: 20 })

      // 按钮 - 点击后触发 sendMessage
      // 这个按钮对象在运行时只有一个实例
      // 它的状态(buttonHint)在多次点击之间保持
      Button('点击发送消息')
        .fontSize(18)
        .width('80%')
        .height(60)
        .backgroundColor('#FF5722')
        .margin({ top: 30 })
        .onClick(() => {
          this.sendMessage(); // 多次点击同一个方法
        })

      // 点击计数提示
      Text('💡 提示: 多次点击按钮观察行为')
        .fontSize(12)
        .fontColor(Color.Orange)
        .margin({ top: 10 })

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