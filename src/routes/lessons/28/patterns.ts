import testVertexShader from "$lib/shaders/patterns/vertex.glsl"
import testFragmentShader1 from "$lib/shaders/patterns/fragment_1.glsl"
import testFragmentShader2 from "$lib/shaders/patterns/fragment_2.glsl"
import testFragmentShader3 from "$lib/shaders/patterns/fragment_3.glsl"
import testFragmentShader4 from "$lib/shaders/patterns/fragment_4.glsl"
import testFragmentShader5 from "$lib/shaders/patterns/fragment_5.glsl"
import testFragmentShader6 from "$lib/shaders/patterns/fragment_6.glsl"
import testFragmentShader7 from "$lib/shaders/patterns/fragment_7.glsl"
import testFragmentShader8 from "$lib/shaders/patterns/fragment_8.glsl"
import testFragmentShader9 from "$lib/shaders/patterns/fragment_9.glsl"
import testFragmentShader10 from "$lib/shaders/patterns/fragment_10.glsl"
import testFragmentShader11 from "$lib/shaders/patterns/fragment_11.glsl"
import testFragmentShader12 from "$lib/shaders/patterns/fragment_12.glsl"
import testFragmentShader13 from "$lib/shaders/patterns/fragment_13.glsl"
import testFragmentShader14 from "$lib/shaders/patterns/fragment_14.glsl"
import testFragmentShader15 from "$lib/shaders/patterns/fragment_15.glsl"
import testFragmentShader16 from "$lib/shaders/patterns/fragment_16.glsl"
import testFragmentShader17 from "$lib/shaders/patterns/fragment_17.glsl"
import testFragmentShader18 from "$lib/shaders/patterns/fragment_18.glsl"
import testFragmentShader19 from "$lib/shaders/patterns/fragment_19.glsl"
import testFragmentShader20 from "$lib/shaders/patterns/fragment_20.glsl"
import testFragmentShader21 from "$lib/shaders/patterns/fragment_21.glsl"
import testFragmentShader22 from "$lib/shaders/patterns/fragment_22.glsl"
import testFragmentShader23 from "$lib/shaders/patterns/fragment_23.glsl"
import testFragmentShader24 from "$lib/shaders/patterns/fragment_24.glsl"
import testFragmentShader25 from "$lib/shaders/patterns/fragment_25.glsl"
import testFragmentShader26 from "$lib/shaders/patterns/fragment_26.glsl"
import testFragmentShader27 from "$lib/shaders/patterns/fragment_27.glsl"
import testFragmentShader28 from "$lib/shaders/patterns/fragment_28.glsl"
import testFragmentShader29 from "$lib/shaders/patterns/fragment_29.glsl"
import testFragmentShader30 from "$lib/shaders/patterns/fragment_30.glsl"
import testFragmentShader31 from "$lib/shaders/patterns/fragment_31.glsl"
import testFragmentShader32 from "$lib/shaders/patterns/fragment_32.glsl"
import testFragmentShader33 from "$lib/shaders/patterns/fragment_33.glsl"
import testFragmentShader34 from "$lib/shaders/patterns/fragment_34.glsl"
import testFragmentShader35 from "$lib/shaders/patterns/fragment_35.glsl"
import testFragmentShader36 from "$lib/shaders/patterns/fragment_36.glsl"
import testFragmentShader37 from "$lib/shaders/patterns/fragment_37.glsl"
import testFragmentShader38 from "$lib/shaders/patterns/fragment_38.glsl"
import testFragmentShader39 from "$lib/shaders/patterns/fragment_39.glsl"
import testFragmentShader40 from "$lib/shaders/patterns/fragment_40.glsl"
import testFragmentShader41 from "$lib/shaders/patterns/fragment_41.glsl"
import testFragmentShader42 from "$lib/shaders/patterns/fragment_42.glsl"
import testFragmentShader43 from "$lib/shaders/patterns/fragment_43.glsl"
import testFragmentShader44 from "$lib/shaders/patterns/fragment_44.glsl"
import testFragmentShader45 from "$lib/shaders/patterns/fragment_45.glsl"
import testFragmentShader46 from "$lib/shaders/patterns/fragment_46.glsl"
import testFragmentShader47 from "$lib/shaders/patterns/fragment_47.glsl"
import testFragmentShader48 from "$lib/shaders/patterns/fragment_48.glsl"
import testFragmentShader49 from "$lib/shaders/patterns/fragment_49.glsl"
import testFragmentShader50 from "$lib/shaders/patterns/fragment_50.glsl"

import * as THREE from "three";

export default function generatePatterns(): THREE.Mesh<THREE.PlaneGeometry, THREE.ShaderMaterial, THREE.Object3DEventMap>[] {
    const fragmentShaders = [
        testFragmentShader1,
        testFragmentShader2,
        testFragmentShader3,
        testFragmentShader4,
        testFragmentShader5,
        testFragmentShader6,
        testFragmentShader7,
        testFragmentShader8,
        testFragmentShader9,
        testFragmentShader10,
        testFragmentShader11,
        testFragmentShader12,
        testFragmentShader13,
        testFragmentShader14,
        testFragmentShader15,
        testFragmentShader16,
        testFragmentShader17,
        testFragmentShader18,
        testFragmentShader19,
        testFragmentShader20,
        testFragmentShader21,
        testFragmentShader22,
        testFragmentShader23,
        testFragmentShader24,
        testFragmentShader25,
        testFragmentShader26,
        testFragmentShader27,
        testFragmentShader28,
        testFragmentShader29,
        testFragmentShader30,
        testFragmentShader31,
        testFragmentShader32,
        testFragmentShader33,
        testFragmentShader34,
        testFragmentShader35,
        testFragmentShader36,
        testFragmentShader37,
        testFragmentShader38,
        testFragmentShader39,
        testFragmentShader40,
        testFragmentShader41,
        testFragmentShader42,
        testFragmentShader43,
        testFragmentShader44,
        testFragmentShader45,
        testFragmentShader46,
        testFragmentShader47,
        testFragmentShader48,
        testFragmentShader49,
        testFragmentShader50,
    ];

    const meshes = [];

    const geometry = new THREE.PlaneGeometry(1, 1, 32, 32);
    for (const fragmentShader of fragmentShaders) {
        // Geometry

        // Material
        // Because we use ShaderMaterial instead of RawShaderMaterial,
        // we have uv/position attributes and uv attribute is automatically created
        const material = new THREE.ShaderMaterial({
            vertexShader: testVertexShader,
            fragmentShader: fragmentShader,
            side: THREE.DoubleSide,
        });

        // Mesh
        meshes.push(new THREE.Mesh(geometry, material));
    }

    return meshes;
}
