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
        
        int a[SIZE_Y_A][SIZE_X_A] = {
            {1, 2, 3},
            {4, 5, 6}
        };
        st_matrix matrix_a = {(int *)a, SIZE_Y_A, SIZE_X_A};
        int b[SIZE_Y_B][SIZE_X_B] = {
            {7, 8},
            {9, 10},
            {11, 12}
        };
        st_matrix matrix_b = {(int *)b, SIZE_Y_B, SIZE_X_B};

        int multiplied[matrix_a.y][matrix_b.x];
        multiply_matrix(&matrix_a, &matrix_b, adder, (int *)multiplied);


        print_matrix(&(st_matrix){(int *)multiplied, matrix_a.y, matrix_b.x});

        NSLog(@"Execution finished");
    }
    return 0;
}
