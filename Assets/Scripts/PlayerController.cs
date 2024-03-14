using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [SerializeField] float _speed = 3f;
    [SerializeField] float _rotateSpeed = 30f;
    float _angle;
    Animator _animator;

    void Start()
    {
        _angle = 0f;
        _animator = GetComponent<Animator>();
    }

    void Update()
    {
        float dir = Mathf.Max(0, Input.GetAxis("Vertical"));
        this.transform.position += dir * this.transform.forward * _speed * Time.deltaTime;
        _animator.SetFloat("run", dir);

        dir = Input.GetAxis("Horizontal");
        _angle += dir * _rotateSpeed * Time.deltaTime;
        this.transform.rotation = Quaternion.Euler(this.transform.up * _angle);
    }
}
