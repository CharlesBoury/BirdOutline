Shader "Sprites/Outline"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0

        // Add values to determine if outlining is enabled and outline color.
        [PerRendererData] _Interior ("Interior", Float) = 0
        [PerRendererData] _Exterior ("Exterior", Float) = 0
        [PerRendererData] _OutlineColor("Outline Color", Color) = (1,1,1,1)
        [PerRendererData] _OutlineAlphaCorner("Outline Alpha Corner", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ PIXELSNAP_ON
            #pragma shader_feature ETC1_EXTERNAL_ALPHA
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
            };

            fixed4 _Color;
            float _Exterior;
            float _Interior;
            fixed4 _OutlineColor;
            float _OutlineAlphaCorner;

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = mul(UNITY_MATRIX_MVP, IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color * _Color;
                #ifdef PIXELSNAP_ON
                OUT.vertex = UnityPixelSnap (OUT.vertex);
                #endif

                return OUT;
            }

            sampler2D _MainTex;
            sampler2D _AlphaTex;
            float4 _MainTex_TexelSize;

            fixed4 SampleSpriteTexture (float2 uv)
            {
                fixed4 color = tex2D (_MainTex, uv);

                #if ETC1_EXTERNAL_ALPHA
                // get the color from an external texture (usecase: Alpha support for ETC1 on android)
                color.a = tex2D (_AlphaTex, uv).r;
                #endif //ETC1_EXTERNAL_ALPHA

                return color;
            }

            fixed4 frag(v2f IN) : SV_Target
            {

                // Get the pixel
                fixed4 c = SampleSpriteTexture (IN.texcoord) * IN.color;

                // Get the neighbouring eight pixels.
                fixed4 pixelUp    = tex2D(_MainTex, IN.texcoord + fixed2(0, _MainTex_TexelSize.y));
                fixed4 pixelDown  = tex2D(_MainTex, IN.texcoord + fixed2(0,- _MainTex_TexelSize.y));
                fixed4 pixelRight = tex2D(_MainTex, IN.texcoord + fixed2(_MainTex_TexelSize.x, 0));
                fixed4 pixelLeft  = tex2D(_MainTex, IN.texcoord + fixed2(-_MainTex_TexelSize.x, 0));

                fixed4 pixelUpLeft    = tex2D(_MainTex, IN.texcoord + fixed2(-_MainTex_TexelSize.x,  _MainTex_TexelSize.y));
                fixed4 pixelUpRight   = tex2D(_MainTex, IN.texcoord + fixed2( _MainTex_TexelSize.x,  _MainTex_TexelSize.y));
                fixed4 pixelDownLeft  = tex2D(_MainTex, IN.texcoord + fixed2(-_MainTex_TexelSize.x,- _MainTex_TexelSize.y));
                fixed4 pixelDownRight = tex2D(_MainTex, IN.texcoord + fixed2( _MainTex_TexelSize.x,- _MainTex_TexelSize.y));



                // If we want an interior outline, then on each visible pixel...
                if (_Interior > 0 && c.a != 0) {
                    // If one of the neighbouring pixels is invisible, we render an outline.
                    if (pixelUp.a * pixelDown.a * pixelRight.a * pixelLeft.a == 0) {
                        c.rgb = (1 - _OutlineColor.a) * c.rgb + _OutlineColor.a * _OutlineColor.rgb;
                    }
                    // for the corners the alpha can be lower (with _OutlineAlphaCorner)
                    else if (pixelUpLeft.a * pixelUpRight.a * pixelDownLeft.a * pixelDownRight.a == 0) {
                        float newAlpha = _OutlineColor.a * _OutlineAlphaCorner;
                        c.rgb = (1 - newAlpha)*c.rgb + newAlpha * _OutlineColor.rgb;
                    }
                }

                // If we want an exterior outline, then on each invisible pixel...
                if (_Exterior > 0 && c.a == 0) {
                    // If one of the neighbouring pixels is visible, we render an outline.
                    if (pixelUp.a + pixelDown.a + pixelRight.a + pixelLeft.a != 0) {
                        c.rgba = fixed4(1, 1, 1, 1) * _OutlineColor;
                    }
                    // for the corners the alpha can be lower (with _OutlineAlphaCorner)
                    else if (pixelUpLeft.a + pixelUpRight.a + pixelDownLeft.a + pixelDownRight.a != 0) {
                        c.rgba = fixed4(1, 1, 1, _OutlineAlphaCorner) * _OutlineColor;
                    }
                }

                c.rgb *= c.a;

                return c;
            }
            ENDCG
        }
    }
}