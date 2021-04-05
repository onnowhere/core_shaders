#version 150

#moj_import <vsh_util.glsl>
#moj_import <ortho_config.glsl>

in vec3 Position;
in vec2 UV0;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec2 texCoord0;
out vec4 vertexColor;

void main() {
    // Skip Main Menu and GUI
    if (!isPanorama(ProjMat) && !isGUI(ProjMat)) {
        mat4 OrthoMat = getOrthoMat(ProjMat, ZOOM);
        gl_Position = OrthoMat * ModelViewMat * vec4(Position, 1.0);
    } else {
        gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    }

    texCoord0 = UV0;
    vertexColor = Color;
}
