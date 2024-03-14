using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    [SerializeField] Transform _target;
    [SerializeField] float _distance = 3;
    [SerializeField] float _height = 3;

    void LateUpdate()
    {
        if (_target == null) return;

        Vector3 pos = _target.forward * -_distance + new Vector3(0, _height, 0);
        pos = _target.position + pos;
        this.transform.position = Vector3.Lerp(this.transform.position, pos, 12.0f * Time.deltaTime);
        this.transform.LookAt(_target);
    }
}
