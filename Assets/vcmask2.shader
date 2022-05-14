Shader "Custom/vcmask2"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MainTex2("Albedo (RGB)", 2D) = "white" {}
        _MainTex3("Albedo (RGB)", 2D) = "white" {}
        _MainTex4("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard noambient

        sampler2D _MainTex;
        sampler2D _MainTex2;
        sampler2D _MainTex3;
        sampler2D _MainTex4;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_MainTex2;
            float2 uv_MainTex3;
            float2 uv_MainTex4;
            float4 color:COLOR;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 d = tex2D(_MainTex2, IN.uv_MainTex2);
            fixed4 e = tex2D(_MainTex3, IN.uv_MainTex3);
            fixed4 f = tex2D(_MainTex4, IN.uv_MainTex4);

            /*
                vcmask ���� �ߴ� ��ó�� lerp() ��� cg ���̴� �����Լ��� �̿��ؼ�
                4���� �ؽ��ĸ� Vertex Color �� ����� FBX �𵨿� ����ŷ����.
                -> �̷� ������� ��Ƽ �ؽ��ĸ��� �����߾���!

                ������, lerp() �Լ���
                GLSL ���� �ٸ� ���̴� ������ mix() ��� �̸���
                ��Ȯ�� ������ ����� �����ϴ� �����Լ��� ������.
            */
            o.Albedo = lerp(c.rgb, d.rgb, IN.color.r);
            o.Albedo = lerp(o.Albedo, e.rgb, IN.color.g);
            o.Albedo = lerp(o.Albedo, f.rgb, IN.color.b);
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}