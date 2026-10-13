
Shader "Custom/BlueprintOutline"
{
    Properties
    {
        [HDR] _OutlineColor ("Outline Glow Colour", Color) = (0, 2, 4, 1)
        _OutlineWidth ("Outline Width", Range(0.001, 0.05)) = 0.008
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
            Name "Outline"
            Cull Front
            ZWrite Off
            ZTest LEqual

            HLSLPROGRAM

            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4 _OutlineColor;
                float _OutlineWidth;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
            };

            Varyings Vert(Attributes input)
            {
                Varyings output;

                float4 positionCS =
                    TransformObjectToHClip(input.positionOS.xyz);

                float3 normalOS = normalize(input.normalOS);

                float4 normalPointCS =
                    TransformObjectToHClip(
                        input.positionOS.xyz + normalOS
                    );

                float2 normalCS =
                    normalPointCS.xy - positionCS.xy;

                float lengthNormal = length(normalCS);

                if (lengthNormal > 0.00001)
                {
                    normalCS /= lengthNormal;

                    positionCS.xy +=
                        normalCS * _OutlineWidth * positionCS.w;
                }

                output.positionHCS = positionCS;

                return output;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                return _OutlineColor;
            }

            ENDHLSL
        }
    }
}
