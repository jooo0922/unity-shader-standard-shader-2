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
            질감을 더욱 사실적으로 표현하려면 '스펙큘러' 를 추가해줘야 함.
            스펙큘러를 추가하려면 스탠다드 셰이더 구조체에서 
            Metallic 과 Smoothness 프로퍼티에 값을 추가하면 됨.

            이 값을 유니티 인터페이스로 받기 위해
            해당 값을 슬라이더로 받는 Property 를 추가함.
        */
        _Metallic("Metallic", Range(0, 1)) = 0
        _Smoothness("Smoothness", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard // 스펙큘러 추가 시 주변 환경광 반사를 적용해야 더 예쁘게 나와서 noambient 키워드는 삭제함. 

        /*
            지금 노말맵 인터페이스를 추가하고,
            o.Normal 에 UnpackNormal() 내장함수로 노말맵 텍셀값을
            계산하여 리턴받은 float3 값을 할당하는 로직만 추가해줘도,
            p.240 에 설명되어 있는 에러가 발생하고 있음.

            즉, 현재의 셰이더 코드가
            셰이더 2.0 버전에서 연산할 수 있는 텍스쳐 선형보간 수준을
            넘어선 복잡하고 무거운 연산이 추가되었다는 의미임.

            이럴 경우, 원래 boilerplate 코드에서 지워놨던
            '#pragma target 3.0' 을 되살리면 해결됨.

            단, 이럴 경우 셰이더 2.0까지만 지원하는
            디바이스에서는 돌아가지 못할것임.

            그런데 최근 대부분의 PC 및 모바일에서는
            3.0 버전의 셰이더를 지원하지 못하는 디바이스를
            찾는 게 더 어려울 정도이기 때문에
            target 3.0 을 지우지 않고 놔둬도 크게 문제될 건 없음.

            따라서, 이제부터는 연산이 좀 복잡하고 무거워질 예정이므로,
            필요에 따라 target 3.0 버전으로 셰이더 코드를 작성할 필요가 있음.
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
                vcmask 에서 했던 것처럼 lerp() 라는 cg 셰이더 내장함수를 이용해서
                4장의 텍스쳐를 Vertex Color 가 적용된 FBX 모델에 마스킹해줌.
                -> 이런 방식으로 멀티 텍스쳐링을 구현했었지!

                참고로, lerp() 함수는
                GLSL 같은 다른 셰이더 언어에서는 mix() 라는 이름의
                정확히 동일한 기능을 수행하는 내장함수가 존재함.
            */
            o.Albedo = lerp(c.rgb, d.rgb, IN.color.r);
            o.Albedo = lerp(o.Albedo, e.rgb, IN.color.g);
            o.Albedo = lerp(o.Albedo, f.rgb, IN.color.b);

            // 첫번째 standard-shader 예제에서 했던 것처럼
            // 노말맵의 텍셀값을 UnpackNormal() 내장함수로 계산하여 스탠다드 쉐이더 구조체의 Normal 프로퍼티에 할당해 줌!
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

            // 스펙큘러를 추가해 노말맵이 적용된 질감을 더욱 사실적으로 표현하기 위해
            // 스탠다드 쉐이더 구조체의 Metallic, Smoothness 프로퍼티에 인터페이스로부터 받은 값을 할당해 줌.
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;

            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
