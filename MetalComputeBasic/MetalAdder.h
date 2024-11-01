/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class to manage all of the Metal objects this app creates.
*/

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalAdder : NSObject
- (instancetype)initWithDevice:(id<MTLDevice>)device;
- (void)prepareData:(float *)array_a:(float *)array_b
                   :(unsigned long)size;
- (void)sendComputeCommand:(unsigned long)size;
@end

NS_ASSUME_NONNULL_END
