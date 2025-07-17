// Upgrade NOTE: commented out 'float3 _WorldSpaceCameraPos', a built-in variable

Shader "Unlit/Cubo"
{
    Properties
    {
        _CubeMap ("Environment Cubemap", CUBE) = "" {}
        _TintColor ("Tint Color", Color) = (0.7,0.85,1,0.3)
        _Glossiness ("Glossiness", Range(0,1)) = 0.8
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            samplerCUBE _CubeMap;
            float4 _TintColor;
            float _Glossiness;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                UNITY_FOG_COORDS(2)
            };

            // float3 _WorldSpaceCameraPos;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                UNITY_TRANSFER_FOG(o,o.pos);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // Normaliza
                float3 N = normalize(i.worldNormal);
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);

                // Reflexão do vetor view sobre a normal
                float3 R = reflect(-V, N);

                // Amostra o environment map com o vetor refletido
                float4 reflectedColor = texCUBE(_CubeMap, R);

                // Fresnel simples (Schlick's approximation)
                float fresnel = pow(1.0 - saturate(dot(V, N)), 5);

                // Combina o reflexo com a cor do vidro (tint)
                float4 color = lerp(_TintColor, reflectedColor, fresnel);

                // Transparência controlada pela alpha do tint
                color.a = _TintColor.a;

                UNITY_APPLY_FOG(i.fogCoord, color);

                return color;
            }
            ENDCG
        }
    }
}
