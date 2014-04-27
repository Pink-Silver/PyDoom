#include <Python.h>

static PyMethodDef rmethods[] = {
    {NULL, NULL, 0, NULL} // Sentinel
};

static struct PyModuleDef rmodule = {
    PyModuleDef_HEAD_INIT,
    "columnrenderer",
    "The 2D column-based renderer for PyDoom",
    -1,
    rmethods
};

PyMODINIT_FUNC PyInit_columnrenderer (void)
{
    PyObject *m;
    
    m = PyModule_Create(&rmodule);
    if (m == NULL)
        return NULL;
    
    return m;
}
