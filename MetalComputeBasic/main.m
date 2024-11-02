/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An app that performs a simple calculation on a GPU.
*/

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MetalAdder.h"
#include "Mnist.h"

#define SIZE_X_A 3
#define SIZE_Y_A 2

#define SIZE_X_B 2
#define SIZE_Y_B 3

typedef struct st_matrix {
    int *data;
    int y;
    int x;
} st_matrix;

void multiply_matrix(st_matrix *a, st_matrix *b, MetalAdder *adder, int *result)
{
    for (int i = 0; i < a->y; i++) {
        for (int j = 0; j < b->x; j++) {
            int tmp[b->y];
            for (int k = 0; k < b->y; k++) {
                tmp[k] = b->data[(k * b->x) + j];
            }

            // Create buffers to hold data
            [adder prepareListInt:(a->data + (i * a->x)) :tmp :a->x];
            
            // Send a command to the GPU to perform the calculation.
            [adder sendComputeCommand:a->x :&(result[(i * a->y) + j])];
        }
    }
}

void print_matrix(st_matrix *matrix)
{
    for (int i = 0; i < matrix->x; i++) {
        for (int j = 0; j < matrix->y; j++) {
            printf("%d ", matrix->data[(i * matrix->y) + j]);
        }
        printf("\n");
    }
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();

        // C-style string
        char *functionName = "multiply_ints_arrays";

        // Convert to NSString
        NSString *functionNameNSString = [NSString stringWithUTF8String:functionName];


        // Create the custom object used to encapsulate the Metal code.
        // Initializes objects to communicate with the GPU.
        MetalAdder* adder = [[MetalAdder alloc] initWithDevice:device :functionNameNSString];
        
        // inputs = [ [ 0, 0 ], [ 0, 1 ], [ 1, 0 ], [ 1, 1 ] ]
        // output = [ 0, 0, 0, 1 ]

        
        load_mnist();

        int i;
        for (i=0; i<784; i++) {
            printf("%1.1f ", test_image[0][i]);
            if ((i+1) % 28 == 0) putchar('\n');
        }
        printf("label: %d\n", test_label[0]);

        // int multiplied[matrix_a.y][matrix_b.x];
        // multiply_matrix(&matrix_a, &matrix_b, adder, (int *)multiplied);


        // print_matrix(&(st_matrix){(int *)multiplied, matrix_a.y, matrix_b.x});

        NSLog(@"Execution finished");
    }
    return 0;
}

// TODO
// - Transpose a matrix
// - reshape, from a marix to a list
// - clip ?  limits the values in an array to a specified range
