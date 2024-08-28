Shader "Custom/MyWater"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        a ("Amplitude", float) = 0
        s ("Speed", float) = 1
        k ("WaveLength", float) = 0
        
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha fullforwardshadows vertex:vertexShader
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float a, s, k;
       
        void vertexShader(inout appdata_full vertexData)
        {
            //float c = s * 2/k;
            float w = (2 * UNITY_PI)/k;
            float3 pos = vertexData.vertex.xyz;
            pos.y = a * sin(pos.x * w + _Time.y * s);
            vertexData.vertex.xyz = pos;

            float3 tan = float3(1, cos(pos.x * w + _Time.y * s), 0);
            vertexData.normal = float3(-tan.y, tan.x, 0);
        }

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
