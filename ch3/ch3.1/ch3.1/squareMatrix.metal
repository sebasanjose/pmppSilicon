#include <metal_stdlib>
using namespace metal;

// Kernel function to square each element of the matrix
kernel void squareMatrix(
    device int *matrix [[buffer(0)]],  // Input/output matrix
    constant int &width [[buffer(1)]], // Matrix width
    constant int &height [[buffer(2)]], // Matrix height
    uint2 threadPosition [[thread_position_in_grid]]) {
    
    // Get the global row and column indices
    int row = threadPosition.y;
    int col = threadPosition.x;

    // Ensure thread is within matrix bounds
    if (row < height && col < width) {
        int idx = row * width + col; // Convert 2D index to 1D
        matrix[idx] = matrix[idx] * matrix[idx]; // Square the element
    }
}
