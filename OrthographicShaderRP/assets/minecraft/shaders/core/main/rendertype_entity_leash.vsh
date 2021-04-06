/*
 * Created by Onnowhere (https://github.com/onnowhere)
 * Orthographic core vertex shader
 */

#version 150

#moj_import <vsh_util.glsl>
#moj_import <ortho_config.glsl>

in vec3 Position;
in vec4 Color;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec4 ColorModulator;

out float vertexDistance;
flat out vec4 vertexColor;

void main() {
    mat4 OrthoMat = getOrthoMat(ProjMat, ZOOM);
    gl_Position = OrthoMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    vertexColor = Color * ColorModulator * texelFetch(Sampler2, UV2 / 16, 0);
}
