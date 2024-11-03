/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class to manage all of the Metal objects this app creates.
*/

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "matrix_type.h"

NS_ASSUME_NONNULL_BEGIN

@interface MetalAdder : NSObject

- (instancetype) initWithDevice: (id<MTLDevice>) device : (NSString *) functionName;
- (void) multiply_matrix_direct_buffer: (st_matrix *) matrixA : (st_matrix *) matrixB : (double[]) result;
- (void) prepareListDouble: (double *) arrayA : (double *) arrayB : (unsigned int) j : (unsigned long) size;
- (void) prepareListInt: (int *) arrayA : (int *) size : (unsigned long) size;
- (void) prepareListFloat: (float *) arrayA : (float *) size : (unsigned long) size;
- (void) sendComputeCommand: (unsigned long) size : (double *) result;
@end

NS_ASSUME_NONNULL_END
