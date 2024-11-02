/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An app that performs a simple calculation on a GPU.
*/

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import "MetalAdder.h"
#include "Mnist.h"

#define SIZE_IMAGE 28

typedef struct st_matrix {
    double *data;
    int y;
    int x;
} st_matrix;

void multiply_matrix(st_matrix *a, st_matrix *b, MetalAdder *adder, double result[])
{
    for (int i = 0; i < a->y; i++) {
        for (int j = 0; j < b->x; j++) {
            double tmp[b->y];
            for (int k = 0; k < b->y; k++) {
                tmp[k] = b->data[(k * b->x) + j];
            }

            // Create buffers to hold data
            [adder prepareListDouble:(a->data + (i * a->x)) :tmp :a->x];
            
            // Send a command to the GPU to perform the calculation.
            [adder sendComputeCommand:a->x :&(result[(i * a->y) + j])];
        }
    }
}

void print_matrix(st_matrix *matrix)
{
    for (int i = 0; i < matrix->x * matrix->y; i++) {
        printf("%1.1f ", matrix->data[i]);
        if ((i + 1) % matrix->y == 0)
            printf("\n");
    }
}

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        load_mnist();

        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        MetalAdder* adder = [[MetalAdder alloc] initWithDevice:device :@"multiply_floats_arrays"];

        st_matrix first = {test_image[0], SIZE_IMAGE, SIZE_IMAGE};
        st_matrix second = {test_image[1], SIZE_IMAGE, SIZE_IMAGE};

        double output_result[SIZE];
        multiply_matrix(&first, &second, adder, output_result);


        print_matrix(&(st_matrix){output_result, SIZE_IMAGE, SIZE_IMAGE});

        NSLog(@"Execution finished");
    }
    return 0;
}

// TODO
// - Transpose a matrix
// - reshape, from a marix to a list
// - clip ?  limits the values in an array to a specified range
