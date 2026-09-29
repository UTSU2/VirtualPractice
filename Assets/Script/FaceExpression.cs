using UnityEngine;
using UnityEngine.InputSystem;
using UniVRM10;

public class FaceExpression : MonoBehaviour
{
    [SerializeField] private Vrm10Instance vrmInstance;

    private void Update()
    {
        BlinkUpdate();
        MouthUpdate();
    }

    private void BlinkUpdate()
    {
        float leftBlinkWeight = 0f;
        float rightBlinkWeight = 0f;

        if (Keyboard.current == null)
            return;

        if (Keyboard.current.qKey.isPressed)
            leftBlinkWeight = 1f;

        if (Keyboard.current.eKey.isPressed)
            rightBlinkWeight = 1f;

        vrmInstance.Runtime.Expression.SetWeight(
            ExpressionKey.BlinkLeft,
            leftBlinkWeight
        );
        vrmInstance.Runtime.Expression.SetWeight(
            ExpressionKey.BlinkRight,
            rightBlinkWeight
        );
    }

    private void MouthUpdate()
    {
        if (Keyboard.current == null)
            return;

        float aaWeight = Keyboard.current.digit1Key.isPressed ? 1f : 0f;
        float ihWeight = Keyboard.current.digit2Key.isPressed ? 1f : 0f;
        float ouWeight = Keyboard.current.digit3Key.isPressed ? 1f : 0f;
        float eeWeight = Keyboard.current.digit4Key.isPressed ? 1f : 0f;
        float ohWeight = Keyboard.current.digit5Key.isPressed ? 1f : 0f;

        vrmInstance.Runtime.Expression.SetWeight(
            ExpressionKey.Aa,
            aaWeight
        );
        vrmInstance.Runtime.Expression.SetWeight(
            ExpressionKey.Ih,
            ihWeight
        );
        vrmInstance.Runtime.Expression.SetWeight(
            ExpressionKey.Ou,
            ouWeight
        );
        vrmInstance.Runtime.Expression.SetWeight(
            ExpressionKey.Ee,
            eeWeight
        );
        vrmInstance.Runtime.Expression.SetWeight(
            ExpressionKey.Oh,
            ohWeight
        );
    }
}
