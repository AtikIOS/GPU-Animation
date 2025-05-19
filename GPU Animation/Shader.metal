//
//  Shader.metal
//  NoteBook Project
//
//  Created by Atik Hasan on 5/19/25.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

fragment float4 sandShader(VertexOut in [[stage_in]],
                           texture2d<float> inputTexture [[texture(0)]],
                           constant float2 &drag [[buffer(0)]],
                           constant float &intensity [[buffer(1)]]) {
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    float2 uv = in.texCoord;

    float dist = distance(uv * float2(300.0, 300.0), drag);
    float effect = sin(dist * intensity * 50.0) * 0.02;

    uv.x += effect;
    uv.y += effect;

    return inputTexture.sample(textureSampler, uv);
}



vertex VertexOut vertex_passthrough(uint vertexID [[vertex_id]]) {
    float2 positions[4] = {
        float2(-1.0, -1.0),
        float2( 1.0, -1.0),
        float2(-1.0,  1.0),
        float2( 1.0,  1.0)
    };

    float2 uvs[4] = {
        float2(0.0, 1.0),
        float2(1.0, 1.0),
        float2(0.0, 0.0),
        float2(1.0, 0.0)
    };

    VertexOut out;
    out.position = float4(positions[vertexID], 0.0, 1.0);
    out.texCoord = uvs[vertexID];
    return out;
}
