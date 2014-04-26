/*
** py_console.cpp
** Console interaction module for Python.
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

#include "c_console.h"
#include "doomtype.h"

using namespace PyCPP;

// Module Functions

VARARG_METHOD (console, print)
{
	try
	{
		char *string = NULL;
		if (!PyArg_ParseTuple(args, "s", &string))
			handleException ();

		PrintString (PRINT_HIGH, const_cast<const char *>(string));
		Py_RETURN (Py_None);
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}

VARARG_METHOD (console, printlevel)
{
	try
	{
		int *level = NULL;
		char *string = NULL;

		if (!PyArg_ParseTuple(args, "is", &level, &string))
			handleException ();

		PrintString (*level, string);
		Py_RETURN (Py_None);
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}

// Module

static PyMethodDef console_methods[] = {
	PYMODMETHOD(console, print, METH_VARARGS, "console.print (string)\n\nPrints a string to the ZDoom console."),
	PYMODMETHOD(console, printlevel, METH_VARARGS, "console.printlevel (level, string)\n\nPrints a string to the ZDoom console at the specified print level. Level is one\nof the supplied PRINT_* constants."),
	PYMODMETHOD_END,
};

PyDoc_STRVAR(console_doc,
"Allows interaction with the console.");

static PyModuleDef consolemodule = {
    PyModuleDef_HEAD_INIT,
    "console",
    console_doc,
    -1,
    console_methods,
    NULL,
    NULL,
    NULL,
    NULL
};

PyObject *init_console()
{
	try
	{
		PyObject *m = NULL;

		m = PyModule_Create (&consolemodule);
		if (m == NULL)
			handleException ();

		PyModule_AddObject(m, "PRINT_PICKUP",   Long (PRINT_LOW));
		PyModule_AddObject(m, "PRINT_DEATH",    Long (PRINT_MEDIUM));
		PyModule_AddObject(m, "PRINT_CRITICAL", Long (PRINT_HIGH));
		PyModule_AddObject(m, "PRINT_CHAT",     Long (PRINT_CHAT));
		PyModule_AddObject(m, "PRINT_TEAMCHAT", Long (PRINT_TEAMCHAT));
		PyModule_AddObject(m, "PRINT_LOGFILE",  Long (PRINT_LOG));
		PyModule_AddObject(m, "PRINT_BOLD",     Long (PRINT_BOLD));

		return m;
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}

