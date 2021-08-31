/*
 * Created by Onnowhere (https://github.com/onnowhere)
 * Utility functions for Minecraft core vertex shaders
 */

#define LIGHT0_DIRECTION vec3(0.2, 1.0, -0.7) // Default light 0 direction everywhere except in inventory
#define LIGHT1_DIRECTION vec3(-0.2, 1.0, 0.7) // Default light 1 direction everywhere except in nether and inventory

/*
 * Returns the FOV in degrees
 * Calculates using the fact that top/near = tan(theta / 2)
 */
float getFOV(mat4 ProjMat) {
    return atan(1.0, ProjMat[1][1]) * 114.591559;
}

/*
 * Returns if rendering in a GUI
 * In the GUI, near is 1000 and far is 3000, so -(far+near)/(far-near) = -2.0
 */
bool isGUI(mat4 ProjMat) {
    return ProjMat[3][2] == -2.0;
}

/*
 * Returns if rendering in the main menu background panorama
 * Checks the far clipping plane value so this should only be used with position_tex_color
 */
bool isPanorama(mat4 ProjMat) {
    float far = ProjMat[3][2] / (ProjMat[2][2] + 1);
    return far < 9.99996 && far > 9.99995;
}

/*
 * Returns if rendering in the nether given light directions
 * In the nether, the light directions are parallel but in opposite directions
 */
bool isNether(vec3 light0, vec3 light1) {
    return light0 == -light1;
}

/*
 * Returns camera to world space matrix given light directions
 * Creates matrix by comparing world space light directions to camera space light directions
 */
mat3 getWorldMat(vec3 light0, vec3 light1) {
    if (isNether(light0, light1)) {
        // Cannot determine matrix in the nether due to parallel light directions
        return mat3(0.0);
    }
    mat3 V = mat3(normalize(LIGHT0_DIRECTION), normalize(LIGHT1_DIRECTION), normalize(cross(LIGHT0_DIRECTION, LIGHT1_DIRECTION)));
    mat3 W = mat3(normalize(light0), normalize(light1), normalize(cross(light0, light1)));
    return W * inverse(V);
}

/*
 * Returns far clipping plane distance
 * Evaluates far clipping plane by extracting it from the projection matrix
 */
float getFarClippingPlane(mat4 ProjMat) {
    vec4 distProbe = inverse(ProjMat) * vec4(0.0, 0.0, 1.0, 1.0);
    return length(distProbe.xyz / distProbe.w);
}

/*
 * Returns render distance based on far clipping plane
 * Uses far clipping plane distance to get render distance in chunks
 */
float getRenderDistance(mat4 ProjMat) {
    return round(getFarClippingPlane(ProjMat) / 64.0);
}

/*
 * Returns orthographic transformation matrix
 * Creates matrix by extracting values from projection matrix
 */
mat4 getOrthoMat(mat4 ProjMat, float Zoom) {
    float far = getFarClippingPlane(ProjMat);
    float near = -1000.0; // Avoid clipping distance
    
    float fixed_near = 0.05; // Fixed distance that should never change
    float left = -(0.5 / (ProjMat[0][0] / (2.0 * fixed_near))) / Zoom;
    float right = -left;
    float top = (0.5 / (ProjMat[1][1] / (2.0 * fixed_near))) / Zoom;
    float bottom = -top;

    return mat4(2.0 / (right - left),               0.0,                                0.0,                            0.0,
                0.0,                                2.0 / (top - bottom),               0.0,                            0.0,
                0.0,                                0.0,                                -2.0 / (far - near),            0.0,
                -(right + left) / (right - left),   -(top + bottom) / (top - bottom),   -(far + near) / (far - near),   1.0);
}
