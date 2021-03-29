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

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float rand(vec3 p) {
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

void main() {
    // Use UV as vertex id order is not guaranteed due to water being double sided with different vertex order on the underside
    vec2 uv = mod(UV0, 16.0/1024.0) * 1024.0/16.0;

    vertexDistance = length((ModelViewMat * vec4(Position + ChunkOffset, 1.0)).xyz);
    vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
    
    vec3 uvOffset = vec3(uv.x, 0.0, uv.y);
    
    if (Normal == vec3(1.0, 0.0, 0.0)) { // Positive X
        uvOffset = vec3(0.0, 1.0 - uv.y, 1.0 - uv.x);
    } else if (Normal == vec3(0.0, 1.0, 0.0)) { // Positive Y
        uvOffset = vec3(uv.x, 0.0, uv.y);
    } else if (Normal == vec3(0.0, 0.0, 1.0)) { // Positive Z
        uvOffset = vec3(uv.x, 1.0 - uv.y, 0.0);
    } else if (Normal == vec3(-1.0, 0.0, 0.0)) { // Negative X
        uvOffset = vec3(0.0, 1.0 - uv.y, uv.x);
    } else if (Normal == vec3(0.0, -1.0, 0.0)) { // Negative Y
        uvOffset = vec3(uv.x, 0.0, 1.0 - uv.y);
    } else if (Normal == vec3(0.0, 0.0, -1.0)) { // Negative Z
        uvOffset = vec3(1.0 - uv.x, 1.0 - uv.y, 0.0);
    }
    
    // Sync random and fade amount between vertices on same face
    float random = rand((Position - uvOffset));
    float fadeAmount = max(0.0, length((ModelViewMat * vec4(Position - uvOffset + vec3(0.5) + ChunkOffset, 1.0)).xyz) - distanceThreshold);
    fadeAmount *= fadeAmount;
    
    float animation = (sin(mod((random + GameTime) * 1600.0, twoPi)) / 8.0) * 0.25;
    float scale = clamp(fadeAmount * (animation + 0.75) * 0.1 / fadeScale, 0.0, 1.0);
    vec3 uvScale = vec3(0.5 - uv.x, 0.0, 0.5 - uv.y) * scale;
    if (Normal == vec3(1.0, 0.0, 0.0)) { // Positive X
        uvScale = vec3(0.0, uv.y - 0.5, uv.x - 0.5) * scale;
    } else if (Normal == vec3(0.0, 1.0, 0.0)) { // Positive Y
        uvScale = vec3(0.5 - uv.x, 0.0, 0.5 - uv.y) * scale;
    } else if (Normal == vec3(0.0, 0.0, 1.0)) { // Positive Z
        uvScale = vec3(0.5 - uv.x, uv.y - 0.5, 0.0) * scale;
    } else if (Normal == vec3(-1.0, 0.0, 0.0)) { // Negative X
        uvScale = vec3(0.0, uv.y - 0.5, 0.5 - uv.x) * scale;
    } else if (Normal == vec3(0.0, -1.0, 0.0)) { // Negative Y
        uvScale = vec3(0.5 - uv.x, 0.0, uv.y - 0.5) * scale;
    } else if (Normal == vec3(0.0, 0.0, -1.0)) { // Negative Z
        uvScale = vec3(uv.x - 0.5, uv.y - 0.5, 0.0) * scale;
    }
    
    // Position with scaling
    if (any(notEqual(mod(Position, vec3(1.0)), vec3(0.0)))) {
        // Don't floor for non full blocks
        gl_Position = ProjMat * ModelViewMat * vec4(Position + uvScale + ChunkOffset, 1.0);
    } else {
        gl_Position = ProjMat * ModelViewMat * vec4(floor(Position) + uvScale + ChunkOffset, 1.0);
    }
    // Position with offset
    gl_Position += normal * fadeAmount * (0.2 / fadeScale * random + animation * 0.04);
    // Disable visibility when out of range
    if (fadeAmount > 15.0 * fadeScale) {
        gl_Position = vec4(100.0, 100.0, 100.0, -1.0);
    }
}
