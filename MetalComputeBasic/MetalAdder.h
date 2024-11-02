/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class to manage all of the Metal objects this app creates.
*/

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalAdder : NSObject
- (instancetype)initWithDevice:(id<MTLDevice>)device:(NSString *)function_name;
- (void)prepareListInt:(int *)array_a:(int *)array_b
                      :(unsigned long)size;
- (void)prepareListFloat:(float *)array_a:(float *)array_b
                        :(unsigned long)size;
- (void)sendComputeCommand:(unsigned long)size:(int *)result;
@end

NS_ASSUME_NONNULL_END
