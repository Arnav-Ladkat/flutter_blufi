//
//  ESPFBYBLEHelper.m
//  EspBlufi
//
//  Created by fanbaoying on 2020/6/11.
//  Copyright © 2020 espressif. All rights reserved.
//

#import "ESPFBYBLEHelper.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ESPFBYBLEHelper ()<CBCentralManagerDelegate,CBPeripheralDelegate>
// 中心管理者(管理设备的扫描和连接)
@property (nonatomic, strong) CBCentralManager *centralManager;
// 存储的设备
@property (nonatomic, strong) NSMutableArray *peripherals;

// 外设状态
@property (nonatomic, assign) CBManagerState peripheralState;

@end

@implementation ESPFBYBLEHelper

- (void)ESPFBYBLEHelperInit {
    self.centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

//单例模式
+ (instancetype)share {
    static ESPFBYBLEHelper *share = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        share = [[ESPFBYBLEHelper alloc]init];
        [share ESPFBYBLEHelperInit];
    });
    return share;
}

- (void)stopScan {
    [self.centralManager stopScan];
}

- (void)startScan:(FBYBleDeviceBackBlock)device {
    
    NSLog(@"scan device");
    _bleScanSuccessBlock = device;
    if (self.peripheralState ==  CBManagerStatePoweredOn)
    {
        [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

/**
 扫描到设备
 
 @param central 中心管理者
 @param peripheral 扫描到的设备
 @param advertisementData 广告信息
 @param RSSI 信号强度
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    ESPPeripheral *espPeripheral = [[ESPPeripheral alloc] initWithPeripheral:peripheral];
    espPeripheral.name = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    espPeripheral.rssi = RSSI.intValue;
    if (self.bleScanSuccessBlock) {
        self.bleScanSuccessBlock(espPeripheral);
    }
}

// 状态更新时调用
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBManagerStateUnknown:{
            NSLog(@"Unknown status");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateResetting:
        {
            NSLog(@"reset state");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnsupported:
        {
            NSLog(@"unsupported state");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStateUnauthorized:
        {
            NSLog(@"Unauthorized state");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOff:
        {
            NSLog(@"Disabled");
            self.peripheralState = central.state;
        }
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@"On state - available state");
            self.peripheralState = central.state;
            NSLog(@"%ld",(long)self.peripheralState);
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
        }
            break;
        default:
            break;
    }
}

@end
