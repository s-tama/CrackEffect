using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[ExecuteAlways]
public class CrackedScreen : MonoBehaviour
{
    [SerializeField] Transform[] _children = new Transform[0];
    [SerializeField] Camera _renderCamera;
    [SerializeField] Material _baseMaterial = null;
    [SerializeField, Range(0f, 1f)] float _progress = 0;
    [SerializeField] bool _useGravity = true;
    [SerializeField] float _force = 20f;
    [SerializeField] Vector3 _offsetCenter = Vector3.zero;
    [SerializeField] float _radius = 10f;
    [SerializeField][Range(0, 1)] float _crackRatio = 1;
    [SerializeField][Range(0, 1)] float _gapBrightness = 1;
    [SerializeField][Range(0, 1)] float _gapRatio = 1;
    [SerializeField] Material _skybox;
    Rigidbody[] _rigidbodies;

    void Start()
    {
        _rigidbodies = GetComponentsInChildren<Rigidbody>(true);
    }

    void Update()
    {
        _baseMaterial.SetFloat("_CrackRatio", _crackRatio);
        _baseMaterial.SetFloat("_GapBrightness", _gapBrightness);
        _baseMaterial.SetFloat("_GapRatio", _gapRatio);
    }

    public void Break()
    {
        //StartCoroutine(BreakAsync());
        //var rigidbodies = GetComponentsInChildren<Rigidbody>();
        //if (ArrayUtility.IsNullOrEmpty(rigidbodies))
        //    return;
        //foreach (var rb in rigidbodies)
        //{
        //    rb.isKinematic = false;
        //    rb.useGravity = _useGravity;
        //    rb.AddExplosionForce(_force, transform.position + _offsetCenter, _radius);
        //    //var sphereVec = UnityEngine.Random.insideUnitSphere;
        //    //sphereVec.x = Mathf.Clamp(sphereVec.x, 0.5f, 1);
        //    //sphereVec.y = Mathf.Clamp(sphereVec.y, 0.5f, 1);
        //    //rb.AddForce(sphereVec * _force);
        //    //rb.AddTorque(UnityEngine.Random.insideUnitSphere);
        //}

        foreach (var rb in _rigidbodies)
        {
            rb.isKinematic = false;
            var sphereVec = UnityEngine.Random.insideUnitSphere;
            sphereVec.z = -1;
            rb.AddForce(sphereVec * _force);
            rb.AddTorque(UnityEngine.Random.insideUnitSphere * _force, ForceMode.Acceleration);
        }
    }

    public void On()
    {
        var rt = RenderTexture.GetTemporary(_renderCamera.targetTexture.descriptor);
        Graphics.Blit(_renderCamera.targetTexture, rt);
        _baseMaterial.SetTexture("_BaseMap", rt);
        RenderTexture.ReleaseTemporary(_renderCamera.targetTexture);

        foreach (var rb in _rigidbodies)
        {
            rb.gameObject.SetActive(true);
        }

        RenderSettings.skybox = _skybox;
    }

    public void Off()
    {
        foreach (var rb in _rigidbodies)
        {
            rb.gameObject.SetActive(false);
        }
    }

    IEnumerator BreakAsync()
    {
        if (ArrayUtility.IsNullOrEmpty(_rigidbodies))
            yield break;

        foreach (var rb in _rigidbodies)
        {
            rb.isKinematic = false;
            rb.useGravity = _useGravity;
            //rb.AddExplosionForce(_force, transform.position + _offsetCenter, _radius);
            var sphereVec = UnityEngine.Random.insideUnitSphere;
            sphereVec.z = -1;
            //Vector3 dist = rb.transform.position - transform.position;
            //dist.z = -1;
            rb.AddForce(sphereVec * _force);
            rb.AddTorque(UnityEngine.Random.insideUnitSphere * _force, ForceMode.Acceleration);
        }

        // àÍèuÇæÇØìÆÇ©ÇµÇƒÇ–Ç—äÑÇÍÇââèo
        yield return new WaitForSeconds(0.02f);

        foreach (var rb in _rigidbodies)
        {
            rb.isKinematic = true;
        }

        yield return new WaitForSeconds(0.8f);

        foreach (var rb in _rigidbodies)
        {
            rb.isKinematic = false;
            rb.AddExplosionForce(_force, transform.position + _offsetCenter, _radius, 3.0f);
            var sphereVec = UnityEngine.Random.insideUnitSphere;
            sphereVec.z = -1;
            //Vector3 dist = rb.transform.position - transform.position;
            //dist.z = -1;
            rb.AddForce(sphereVec * _force);
            rb.AddTorque(UnityEngine.Random.insideUnitSphere * _force, ForceMode.Acceleration);
        }

        yield return null;
    }



#if UNITY_EDITOR
    void Reset()
    {
        //_children = new Transform[transform.childCount];
        //for (int i = 0; i < transform.childCount; i++)
        //{
        //    _children[i] = transform.GetChild(i);
        //}
    }

    void OnValidate()
    {
        if (ArrayUtility.IsNullOrEmpty(_children))
            return;

        //if (_baseMaterial != _prevMaterial)
        //{
        //    var renderers = GetComponentsInChildren<Renderer>();
        //    if (!ArrayUtility.IsNullOrEmpty(renderers))
        //        Array.ForEach(renderers, r => r.sharedMaterial = _baseMaterial);
        //    _prevMaterial = _baseMaterial;
        //}
    }
#endif
}

public static class ArrayUtility
{
    public static bool IsNullOrEmpty<T>(in T[] array)
    {
        return array == null || array.Length == 0;
    }
}
