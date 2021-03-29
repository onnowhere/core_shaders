#version 150

#moj_import <vertex_fade.glsl>
#moj_import <light.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform float GameTime;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec4 normal;

#define twoPi 6.283185307179586

void main() {
    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    float fadeAmount = max(0.0, vertexDistance - distanceThreshold);
    fadeAmount *= fadeAmount;
    
    float animation = (sin(mod(GameTime * 1600.0, twoPi)) / 8.0) * 0.25;
    float scale = clamp(fadeAmount * (animation + 0.75) * 0.1 / fadeScale, 0.0, 1.0);

    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    // Skip inventory items
    if (ProjMat[3][2] / (ProjMat[2][2] + 1) >= 0.0) {
        // Position with offset
        gl_Position += normal * fadeAmount * (0.1 / fadeScale + animation * 0.04);
        // Disable visibility when out of range
        if (fadeAmount > 15.0 * fadeScale) {
            gl_Position = vec4(100.0, 100.0, 100.0, -1.0);
        }
    }
}
