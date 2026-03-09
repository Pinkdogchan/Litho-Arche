using System.Collections;
using UnityEngine;
using Live2D.Cubism.Core;
using Live2D.Cubism.Framework;

/// <summary>
/// Gemini から受け取ったテキストに合わせて Live2D モデルを口パクさせる。
///
/// [設定手順]
///  1. Live2D モデルの GameObject にこのスクリプトをアタッチ
///  2. cubismModel にモデルの CubismModel コンポーネントを割り当て
///  3. GeminiApiClient.OnResponseReceived イベントをここの StartLipSync へ接続
///
/// [口パクの仕組み]
///  - テキストの文字数から「推定発話時間」を算出
///  - その間、ParamMouthOpenY をサイン波でアニメーション
///  - 母音 (a/i/u/e/o) の密度で最大開口量を調整
/// </summary>
public class TextLipSyncController : MonoBehaviour
{
    [Header("Live2D モデル")]
    [SerializeField] private CubismModel cubismModel;

    [Header("口パクパラメータ名 (Live2D Editor で確認)")]
    [SerializeField] private string mouthOpenParamId  = "ParamMouthOpenY";
    [SerializeField] private string mouthFormParamId  = "ParamMouthForm"; // 笑顔←→への字

    [Header("口パク速度・開口量")]
    [SerializeField] private float syllablesPerSecond = 6f;   // 発話速度（mora/sec）
    [SerializeField] private float maxOpenAmount      = 1.0f;
    [SerializeField] private float minOpenAmount      = 0.05f; // 完全に閉じず僅かに残す
    [SerializeField] private float mouthFormValue     = 0.5f;  // 話すときの口の形

    // 現在再生中のコルーチン参照（中断用）
    private Coroutine _lipSyncCoroutine;

    // Live2D パラメータ参照（キャッシュ）
    private CubismParameter _mouthOpenParam;
    private CubismParameter _mouthFormParam;

    private void Start()
    {
        CacheParameters();
    }

    private void CacheParameters()
    {
        if (cubismModel == null)
        {
            Debug.LogError("[LipSync] CubismModel が未設定です。");
            return;
        }

        foreach (var p in cubismModel.Parameters)
        {
            if (p.Id == mouthOpenParamId) _mouthOpenParam = p;
            if (p.Id == mouthFormParamId) _mouthFormParam = p;
        }

        if (_mouthOpenParam == null)
            Debug.LogWarning($"[LipSync] パラメータ '{mouthOpenParamId}' が見つかりません。ID を確認してください。");
    }

    /// <summary>
    /// GeminiApiClient.OnResponseReceived に接続して呼び出す。
    /// Inspector の UnityEvent や AddListener でも可。
    /// </summary>
    public void StartLipSync(string responseText)
    {
        if (_lipSyncCoroutine != null)
            StopCoroutine(_lipSyncCoroutine);

        _lipSyncCoroutine = StartCoroutine(LipSyncRoutine(responseText));
    }

    private IEnumerator LipSyncRoutine(string text)
    {
        if (_mouthOpenParam == null) yield break;

        // 発話時間を文字数と母音密度から推定
        float duration    = EstimateDuration(text);
        float vowelDensity = CountVowelDensity(text); // 0.0〜1.0

        float elapsed = 0f;
        float baseFreq = syllablesPerSecond * Mathf.PI; // サイン波の角周波数

        // 口を開ける
        if (_mouthFormParam != null)
            _mouthFormParam.Value = mouthFormValue;

        while (elapsed < duration)
        {
            // サイン波で口の開閉を表現、末尾にかけてフェードアウト
            float progress   = elapsed / duration;
            float envelope   = Mathf.SmoothStep(1f, 0f, Mathf.Pow(progress, 4f)); // 末尾で閉じる
            float sineValue  = (Mathf.Sin(elapsed * baseFreq) + 1f) * 0.5f;       // 0〜1

            float openAmount = Mathf.Lerp(minOpenAmount,
                                           maxOpenAmount * vowelDensity,
                                           sineValue * envelope);

            _mouthOpenParam.Value = openAmount;

            elapsed += Time.deltaTime;
            yield return null;
        }

        // 発話終了 → 口を閉じる
        yield return StartCoroutine(CloseMouthSmooth(0.15f));
        _lipSyncCoroutine = null;
    }

    private IEnumerator CloseMouthSmooth(float closeDuration)
    {
        float start   = _mouthOpenParam.Value;
        float elapsed = 0f;

        while (elapsed < closeDuration)
        {
            _mouthOpenParam.Value = Mathf.Lerp(start, 0f, elapsed / closeDuration);
            elapsed += Time.deltaTime;
            yield return null;
        }

        _mouthOpenParam.Value = 0f;
        if (_mouthFormParam != null)
            _mouthFormParam.Value = 0f;
    }

    /// <summary>テキストの文字数から発話時間（秒）を推定</summary>
    private float EstimateDuration(string text)
    {
        // 日本語: 約8〜10mora/sec が自然速度。ここでは syllablesPerSecond を利用
        int charCount = text.Replace(" ", "").Replace("\n", "").Length;
        float duration = charCount / syllablesPerSecond;
        return Mathf.Clamp(duration, 0.3f, 30f);
    }

    /// <summary>母音の多さを 0.5〜1.0 にマッピング（口の大きさ調整用）</summary>
    private float CountVowelDensity(string text)
    {
        if (string.IsNullOrEmpty(text)) return 0.5f;

        int vowels = 0;
        string lower = text.ToLower();
        foreach (char c in lower)
        {
            if (c == 'a' || c == 'i' || c == 'u' || c == 'e' || c == 'o' ||
                // ひらがな母音行
                (c >= 'あ' && c <= 'お') ||
                c == 'な' || c == 'た' || c == 'か') // 代表的な開口音
                vowels++;
        }

        float ratio = (float)vowels / text.Length;
        return Mathf.Lerp(0.5f, 1.0f, Mathf.Clamp01(ratio * 3f));
    }

    /// <summary>外部から口パクを即座に停止する</summary>
    public void StopLipSync()
    {
        if (_lipSyncCoroutine != null)
        {
            StopCoroutine(_lipSyncCoroutine);
            _lipSyncCoroutine = null;
        }
        StartCoroutine(CloseMouthSmooth(0.1f));
    }
}
