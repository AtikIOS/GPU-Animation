//
//  ViewController.swift
//  GPU Animation
//
//  Created by Atik Hasan on 5/19/25.
//

import UIKit
import MetalKit
import simd

class ViewController: UIViewController {
    
    var metalView: MTKView!
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var texture: MTLTexture!
    
    var displayLink: CADisplayLink!
    var angle: CGFloat = 0
    var drag = SIMD2<Float>(0, 0)
    var intensity: Float = 0.03
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMetal()
        setupDisplayLink()
    }
    
    func setupMetal() {
        device = MTLCreateSystemDefaultDevice()
        metalView = MTKView(frame: CGRect(x: 0, y: 0, width: 360, height: 360), device: device)
        metalView.center = view.center
        metalView.clearColor = MTLClearColorMake(0.6, 0.45, 0.3, 1) // Background
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.delegate = self
        view.addSubview(metalView)
        
        commandQueue = device.makeCommandQueue()
        
        let library = device.makeDefaultLibrary()
        let vertexFunc = library?.makeFunction(name: "vertex_passthrough")
        let fragmentFunc = library?.makeFunction(name: "sandShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunc
        pipelineDescriptor.fragmentFunction = fragmentFunc
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        
        texture = loadTexture(imageName: "sample")
    }
    
    func setupDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateAnimation))
        displayLink.add(to: .main, forMode: .default)
    }
    
    @objc func updateAnimation() {
        angle += 0.01
        drag = SIMD2<Float>(
            Float(180 + cos(angle) * 100),
            Float(180 + sin(angle) * 100)
        )
        metalView.setNeedsDisplay()
    }
    
    func loadTexture(imageName: String) -> MTLTexture? {
        guard let image = UIImage(named: imageName)?.cgImage else { return nil }
        let textureLoader = MTKTextureLoader(device: device)
        return try? textureLoader.newTexture(cgImage: image, options: nil)
    }
}

extension ViewController: MTKViewDelegate {
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
              let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        encoder.setRenderPipelineState(pipelineState)
        
        encoder.setFragmentTexture(texture, index: 0)
        encoder.setFragmentBytes(&drag, length: MemoryLayout<SIMD2<Float>>.size, index: 0)
        encoder.setFragmentBytes(&intensity, length: MemoryLayout<Float>.size, index: 1)
        
        encoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
}


// Others Animation :
/*
  1. Wavy/oscillating motion
 drag = SIMD2<Float>(
 Float(180 + sin(angle * 2) * 100),
 Float(180)
 )
 
  2. Linear back-and-forth motion
 drag = SIMD2<Float>(
 Float(180 + sin(angle) * 100),
 Float(180)
 )
 
 diagonal
 drag = SIMD2<Float>(
 Float(180 + sin(angle) * 100),
 Float(180 + sin(angle) * 100)
 )
 
 
  3. Spiral motion
 let radius = angle * 10
 drag = SIMD2<Float>(
 Float(180 + cos(angle) * radius),
 Float(180 + sin(angle) * radius)
 )
 
  4. Pulsing center effect (no movement, but intensity changes)
 intensity = 0.02 + 0.01 * sin(angle * 4)
 
  5. Random glitchy effect
 drag = SIMD2<Float>(
 Float(arc4random_uniform(360)),
 Float(arc4random_uniform(360))
 )
 
 
 Bonus: Combine animations
 drag = SIMD2<Float>(
 Float(180 + cos(angle) * 50 + sin(angle * 3) * 25),
 Float(180 + sin(angle) * 50)
 )
 intensity = 0.02 + 0.01 * sin(angle * 2)
 
 
 */





