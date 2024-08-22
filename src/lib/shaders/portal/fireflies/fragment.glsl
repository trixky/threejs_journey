#define STRENGTH_FACTOR 0.05
#define STRENGTH_REDUCER STRENGTH_FACTOR * 2.

void main() {
    float distanceToCenter = distance(gl_PointCoord, vec2(0.5));
    float strength = STRENGTH_FACTOR / distanceToCenter - STRENGTH_REDUCER ;

    gl_FragColor = vec4(1.0, 1.0, 1.0, strength);
}