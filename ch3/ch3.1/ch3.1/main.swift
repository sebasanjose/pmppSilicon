import MetalKit

// Define the matrix dimensions
let width = 6
let height = 4
let matrixSize = width * height

// Initialize the matrix with values 1 to width*height
var matrix: [Int] = Array(1...matrixSize)

// Setup Metal
guard let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue(),
      let library = device.makeDefaultLibrary(),
      let kernelFunction = library.makeFunction(name: "squareMatrix"),
      let computePipeline = try? device.makeComputePipelineState(function: kernelFunction) else {
    fatalError("Metal setup failed")
}

// Create Metal buffers
let matrixBuffer = device.makeBuffer(bytes: matrix, length: matrixSize * MemoryLayout<Int>.stride, options: .storageModeShared)!
var widthBuffer = width
var heightBuffer = height
let widthBufferPointer = device.makeBuffer(bytes: &widthBuffer, length: MemoryLayout<Int>.stride, options: .storageModeShared)!
let heightBufferPointer = device.makeBuffer(bytes: &heightBuffer, length: MemoryLayout<Int>.stride, options: .storageModeShared)!

// Create a command buffer
guard let commandBuffer = commandQueue.makeCommandBuffer(),
      let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {
    fatalError("Command buffer setup failed")
    
}

// Configure thread execution
let threadsPerThreadgroup = MTLSize(width: 2, height: 2, depth: 1) // 2x2 threads per threadgroup
let threadgroupsPerGrid = MTLSize(
    width: (width + threadsPerThreadgroup.width - 1) / threadsPerThreadgroup.width,
    height: (height + threadsPerThreadgroup.height - 1) / threadsPerThreadgroup.height,
    depth: 1
)

// Set up compute encoder
computeEncoder.setComputePipelineState(computePipeline)
computeEncoder.setBuffer(matrixBuffer, offset: 0, index: 0)
computeEncoder.setBuffer(widthBufferPointer, offset: 0, index: 1)
computeEncoder.setBuffer(heightBufferPointer, offset: 0, index: 2)

// Dispatch the threadgroups
computeEncoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)

// End encoding and commit the command buffer
computeEncoder.endEncoding()
commandBuffer.commit()
commandBuffer.waitUntilCompleted()

// Retrieve the result
let resultPointer = matrixBuffer.contents().bindMemory(to: Int.self, capacity: matrixSize)
let resultMatrix = Array(UnsafeBufferPointer(start: resultPointer, count: matrixSize))

// Print the result
print("Squared Matrix:")
for row in 0..<height {
    let startIndex = row * width
    let endIndex = startIndex + width
    print(resultMatrix[startIndex..<endIndex].map { String($0) }.joined(separator: " "))
}
