varying vec3 vPosition;
varying vec3 vNormal;

uniform float uTime;
uniform vec3 uColor;
uniform float uStripeNumber;
uniform float uStripeSpeed;
uniform float uSharpness;

void main() {
    vec3 normal = normalize(vNormal);
    // because the normal is interpolated, it will not be awlays normalized (1.0)
    // that remove artifacts
    if(!gl_FrontFacing) {
        normal = -normal;
        // remove depth write in three js to remove glitch
        // add blending in three js to addition the front and back face
    }

    // Stripes
    float stripes = mod((vPosition.y - uTime * uStripeSpeed) * uStripeNumber, 1.0);
    stripes = pow(stripes, 3.0);

    // Fresnel
    vec3 viewDirection = normalize(vPosition - cameraPosition);
    float fresnel = dot(viewDirection, normal) + 1.0;
    fresnel = pow(fresnel, uSharpness);

    // Fall off
    float falloff = smoothstep(0.8, 0.0, fresnel);

    // Holographic
    float holographic = fresnel * stripes;
    holographic += fresnel * 1.25;
    holographic *= falloff;

    gl_FragColor = vec4(uColor, holographic);
    // gl_FragColor = vec4(normal, 1.0);

    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}