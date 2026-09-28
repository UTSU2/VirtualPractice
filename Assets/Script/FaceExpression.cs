using UnityEngine;
using UnityEngine.InputSystem;
using UniVRM10;

public class FaceExpression : MonoBehaviour
{
    [SerializeField] private Vrm10Instance vrmInstance;

    private void Update()
    {
        BlinkUpdate();
    }

    private void BlinkUpdate()
    {
        float blinkWeight;

        if (Keyboard.current != null && Keyboard.current.spaceKey.isPressed)
            blinkWeight = 1f;
        else
            blinkWeight = 0f;

        vrmInstance.Runtime.Expression.SetWeight(
            ExpressionKey.Blink,
            blinkWeight
        );
    }
}
