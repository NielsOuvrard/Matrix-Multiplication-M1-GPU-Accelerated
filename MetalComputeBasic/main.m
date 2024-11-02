/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An app that performs a simple calculation on a GPU.
*/

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MetalAdder.h"

#define SIZE_2 3
#define SIZE_1 2

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();

        // C-style string
        char *functionName = "multiply_ints_arrays";

        // Convert to NSString
        NSString *functionNameNSString = [NSString stringWithUTF8String:functionName];




        // Create the custom object used to encapsulate the Metal code.
        // Initializes objects to communicate with the GPU.
        MetalAdder* adder = [[MetalAdder alloc] initWithDevice:device :functionNameNSString];
        
        int a[SIZE_1][SIZE_2] = {
            {1, 2, 3},
            {4, 5, 6}
        };
        int b[SIZE_2][SIZE_1] = {
            {7, 8},
            {9, 10},
            {11, 12}
        };

        int tmp[SIZE_2];

        for (int i = 0; i < SIZE_1; i++) {
            int result_line;
            for (int j = 0; j < SIZE_2; j++) {
                tmp[j] = b[j][i];
            }

            // Create buffers to hold data
            [adder prepareListInt:a[i] :tmp :SIZE_2];
            
            // Send a command to the GPU to perform the calculation.
            [adder sendComputeCommand:SIZE_2 :&result_line];

            printf("array a * b R=%d result =%d\n", i, result_line);
        }



        NSLog(@"Execution finished");
    }
    return 0;
}
