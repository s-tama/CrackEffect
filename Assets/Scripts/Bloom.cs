using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : MonoBehaviour
{
    [SerializeField] Shader _shader;
    Material _material;

    // Bloom�̋��x
    [Range(0, 1f)] [SerializeField] float _strength = 0.3f;
    [Range(1, 12)] [SerializeField] int _samplerCnt = 6;
    // �u���[�̋��x
    [Range(1, 64)] [SerializeField] int _blur = 20;
    // ���邳�̂������l
    [Range(0, 1f)] [SerializeField] float _threshold = 0.3f;
    // RenderTexture�T�C�Y�̕���
    [Range(1, 12)] [SerializeField] int _ratio = 1;

    private void Start()
    {
        _material = new Material(_shader);
        _material.hideFlags = HideFlags.DontSave;
    }

    void Update()
    {
        //var tmp = 
    }
}
