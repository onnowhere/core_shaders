#version 150

#moj_import <vsh_util.glsl>
#moj_import <ortho_config.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat4 TextureMat;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

void main() {
    // Skip GUI
    if (!isGUI(ProjMat)) {
        mat4 OrthoMat = getOrthoMat(ProjMat, ZOOM);
        gl_Position = OrthoMat * ModelViewMat * vec4(Position, 1.0);
    } else {
        gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    }

    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    vertexColor = Color;
    texCoord0 = (TextureMat * vec4(UV0, 0.0, 1.0)).xy;
}
