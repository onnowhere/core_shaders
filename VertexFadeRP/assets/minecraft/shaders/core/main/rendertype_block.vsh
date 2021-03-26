#version 150

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

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec4 normal;

float mod289(float x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 mod289(vec4 x){return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec4 perm(vec4 x){return mod289(((x * 34.0) + 1.0) * x);}

float rand(vec3 p){
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
    gl_Position = ProjMat * ModelViewMat * vec4(Position + ChunkOffset, 1.0);
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
    
    float distanceThreshold = 12.0;
    float blockDistance = max(0.0, length((ModelViewMat * vec4(Position - uvOffset + vec3(0.5) + ChunkOffset, 1.0)).xyz) - distanceThreshold);
    blockDistance *= blockDistance;
    
    float scale = clamp(blockDistance * 0.1, 0.0, 1.0);
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

    gl_Position = ProjMat * ModelViewMat * vec4(floor(Position) + uvScale + ChunkOffset, 1.0);
    gl_Position += normal * blockDistance * 0.2 * rand(Position - uvOffset);
    if (blockDistance > 10.0) {
        gl_Position = vec4(0.0);
    }
}
