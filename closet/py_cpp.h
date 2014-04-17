/*
** py_cpp.h
** Python wrappers for common objects and functionality. (Header)
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

#include <exception>
#include <string.h>
#include "zstring.h"

#define PY_SSIZE_T_CLEAN
#include <Python.h>

#define Py_RETURN(a) return Py_INCREF(a), a

namespace PyCPP
{
	class PythonException: public std::exception
	{
	public:
		PyObject *extype;
		PyObject *exvalue;
		PyObject *extraceback;

		PythonException (PyObject *etype, PyObject *eval, PyObject *etb) : extype (etype), exvalue (eval), extraceback (etb)
		{
			Py_XINCREF (this->extype);
			Py_XINCREF (this->exvalue);
			Py_XINCREF (this->extraceback);
		}

		PythonException (const PythonException &other)
		{
			this->extype      = other.extype;
			this->exvalue     = other.exvalue;
			this->extraceback = other.extraceback;
			Py_XINCREF (this->extype);
			Py_XINCREF (this->exvalue);
			Py_XINCREF (this->extraceback);
		}

		~PythonException ()
		{
			Py_XDECREF (this->extype);
			Py_XDECREF (this->exvalue);
			Py_XDECREF (this->extraceback);
		}
	};

	void handleException ();
	void raiseException (PyObject *type, const char *message);

	class Object;
	class   Long;
	class   Mapping;
	class     Dict;
	class Sequence;
	class   List;
	class   Tuple;
	class   String;
	class   Bytes;

	class Object
	{
	protected:
		PyObject *ptr;
	public:
		Object (PyObject *in_ptr, bool needref = true) : ptr (in_ptr)
		{
			if (this->ptr != NULL && needref)
				Py_INCREF (this->ptr);
		}

		Object (const Object &other)
		{
			this->ptr = other.ptr;
			Py_INCREF (this->ptr);
		}

		~Object ()
		{
			if (this->ptr != NULL)
			{
				assert (this->ptr->ob_refcnt > 0);
				Py_DECREF (this->ptr);
			}
		}

		// Operator overloads

		operator PyObject *();
		bool operator< (Object other);
		bool operator<= (Object other);
		bool operator== (Object other);
		bool operator!= (Object other);
		bool operator> (Object other);
		bool operator>= (Object other);

		// Basic functions

		Object newRef ();
		bool hasAttr (Object attrName);
		bool hasAttr (const char *attrName);
		Object getAttr (Object attrName);
		Object getAttr (const char *attrName);
		void setAttr (Object attrName, Object attrValue);
		void setAttr (const char *attrName, Object attrValue);
		void delAttr (Object attrName);
		void delAttr (const char *attrName);

		virtual Object getItem (Object itemName);
		virtual void setItem (Object itemName, Object itemValue);
		virtual void delItem (Object itemName);
		virtual Py_ssize_t len ();

		String repr ();
		String ascii ();
		String str ();
		Bytes bytes ();
	};

	class Long : public Object
	{
	public:
		Long (PyObject *in_ptr, bool needref = true) : Object (in_ptr, needref) {}
		Long (Py_ssize_t value = 0) : Object (NULL, false)
		{
			this->ptr = PyLong_FromSsize_t (value);
			if (!this->ptr)
				handleException ();
		}

		// Operator overrides

		operator long();
		operator long long();
		operator Py_ssize_t();
		operator unsigned long();
		operator unsigned long long();
		operator size_t();
		operator double();
	};

	class Sequence : public Object
	{
	public:
		Sequence (PyObject *in_ptr, bool needref = true) : Object (in_ptr, needref) {}

		// Operator overloads

		Sequence operator+ (Sequence other);
		Sequence operator* (Py_ssize_t count);
		Sequence operator+= (Sequence other);
		Sequence operator*= (Py_ssize_t count);

		// Basic functions

		virtual Py_ssize_t len ();
		virtual Object get (Py_ssize_t index);
		virtual void set (Py_ssize_t index, Object item);
		virtual void del (Py_ssize_t index);
		virtual Sequence getSlice (Py_ssize_t start, Py_ssize_t end);
		virtual void setSlice (Py_ssize_t start, Py_ssize_t end, Object item);
		virtual void delSlice (Py_ssize_t start, Py_ssize_t end);
		Py_ssize_t count (Object item);
		bool contains (Object item);
		Py_ssize_t indexOf (Object item);
		Sequence asList ();
		Sequence asTuple ();
	};

	class Tuple : public Sequence
	{
	public:
		Tuple (PyObject *in_ptr, bool needref = true) : Sequence (in_ptr, needref) {}
		Tuple (Py_ssize_t size = 0) : Sequence (NULL, false)
		{
			this->ptr = PyTuple_New (size);
			if (!this->ptr)
				handleException ();
		}

		// Basic functions

		virtual Py_ssize_t len ();
		virtual Object get (Py_ssize_t index);
		virtual void set (Py_ssize_t index, Object item);
		virtual Sequence getSlice (Py_ssize_t start, Py_ssize_t end);

		void resize (Py_ssize_t newsize);
	};

	class List : public Sequence
	{
	public:
		List (PyObject *in_ptr, bool needref = true) : Sequence (in_ptr, needref) {}
		List (Py_ssize_t size = 0) : Sequence (NULL, false)
		{
			this->ptr = PyList_New (size);
			if (!this->ptr)
				handleException ();
		}

		// Basic functions

		virtual Py_ssize_t len ();
		virtual Object get (Py_ssize_t index);
		virtual void set (Py_ssize_t index, Object item);
		virtual Sequence getSlice (Py_ssize_t start, Py_ssize_t end);
		virtual void setSlice (Py_ssize_t start, Py_ssize_t end, Object item);
		virtual void delSlice (Py_ssize_t start, Py_ssize_t end);

		void insert (Py_ssize_t index, Object item);
		void append (Object item);
		void sort ();
		void reverse ();
	};

	class Bytes : public Sequence
	{
	public:
		Bytes (PyObject *in_ptr, bool needref = true) : Sequence (in_ptr, needref) {}
		Bytes (const char* str, Py_ssize_t len = -1) : Sequence (NULL, false)
		{
			if (len < 0)
				len = strlen (str);
			this->ptr = PyBytes_FromStringAndSize(str, len);
			if (!this->ptr)
				handleException ();
		}
		Bytes (FString zstring) : Sequence (NULL, false)
		{
			this->ptr = PyBytes_FromStringAndSize(zstring.GetChars(), zstring.Len());
			if (!this->ptr)
				handleException ();
		}

		// Operator overloads

		operator char *();

		// Basic functions

		char *toChar();
	};

	class String : public Sequence
	{
	public:
		String (PyObject *in_ptr, bool needref = true) : Sequence (in_ptr, needref) {}
		String (Py_ssize_t size, Py_UCS4 charsize = 1114111) : Sequence (NULL, false)
		{
			this->ptr = PyUnicode_New (size, charsize);
			if (!this->ptr)
				handleException ();
		}
		String (const char *string, Py_ssize_t size = -1) : Sequence (NULL, false)
		{
			if (size < 0)
				size = strlen (string);
			this->ptr = PyUnicode_Decode (string, size, "cp1252", "ignore");
			if (!this->ptr)
				handleException ();
		}
		String (FString zstring) : Sequence (NULL, false)
		{
			this->ptr = PyUnicode_Decode (zstring.GetChars(), zstring.Len(), "cp1252", "ignore");
			if (!this->ptr)
				handleException ();
		}

		// Operator overloads

		String operator+ (String combine);

		// Basic functions

		List split (String *sep = NULL, Py_ssize_t maxsplit = -1);
		List splitlines (bool keepends = false);
		String join (Sequence seq);
		Py_ssize_t find (String substr, Py_ssize_t start, Py_ssize_t end, int direction = 1);
		Py_ssize_t count (String substr, Py_ssize_t start, Py_ssize_t end);
		String replace (String substr, String replstr, Py_ssize_t maxcount = -1);
		Bytes asBytes ();
	};

	class Mapping : public Object
	{
	public:
		Mapping (PyObject *in_ptr, bool needref = true) : Object (in_ptr, needref) {}

		// Basic functions

		virtual Py_ssize_t len ();
		virtual bool hasKey (Object key);
		virtual bool hasKey (const char *key);
		virtual Object getItem (const char *itemName);
		virtual void setItem (const char *itemName, Object itemValue);
		virtual void delItem (const char *itemName);
	};

	class Dict : public Mapping
	{
	public:
		Dict (PyObject *in_ptr, bool needref = true) : Mapping (in_ptr, needref) {}
		Dict () : Mapping (NULL, false)
		{
			this->ptr = PyDict_New ();
			if (!this->ptr)
				handleException ();
			Py_INCREF (this->ptr);
		}

		// Basic functions

		virtual bool hasKey (Object key);
		virtual Object getItem (Object itemName);
		virtual Object getItem (const char *itemName);
		virtual void setItem (Object itemName, Object itemValue);
		virtual void setItem (const char *itemName, Object itemValue);
		virtual void delItem (Object itemName);
		virtual void delItem (const char *itemName);

		Dict copy ();
	};

	// Global functions

	bool isInstance (Object instance, Object kind);

	// Extensions
#define NOARG_METHOD(modname, name) static PyObject * modname ## _ ## name (PyObject *, PyObject *)
#define VARARG_METHOD(modname, name) static PyObject * modname ## _ ## name (PyObject *, PyObject *args)
#define KEYWORD_METHOD(modname, name) static PyObject * modname ## _ ## name (PyObject *, PyObject *args, PyObject *kwds)

#define PYMODMETHOD(modname, name, type, doc) {#name, (PyCFunction)modname ## _ ## name, type, PyDoc_STR(doc)}
#define PYMODMETHOD_END {NULL, NULL}

#define NOARG_CLASSMETHOD(classname, name) static PyObject * classname ## :: ## name (PyObject *, PyObject *)
#define VARARG_CLASSMETHOD(classname, name) static PyObject * classname ## :: ## name (PyObject *, PyObject *args)
#define KEYWORD_CLASSMETHOD(classname, name) static PyObject * classname ## :: ## name (PyObject *, PyObject *args, PyObject *kwds)

#define PYCLASSMETHOD(classname, name, type, doc) {#name, (PyCFunction)classname ## :: ## name, type, PyDoc_STR(doc)}
#define PYCLASSMETHOD_END {NULL, NULL}

}
