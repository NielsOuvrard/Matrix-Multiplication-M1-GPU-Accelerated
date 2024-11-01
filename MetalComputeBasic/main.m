/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An app that performs a simple calculation on a GPU.
*/

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MetalAdder.h"

// This is the C version of the function that the sample
// implements in Metal Shading Language.
void add_arrays(const float* inA,
                const float* inB,
                float* result,
                int length)
{
    for (int index = 0; index < length ; index++)
    {
        result[index] = inA[index] + inB[index];
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();

        // Create the custom object used to encapsulate the Metal code.
        // Initializes objects to communicate with the GPU.
        MetalAdder* adder = [[MetalAdder alloc] initWithDevice:device];
        
        unsigned long arrayLength = 24;

        float a[arrayLength];
        float b[arrayLength];

        for (int i = 0; i < arrayLength; i++)
        {
            a[i] = i * 2.1;
            b[i] = i * 0.3;
        }


        // Create buffers to hold data
        [adder prepareData:a :b :arrayLength];
        
        // Send a command to the GPU to perform the calculation.
        [adder sendComputeCommand:arrayLength];

        NSLog(@"Execution finished");
    }
    return 0;
}
