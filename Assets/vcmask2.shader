Shader "Custom/vcmask2"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MainTex2("Albedo (RGB)", 2D) = "white" {}
        _MainTex3("Albedo (RGB)", 2D) = "white" {}
        _MainTex4("Albedo (RGB)", 2D) = "white" {}
        _BumpMap("Normalmap", 2D) = "bump" {}

        /*
            ������ ���� ��������� ǥ���Ϸ��� '����ŧ��' �� �߰������ ��.
            ����ŧ���� �߰��Ϸ��� ���Ĵٵ� ���̴� ����ü���� 
            Metallic �� Smoothness ������Ƽ�� ���� �߰��ϸ� ��.

            �� ���� ����Ƽ �������̽��� �ޱ� ����
            �ش� ���� �����̴��� �޴� Property �� �߰���.
        */
        _Metallic("Metallic", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard // ����ŧ�� �߰� �� �ֺ� ȯ�汤 �ݻ縦 �����ؾ� �� ���ڰ� ���ͼ� noambient Ű����� ������. 

        /*
            ���� �븻�� �������̽��� �߰��ϰ�,
            o.Normal �� UnpackNormal() �����Լ��� �븻�� �ؼ�����
            ����Ͽ� ���Ϲ��� float3 ���� �Ҵ��ϴ� ������ �߰����൵,
            p.240 �� ����Ǿ� �ִ� ������ �߻��ϰ� ����.

            ��, ������ ���̴� �ڵ尡
            ���̴� 2.0 �������� ������ �� �ִ� �ؽ��� �������� ������
            �Ѿ �����ϰ� ���ſ� ������ �߰��Ǿ��ٴ� �ǹ���.

            �̷� ���, ���� boilerplate �ڵ忡�� ��������
            '#pragma target 3.0' �� �ǻ츮�� �ذ��.

            ��, �̷� ��� ���̴� 2.0������ �����ϴ�
            ����̽������� ���ư��� ���Ұ���.

            �׷��� �ֱ� ��κ��� PC �� ����Ͽ�����
            3.0 ������ ���̴��� �������� ���ϴ� ����̽���
            ã�� �� �� ����� �����̱� ������
            target 3.0 �� ������ �ʰ� ���ֵ� ũ�� ������ �� ����.

            ����, �������ʹ� ������ �� �����ϰ� ���ſ��� �����̹Ƿ�,
            �ʿ信 ���� target 3.0 �������� ���̴� �ڵ带 �ۼ��� �ʿ䰡 ����.
        */
        #pragma target 3.0 

        sampler2D _MainTex;
        sampler2D _MainTex2;
        sampler2D _MainTex3;
        sampler2D _MainTex4;
        sampler2D _BumpMap;
        float _Metallic;
        float _Smoothness;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_MainTex2;
            float2 uv_MainTex3;
            float2 uv_MainTex4;
            float2 uv_BumpMap;
            float4 color:COLOR;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 d = tex2D (_MainTex2, IN.uv_MainTex2);
            fixed4 e = tex2D (_MainTex3, IN.uv_MainTex3);
            fixed4 f = tex2D (_MainTex4, IN.uv_MainTex4);

            /*
                vcmask ���� �ߴ� ��ó�� lerp() ��� cg ���̴� �����Լ��� �̿��ؼ�
                4���� �ؽ��ĸ� Vertex Color �� ����� FBX �𵨿� ����ŷ����.
                -> �̷� ������� ��Ƽ �ؽ��ĸ��� �����߾���!

                �����, lerp() �Լ���
                GLSL ���� �ٸ� ���̴� ������ mix() ��� �̸���
                ��Ȯ�� ������ ����� �����ϴ� �����Լ��� ������.
            */
            o.Albedo = lerp(c.rgb, d.rgb, IN.color.r);
            o.Albedo = lerp(o.Albedo, e.rgb, IN.color.g);
            o.Albedo = lerp(o.Albedo, f.rgb, IN.color.b);

            // ù��° standard-shader �������� �ߴ� ��ó��
            // �븻���� �ؼ����� UnpackNormal() �����Լ��� ����Ͽ� ���Ĵٵ� ���̴� ����ü�� Normal ������Ƽ�� �Ҵ��� ��!
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

            // ����ŧ���� �߰��� �븻���� ����� ������ ���� ��������� ǥ���ϱ� ����
            // ���Ĵٵ� ���̴� ����ü�� Metallic, Smoothness ������Ƽ�� �������̽��κ��� ���� ���� �Ҵ��� ��.
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;

            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
