Shader "Custom/UnityChanClothingURP"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _ShadowColor ("Shadow Color", Color) = (0.8, 0.8, 1, 1)

        _SpecularPower ("Specular Power", Float) = 20
        _EdgeThickness ("Outline Thickness", Float) = 1

        _MainTex ("Diffuse", 2D) = "white" {}
        _FalloffSampler ("Falloff Control", 2D) = "white" {}
        _RimLightSampler ("RimLight Control", 2D) = "white" {}
        _SpecularReflectionSampler ("Specular / Reflection Mask", 2D) = "white" {}
        _EnvMapSampler ("Environment Map", 2D) = "" {}
        _NormalMapSampler ("Normal Map", 2D) = "" {}

        _NormalStrength ("Normal Strength", Range(0, 2)) = 1
        _Cull ("Cull Mode", Float) = 2
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "ForwardLit"

            Tags
            {
                "LightMode" = "UniversalForward"
            }

            Cull [_Cull]
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
                float4 tangentOS  : TANGENT;
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;

                float2 uv : TEXCOORD0;

                float3 positionWS : TEXCOORD1;
                float3 normalWS   : TEXCOORD2;
                float3 tangentWS  : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            TEXTURE2D(_FalloffSampler);
            SAMPLER(sampler_FalloffSampler);

            TEXTURE2D(_NormalMapSampler);
            SAMPLER(sampler_NormalMapSampler);

            CBUFFER_START(UnityPerMaterial)

                float4 _Color;
                float4 _MainTex_ST;
                float _NormalStrength;

            CBUFFER_END

            Varyings Vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs =
                    GetVertexPositionInputs(input.positionOS.xyz);

                output.positionHCS =
                    positionInputs.positionCS;

                output.positionWS =
                    positionInputs.positionWS;

                VertexNormalInputs normalInputs =
                    GetVertexNormalInputs(
                        input.normalOS,
                        input.tangentOS
                    );

                output.normalWS =
                    normalInputs.normalWS;

                output.tangentWS =
                    normalInputs.tangentWS;

                output.bitangentWS =
                    normalInputs.bitangentWS;

                output.uv =
                    TRANSFORM_TEX(input.uv, _MainTex);

                return output;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                // Diffuse texture
                half4 baseColor =
                    SAMPLE_TEXTURE2D(
                        _MainTex,
                        sampler_MainTex,
                        input.uv
                    );

                // Normal Map
                half4 normalSample =
                    SAMPLE_TEXTURE2D(
                        _NormalMapSampler,
                        sampler_NormalMapSampler,
                        input.uv
                    );

                half3 normalTS =
                    UnpackNormalScale(
                        normalSample,
                        _NormalStrength
                    );

                half3x3 tangentToWorld =
                    half3x3(
                        normalize(input.tangentWS),
                        normalize(input.bitangentWS),
                        normalize(input.normalWS)
                    );

                half3 normalWS =
                    normalize(
                        TransformTangentToWorld(
                            normalTS,
                            tangentToWorld
                        )
                    );

                half3 viewDirection =
                    GetWorldSpaceNormalizeViewDir(input.positionWS);
                
                half normalDotEye =
                    dot(normalWS, viewDirection);

                half falloffU =
                    clamp(
                        1.0 - abs(normalDotEye),
                        0.02,
                        0.98
                    );

                half4 falloffColor =
                    SAMPLE_TEXTURE2D(
                        _FalloffSampler,
                        sampler_FalloffSampler,
                        float2(falloffU, 0.25)
                    );

                falloffColor *= 0.3;

                // URP Main Light
                Light mainLight = GetMainLight();

                half NdotL =
                    saturate(
                        dot(
                            normalWS,
                            mainLight.direction
                        )
                    );

                // 간단한 기본 조명
                half3 lighting =
                    mainLight.color *
                    (NdotL * 0.5 + 0.5);

                half3 shadowColor =
                    baseColor.rgb * baseColor.rgb;

                half3 combinedColor =
                    lerp(
                        baseColor.rgb,
                        shadowColor,
                        falloffColor.r
                    );

                combinedColor *=
                    1.0 +
                    falloffColor.rgb *
                    falloffColor.a;

                half3 finalColor =
                    combinedColor *
                    _Color.rgb *
                    lighting;

                return half4(
                    finalColor,
                    baseColor.a * _Color.a
                );
            }

            ENDHLSL
        }
    }
}