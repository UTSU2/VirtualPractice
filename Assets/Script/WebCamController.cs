using UnityEngine;
using UnityEngine.UI;

public class WebCamController : MonoBehaviour
{
    [SerializeField] private RawImage webcamView;
    private WebCamTexture webCamTexture;
    void Start()
    {
        StartWebcam();
    }

    private void StartWebcam()
    {
        webCamTexture = new WebCamTexture();

        webcamView.texture = webCamTexture;

        webCamTexture.Play();
    }
}
