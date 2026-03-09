using UnityEngine;

/// <summary>
/// ジャイロセンサーの傾きに連動して内部ポイントライトをオフセットし、
/// 結晶の Specular がキラキラと揺れる演出を行う。
/// GPU インスタンシング対応のため、MaterialPropertyBlock 経由でシェーダーに値を渡す。
/// </summary>
[RequireComponent(typeof(Light))]
public class GyroLinkedLight : MonoBehaviour
{
    // ── ジャイロ設定 ──────────────────────────────────────────────
    [Header("Gyro")]
    [Range(0f, 1f)]   public float influence    = 0.15f;  // 傾きの反映量
    [Range(1f, 20f)]  public float smoothSpeed  = 6f;     // 追従の滑らかさ
    [Range(0f, 0.3f)] public float maxOffset    = 0.08f;  // 最大移動距離（m）

    // ── ライト設定 ────────────────────────────────────────────────
    [Header("Light")]
    [Range(0f, 5f)]   public float baseIntensity      = 1.5f;
    [Range(0f, 1f)]   public float intensityVariation = 0.25f; // 傾きに連動する強度ブレ

    // ── 露出補正 ──────────────────────────────────────────────────
    [Header("Exposure")]
    [Range(0f, 3f)]   public float exposureMultiplier = 1f;

    // ── 内部 ─────────────────────────────────────────────────────
    private Light         _light;
    private Vector3       _baseLocalPos;
    private Vector3       _currentOffset;
    private Vector3       _targetOffset;

    // シェーダーグローバル ID（Shader.PropertyToID はキャッシュが必須）
    private static readonly int ID_LightOffset  = Shader.PropertyToID("_GyroLightOffset");
    private static readonly int ID_Exposure     = Shader.PropertyToID("_ExposureMultiplier");

    // ── Unity Lifecycle ──────────────────────────────────────────
    void Start()
    {
        _light        = GetComponent<Light>();
        _baseLocalPos = transform.localPosition;

        _light.intensity = baseIntensity * exposureMultiplier;

        if (SystemInfo.supportsGyroscope)
            Input.gyro.enabled = true;
    }

    void Update()
    {
        ReadGyro();
        ApplyToLight();
        PushGlobals();
    }

    void OnValidate()
    {
        // インスペクターで値を変えた際にリアルタイム反映
        if (_light == null) _light = GetComponent<Light>();
        _light.intensity = baseIntensity * exposureMultiplier;
    }

    // ── 内部メソッド ─────────────────────────────────────────────

    void ReadGyro()
    {
        if (!SystemInfo.supportsGyroscope)
        {
            // エディタ確認用：マウス右ドラッグでシミュレート
#if UNITY_EDITOR
            float mx = Input.GetAxis("Mouse X") * 0.1f;
            float my = Input.GetAxis("Mouse Y") * 0.1f;
            _targetOffset = new Vector3(mx, my, 0f) * (maxOffset * influence);
#endif
            return;
        }

        // Unity のジャイロ座標系を World 空間に合わせて補正
        Quaternion raw       = Input.gyro.attitude;
        Quaternion corrected = new Quaternion(raw.x, raw.y, -raw.z, -raw.w);

        Vector3 tilt  = corrected * Vector3.forward;           // 傾きベクトル
        _targetOffset = new Vector3(tilt.x, tilt.y, 0f)
                        * (maxOffset * influence);
    }

    void ApplyToLight()
    {
        // Lerp で滑らかに追従（有機的な揺れ感）
        _currentOffset = Vector3.Lerp(
            _currentOffset,
            _targetOffset,
            Time.deltaTime * smoothSpeed
        );

        transform.localPosition = _baseLocalPos + _currentOffset;

        // 傾き量に応じて強度をわずかにブレさせる
        float t = _currentOffset.magnitude / Mathf.Max(maxOffset, 0.0001f);
        _light.intensity = (baseIntensity + t * intensityVariation) * exposureMultiplier;
    }

    void PushGlobals()
    {
        // GPU インスタンシング対応：グローバルプロパティ経由で全インスタンスに渡す
        // （MaterialPropertyBlock は各 Renderer で個別設定も可能）
        Shader.SetGlobalVector(ID_LightOffset, _currentOffset);
        Shader.SetGlobalFloat(ID_Exposure,     exposureMultiplier);
    }
}
