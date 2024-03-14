using System.Diagnostics;
using UnityEditor;
using UnityEngine;

public class EditorRestart : MonoBehaviour
{
    [MenuItem("File/Restart", priority = 230)]
    static void Restart()
    {
        var filename = EditorApplication.applicationPath;
        var arguments = $"-projectPath{Application.dataPath.Replace("/Assets", string.Empty)}";
        var startInfo = new ProcessStartInfo
        {
            FileName = filename,
            Arguments = arguments,
        };
        Process.Start(startInfo);
        EditorApplication.Exit(0);
    }
}
