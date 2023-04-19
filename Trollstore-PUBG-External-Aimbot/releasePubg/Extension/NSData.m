//
//  NSData.m
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/11/28.
//  
//

#import "NSData.h"

@implementation NSData(HeadLineNews)

-(CMBlockBufferRef)cMBlockBuffer {
    NSMutableData *data = [self mutableCopy];
    CMBlockBufferRef buffer;
    CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, (void*)[data bytes], data.length, kCFAllocatorNull, NULL, 0, self.length, 0, &buffer);
    
    return buffer;
}

-(NSStringEncoding)stringEncoding {
    return [NSString stringEncodingForData:self encodingOptions:NULL convertedString:NULL usedLossyConversion:NULL];
}

@end
