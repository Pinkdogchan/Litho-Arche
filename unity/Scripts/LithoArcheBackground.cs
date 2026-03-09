using UnityEngine;

/// <summary>
/// Litho-Arche の濃紺世界観に合わせた背景・ライティング設定。
/// Camera にアタッチして使用。
///
/// カラーパレット:
///   深宇宙紺   #0A0B1E  (背景ベース)
///   星雲紫     #1E1040  (グラデーション下部)
///   フローライト青 #3A6B9E  (アクセントライト)
///   星辰白     #C8D8F0  (ハイライト)
/// </summary>
[RequireComponent(typeof(Camera))]
public class LithoArcheBackground : MonoBehaviour
{
    [Header("背景グラデーション")]
    [SerializeField] private Color skyColor    = new Color(0.039f, 0.043f, 0.118f); // #0A0B1E
    [SerializeField] private Color groundColor = new Color(0.118f, 0.063f, 0.251f); // #1E1040

    [Header("フローライト アクセントライト")]
    [SerializeField] private Light accentLight;
    [SerializeField] private Color accentColor = new Color(0.227f, 0.420f, 0.620f); // #3A6B9E
    [SerializeField] private float accentIntensity = 1.2f;

    [Header("フィル（柔らかい逆光）")]
    [SerializeField] private Light fillLight;
    [SerializeField] private Color fillColor = new Color(0.078f, 0.039f, 0.157f);  // 深紫
    [SerializeField] private float fillIntensity = 0.4f;

    [Header("星屑パーティクル（任意）")]
    [SerializeField] private ParticleSystem starParticles;

    private Camera _cam;

    private void Awake()
    {
        _cam = GetComponent<Camera>();
        ApplyBackgroundSettings();
        ApplyLighting();
        ConfigureStarParticles();
    }

    private void ApplyBackgroundSettings()
    {
        _cam.clearFlags      = CameraClearFlags.SolidColor;
        _cam.backgroundColor = skyColor;

        // URP / Built-in 両対応: Gradient Sky はシェーダーで別途設定推奨
        RenderSettings.ambientMode = UnityEngine.Rendering.AmbientMode.Trilight;
        RenderSettings.ambientSkyColor     = skyColor;
        RenderSettings.ambientEquatorColor = Color.Lerp(skyColor, groundColor, 0.5f);
        RenderSettings.ambientGroundColor  = groundColor;
        RenderSettings.ambientIntensity    = 0.6f;

        // フォグ（遠景の深み）
        RenderSettings.fog      = true;
        RenderSettings.fogColor = skyColor;
        RenderSettings.fogMode  = FogMode.ExponentialSquared;
        RenderSettings.fogDensity = 0.015f;
    }

    private void ApplyLighting()
    {
        // アクセントライト（フローライトの青光）
        if (accentLight != null)
        {
            accentLight.color     = accentColor;
            accentLight.intensity = accentIntensity;
            accentLight.type      = LightType.Directional;
        }

        // フィルライト（背後からの深紫の逆光）
        if (fillLight != null)
        {
            fillLight.color     = fillColor;
            fillLight.intensity = fillIntensity;
            fillLight.type      = LightType.Directional;
        }
    }

    private void ConfigureStarParticles()
    {
        if (starParticles == null) return;

        var main = starParticles.main;
        main.startColor    = new ParticleSystem.MinMaxGradient(
                                 new Color(0.78f, 0.85f, 0.94f, 0.3f),   // 星辰白・薄
                                 new Color(0.60f, 0.70f, 0.90f, 0.8f));  // フローライト青
        main.startSize     = new ParticleSystem.MinMaxCurve(0.005f, 0.02f);
        main.startLifetime = new ParticleSystem.MinMaxCurve(5f, 15f);
        main.startSpeed    = new ParticleSystem.MinMaxCurve(0f, 0.01f);
        main.maxParticles  = 300;

        var emission = starParticles.emission;
        emission.rateOverTime = 5f;

        var shape = starParticles.shape;
        shape.shapeType = ParticleSystemShapeType.Box;
        shape.scale     = new Vector3(20f, 12f, 1f);
    }

#if UNITY_EDITOR
    // Inspector でリアルタイムプレビュー
    private void OnValidate()
    {
        if (_cam == null) _cam = GetComponent<Camera>();
        ApplyBackgroundSettings();
        ApplyLighting();
    }
#endif
}
