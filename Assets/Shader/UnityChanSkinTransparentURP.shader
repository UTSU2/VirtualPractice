Shader "Custom/UnityChanSkinTransparentURP"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
        _ShadowColor ("Shadow Color", Color) = (0.8, 0.8, 1, 1)
        _EdgeThickness ("Outline Thickness", Float) = 1

        _MainTex ("Diffuse", 2D) = "white" {}
        _FalloffSampler ("Falloff Control", 2D) = "white" {}
        _RimLightSampler ("RimLight Control", 2D) = "white" {}
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent+1"
        }

        Pass
        {
            Name "Forward"

            Tags
            {
                "LightMode" = "UniversalForward"
            }
            
            Blend SrcAlpha OneMinusSrcAlpha, One One

            Cull Back
            ZWrite Off
            ZTest LEqual

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_FalloffSampler);
            SAMPLER(sampler_FalloffSampler);

            TEXTURE2D(_RimLightSampler);
            SAMPLER(sampler_RimLightSampler);

            CBUFFER_START(UnityPerMaterial)
                float4 _Color;
                float4 _ShadowColor;
                float4 _MainTex_ST;
                float _EdgeThickness;
            CBUFFER_END

            Varyings Vert(Attributes input)
            {
                Varyings output;

                VertexPositionInputs positionInputs =
                    GetVertexPositionInputs(input.positionOS.xyz);

                VertexNormalInputs normalInputs =
                    GetVertexNormalInputs(input.normalOS);

                output.positionHCS = positionInputs.positionCS;
                output.positionWS = positionInputs.positionWS;
                output.normalWS = normalInputs.normalWS;

                output.uv =
                    TRANSFORM_TEX(input.uv, _MainTex);

                return output;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                half4 diffuse = SAMPLE_TEXTURE2D(
                    _MainTex,
                    sampler_MainTex,
                    input.uv
                );

                half3 normalWS =
                    normalize(input.normalWS);

                half3 viewDirection =
                    GetWorldSpaceNormalizeViewDir(
                        input.positionWS
                    );

                Light mainLight =
                    GetMainLight();

                // -------------------------
                // Falloff
                // -------------------------

                half normalDotEye =
                    dot(normalWS, viewDirection);

                half falloffU =
                    clamp(
                        1.0 - abs(normalDotEye),
                        0.02,
                        0.98
                    );

                half4 falloff =
                    SAMPLE_TEXTURE2D(
                        _FalloffSampler,
                        sampler_FalloffSampler,
                        float2(falloffU, 0.25)
                    );

                half3 combinedColor =
                    lerp(
                        diffuse.rgb,
                        falloff.rgb * diffuse.rgb,
                        falloff.a
                    );

                // -------------------------
                // Rim Light
                // -------------------------

                half rimDot =
                    saturate(
                        0.5 *
                        (
                            dot(
                                normalWS,
                                mainLight.direction
                            ) + 1.0
                        )
                    );

                half rimU =
                    saturate(
                        rimDot * falloffU
                    );

                half rim =
                    SAMPLE_TEXTURE2D(
                        _RimLightSampler,
                        sampler_RimLightSampler,
                        float2(rimU, 0.25)
                    ).r;

                combinedColor +=
                    rim * diffuse.rgb * 0.5;

                // Main Light 색
                combinedColor *=
                    mainLight.color;

                return half4(
                    combinedColor,
                    diffuse.a
                ) * _Color;
            }

            ENDHLSL
        }
    }
}