
Shader "Custom/WaterSimulationShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _WaveA ("Wave A (dir, steepness, wavelength)", Vector) = (1,0,0.5,10)
        _Waves("Number of waves to sum", int) = 4
    }
    SubShader
    {
        
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha fullforwardshadows vertex:vert
        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0
        //#pragma surface surf Standard fullforwardshadows vertex:vert addshadow

        sampler2D _MainTex;


        
        half _Glossiness;
        half _Metallic;
        fixed4 _Color;
        float4 _WaveA;
        float _Waves;
        
      

        float3 GerstnerWave (float4 wave, float3 p, inout float3 tangent, inout float3 binormal) 
        {
		    float steepness = wave.z;
		    float wavelength = wave.w;
            float k = 2 * UNITY_PI / wavelength;
		    float c = sqrt(9.8 / k);
		    float2 d = normalize(wave.xy);
		    float f = k * (dot(d, p.xz) - c * _Time.y);
            float a = steepness / k;
			

		    tangent += float3(
			    -d.x * d.x * (steepness * sin(f)),
			    d.x * (steepness * cos(f)),
                -d.x * d.y * (steepness * sin(f))
			);
			binormal += float3(
			    -d.x * d.y * (steepness * sin(f)),
			    d.y * (steepness * cos(f)),
                -d.y * d.y * (steepness * sin(f))
			);
		    return float3(
			    d.x * (a * cos(f)),
			    a * sin(f),
			    d.y * (a * cos(f))
		    );
		}
        struct Input
        {
            float2 uv_MainTex;
            float3 _Normal;
        };
        void vert(inout appdata_full vertexData, out Input o) 
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            float3 gridPoint = vertexData.vertex.xyz;
			float3 tangent = float3(1, 0, 0);
			float3 binormal = float3(0, 0, 1);
			float3 p = gridPoint;
            float4 nextWave = _WaveA;
            for(int i = 0; i < _Waves; i++)
            {
                float angle = frac(sin(i) * 43758.5453123) * 2.0 * UNITY_PI;
                float2 randomVector = float2(cos(angle), sin(angle));

                p +=  GerstnerWave(nextWave, gridPoint, tangent, binormal);
                nextWave.xy = randomVector;
                nextWave.z *= 0.8;
                nextWave.w *= 0.8;
            }

			vertexData.vertex.xyz = p;
			float3 normal = normalize(cross(binormal, tangent));
			vertexData.normal = normal;

            o._Normal = normal;
        }
        

        UNITY_INSTANCING_BUFFER_START(Props) UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input i, inout SurfaceOutputStandard o)
        {
            float4 c = tex2D (_MainTex, i.uv_MainTex) * _Color;
         
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        } 
        ENDCG
    }
    FallBack "Diffuse"
}
