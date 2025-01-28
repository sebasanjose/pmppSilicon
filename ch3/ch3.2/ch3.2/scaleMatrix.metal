//
//  scaleMatrix.metal
//  ch3.2
//
//  Created by Sebastian Juarez on 1/28/25.
//

#include <metal_stdlib>
using namespace metal;

// Kernel function to scale each matrix element by 2
kernel void scaleMatrix(
    device int *matrix [[buffer(0)]],  // Input/Output matrix
    constant int &width [[buffer(1)]], // Matrix width
    constant int &height [[buffer(2)]], // Matrix height
    uint2 threadPosition [[thread_position_in_grid]]) {

    // Extract row and column indices
    int row = threadPosition.y;
    int col = threadPosition.x;

    // Ensure thread is within valid matrix bounds
    if (row < height && col < width) {
        int idx = row * width + col; // Convert (row, col) to 1D index
        matrix[idx] *= 2;  // Scale value by 2
    }
}
