varying vec2 vUv; // Let's give uv to the fragment shader

#define PI 3.1415926535897932384626433832795

vec2 rotate(vec2 uv, float rotation, vec2 mid)
{
    return vec2(
      cos(rotation) * (uv.x - mid.x) + sin(rotation) * (uv.y - mid.y) + mid.x,
      cos(rotation) * (uv.y - mid.y) - sin(rotation) * (uv.x - mid.x) + mid.y
    );
}

void main() {
    vec2 rotatedUv = rotate(vUv, PI / 4.0, vec2(0.5));

    vec2 stretchVUvX = vec2(rotatedUv.x * 0.1 + 0.45, rotatedUv.y * 0.5 + 0.25);
    vec2 stretchVUvY = vec2(rotatedUv.y * 0.1 + 0.45, rotatedUv.x * 0.5 + 0.25);
    float gradX = 0.015 / length(stretchVUvX - 0.5);
    float gradY = 0.015 / length(stretchVUvY - 0.5);
    float gradXY = gradX * gradY;
    float gradReversePoint =  gradXY;

    vec3 grad3 = vec3(gradReversePoint);

    gl_FragColor = vec4(grad3, 1.0);
}