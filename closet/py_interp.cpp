/*
** py_interp.cpp
** Houses the interfaces for the Python interpreter.
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

#include "py_console.h"
#include "py_wads.h"
#include "py_iface.h"
#include "i_system.h"
#include "cmdlib.h"
#include "m_argv.h"

using namespace PyCPP;

void Doom_PyInit()
{
	static char stdlib[PATH_MAX];
	mysnprintf (stdlib, countof(stdlib), "%s%s%s", progdir.GetChars(), progdir[progdir.Len() - 1] != '/' ? "/" : "", "pystdlib.zip");
	static wchar_t pypath[PATH_MAX + 32];
	mbstowcs (pypath, stdlib, PATH_MAX + 32);

	PyImport_AppendInittab("console", &init_console);
	PyImport_AppendInittab("interface", &init_interface);
	PyImport_AppendInittab("wads", &init_wads);
	Py_SetProgramName(L"gzdoom");
	Py_SetPath(pypath);
	Py_Initialize();
	List *args = new List(Args->NumArgs());
	for (int i = 0; i < Args->NumArgs(); ++i)
	{
		String *str = new String(Args->GetArg(i));
		args->set(i, str->newRef());
		delete str;
	};
	String *progstr = new String(progdir);
	PySys_SetObject("argv", args->newRef());
	PySys_SetObject("progdir", progstr->newRef());
	delete args;
	delete progstr;
	delete Args;
	Printf ("Python %s on %s\n", Py_GetVersion(), Py_GetPlatform());
}

void Doom_PyMain()
{
	PyObject *mod2 = PyImport_ImportModule("zdoom.console_setup");
	
	if (!mod2)
		I_FatalError("Could not import setup module!");

	if (!PyObject_HasAttrString(mod2, "ReportFatalError"))
		I_FatalError("Setup module has no error reporting function!");

	PySys_SetObject ("excepthook", PyObject_GetAttrString (mod2, "ReportFatalError"));

	Py_XDECREF (mod2);

	PyObject *mod = PyImport_ImportModule("zdoom.__main__");

	if (!mod)
		PyErr_Print();

	if (!PyObject_HasAttrString(mod, "main"))
		I_FatalError("Main module has no main() function!");

	PyObject *main = PyObject_GetAttrString(mod, "main");
	PyObject *result = PyObject_Call(main, Tuple (), NULL);

	if (!result)
		PyErr_Print();

	Py_XDECREF (mod);
	Py_XDECREF (main);
	Py_XDECREF (result);
}
