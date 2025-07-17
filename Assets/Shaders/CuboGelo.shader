Shader "Unlit/CuboGelo"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _BumpMap ("Normal Map", 2D) = "bump" {}
        _FresnelColor ("Edge Color", Color) = (0.5, 0.7, 1.0, 1.0)
        _EdgeThickness ("Edge Power", Range(0.1, 5)) = 2.0
        _RefractionAmt ("Refraction Strength", Range(0, 0.1)) = 0.02
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }
        LOD 200
        Cull Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD3;
            };

            sampler2D _MainTex;
            sampler2D _BumpMap;
            float4 _FresnelColor;
            float _EdgeThickness;
            float _RefractionAmt;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                o.viewDir = normalize(_WorldSpaceCameraPos - o.worldPos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb;
                fixed3 n = UnpackNormal(tex2D(_BumpMap, i.uv));
                float fresnel = pow(1.0 - saturate(dot(i.viewDir, i.worldNormal)), _EdgeThickness);
                fresnel = saturate(fresnel * 0.8); // Reduz exagero
                fixed3 edge = fresnel * _FresnelColor.rgb;
                float2 offset = n.xy * _RefractionAmt;
                fixed3 col = tex2D(_MainTex, i.uv + offset).rgb;
                return fixed4(col + edge, 1.0);
            }

            ENDCG
        }
    }

    FallBack "Transparent/VertexLit"
}
