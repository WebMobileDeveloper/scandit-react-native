//
//  RCTConvert+Scandit.m
//  RCTScanditBarcodeScanner
//
//  Created by Luca Torella on 17.08.17.
//  Copyright © 2017 Scandit. All rights reserved.
//

#import "RCTConvert+Scandit.h"

@import ScanditBarcodeScanner;

@implementation RCTConvert (Scandit)

RCT_ENUM_CONVERTER(SBSCameraSwitchVisibility,
                   (@{
                      @"never": @(SBSCameraSwitchVisibilityNever),
                      @"always": @(SBSCameraSwitchVisibilityAlways),
                      @"onTablet": @(SBSCameraSwitchVisibilityOnTablet),
                      }),
                   SBSCameraSwitchVisibilityNever,
                   integerValue)

RCT_ENUM_CONVERTER(SBSMatrixScanHighlightingState,
                   (@{
                      @"localized": @(SBSMatrixScanHighlightingStateLocalized),
                      @"recognized": @(SBSMatrixScanHighlightingStateRecognized),
                      @"rejected": @(SBSMatrixScanHighlightingStateRejected),
                      }),
                   SBSMatrixScanHighlightingStateLocalized,
                   integerValue)

RCT_ENUM_CONVERTER(SBSGuiStyle,
                   (@{
                      @"default": @(SBSGuiStyleDefault),
                      @"laser": @(SBSGuiStyleLaser),
                      @"none": @(SBSGuiStyleNone),
                      @"matrixScan": @(SBSGuiStyleMatrixScan),
                      @"locationsOnly": @(SBSGuiStyleLocationsOnly),
                      }),
                   SBSMatrixScanHighlightingStateLocalized,
                   integerValue)

@end
