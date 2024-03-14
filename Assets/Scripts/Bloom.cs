using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : MonoBehaviour
{
    [SerializeField] Shader _shader;
    Material _material;

    // Bloomの強度
    [Range(0, 1f)] [SerializeField] float _strength = 0.3f;
    [Range(1, 12)] [SerializeField] int _samplerCnt = 6;
    // ブラーの強度
    [Range(1, 64)] [SerializeField] int _blur = 20;
    // 明るさのしきい値
    [Range(0, 1f)] [SerializeField] float _threshold = 0.3f;
    // RenderTextureサイズの分母
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
