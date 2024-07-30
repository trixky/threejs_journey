uniform mat4 projectionMatrix; // input data from javascript (projection matrix)
// clip space: x, y, z, w
uniform mat4 viewMatrix; // input data from javascript (view matrix)
// three.js compute projection and view matrix (camera: rotation, field of view, near, far) and put it in projectionMatrix and viewMatrix
uniform mat4 modelMatrix; // input data from javascript (model matrix)
// three.js compute position/rotation/scale of the object and put it in modelMatrix

// uniform mat4 modelViewMatrix; // modelMatrix * viewMatrix

// built-in functions
// https://shaderific.com/glsl.html
// https://www.khronos.org/registry/OpenGL-Refpages/gl4/html/indexflat.php
// https://thebookofshaders.com/
// sin
// cos
// tan
// min
// max
// pow
// exp
// mod
// clamp
// mix
// cross
// dot
// step
// smoothstep
// length
// distance
// normalize
// reflect
// refract

float loremIpsum(float c) {
    float a = 1.0;
    float b = 2.0;

    return a + b + c;
}

attribute vec3 position; // input data from javascript (position of each vertex)
attribute float aRandom; // input data from javascript (random number) (custom)
varying float vRandom;

void main() {
        // ----------------------------- computation example -----------------------------
    float result = loremIpsum(3.0);
    // float a = 1.0;
    // float b = 2.0;
    // float c = a + b; // * + / -

    // float a = 1.0;
    // int b = 2.0;
    // float c = a + float(b); // * + / -

    // bool d = true;
    // bool e = false;

    // vec2 foo = vec2(1.0, 2.0); // 2d vector
    // vec3 bar1 = vec3(1.0); // 3d vector
    // vec3 bar2 = vec3(1.0, 2.0, 3.0); // 3d vector
    // bar2.z = 4.0; // can use .x, .y, .z, .w or .r, .g, .b, .a
    // vec3 bar3 = vec3(foo, 1.0);
    // vec2 swizzle = bar2.zy; // swizzle

    // ----------------------------- rules -----------------------------
    // gl_FragColor already defined by the system and it's the output color (vec4)
    // attribute is the input data

    // vec4(position, 1.0) transforms the 3d position to 4d position

    // gl_Position =  vec4(position, 1.0);
    // gl_Position = projectionMatrix * viewMatrix * modelMatrix * vec4(position, 1.0);

    vec4 modelPosition = modelMatrix * vec4(position, 1.0);
    // modelPosition.z += sin(modelPosition.x * 10.0) * 0.1;
    modelPosition.z += aRandom * 0.1;
    vec4 viewPosition = viewMatrix * modelPosition;
    vec4 projectionPosition = projectionMatrix * viewPosition;

    gl_Position = projectionPosition;
    vRandom = aRandom; // give the random number to the fragment shader
}
