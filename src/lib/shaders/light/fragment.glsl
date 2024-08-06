uniform vec3 uColor;

varying vec3 vNormal;
varying vec3 vPosition;

#include ./includes/ambiant_light.glsl
#include ./includes/directional_light.glsl
#include ./includes/point_light.glsl


void main() {
    vec3 normal = normalize(vNormal);
    // remove artifacts by normalize the normal
    vec3 color = uColor;
    vec3 viewDirection = normalize(vPosition - cameraPosition);

    vec3 light = vec3(0.0);
    light += ambiantLight(vec3(1.0), 0.03);
    light += directionalLight(vec3(0.1, 0.1, 1.0), 1., normal, vec3(0., 0., 3.), viewDirection, 20.);
    light += pointLight(vec3(1.0, 0.1, 0.1), 1., normal, vec3(0., 2.5, 0.), viewDirection, 20., vPosition, 0.25);
    light += pointLight(vec3(0.1, 1.0, 0.5), 1., normal, vec3(2., 2., 2.), viewDirection, 20., vPosition, 0.25);
    color *= light;

    // Final color
    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}