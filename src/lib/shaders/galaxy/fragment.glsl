varying vec3 vColor;

void main() {
    // gl_PointCoord is provided for us by WebGL for the particles

    // Disc
    // vec2 centerdPointCoord = gl_PointCoord - 0.5;
    // float pointDistance = length(centerdPointCoord);
    // float reversedDistance = 1.0 - pointDistance;
    // float strength = step(0.5, reversedDistance);

    // Diffuse
    // float strength = distance(gl_PointCoord, vec2(0.5));
    // strength *= 2.;
    // strength = 1. - strength;

    // Light point
    float strength = distance(gl_PointCoord, vec2(0.5));
    strength = 1.0 - strength;
    strength = pow(strength, 20.0);

    // Add Color
    vec3 finalColor = strength * vec3(vColor);

    gl_FragColor = vec4(finalColor, 1.0);
    // #include <colorspace_fragment>
}