/*
 * Created by Onnowhere (https://github.com/onnowhere)
 * Orthographic core vertex shader
 */

#version 150

#moj_import <vsh_util.glsl>
#moj_import <ortho_config.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in vec2 UV2;
in vec3 Normal;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;

void main() {
    mat4 OrthoMat = getOrthoMat(ProjMat, ZOOM);
    gl_Position = OrthoMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    vertexColor = Color;
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = OrthoMat * ModelViewMat * vec4(Normal, 0.0);
}
