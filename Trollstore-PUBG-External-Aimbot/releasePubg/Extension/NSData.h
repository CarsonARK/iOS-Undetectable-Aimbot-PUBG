//
//  NSData.h
//  HeadLineNews-Objc
//
//  Created by p-x9 on 2021/11/28.
//  
//

#import <Foundation/Foundation.h>
#import <AVKit/AVKit.h>

@interface NSData(HeadLineNews)
-(CMBlockBufferRef)cMBlockBuffer;
-(NSStringEncoding)stringEncoding;
@end
