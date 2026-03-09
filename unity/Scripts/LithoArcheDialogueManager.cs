using UnityEngine;
using UnityEngine.UI;
using TMPro;

/// <summary>
/// 全体の司令塔。UI からテキストを受け取り、Gemini に送信し、
/// 応答を口パクコントローラーへ渡す。
///
/// [Hierarchy 例]
///   Canvas
///   ├─ InputField (TMP)  ← ユーザー入力
///   ├─ SendButton
///   └─ ResponseText (TMP) ← ルーフェンの返答表示
/// </summary>
public class LithoArcheDialogueManager : MonoBehaviour
{
    [Header("コンポーネント参照")]
    [SerializeField] private GeminiApiClient   geminiClient;
    [SerializeField] private TextLipSyncController lipSync;

    [Header("UI")]
    [SerializeField] private TMP_InputField inputField;
    [SerializeField] private Button         sendButton;
    [SerializeField] private TMP_Text       responseLabel;
    [SerializeField] private TMP_Text       statusLabel;

    private void Start()
    {
        // イベント接続
        geminiClient.OnResponseReceived += HandleResponse;
        geminiClient.OnErrorOccurred    += HandleError;

        sendButton.onClick.AddListener(OnSendClicked);

        // Enter キーでも送信
        inputField.onSubmit.AddListener(_ => OnSendClicked());

        SetStatus("ルーフェンに話しかけてください");
    }

    private void OnDestroy()
    {
        geminiClient.OnResponseReceived -= HandleResponse;
        geminiClient.OnErrorOccurred    -= HandleError;
    }

    private void OnSendClicked()
    {
        string text = inputField.text.Trim();
        if (string.IsNullOrEmpty(text)) return;

        inputField.text = "";
        sendButton.interactable = false;
        SetStatus("ルーフェンが考えています…");

        geminiClient.SendMessage(text);
    }

    private void HandleResponse(string response)
    {
        responseLabel.text = response;
        sendButton.interactable = true;
        SetStatus("");

        // 口パクを開始
        lipSync.StartLipSync(response);
    }

    private void HandleError(string error)
    {
        responseLabel.text = "(通信エラーが発生しました)";
        sendButton.interactable = true;
        SetStatus($"エラー: {error}");
        Debug.LogError($"[Gemini] {error}");
    }

    private void SetStatus(string msg)
    {
        if (statusLabel != null)
            statusLabel.text = msg;
    }
}
