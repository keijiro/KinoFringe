//
// KinoFringe - Chromatic aberration effect
//
// Copyright (C) 2015 Keijiro Takahashi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
Shader "Hidden/Kino/Fringe"
{
    Properties
    {
        _MainTex ("-", 2D) = "" {}
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;

    float _Axial;
    float _Lateral;
    float _SampleDist;

    // Poisson disk sample points
    static const uint SAMPLE_NUM = 8;
    static const float2 POISSON_SAMPLES[SAMPLE_NUM] =
    {
        float2(0.506456158113, 0.216884156934) * 2 - 1,
        float2(0.989818956980, 0.747194792852) * 2 - 1,
        float2(0.000402764999, 0.271360572518) * 2 - 1,
        float2(0.548290703131, 0.786973666349) * 2 - 1,
        float2(0.706589330496, 0.491162115587) * 2 - 1,
        float2(0.283019706155, 0.534466520374) * 2 - 1,
        float2(0.261566808856, 0.937111516353) * 2 - 1,
        float2(0.804170282245, 0.032975327061) * 2 - 1
    };
    
    // Poisson filter
    half3 poisson_filter(float2 uv)
    {
        half3 acc = 0;
        for (uint i = 0; i < SAMPLE_NUM; i++)
        {
            float2 disp = POISSON_SAMPLES[i];
            disp *= _MainTex_TexelSize.xy * _SampleDist;
            acc += tex2D(_MainTex, uv + disp).rgb;
        }
        return acc / SAMPLE_NUM;
    }

    // Rec.709 Luminance
    half luminance(half3 rgb)
    {
        return dot(rgb, half3(0.2126, 0.7152, 0.0722));
    }

    half4 frag(v2f_img i) : SV_Target
    {
        float k = 0.0;
        float kcube = 0.01;
        float2 uv = i.uv;
        float2 uv2 = (uv - 0.5) * float2(_MainTex_TexelSize.y / _MainTex_TexelSize.x, 1);
        float r2 = dot(uv2, uv2);
        
        float f1 = 1.0 + r2 * (k + kcube * sqrt(r2));
        float f2 = 1.0 + r2 * (-k - kcube * sqrt(r2));

        float2 uva = (uv - 0.5) * f1 + 0.5;
        float2 uvb = (uv - 0.5) * f2 + 0.5;
        
        half4 src = tex2D(_MainTex, i.uv);
        half4 src2 = tex2D(_MainTex, uva);
        half4 src3 = tex2D(_MainTex, uvb);

        src.r = src3.r;
        src.b = src2.b;

//        half4 src = tex2D(_MainTex, i.uv);
        half3 blur = poisson_filter(uvb);

        half ldiff = luminance(abs(src.rbg - blur));
        src.rb = lerp(src.rb, blur.rb, saturate(ldiff * 10 * _Axial));
        
        return src;
    }

    ENDCG

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }
}
