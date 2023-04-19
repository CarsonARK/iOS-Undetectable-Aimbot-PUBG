//
//  UIImage.m
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/11/28.
//  
//

#import "UIImage.h"
#import "NSData.h"

@implementation UIImage(HeadLineNews)
-(CMSampleBufferRef)cmSampleBuffer {
    return [self sampleBufferFromJPEGData:UIImageJPEGRepresentation(self, 1)];
}
-(CMSampleBufferRef)sampleBufferFromJPEGData:(NSData*)jpegData {
    CGImageRef cgImage = self.CGImage;
    CMFormatDescriptionRef format;
    CMVideoFormatDescriptionCreate(kCFAllocatorDefault, kCMVideoCodecType_JPEG, (int32_t)CGImageGetWidth(cgImage), (int32_t)CGImageGetHeight(cgImage), nil, &format);
    
    CMSampleTimingInfo timingInfo;
    timingInfo.decodeTimeStamp = CMTimeMake(1, 60);
    timingInfo.presentationTimeStamp = CMTimeMake(CACurrentMediaTime(), 60);
    timingInfo.duration = kCMTimeInvalid;
    
    CMSampleBufferRef sampleBuffer;
    size_t size = jpegData.length * 8;
    CMSampleBufferCreateReady(kCFAllocatorDefault, [jpegData cMBlockBuffer], format, 1, 1, &timingInfo, 1, &size, &sampleBuffer);
    
    return sampleBuffer;
}

@end
