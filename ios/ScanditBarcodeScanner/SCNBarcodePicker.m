//
//  SCNBarcodePicker.m
//  SCNScanditBarcodeScanner
//
//  Created by Luca Torella on 13.08.17.
//  Copyright © 2017 Scandit. All rights reserved.
//

#import "SCNBarcodePicker.h"
#import <React/RCTLog.h>
#import <UIKit/UIKit.h>

@import ScanditBarcodeScanner;

static inline NSDictionary<NSString *, id> *dictionaryFromQuadrilateral(SBSQuadrilateral quadrilateral) {
    return @{
             @"topLeft": @[@(quadrilateral.topLeft.x), @(quadrilateral.topLeft.y)],
             @"topRight": @[@(quadrilateral.topRight.x), @(quadrilateral.topRight.y)],
             @"bottomLeft": @[@(quadrilateral.bottomLeft.x), @(quadrilateral.bottomLeft.y)],
             @"bottomRight": @[@(quadrilateral.bottomRight.x), @(quadrilateral.bottomRight.y)],
             };
}

static NSDictionary<NSString *, id> *dictionaryFromCode(SBSCode *code, NSNumber *identifier) {
    NSMutableArray<NSNumber *> *bytesArray = [NSMutableArray arrayWithCapacity:code.rawData.length];
    if (code.rawData != nil) {
        unsigned char *bytes = (unsigned char *)[code.rawData bytes];
        for (int i = 0; i < code.rawData.length; i++) {
            [bytesArray addObject:@(bytes[i])];
        }
    }

    return @{
             @"id": identifier ?: @(-1),
             @"rawData": bytesArray,
             @"data": code.data ?: @"",
             @"symbology": code.symbologyName,
             @"compositeFlag": @(code.compositeFlag),
             @"isGs1DataCarrier": [NSNumber numberWithBool:code.isGs1DataCarrier],
             @"isRecognized": [NSNumber numberWithBool:code.isRecognized],
             @"location": dictionaryFromQuadrilateral(code.location),
             };
}

static inline NSDictionary *dictionaryFromScanSession(SBSScanSession *session) {
    NSMutableArray *allRecognizedCodes = [NSMutableArray arrayWithCapacity:session.allRecognizedCodes.count];
    for (SBSCode *code in session.allRecognizedCodes) {
        [allRecognizedCodes addObject:dictionaryFromCode(code, nil)];
    }
    NSMutableArray *newlyLocalizedCodes = [NSMutableArray arrayWithCapacity:session.newlyLocalizedCodes.count];
    for (SBSCode *code in session.newlyLocalizedCodes) {
        [newlyLocalizedCodes addObject:dictionaryFromCode(code, nil)];
    }
    NSMutableArray *newlyRecognizedCodes = [NSMutableArray arrayWithCapacity:session.newlyRecognizedCodes.count];
    int i = 0;
    for (SBSCode *code in session.newlyRecognizedCodes) {
        [newlyRecognizedCodes addObject:dictionaryFromCode(code, @(i))];
        i++;
    }
    return @{
             @"allRecognizedCodes": allRecognizedCodes,
             @"newlyLocalizedCodes": newlyLocalizedCodes,
             @"newlyRecognizedCodes": newlyRecognizedCodes,
             };
}

static inline NSDictionary *dictionaryFromTrackedCodes(NSDictionary<NSNumber *, SBSTrackedCode *> *trackedCodes) {
    NSMutableArray *newlyTrackedCodes = [NSMutableArray arrayWithCapacity:trackedCodes.count];
    for (NSNumber *identifier in trackedCodes) {
        [newlyTrackedCodes addObject:dictionaryFromCode(trackedCodes[identifier], identifier)];
    }
    return @{@"newlyTrackedCodes": newlyTrackedCodes};
}

static inline NSDictionary *dictionaryFromBase64FrameString(NSString *base64FrameString) {
    return @{@"base64FrameString": base64FrameString};
}

static inline NSString *base64StringFromFrame(CMSampleBufferRef *frame) {

    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(*frame);
    // Lock the base address of the pixel buffer.
    CVPixelBufferLockBaseAddress(imageBuffer,0);

    // Get the pixel buffer width and height.
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);

    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);

    CVPlanarPixelBufferInfo_YCbCrBiPlanar *bufferInfo = (CVPlanarPixelBufferInfo_YCbCrBiPlanar *)baseAddress;

    int yOffset = CFSwapInt32BigToHost(bufferInfo->componentInfoY.offset);
    int yRowBytes = CFSwapInt32BigToHost(bufferInfo->componentInfoY.rowBytes);
    int cbCrOffset = CFSwapInt32BigToHost(bufferInfo->componentInfoCbCr.offset);
    int cbCrRowBytes = CFSwapInt32BigToHost(bufferInfo->componentInfoCbCr.rowBytes);

    unsigned char *dataPtr = (unsigned char*)baseAddress;
    unsigned char *rgbaImage = (unsigned char*)malloc(4 * width * height);

    for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
            int ypIndex = yOffset + (x + y * yRowBytes);

            int yp = (int) dataPtr[ypIndex];

            unsigned char* cbCrPtr = dataPtr + cbCrOffset;
            unsigned char* cbCrLinePtr = cbCrPtr + cbCrRowBytes * (y >> 1);

            unsigned char cb = cbCrLinePtr[x & ~1];
            unsigned char cr = cbCrLinePtr[x | 1];

            // YpCbCr to RGB conversion as used in JPEG and MPEG
            // full-range:
            int r = yp                        + 1.402   * (cr - 128);
            int g = yp - 0.34414 * (cb - 128) - 0.71414 * (cr - 128);
            int b = yp + 1.772   * (cb - 128);

            r = MIN(MAX(r, 0), 255);
            g = MIN(MAX(g, 0), 255);
            b = MIN(MAX(b, 0), 255);
            //printf("x/y %d/%d\n", x, y);
            rgbaImage[(x + y * width) * 4] = (unsigned char) b;
            rgbaImage[(x + y * width) * 4 + 1] = (unsigned char) g;
            rgbaImage[(x + y * width) * 4 + 2] = (unsigned char) r;
            rgbaImage[(x + y * width) * 4 + 3] = (unsigned char) 255;
        }
    }

    // Create a device-dependent RGB color space.
    static CGColorSpaceRef colorSpace = NULL;
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace == NULL) {
            // Handle the error appropriately.
            free(rgbaImage);
            return nil;
        }

    }

    // Create a Quartz direct-access data provider that uses data we supply.
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbaImage, 4 * width * height, NULL);

    // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, width * 4,
                                       colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                                       dataProvider, NULL, true, kCGRenderingIntentDefault);

    CGDataProviderRelease(dataProvider);

    // Create and return an image object to represent the Quartz image.
    UIImage *image = [UIImage imageWithCGImage:cgImage];

    // Create base64 String from UIImage
    NSString *base64String = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    CGImageRelease(cgImage);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    free(rgbaImage);

    // Return a String which is easily readable by js side.
    return [@"data:image/png;base64," stringByAppendingString:base64String];
}

@interface SCNBarcodePicker () <SBSScanDelegate, SBSProcessFrameDelegate>

@property (nonatomic) BOOL shouldStop;
@property (nonatomic) BOOL shouldPause;
@property (nonatomic, nullable) NSArray<NSNumber *> *codesToReject;
@property (nonatomic) dispatch_semaphore_t didScanSemaphore;

// MatrixScan
@property (nonatomic) dispatch_semaphore_t didProcessFrameSemaphore;
@property (nonatomic) BOOL matrixScanEnabled;
@property (nonatomic, nullable) NSArray<NSNumber *> *idsToVisuallyReject;
@property (nonatomic, nullable) NSSet<NSNumber *> *lastFrameRecognizedIds;

@end

@implementation SCNBarcodePicker

- (instancetype)init {
    self = [super init];
    if (self) {
        _matrixScanEnabled = NO;
        SBSScanSettings *scanSettings = [SBSScanSettings defaultSettings];
        _picker = [[SBSBarcodePicker alloc] initWithSettings:scanSettings];
        _picker.scanDelegate = self;
        _picker.processFrameDelegate = self;
        _didScanSemaphore = dispatch_semaphore_create(0);
        _didProcessFrameSemaphore = dispatch_semaphore_create(0);
        [self addSubview:_picker.view];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.picker.view.frame = self.bounds;
}

- (void)setScanSettings:(NSDictionary *)dictionary {
    _scanSettings = dictionary;
    NSError *error = nil;
    SBSScanSettings *scanSettings = [SBSScanSettings settingsWithDictionary:dictionary error:&error];
    if (error != nil) {
        RCTLogError(@"Invalid scan settings: %@", error.localizedDescription);
    } else {
        __weak typeof(self)weakSelf = self;
        self.matrixScanEnabled = scanSettings.matrixScanEnabled;
        [self.picker applyScanSettings:scanSettings completionHandler:^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf.onSettingsApplied != nil) {
                NSDictionary *emptyDictionary = [[NSDictionary alloc] init];
                strongSelf.onSettingsApplied(emptyDictionary);
            }
        }];
    }
}

- (void)finishOnScanCallbackShouldStop:(BOOL)shouldStop
                           shouldPause:(BOOL)shouldPause
                         codesToReject:(NSArray<NSNumber *> *)codesToReject {
    self.shouldStop = shouldStop;
    self.shouldPause = shouldPause;
    self.codesToReject = codesToReject;
    dispatch_semaphore_signal(self.didScanSemaphore);
}

- (void)finishOnRecognizeNewCodesShouldStop:(BOOL)shouldStop
                                shouldPause:(BOOL)shouldPause
                        idsToVisuallyReject:(NSArray<NSNumber *> *)idsToVisuallyReject {
    self.shouldStop = shouldStop;
    self.shouldPause = shouldPause;
    self.idsToVisuallyReject = idsToVisuallyReject;
    dispatch_semaphore_signal(self.didProcessFrameSemaphore);
}

- (void)setMatrixScanEnabled:(BOOL)matrixScanEnabled {
    if (_matrixScanEnabled != matrixScanEnabled) {
        _matrixScanEnabled = matrixScanEnabled;
        self.picker.processFrameDelegate = matrixScanEnabled ? self : nil;
    }
}

#pragma mark - SBSScanDelegate

- (void)barcodePicker:(SBSBarcodePicker *)picker didScan:(SBSScanSession *)session {
    if (_matrixScanEnabled) {
        return;
    }
    if (self.onScan) {
        self.onScan(dictionaryFromScanSession(session));
    }
    // Suspend the session thread, until finishOnScanCallbackShouldStop:shouldPause:codesToReject: is called from JS
    dispatch_semaphore_wait(self.didScanSemaphore, DISPATCH_TIME_FOREVER);
    if (self.shouldStop) {
        [session stopScanning];
    } else if (self.shouldPause) {
        [session pauseScanning];
    } else {
        for (NSNumber *index in self.codesToReject) {
            if (index.integerValue == -1) {
                continue;
            }
            SBSCode *code = session.newlyRecognizedCodes[index.integerValue];
            [session rejectCode:code];
        }
        self.codesToReject = nil;
    }
}

#pragma mark - SBSProcessFrameDelegate

- (void)barcodePicker:(nonnull SBSBarcodePicker *)barcodePicker
      didProcessFrame:(nonnull CMSampleBufferRef)frame
              session:(nonnull SBSScanSession *)session {

    // Call `onBarcodeFrameAvailable` only when new codes have been recognized.
    if (self.shouldPassBarcodeFrame && session.newlyRecognizedCodes.count > 0) {
        NSDictionary *processedFrameDictionary = dictionaryFromBase64FrameString(base64StringFromFrame(&frame));
        self.onBarcodeFrameAvailable(processedFrameDictionary);
    }

    if (session.trackedCodes == nil) {
        return;
    }

    NSMutableSet<NSNumber *> *recognizedCodeIds = [NSMutableSet set];
    NSMutableDictionary<NSNumber *, SBSTrackedCode *> *newlyTrackedCodes = [NSMutableDictionary dictionary];

    for (NSNumber *identifier in session.trackedCodes.allKeys) {
        SBSTrackedCode *code = session.trackedCodes[identifier];
        if (code.isRecognized) {
            [recognizedCodeIds addObject:identifier];
            if (self.lastFrameRecognizedIds == nil || ![self.lastFrameRecognizedIds containsObject:identifier]) {
                newlyTrackedCodes[identifier] = code;
            }
        }
    }
    self.lastFrameRecognizedIds = recognizedCodeIds;

    if (newlyTrackedCodes.count > 0) {
        NSDictionary *newCodes = dictionaryFromTrackedCodes(newlyTrackedCodes);
        self.onRecognizeNewCodes(newCodes);

        // Suspend the session thread, until finishOnRecognizeNewCodesShouldStop:shouldPause:idsToVisuallyReject: is called from JS
        dispatch_semaphore_wait(self.didProcessFrameSemaphore, DISPATCH_TIME_FOREVER);
        if (self.shouldStop) {
            [session stopScanning];
        } else if (self.shouldPause) {
            [session pauseScanning];
        } else {
            for (NSNumber *identifier in self.idsToVisuallyReject) {
                SBSTrackedCode *code = session.trackedCodes[identifier];
                [session rejectTrackedCode:code];
            }
            self.idsToVisuallyReject = nil;
        }
    }
}

@end
