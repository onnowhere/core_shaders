/*
 * Created by Onnowhere (https://github.com/onnowhere)
 * Orthographic core vertex shader
 */

#version 150

#moj_import <vsh_util.glsl>

in vec3 Position;
in vec4 Color;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out vec4 vertexColor;

void main() {
    // Skip GUI
    if (!isGUI(ProjMat)) {
        // Disable lower hemisphere skybox overlay
        gl_Position = vec4(100.0, 100.0, 100.0, -1.0);
    } else {
        gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    }

    vertexColor = Color;
}
