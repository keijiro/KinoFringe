//
// KinoFringe - Chromatic aberration effect
//
// Copyright (C) 2015 Keijiro Takahashi
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
using UnityEngine;

namespace Kino
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    [AddComponentMenu("Kino Image Effects/Fringe")]
    public class Fringe : MonoBehaviour
    {
        #region Public Properties

        // Axial aberration
        [SerializeField, Range(0, 1)]
        float _axialAberration = 1;

        public float axialAberration {
            get { return _axialAberration; }
            set { _axialAberration = value; }
        }

        // Lateral aberration
        [SerializeField, Range(0, 1)]
        float _lateralAberration = 1;

        public float lateralAberration {
            get { return _lateralAberration; }
            set { _lateralAberration = value; }
        }

        [SerializeField, Range(0, 4)]
        float _sampleDistance = 4;

        #endregion

        #region Private Properties

        [SerializeField] Shader _shader;

        Material _material;

        #endregion

        #region MonoBehaviour Functions

        void OnRenderImage(RenderTexture source, RenderTexture destination)
        {
            if (_material == null)
            {
                _material = new Material(_shader);
                _material.hideFlags = HideFlags.DontSave;
            }

            _material.SetFloat("_Axial", _axialAberration);
            _material.SetFloat("_Lateral", _lateralAberration);
            _material.SetFloat("_SampleDist", _sampleDistance);

            Graphics.Blit(source, destination, _material, 0);
        }

        #endregion
    }
}
