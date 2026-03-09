using System;
using System.Collections;
using System.Text;
using UnityEngine;
using UnityEngine.Networking;

/// <summary>
/// Gemini API へテキストを送信し、応答テキストを返すクライアント。
/// Inspector の apiKey に Gemini API キーをセット。
/// </summary>
public class GeminiApiClient : MonoBehaviour
{
    [Header("Gemini API 設定")]
    [SerializeField] private string apiKey = "YOUR_GEMINI_API_KEY";
    [SerializeField] private string modelId = "gemini-2.0-flash";

    private const string EndpointBase =
        "https://generativelanguage.googleapis.com/v1beta/models/{0}:generateContent?key={1}";

    public event Action<string> OnResponseReceived;
    public event Action<string> OnErrorOccurred;

    /// <summary>ユーザーの発言テキストを Gemini へ送り、応答を受け取る</summary>
    public void SendMessage(string userText)
    {
        StartCoroutine(PostToGemini(userText));
    }

    private IEnumerator PostToGemini(string userText)
    {
        string url = string.Format(EndpointBase, modelId, apiKey);

        // リクエスト JSON 組み立て（System Prompt でルーフェンの口調を設定可能）
        string bodyJson = BuildRequestJson(userText);
        byte[] bodyRaw = Encoding.UTF8.GetBytes(bodyJson);

        using var req = new UnityWebRequest(url, "POST");
        req.uploadHandler   = new UploadHandlerRaw(bodyRaw);
        req.downloadHandler = new DownloadHandlerBuffer();
        req.SetRequestHeader("Content-Type", "application/json");

        yield return req.SendWebRequest();

        if (req.result != UnityWebRequest.Result.Success)
        {
            OnErrorOccurred?.Invoke(req.error);
            yield break;
        }

        string reply = ParseResponse(req.downloadHandler.text);
        OnResponseReceived?.Invoke(reply);
    }

    private string BuildRequestJson(string userText)
    {
        // 世界観に合わせたシステム指示
        string systemPrompt =
            "あなたはLitho-Archeの主席記録官・ルーフェンです。" +
            "落ち着いた知性的な口調で短く答えてください。";

        // シンプルな JSON 手組み（JsonUtility 非対応の入れ子構造のため）
        return $@"{{
  ""system_instruction"": {{
    ""parts"": [{{ ""text"": ""{EscapeJson(systemPrompt)}"" }}]
  }},
  ""contents"": [{{
    ""role"": ""user"",
    ""parts"": [{{ ""text"": ""{EscapeJson(userText)}"" }}]
  }}],
  ""generationConfig"": {{
    ""temperature"": 0.7,
    ""maxOutputTokens"": 256
  }}
}}";
    }

    private string ParseResponse(string json)
    {
        // 最小限のパース（JsonUtility で対応できない深い階層はここで処理）
        const string marker = "\"text\": \"";
        int start = json.IndexOf(marker, StringComparison.Ordinal);
        if (start < 0) return "(応答を取得できませんでした)";

        start += marker.Length;
        int end = json.IndexOf("\"", start, StringComparison.Ordinal);
        if (end < 0) return "(応答パース失敗)";

        return json.Substring(start, end - start)
                   .Replace("\\n", "\n")
                   .Replace("\\\"", "\"");
    }

    private string EscapeJson(string s) =>
        s.Replace("\\", "\\\\").Replace("\"", "\\\"").Replace("\n", "\\n");
}
