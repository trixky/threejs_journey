// #define PI = 3.14159265359; // already defined in the engine three.js

varying vec3 vPosition;

uniform float uSliceStart;
uniform float uSliceArc;

void main() {
    float angle = atan(vPosition.y, vPosition.x);
    angle -= uSliceStart;
    angle = mod(angle, PI2); // negative values are allowed in glsl for mod (not in js)

    if(angle > 0.0 && angle < uSliceArc)
        discard;

    // -------------------------- can't use it
    // if(!gl_FrontFacing)
    //     csm_FragColor = vec4(vec3(angle), 1.0);
    // problem: if csm_FragColor is called, all gl_FragColor are ignored/replaced by csm_FragColor

    float csm_Slice; // Dont forget to declare it for activate the patchmap
}