/*
** py_iface.cpp
** A module to handle various I_ system functions.
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

#include "i_system.h"

using namespace PyCPP;

// Module Functions

VARARG_METHOD (interface, error_fatal)
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

VARARG_METHOD (interface, error)
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

// Module

static PyMethodDef interface_methods[] = {
	PYMODMETHOD(interface, error_fatal, METH_VARARGS, "interface.error_fatal (string)\n\nForces ZDoom to crash with the following error message. WARNING: PLEASE USE SPARINGLY."),
	PYMODMETHOD(interface, error, METH_VARARGS, "interface.error (string)\n\nDrops ZDoom to the console with the following error message, ending the game as necessary."),
	PYMODMETHOD_END,
};

PyDoc_STRVAR(interface_doc,
"Allows interaction with the console.");

static PyModuleDef consolemodule = {
    PyModuleDef_HEAD_INIT,
    "interface",
    interface_doc,
    -1,
    interface_methods,
    NULL,
    NULL,
    NULL,
    NULL
};

PyObject *init_interface()
{
	try
	{
		PyObject *m = NULL;

		m = PyModule_Create (&consolemodule);
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

