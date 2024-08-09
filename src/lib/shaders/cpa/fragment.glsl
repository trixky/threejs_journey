varying vec3 vColor;

void main()
{
    vec2 uv = gl_PointCoord;
    float distanceCenter = distance(uv, vec2(0.5));

    if (distanceCenter > 0.5)
        discard; // Don't render the outer part of the circle (sharp)
    // discard can have a performance impact, but it's negligible in this case

    gl_FragColor = vec4(vColor, 1.0);

    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}