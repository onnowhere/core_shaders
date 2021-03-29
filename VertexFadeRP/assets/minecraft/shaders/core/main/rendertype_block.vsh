#version 150

#moj_import <vertex_fade.glsl>
#moj_import <light.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;
uniform float GameTime;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 normal;

#define pi 3.141592653589793238
#define twoPi 6.283185307179586 // pi * 2
#define halfPi 1.570796326794896619 // pi / 2

float rand(vec3 co) {
    return fract(sin(dot(co.xyz, vec3(12.9898,78.233,144.7272))) * 43758.5453);
}

mat3 rotationMatrix(vec3 axis, float angle) {
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

void main() {
    vertexDistance = length((ModelViewMat * vec4(Position + ChunkOffset, 1.0)).xyz);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
    
    // Rotate to Positive Z direction
    float vertexId = mod(gl_VertexID, 4.0);
    vec3 fractPosition = Position; // Positive Z
    if (abs(Normal) == vec3(1.0, 0.0, 0.0)) { // Positive/Negative X
        fractPosition *= rotationMatrix(Normal.zxy, -halfPi); // Rotate around Y axis
    } else if (abs(Normal) == vec3(0.0, 1.0, 0.0)) { // Positive/Negative Y
        fractPosition *= rotationMatrix(Normal.yzx, halfPi); // Rotate around X axis
    } else if (Normal == vec3(0.0, 0.0, -1.0)) { // Positive/Negative Y
        fractPosition *= rotationMatrix(Normal.yzx, -pi); // Rotate around Y axis
    }
    fractPosition = fract(fractPosition);

    // Positive Z
    vec3 originOffset = vec3(0.5, 0.5, 0.0);
    // Apply offsetting for fractional positions
    if (fractPosition.x > 0.001 && fractPosition.x < 0.999) { originOffset.x = 0.5 - fractPosition.x; }
    if (fractPosition.y > 0.001 && fractPosition.y < 0.999) { originOffset.y = 0.5 - fractPosition.y; }
    
    // Correct offsetting for integer positions
    if (vertexId == 0.0 && originOffset.y == 0.5) { originOffset.y *= -1.0; }
    else if (vertexId == 2.0 && originOffset.x == 0.5) { originOffset.x *= -1.0; }
    else if (vertexId == 3.0) {
        if (originOffset.x == 0.5) { originOffset.x *= -1.0; }
        if (originOffset.y == 0.5) { originOffset.y *= -1.0; }
    }
    
    // Rotate back to original direction
    if (abs(Normal) == vec3(1.0, 0.0, 0.0)) { // Positive/Negative X
        originOffset *= rotationMatrix(Normal.zxy, halfPi);
    } else if (abs(Normal) == vec3(0.0, 1.0, 0.0)) { // Positive/Negative Y
        originOffset *= rotationMatrix(Normal.yzx, -halfPi);
    } else if (Normal == vec3(0.0, 0.0, -1.0)) { // Negative Z
        originOffset *= rotationMatrix(Normal.yzx, pi);
    }
    
    // Sync random and fade amount between vertices on same face
    float random = rand((Position + originOffset) / 100.0);
    float fadeAmount = max(0.0, length((ModelViewMat * vec4(Position + originOffset + ChunkOffset, 1.0)).xyz) - distanceThreshold);
    fadeAmount *= fadeAmount;
    
    float animation = (sin(mod((random + GameTime) * 1600.0, twoPi)) / 8.0) * 0.25;
    float scale = clamp(fadeAmount * (animation + 0.75) * 0.1 / fadeScale, 0.0, 1.0);

    // Position with scaling
    gl_Position = ProjMat * ModelViewMat * vec4(Position + scale * originOffset + ChunkOffset, 1.0);
    // Position with offset
    gl_Position += normal * fadeAmount * (0.2 / fadeScale * random + animation * 0.04);
    // Disable visibility when out of range
    if (fadeAmount > 15.0 * fadeScale) {
        gl_Position = vec4(100.0, 100.0, 100.0, -1.0);
    }
}
