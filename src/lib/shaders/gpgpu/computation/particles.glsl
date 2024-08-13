// uniform sampler2D uParticles; // already imported automatically

uniform float uTimes;
uniform float uDeltaTime;
uniform float uFlowFieldInfluence;
uniform float uFlowFieldStrength;
uniform float uFlowFieldFrequency;

uniform sampler2D uBase;

#include ../simplexNoise4d.glsl;

void main() {
    float time = uTimes * 0.2;
    vec2 uv = gl_FragCoord.xy / resolution.xy;
    vec4 particle = texture(uParticles, uv);
    vec4 base = texture(uBase, uv);

    // Dead
    if(particle.a >= 1.0) {
        particle.a = mod(particle.a, 1.0); // Fix the bug when user leave and comeback to the page
        particle.xyz = base.xyz;
    } else {
        // Strength
        float strength = simplexNoise4d(vec4(base.xyz * 0.2, time + 1.));
        float influence = (uFlowFieldInfluence - 0.5) * 2.;
        strength = smoothstep(influence, 1.0, strength);

        // Flow field
        vec3 flowField = vec3(simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 0.0, time)), simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 1.0, time)), simplexNoise4d(vec4(particle.xyz * uFlowFieldFrequency + 2.0, time)));

        flowField = normalize(flowField);
        particle.xyz += flowField * uDeltaTime * strength * uFlowFieldStrength;

        // Decay
        particle.a += 0.3 * uDeltaTime;
    }

    gl_FragColor = particle;
}