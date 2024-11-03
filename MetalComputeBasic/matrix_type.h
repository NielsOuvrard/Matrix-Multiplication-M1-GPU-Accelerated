//
//  matrix_type.h
//  MetalComputeBasic
//
//  Created by Niels Ouvrard on 03/11/2024.
//  Copyright © 2024 Apple. All rights reserved.
//


#define SIZE_IMAGE 28

typedef struct st_matrix {
    double *data;
    int y;
    int x;
} st_matrix;
