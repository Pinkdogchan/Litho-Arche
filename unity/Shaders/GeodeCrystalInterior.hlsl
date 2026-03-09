// GeodeCrystalInterior.hlsl
// ジオード内部結晶の Specular をジャイロ連動ライトで計算するシェーダーインクルード
// Unity URP Shader Graph の Custom Function ノードから呼び出す

#ifndef GEODE_CRYSTAL_INTERIOR_INCLUDED
#define GEODE_CRYSTAL_INTERIOR_INCLUDED

// C# 側 GyroLinkedLight.cs が Shader.SetGlobalVector/Float で書き込む値
float3 _GyroLightOffset;
float  _ExposureMultiplier;

/// <summary>
/// ジャイロオフセット済みのライト方向から結晶 Specular を計算する
/// </summary>
/// <param name="WorldPos">フラグメントのワールド座標</param>
/// <param name="WorldNormal">フラグメントの法線（正規化済み）</param>
/// <param name="ViewDir">カメラへの方向ベクトル（正規化済み）</param>
/// <param name="LightWorldPos">ポイントライトのワールド座標（C# から渡す）</param>
/// <param name="LightColor">ライトカラー</param>
/// <param name="Shininess">鋭さ（128 前後が結晶らしい）</param>
/// <param name="OutSpecular">出力：Specular 輝度</param>
void GyroSpecular_float(
    float3  WorldPos,
    float3  WorldNormal,
    float3  ViewDir,
    float3  LightWorldPos,
    float3  LightColor,
    float   Shininess,
    out float3 OutSpecular
)
{
    // ジャイロオフセットを加算したライト位置
    float3 gyroLightPos = LightWorldPos + _GyroLightOffset;
    float3 lightDir     = normalize(gyroLightPos - WorldPos);

    // Blinn-Phong ハーフベクトル
    float3 halfDir = normalize(lightDir + normalize(ViewDir));
    float  NdotH   = saturate(dot(WorldNormal, halfDir));

    // 結晶らしい鋭い Specular
    float  spec    = pow(NdotH, max(Shininess, 1.0));

    OutSpecular = LightColor * spec * _ExposureMultiplier;
}

/// <summary>
/// 内部結晶の「瞬き（Flicker）」アニメーション
/// GyroLinkedLight のオフセット量に応じて Emission を微かにブレさせる
/// </summary>
/// <param name="BaseEmission">ベースの Emission 色</param>
/// <param name="Time">_Time.y</param>
/// <param name="FlickerSpeed">点滅速度</param>
/// <param name="FlickerAmplitude">点滅強度</param>
/// <param name="OutEmission">出力：最終 Emission 色</param>
void CrystalFlicker_float(
    float3 BaseEmission,
    float  Time,
    float  FlickerSpeed,
    float  FlickerAmplitude,
    out float3 OutEmission
)
{
    // ジャイロオフセット量を揺れの係数として使用
    float gyroMag = length(_GyroLightOffset);

    // 時間ベースのゆらぎ（sin の重ね合わせで有機的に）
    float flicker = 1.0
        + sin(Time * FlickerSpeed       ) * FlickerAmplitude * 0.6
        + sin(Time * FlickerSpeed * 1.7 ) * FlickerAmplitude * 0.3
        + gyroMag * 2.0;                 // 傾けるほど明るく輝く

    OutEmission = BaseEmission * max(flicker, 0.0) * _ExposureMultiplier;
}

#endif // GEODE_CRYSTAL_INTERIOR_INCLUDED
