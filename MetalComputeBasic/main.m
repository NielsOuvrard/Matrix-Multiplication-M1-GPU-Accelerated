/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An app that performs a simple calculation on a GPU.
*/

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MetalAdder.h"

#define SIZE_X_A 3
#define SIZE_Y_A 2

#define SIZE_X_B 2
#define SIZE_Y_B 3

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
        
        int a[SIZE_Y_A][SIZE_X_A] = {
            {1, 2, 3},
            {4, 5, 6}
        };
        int b[SIZE_Y_B][SIZE_X_B] = {
            {7, 8},
            {9, 10},
            {11, 12}
        };

        int multiplied[SIZE_Y_A][SIZE_X_B];


        for (int i = 0; i < SIZE_Y_A; i++) {
            for (int j = 0; j < SIZE_X_B; j++) {
                int tmp[SIZE_Y_B];
                for (int k = 0; k < SIZE_Y_B; k++) {
                    tmp[k] = b[k][j];
                }

                // Create buffers to hold data
                [adder prepareListInt:a[i] :tmp :SIZE_X_A];
                
                // Send a command to the GPU to perform the calculation.
                [adder sendComputeCommand:SIZE_X_A :&(multiplied[i][j])];
            }
        }

        // print
        for (int i = 0; i < SIZE_Y_A; i++) {
            for (int j = 0; j < SIZE_X_B; j++) {
                printf("%d ", multiplied[i][j]);
            }
            printf("\n");
        }
        NSLog(@"Execution finished");
    }
    return 0;
}
