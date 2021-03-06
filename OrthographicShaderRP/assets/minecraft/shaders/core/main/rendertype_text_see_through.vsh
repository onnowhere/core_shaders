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
in vec2 UV2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord2;

void main() {
    // Skip GUI
    if (!isGUI(ProjMat)) {
        mat4 OrthoMat = getOrthoMat(ProjMat, ZOOM);
        gl_Position = OrthoMat * ModelViewMat * vec4(Position, 1.0);
    } else {
        gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    }

    vertexColor = Color;
    texCoord0 = UV0;
    texCoord2 = UV2;
}
