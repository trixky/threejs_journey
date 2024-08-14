varying vec3 vPosition;

void main() {
    // Varying
    vPosition = csm_Position.xyz; // csm_Position is before the rotation transformation
}