using UnityEngine;

public class HeadTracking : MonoBehaviour
{
    [SerializeField] private Animator animator;
    [SerializeField] private Transform target;

    [SerializeField] private float rotationSpeed = 5f;

    [SerializeField] private float maxYaw = 60f;
    [SerializeField] private float maxPitch = 30f;

    [SerializeField] private float headWeight = 0.7f;
    [SerializeField] private float neckWeight = 0.3f;
    private Transform head;
    private Transform neck;

    private Quaternion initialHeadRotation;
    private Quaternion initialNeckRotation;
    private void Start()
    {
        head = animator.GetBoneTransform(HumanBodyBones.Head);
        neck = animator.GetBoneTransform(HumanBodyBones.Neck);

        if (head != null)
            initialHeadRotation = head.localRotation;
        if (neck != null)
            initialNeckRotation = neck.localRotation;

    }

    private void LateUpdate()
    {
        headTrackingUpdate();
    }
    private void headTrackingUpdate()
    {
        if (head == null || target == null)
            return;

        Vector3 direction =
            target.position - head.position;

        Vector3 localDirection =
            transform.InverseTransformDirection(direction);

        float yaw =
            Mathf.Atan2(
                localDirection.x,
                localDirection.z
            ) * Mathf.Rad2Deg;

        float pitch =
            -Mathf.Atan2(
                localDirection.y,
                localDirection.z
            ) * Mathf.Rad2Deg;

        yaw = Mathf.Clamp(yaw, -maxYaw, maxYaw);
        pitch = Mathf.Clamp(pitch, -maxPitch, maxPitch);

        Quaternion headLookRotation =
            Quaternion.Euler(pitch * headWeight, yaw * headWeight, 0f);

        Quaternion neckLookRotation =
            Quaternion.Euler(pitch * neckWeight, yaw * neckWeight, 0f);

        Quaternion targetHeadRotation =
            headLookRotation * initialHeadRotation;

        Quaternion targetNeckRotation =
            neckLookRotation * initialNeckRotation;

        head.localRotation =
            Quaternion.Slerp(
                head.localRotation,
                targetHeadRotation,
                rotationSpeed * Time.deltaTime
            );

        neck.localRotation =
            Quaternion.Slerp(
                neck.localRotation,
                targetNeckRotation,
                rotationSpeed * Time.deltaTime
            );
    }
}
