using UnityEngine;

public class HeadTracking : MonoBehaviour
{
    [SerializeField] private Animator animator;
    [SerializeField] private Transform target;

    [SerializeField] private Vector3 rotationOffset;
    [SerializeField] private float rotationSpeed = 5f;
    private Transform head;

    private void Start()
    {
        head = animator.GetBoneTransform(HumanBodyBones.Head);
    }

    private void LateUpdate()
    {
        if (head == null || target == null)
            return;

        Vector3 direction =
            target.position - head.position;

        Quaternion targetRotation =
            Quaternion.LookRotation(direction);

        targetRotation *= Quaternion.Euler(rotationOffset);

        head.rotation =
            Quaternion.Slerp(
                head.rotation,
                targetRotation,
                rotationSpeed * Time.deltaTime
            );
    }
}
