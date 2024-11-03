/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class to manage all of the Metal objects this app creates.
*/

#import "MetalAdder.h"
#include "matrix_type.h"

// The number of floats in each array, and the size of the arrays in bytes.
const unsigned int arrayLength = 1 << 24;
const unsigned int bufferSize = arrayLength * sizeof(float);

@implementation MetalAdder
{
    id<MTLDevice> _mDevice;

    // The compute pipeline generated from the compute kernel in the .metal shader file.
    id<MTLComputePipelineState> _mAddFunctionPSO;

    // The command queue used to pass commands to the device.
    id<MTLCommandQueue> _mCommandQueue;

    // Buffers to hold data.
    id<MTLBuffer> _mBufferA;
    id<MTLBuffer> _mBufferB;
    id<MTLBuffer> _mBufferResult;

}

- (instancetype) initWithDevice: (id<MTLDevice>) device : (NSString *) functionName
{
    self = [super init];
    if (self)
    {
        _mDevice = device;

        NSError* error = nil;

        // Load the shader files with a .metal file extension in the project

        id<MTLLibrary> defaultLibrary = [_mDevice newDefaultLibrary];
        if (defaultLibrary == nil)
        {
            NSLog(@"Failed to find the default library.");
            return nil;
        }

        id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:functionName];
        if (addFunction == nil)
        {
            NSLog(@"Failed to find the adder function.");
            return nil;
        }

        // Create a compute pipeline state object.
        _mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction: addFunction error:&error];
        if (_mAddFunctionPSO == nil)
        {
            //  If the Metal API validation is enabled, you can find out more information about what
            //  went wrong.  (Metal API validation is enabled by default when a debug build is run
            //  from Xcode)
            NSLog(@"Failed to created pipeline state object, error %@.", error);
            return nil;
        }

        _mCommandQueue = [_mDevice newCommandQueue];
        if (_mCommandQueue == nil)
        {
            NSLog(@"Failed to find the command queue.");
            return nil;
        }
    }

    return self;
}


// void multiply_matrix(st_matrix *a, st_matrix *b, MetalAdder *adder, double result[])

- (void) multiply_matrix_direct_buffer: (st_matrix *) matrixA : (st_matrix *) matrixB : (double[]) result
{
    for (unsigned int i = 0; i < matrixA->y; i++) {
        for (unsigned int j = 0; j < matrixB->x; j++) {

            // Create buffers to hold data
            [self prepareListDouble:(matrixA->data + (i * matrixA->x)) :matrixB->data :j :matrixA->x];
            
            // Send matrixA command to the GPU to perform the calculation.
            [self sendComputeCommand:matrixA->x :&(result[(i * matrixA->y) + j])];
        }
    }
}

- (void) prepareListFloat: (float*) array_a : (float*) array_b : (unsigned long) size
{
    // Allocate three buffers to hold our initial data and the result.
    _mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];

    float* dataPtrA = _mBufferA.contents;
    float* dataPtrB = _mBufferB.contents;

    for (unsigned long index = 0; index < size; index++)
    {
        dataPtrA[index] = array_a[index];
        dataPtrB[index] = array_b[index];
    }
}


- (void) prepareListInt: (int *) array_a : (int *) array_b : (unsigned long) size
{
    // Allocate three buffers to hold our initial data and the result.
    _mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];

    int* dataPtrA = _mBufferA.contents;
    int* dataPtrB = _mBufferB.contents;

    for (unsigned long index = 0; index < size; index++)
    {
        dataPtrA[index] = array_a[index];
        dataPtrB[index] = array_b[index];
    }
}

- (void) prepareListDouble: (double *) array_a : (double *) array_b : (unsigned int) j : (unsigned long) size
{
    // Allocate three buffers to hold our initial data and the result.
    _mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];

    double* dataPtrA = _mBufferA.contents;
    double* dataPtrB = _mBufferB.contents;

    for (unsigned long index = 0; index < size; index++)
    {
        dataPtrA[index] = array_a[index];
        dataPtrB[index] = array_b[(index * size) + j];
    }
}

- (void) sendComputeCommand: (unsigned long) size : (double *) result
{
    // Create a command buffer to hold commands.
    id<MTLCommandBuffer> commandBuffer = [_mCommandQueue commandBuffer];
    assert(commandBuffer != nil);

    // Start a compute pass.
    id<MTLComputeCommandEncoder> computeEncoder = [commandBuffer computeCommandEncoder];
    assert(computeEncoder != nil);

    [self encodeAddCommand:computeEncoder];

    // End the compute pass.
    [computeEncoder endEncoding];

    // Execute the command.
    [commandBuffer commit];

    // Normally, you want to do other work in your app while the GPU is running,
    // but in this example, the code simply blocks until the calculation is complete.
    [commandBuffer waitUntilCompleted];

    [self writeResultsDoubles:size :result];
}

- (void)encodeAddCommand:(id<MTLComputeCommandEncoder>)computeEncoder {

    // Encode the pipeline state object and its parameters.
    [computeEncoder setComputePipelineState:_mAddFunctionPSO];
    [computeEncoder setBuffer:_mBufferA offset:0 atIndex:0];
    [computeEncoder setBuffer:_mBufferB offset:0 atIndex:1];
    [computeEncoder setBuffer:_mBufferResult offset:0 atIndex:2];

    MTLSize gridSize = MTLSizeMake(arrayLength, 1, 1);

    // Calculate a threadgroup size.
    NSUInteger threadGroupSize = _mAddFunctionPSO.maxTotalThreadsPerThreadgroup;
    if (threadGroupSize > arrayLength)
    {
        threadGroupSize = arrayLength;
    }
    MTLSize threadgroupSize = MTLSizeMake(threadGroupSize, 1, 1);

    // Encode the compute command.
    [computeEncoder dispatchThreads:gridSize
              threadsPerThreadgroup:threadgroupSize];
}

// - (void) generateRandomFloatData: (id<MTLBuffer>) buffer
// {
//     float* dataPtr = buffer.contents;

//     for (unsigned long index = 0; index < arrayLength; index++)
//     {
//         dataPtr[index] = (float)rand()/(float)(RAND_MAX);
//     }
// }

- (void) verifyResultsFloats: (unsigned long) size
{
    float* a = _mBufferA.contents;
    float* b = _mBufferB.contents;
    float* result = _mBufferResult.contents;

    for (unsigned long index = 0; index < size; index++)
    {
        if (result[index] != (a[index] + b[index]))
        {
            printf("Compute ERROR: index=%lu result=%g vs %g=a+b\n",
                   index, result[index], a[index] + b[index]);
            assert(result[index] == (a[index] + b[index]));
        }
    }
    printf("Compute results as expected\n");
}

- (void) writeResultsInts: (unsigned long) size : (int *) result
{
    int* resultBuffer = _mBufferResult.contents;

    (*result) = 0;
    for (unsigned long index = 0; index < size; index++) {
        (*result) += resultBuffer[index];
    }
}

- (void) writeResultsDoubles: (unsigned long) size : (double *) result
{
    double* resultBuffer = _mBufferResult.contents;

    (*result) = 0;
    for (unsigned long index = 0; index < size; index++) {
        (*result) += resultBuffer[index];
    }
}

@end
