#include <Python.h>
#ifdef _MSC_VER
#include <Windows.h>
#endif
#include <gl/gl.h>

static PyMethodDef rmethods[] = {
    {NULL, NULL, 0, NULL} // Sentinel
};

static struct PyModuleDef rmodule = {
    PyModuleDef_HEAD_INIT,
    "gl2d_renderer",
    "The 2D column-based renderer for PyDoom",
    -1,
    rmethods
};

PyMODINIT_FUNC PyInit_gl2d_renderer (void)
{
    PyObject *m;
    
    m = PyModule_Create(&rmodule);
    if (m == NULL)
        return NULL;
    
    return m;
}
