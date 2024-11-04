# Matrix Multiplication Metal Apple Sicicone Accelerated

Use Metal to find GPUs and perform calculations on them.
My goal is to use the GPU to calculate matrices multiplications.

I used the sample code from the Apple Developer "Performing Calculations on a GPU" to understand how to use the Apple Metal framework to perform calculations on the GPU.

```c
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
```

This is a time-consuming operation, and the GPU can perform it much faster than the CPU.

It need:

n \* n² = n³ multiplications

(n - 1) \* n = n² additions

Every value of the matrix `multiplied` is calculated by the GPU in parallel, using this code:

```c
kernel void multiply_ints_arrays(device const int* inA,
                            device const int* inB,
                            device int* result,
                            uint index [[thread_position_in_grid]])
{
    result[index] = inA[index] * inB[index];
}
```

First version:

```shell
./MetalComputeBasic  0.15s user 5.77s system 84% cpu 7.011 total
```

[MTLDevice]: https://developer.apple.com/documentation/metal/mtldevice
[MTLCreateSystemDefaultDevice]: https://developer.apple.com/documentation/metal/1433401-mtlcreatesystemdefaultdevice
[MTLResource]: https://developer.apple.com/documentation/metal/mtlresource
[MTLBuffer]: https://developer.apple.com/documentation/metal/mtlbuffer
[MTLResourceStorageModeShared]: https://developer.apple.com/documentation/metal/mtlresourceoptions/mtlresourcestoragemodeshared
[MTLComputePipelineState]: https://developer.apple.com/documentation/metal/mtlcomputepipelinestate
[maxTotalThreadsPerThreadgroup]: https://developer.apple.com/documentation/metal/mtlcomputepipelinestate/1414927-maxtotalthreadsperthreadgroup
[status]: https://developer.apple.com/documentation/metal/mtlcommandbuffer/1443048-status
[addCompletedHandler]: https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442997-addcompletedhandler
[MTLLibrary]: https://developer.apple.com/documentation/metal/mtllibrary
[MTLFunction]: https://developer.apple.com/documentation/metal/mtlfunction
[HelloTriangle]: https://developer.apple.com/documentation/metal
