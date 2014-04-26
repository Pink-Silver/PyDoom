/*
** py_renderer.cpp
** Python module - Interacts with the renderer and screen
**
**---------------------------------------------------------------------------
** Copyright 2013 Kate Stone
** All rights reserved.
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions
** are met:
**
** 1. Redistributions of source code must retain the above copyright
**    notice, this list of conditions and the following disclaimer.
** 2. Redistributions in binary form must reproduce the above copyright
**    notice, this list of conditions and the following disclaimer in the
**    documentation and/or other materials provided with the distribution.
** 3. The name of the author may not be used to endorse or promote products
**    derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
** IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
** OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
** IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
** INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
** NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
** THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**---------------------------------------------------------------------------
**
*/

#include "py_cpp.h"

using namespace PyCPP;

// Module Functions
/*
VARARG_METHOD (renderer, error_fatal)
{
	try
	{
		char *string = NULL;
		if (!PyArg_ParseTuple(args, "s", &string))
			handleException ();

		I_FatalError (const_cast<const char *>(string));
		Py_RETURN (Py_None);
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}

VARARG_METHOD (renderer, error)
{
	try
	{
		char *string = NULL;
		if (!PyArg_ParseTuple(args, "s", &string))
			handleException ();

		I_Error (const_cast<const char *>(string));
		Py_RETURN (Py_None);
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}
*/
// Module

static PyMethodDef renderer_methods[] = {
	//PYMODMETHOD(renderer, error_fatal, METH_VARARGS, "error_fatal (string)\n\nForces ZDoom to crash with the following error message. WARNING: PLEASE USE SPARINGLY."),
	//PYMODMETHOD(renderer, error, METH_VARARGS, "error (string)\n\nDrops ZDoom to the console with the following error message, ending the game as necessary."),
	PYMODMETHOD_END,
};

PyDoc_STRVAR(renderer_doc,
"Module to facilitate interaction with the renderer.");

static PyModuleDef renderermodule = {
    PyModuleDef_HEAD_INIT,
    "renderer",
    renderer_doc,
    -1,
    renderer_methods,
    NULL,
    NULL,
    NULL,
    NULL
};

PyObject *init_renderer()
{
	try
	{
		PyObject *m = NULL;

		m = PyModule_Create (&renderermodule);
		if (m == NULL)
			handleException ();

		return m;
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}
