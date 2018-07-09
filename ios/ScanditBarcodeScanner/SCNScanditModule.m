//
//  SCNScanditModule.m
//  RCTScanditBarcodeScanner
//
//  Created by Luca Torella on 14.08.17.
//  Copyright © 2017 Scandit. All rights reserved.
//

#import "SCNScanditModule.h"

@import ScanditBarcodeScanner;

@implementation SCNScanditModule

RCT_EXPORT_MODULE(ScanditModule)

RCT_EXPORT_METHOD(setAppKey:(NSString *)appKey) {
    [SBSLicense setAppKey:appKey];
}

@end
