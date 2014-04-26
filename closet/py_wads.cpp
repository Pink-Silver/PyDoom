/*
** py_wads.cpp
** Wad loading and interaction.
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

#include "py_wads.h"
#include "d_main.h"
#include "i_system.h"
#include "w_wad.h"
#include "resourcefiles/resourcefile.h"

using namespace PyCPP;

// Types & Classes

// PyResourceFile

static PyMethodDef pyresfile_methods[] = {
	PYCLASSMETHOD (PyResourceFile, readlump, METH_VARARGS, "PyResourceFile.readlump(index) -> bytes\n\nReads a single lump and returns the contents as a bytestring."),
	PYCLASSMETHOD (PyResourceFile, numlumps, METH_NOARGS,  "PyResourceFile.numlumps() -> int\n\nReturns the total number of lumps in the file."),
	PYCLASSMETHOD (PyResourceFile, lumpnames, METH_NOARGS, "PyResourceFile.lumpnames() -> dict\n\nReturns a dictionary of lump indexes by their name."),
	PYCLASSMETHOD (PyResourceFile, fullnames, METH_NOARGS, "PyResourceFile.fullnames() -> dict\n\nReturns a dictionary of lump indexes by their full name, including directories."),
	PYCLASSMETHOD_END,
};

static PyTypeObject PyResourceFileType = {
	/* The ob_type field must be initialized in the module init function
	 * to be portable to Windows without using C++. */
	PyVarObject_HEAD_INIT(NULL, 0)
	"ResourceFile",             /*tp_name*/
	0,                          /*tp_basicsize*/
	0,                          /*tp_itemsize*/
	/* methods */
	0,                          /*tp_dealloc*/
	0,                          /*tp_print*/
	0,                          /*tp_getattr*/
	0,                          /*tp_setattr*/
	0,                          /*tp_reserved*/
	0,                          /*tp_repr*/
	0,                          /*tp_as_number*/
	0,                          /*tp_as_sequence*/
	0,                          /*tp_as_mapping*/
	0,                          /*tp_hash*/
	0,                          /*tp_call*/
	0,                          /*tp_str*/
	0,                          /*tp_getattro*/
	0,                          /*tp_setattro*/
	0,                          /*tp_as_buffer*/
	Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE, /*tp_flags*/
	0,                          /*tp_doc*/
	0,                          /*tp_traverse*/
	0,                          /*tp_clear*/
	0,                          /*tp_richcompare*/
	0,                          /*tp_weaklistoffset*/
	0,                          /*tp_iter*/
	0,                          /*tp_iternext*/
	pyresfile_methods,          /*tp_methods*/
	0,                          /*tp_members*/
	0,                          /*tp_getset*/
	0, /* see init_wads */      /*tp_base*/
	0,                          /*tp_dict*/
	0,                          /*tp_descr_get*/
	0,                          /*tp_descr_set*/
	0,                          /*tp_dictoffset*/
	0,                          /*tp_init*/
	0,                          /*tp_alloc*/
	0,                          /*tp_new*/
	PyResourceFile::freeResource, /*tp_free*/
	0,                          /*tp_is_gc*/
};

PyObject * PyResourceFile::newResource (PyTypeObject *type, PyObject *args, PyObject *kwds)
{
	try
	{
		char *filename = NULL;
		if (!PyArg_ParseTuple(args, "s", &filename))
			handleException ();

		FResourceFile *fres = FResourceFile::OpenResourceFile (filename, NULL);
		if (!fres)
			raiseException (PyExc_RuntimeError, "Could not open resource file");

		PyResourceFile *newres = new PyResourceFile ();
		PyObject_Init (newres, &PyResourceFileType);
		Py_INCREF (newres);
		newres->resfile = fres;
		return newres;
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}

void PyResourceFile::freeResource (void *self)
{
	PyResourceFile *selfobj = (PyResourceFile *)self;
	delete selfobj;
}

PyObject * PyResourceFile::numlumps (PyObject *selfptr, PyObject *)
{
	try
	{
		PyResourceFile *self = (PyResourceFile *)selfptr;
		
		Long *x = new Long ((unsigned int)self->resfile->LumpCount ());
		
		return *x;
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}

PyObject * PyResourceFile::lumpnames (PyObject *selfptr, PyObject *)
{
	try
	{
		PyResourceFile *self = (PyResourceFile *)selfptr;
		
		Dict *namesdict = new Dict ();

		for (DWORD i = 0; i < self->resfile->LumpCount (); ++i)
		{
			Long *x = new Long ((unsigned int)(i));
			FResourceLump *lmp = self->resfile->GetLump(i);
			String *str = new String (lmp->Name);
			namesdict->setItem (str->newRef(), x->newRef());
			delete x;
			delete str;
		}

		return *namesdict;
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}

PyObject * PyResourceFile::fullnames (PyObject *selfptr, PyObject *)
{
	try
	{
		PyResourceFile *self = (PyResourceFile *)selfptr;

		FResourceLump *lmp = self->resfile->GetLump(0);
		if (!lmp->FullName)
			Py_RETURN (Py_None);
		
		Dict *namesdict = new Dict ();

		for (DWORD i = 0; i < self->resfile->LumpCount (); ++i)
		{
			Long *x = new Long ((unsigned int)(i));
			FResourceLump *lmp = self->resfile->GetLump(i);
			String *str = new String (lmp->FullName);
			namesdict->setItem (str->newRef(), x->newRef());
			delete x;
			delete str;
		}

		return *namesdict;
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}

PyObject * PyResourceFile::readlump (PyObject *selfptr, PyObject *args)
{
	try
	{
		int lumpno = 0;
		if (!PyArg_ParseTuple(args, "i", &lumpno))
			handleException ();

		PyResourceFile *self = (PyResourceFile *)selfptr;
		FResourceLump *reslump = self->resfile->GetLump (lumpno);
		if (reslump == NULL)
			raiseException (PyExc_RuntimeError, "Could not open lump in resource file");

		char *contents = (char *)reslump->CacheLump ();
		int len = reslump->LumpSize;

		char *namespace_name[18] = {
			"global",
			"sprites",
			"flats",
			"colormaps",
			"acs",
			"textures",
			"bloodraw",
			"bloodsfx",
			"bloodmisc",
			"voices",
			"hires",
			"voxels",

			// These namespaces are only used to mark lumps in special subdirectories
			// so that their contents doesn't interfere with the global namespace.
			// searching for data in these namespaces works differently for lumps coming
			// from Zips or other files.
			"zipdirectory",
			"sounds",
			"patches",
			"graphics",
			"music",
			"python",
		};

		PyObject *bytes = Py_BuildValue ("{" "ss" "ss" "ss" "sy#" "}",
			"name", reslump->Name,
			"fullname", reslump->FullName,
			"namespace", reslump->Namespace > -1? namespace_name[reslump->Namespace] : NULL,
			"data", contents, (Py_ssize_t)len);
		if (!bytes)
			handleException ();

		reslump->ReleaseCache ();

		return bytes;
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}

// Module functions

VARARG_METHOD(wads, pickIWAD)
{
	try
	{
		PyObject *listptr = NULL;
		int defresult = 0;
		if (!PyArg_ParseTuple(args, "O!|i", &PyList_Type, &listptr, &defresult))
			handleException ();

		List *wadlist = new List (listptr);
		int result = 0;

		Py_ssize_t length = wadlist->len ();
		WadStuff *tempwads = new WadStuff[length];

		for (Py_ssize_t i = 0; i < length; ++i)
		{
			String *wadname = new String (wadlist->get(i).getAttr("name"));
			String *wadpath = new String (wadlist->get(i).getAttr("filename"));
			Bytes *wadname_b = new Bytes (wadname->asBytes ());
			Bytes *wadpath_b = new Bytes (wadpath->asBytes ());

			tempwads[i].Name = FString (wadname_b->toChar());
			tempwads[i].Path = FString (wadpath_b->toChar());
			tempwads[i].Type = i;

			delete wadname;
			delete wadpath;
			delete wadname_b;
			delete wadpath_b;
		}

		result = I_PickIWad (tempwads, length, true, defresult);

		delete [] tempwads;

		return Long ((Py_ssize_t)result);
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}

// Module

static PyMethodDef wads_methods[] = {
	PYMODMETHOD (wads, pickIWAD, METH_VARARGS, "Displays the window for choosing an IWAD from a presented list."),
	PYMODMETHOD_END,
};

PyDoc_STRVAR(wads_doc,
"Built-in module used for reading from wad files and controlling the wad directory.");

static PyModuleDef wadsmodule = {
    PyModuleDef_HEAD_INIT,
    "wads",
    wads_doc,
    -1,
    wads_methods,
    NULL,
    NULL,
    NULL,
    NULL
};

PyObject *init_wads()
{
	try
	{
		int ready = 0;
		PyResourceFileType.tp_base = &PyBaseObject_Type;
		PyResourceFileType.tp_new = PyResourceFile::newResource;

		PyObject *m = NULL;

		m = PyModule_Create (&wadsmodule);
		if (m == NULL)
			handleException ();

		ready = PyType_Ready (&PyResourceFileType);
		if (ready == -1)
			handleException ();

		PyModule_AddObject(m, "ResourceFile", (PyObject *)&PyResourceFileType);

		return m;
	}
	catch (PythonException &e)
	{
		PyErr_Restore (e.extype, e.exvalue, e.extraceback);
		return NULL;
	}
}
