/*
** py_cpp.cpp
** Python wrappers for common objects and functionality.
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

#include "doomtype.h"
#include "v_text.h"

namespace PyCPP
{
	void handleException ()
	{
		PyObject *ptype = NULL;
		PyObject *pvalue = NULL;
		PyObject *ptraceback = NULL;

		PyErr_Fetch (&ptype, &pvalue, &ptraceback);

		if (!ptype)
			return;

		throw PythonException (ptype, pvalue, ptraceback);
	}

	void raiseException (PyObject *type, const char *message)
	{
		PyErr_SetString (type, message);
		handleException ();
	}

	// Object

	// Operator overloads

	Object::operator PyObject *()
	{
		return this->ptr;
	}

	bool Object::operator< (Object other)
	{
		int result = PyObject_RichCompareBool (this->ptr, other, Py_LT);
		if (result == -1)
			handleException ();
		
		return result? true : false;
	}

	bool Object::operator<= (Object other)
	{
		int result = PyObject_RichCompareBool (this->ptr, other, Py_LE);
		if (result == -1)
			handleException ();
		
		return result? true : false;
	}

	bool Object::operator== (Object other)
	{
		int result = PyObject_RichCompareBool (this->ptr, other, Py_EQ);
		if (result == -1)
			handleException ();
		
		return result? true : false;
	}

	bool Object::operator!= (Object other)
	{
		int result = PyObject_RichCompareBool (this->ptr, other, Py_NE);
		if (result == -1)
			handleException ();
		
		return result? true : false;
	}

	bool Object::operator> (Object other)
	{
		int result = PyObject_RichCompareBool (this->ptr, other, Py_GT);
		if (result == -1)
			handleException ();
		
		return result? true : false;
	}

	bool Object::operator>= (Object other)
	{
		int result = PyObject_RichCompareBool (this->ptr, other, Py_GE);
		if (result == -1)
			handleException ();
		
		return result? true : false;
	}

	// Basic functions

	Object Object::newRef ()
	{
		Py_INCREF (this->ptr);
		return *this;
	}

	bool Object::hasAttr (Object attrName)
	{
		return PyObject_HasAttr (this->ptr, attrName)? true : false;
	}

	bool Object::hasAttr (const char *attrName)
	{
		return PyObject_HasAttrString (this->ptr, attrName)? true : false;
	}

	Object Object::getAttr (Object attrName)
	{
		PyObject *other = PyObject_GetAttr (this->ptr, attrName);
		if (!other)
			handleException ();

		return Object (other, false);
	}

	Object Object::getAttr (const char *attrName)
	{
		PyObject *other = PyObject_GetAttrString (this->ptr, attrName);
		if (!other)
			handleException ();

		return Object (other, false);
	}

	void Object::setAttr (Object attrName, Object attrValue)
	{
		int success = PyObject_SetAttr (this->ptr, attrName, attrValue);
		if (success == -1)
			handleException ();
	}

	void Object::setAttr (const char *attrName, Object attrValue)
	{
		int success = PyObject_SetAttrString (this->ptr, attrName, attrValue);
		if (success == -1)
			handleException ();
	}

	void Object::delAttr (Object attrName)
	{
		int success = PyObject_DelAttr (this->ptr, attrName);
		if (success == -1)
			handleException ();
	}

	void Object::delAttr (const char *attrName)
	{
		int success = PyObject_DelAttrString (this->ptr, attrName);
		if (success == -1)
			handleException ();
	}

	Object Object::getItem (Object itemName)
	{
		PyObject *other = PyObject_GetItem (this->ptr, itemName);
		if (!other)
			handleException ();

		return Object (other, false);
	}

	void Object::setItem (Object itemName, Object itemValue)
	{
		int success = PyObject_SetItem (this->ptr, itemName, itemValue);
		if (success == -1)
			handleException ();
	}

	void Object::delItem (Object itemName)
	{
		int success = PyObject_DelItem (this->ptr, itemName);
		if (success == -1)
			handleException ();
	}

	Py_ssize_t Object::len ()
	{
		Py_ssize_t length = PyObject_Size (this->ptr);
		if (length == -1)
			handleException ();

		return length;
	}

	String Object::repr ()
	{
		PyObject *other = PyObject_Repr (this->ptr);
		if (!other)
			handleException ();

		return String (other, false);
	}

	String Object::ascii ()
	{
		PyObject *other = PyObject_ASCII (this->ptr);
		if (!other)
			handleException ();

		return String (other, false);
	}

	String Object::str ()
	{
		PyObject *other = PyObject_Str (this->ptr);
		if (!other)
			handleException ();

		return String (other, false);
	}

	Bytes Object::bytes ()
	{
		PyObject *other = PyObject_Bytes (this->ptr);
		if (!other)
			handleException ();

		return Bytes (other, false);
	}

	// Long

	// Operator overloads

	Long::operator long()
	{
		long l = PyLong_AsLong(this->ptr);
		if (PyErr_Occurred())
			handleException ();

		return l;
	}

	Long::operator long long()
	{
		long long ll = PyLong_AsLongLong(this->ptr);
		if (PyErr_Occurred())
			handleException ();

		return ll;
	}

	Long::operator Py_ssize_t()
	{
		Py_ssize_t sst = PyLong_AsSsize_t(this->ptr);
		if (PyErr_Occurred())
			handleException ();

		return sst;
	}

	Long::operator unsigned long()
	{
		unsigned long ul = PyLong_AsUnsignedLong(this->ptr);
		if (PyErr_Occurred())
			handleException ();

		return ul;
	}

	Long::operator unsigned long long()
	{
		unsigned long long ull = PyLong_AsUnsignedLongLong(this->ptr);
		if (PyErr_Occurred())
			handleException ();

		return ull;
	}

	Long::operator size_t()
	{
		size_t st = PyLong_AsSize_t(this->ptr);
		if (PyErr_Occurred())
			handleException ();

		return st;
	}

	Long::operator double()
	{
		double d = PyLong_AsDouble(this->ptr);
		if (PyErr_Occurred())
			handleException ();

		return d;
	}

	// Sequence

	// Operator overloads

	Sequence Sequence::operator+ (Sequence other)
	{
		PyObject *merged = PySequence_Concat (this->ptr, other);
		if (!merged)
			handleException ();

		return Sequence (merged, false);
	}

	Sequence Sequence::operator* (Py_ssize_t count)
	{
		PyObject *repeated = PySequence_Repeat(this->ptr, count);
		if (!repeated)
			handleException ();

		return Sequence (repeated, false);
	}

	Sequence Sequence::operator+= (Sequence other)
	{
		PyObject *merged = PySequence_InPlaceConcat (this->ptr, other);
		if (!merged)
			handleException ();

		return Sequence (merged, false);
	}

	Sequence Sequence::operator*= (Py_ssize_t count)
	{
		PyObject *repeated = PySequence_InPlaceRepeat(this->ptr, count);
		if (!repeated)
			handleException ();

		return Sequence (repeated, false);
	}

	// Basic functions

	Py_ssize_t Sequence::len ()
	{
		Py_ssize_t result = PySequence_Length(this->ptr);
		if (result == -1)
			handleException ();

		return result;
	}

	Object Sequence::get (Py_ssize_t index)
	{
		PyObject *item = PySequence_GetItem (this->ptr, index);
		if (!item)
			handleException ();

		return Object (item, false);
	}

	void Sequence::set (Py_ssize_t index, Object item)
	{
		int result = PySequence_SetItem (this->ptr, index, item);
		if (result == -1)
			handleException ();
	}

	void Sequence::del (Py_ssize_t index)
	{
		int result = PySequence_DelItem (this->ptr, index);
		if (!result)
			handleException ();
	}

	Sequence Sequence::getSlice (Py_ssize_t start, Py_ssize_t end)
	{
		PyObject *slice = PySequence_GetSlice (this->ptr, start, end);
		if (!slice)
			handleException ();

		return Sequence (slice, false);
	}

	void Sequence::setSlice (Py_ssize_t start, Py_ssize_t end, Object item)
	{
		int result = PySequence_SetSlice (this->ptr, start, end, item);
		if (result == -1)
			handleException ();
	}

	void Sequence::delSlice (Py_ssize_t start, Py_ssize_t end)
	{
		int result = PySequence_DelSlice (this->ptr, start, end);
		if (result == -1)
			handleException ();
	}

	Py_ssize_t Sequence::count (Object item)
	{
		Py_ssize_t count = PySequence_Count (this->ptr, item);
		if (count == -1)
			handleException ();

		return count;
	}

	bool Sequence::contains (Object item)
	{
		int result = PySequence_Contains (this->ptr, item);
		if (result == -1)
			handleException ();

		return result? true : false;
	}

	Py_ssize_t Sequence::indexOf (Object item)
	{
		Py_ssize_t result = PySequence_Index (this->ptr, item);
		if (result == -1)
			handleException ();

		return result;
	}

	Sequence Sequence::asList ()
	{
		PyObject *list = PySequence_List (this->ptr);
		if (!list)
			handleException ();

		return Sequence (list, false);
	}

	Sequence Sequence::asTuple ()
	{
		PyObject *tup = PySequence_Tuple (this->ptr);
		if (!tup)
			handleException ();

		return Sequence (tup, false);
	}

	// Tuple

	// Basic functions

	Py_ssize_t Tuple::len ()
	{
		Py_ssize_t result = PyTuple_Size (this->ptr);
		if (result == -1)
			handleException ();

		return result;
	}

	Object Tuple::get (Py_ssize_t index)
	{
		PyObject *item = PyTuple_GetItem (this->ptr, index);
		if (!item)
			handleException ();

		return Object (item, false);
	}

	void Tuple::set (Py_ssize_t index, Object item)
	{
		int result = PyTuple_SetItem (this->ptr, index, item);
		if (result == -1)
			handleException ();
	}

	Sequence Tuple::getSlice (Py_ssize_t start, Py_ssize_t end)
	{
		PyObject *list = PyTuple_GetSlice (this->ptr, start, end);
		if (!list)
			handleException ();

		return Sequence (list, false);
	}

	void Tuple::resize (Py_ssize_t newsize)
	{
		PyObject *thistup = this->ptr;
		if (thistup->ob_refcnt > 1)
		{
			assert (false);
			DPrintf (TEXTCOLOR_RED"Attempted to resize tuple with references");
			return;
		}

		int result = _PyTuple_Resize (&thistup, newsize);
		if (!result)
			handleException ();

		this->ptr = thistup;
	}

	// List

	// Basic functions

	Py_ssize_t List::len ()
	{
		Py_ssize_t result = PyList_Size (this->ptr);
		if (result == -1)
			handleException ();

		return result;
	}

	Object List::get (Py_ssize_t index)
	{
		PyObject *item = PyList_GetItem (this->ptr, index);
		if (!item)
			handleException ();

		return Object (item, true);
	}

	void List::set (Py_ssize_t index, Object item)
	{
		int result = PyList_SetItem (this->ptr, index, item);
		if (result == -1)
			handleException ();
	}

	Sequence List::getSlice (Py_ssize_t start, Py_ssize_t end)
	{
		PyObject *list = PyList_GetSlice (this->ptr, start, end);
		if (!list)
			handleException ();

		return Sequence (list, false);
	}

	void List::setSlice (Py_ssize_t start, Py_ssize_t end, Object item)
	{
		int result = PyList_SetSlice (this->ptr, start, end, item);
		if (result == -1)
			handleException ();
	}

	void List::delSlice (Py_ssize_t start, Py_ssize_t end)
	{
		int result = PyList_SetSlice (this->ptr, start, end, NULL);
		if (result == -1)
			handleException ();
	}

	void List::insert (Py_ssize_t index, Object item)
	{
		int result = PyList_Insert (this->ptr, index, item);
		if (result == -1)
			handleException ();
	}

	void List::append (Object item)
	{
		int result = PyList_Append (this->ptr, item);
		if (result == -1)
			handleException ();
	}

	void List::sort ()
	{
		int result = PyList_Sort (this->ptr);
		if (result == -1)
			handleException ();
	}

	void List::reverse ()
	{
		int result = PyList_Reverse (this->ptr);
		if (result == -1)
			handleException ();
	}

	// String

	// Operator overloads

	String String::operator+ (String combine)
	{
		PyObject *other = PyUnicode_Concat (this->ptr, combine);
		if (!other)
			handleException ();

		return String (other, false);
	}

	// Basic functions

	List String::split (String *sep, Py_ssize_t maxsplit)
	{
		PyObject *list = NULL;
		if (sep)
			list = PyUnicode_Split(this->ptr, *sep, maxsplit);
		else
			list = PyUnicode_Split(this->ptr, NULL, maxsplit);

		if (!list)
			handleException ();

		return List (list, false);
	}

	List String::splitlines (bool keepends)
	{
		PyObject *list = PyUnicode_Splitlines(this->ptr, keepends? 1 : 0);
		if (!list)
			handleException ();

		return List (list, false);
	}

	String String::join (Sequence seq)
	{
		PyObject *joined = PyUnicode_Join(this->ptr, seq);
		if (!joined)
			handleException ();

		return String (joined, false);
	}

	Py_ssize_t String::find (String substr, Py_ssize_t start, Py_ssize_t end, int direction)
	{
		Py_ssize_t loc = PyUnicode_Find(this->ptr, substr, start, end, direction);
		if (loc == -2)
			handleException ();

		return loc;
	}

	Py_ssize_t String::count (String substr, Py_ssize_t start, Py_ssize_t end)
	{
		Py_ssize_t amt = PyUnicode_Count(this->ptr, substr, start, end);
		if (amt == -1)
			handleException ();

		return amt;
	}

	String String::replace (String substr, String replstr, Py_ssize_t maxcount)
	{
		PyObject *repl = PyUnicode_Replace(this->ptr, substr, replstr, maxcount);
		if (!repl)
			handleException ();

		return String (repl, false);
	}

	Bytes String::asBytes ()
	{
		PyObject *_byteStr = PyUnicode_AsEncodedString (this->ptr, "cp1252", "strict");
		if (!_byteStr)
			handleException ();

		return Bytes (_byteStr, false);
	}

	// Bytes

	// Operator overloads

	Bytes::operator char *()
	{
		return PyBytes_AsString (this->ptr);
	}

	// Basic functions

	char *Bytes::toChar ()
	{
		return PyBytes_AsString (this->ptr);
	}

	// Mapping

	// Basic functions

	Py_ssize_t Mapping::len ()
	{
		Py_ssize_t size = PyMapping_Size (this->ptr);
		if (size == -1)
			handleException ();

		return size;
	}

	bool Mapping::hasKey (Object key)
	{
		return PyMapping_HasKey (this->ptr, key)? true : false;
	}

	bool Mapping::hasKey (const char *key)
	{
		return PyMapping_HasKeyString (this->ptr, const_cast<char *>(key))? true : false;
	}

	Object Mapping::getItem (const char *itemName)
	{
		PyObject *item = PyMapping_GetItemString (this->ptr, const_cast<char *>(itemName));
		if (!item)
			handleException ();

		return Object (item, false);
	}

	void Mapping::setItem (const char *itemName, Object itemValue)
	{
		int result = PyMapping_SetItemString (this->ptr, const_cast<char *>(itemName), itemValue);
		if (result == -1)
			handleException ();
	}

	void Mapping::delItem (const char *itemName)
	{
		int result = PyMapping_DelItemString (this->ptr, const_cast<char *>(itemName));
		if (result == -1)
			handleException ();
	}

	// Dict

	// Basic functions

	bool Dict::hasKey (Object key)
	{
		int result = PyDict_Contains (this->ptr, key);
		if (result == -1)
			handleException ();

		return result? true : false;
	}

	Object Dict::getItem (Object itemName)
	{
		PyObject *item = PyDict_GetItem(this->ptr, itemName);
		if (!item)
			raiseException (PyExc_KeyError, "Key not found");

		return Object (item, true);
	}

	Object Dict::getItem (const char *itemName)
	{
		PyObject *item = PyDict_GetItemString(this->ptr, itemName);
		if (!item)
			raiseException (PyExc_KeyError, "Key not found");

		return Object (item, true);
	}

	void Dict::setItem (Object itemName, Object itemValue)
	{
		int result = PyDict_SetItem(this->ptr, itemName, itemValue);
		if (result == -1)
			handleException ();
	}

	void Dict::setItem (const char *itemName, Object itemValue)
	{
		int result = PyDict_SetItemString(this->ptr, itemName, itemValue);
		if (result == -1)
			handleException ();
	}

	void Dict::delItem (Object itemName)
	{
		int result = PyDict_DelItem(this->ptr, itemName);
		if (result == -1)
			handleException ();
	}

	void Dict::delItem (const char *itemName)
	{
		int result = PyDict_DelItemString(this->ptr, itemName);
		if (result == -1)
			handleException ();
	}

	Dict Dict::copy ()
	{
		PyObject *newdict = PyDict_Copy(this->ptr);
		if (!newdict)
			handleException ();

		return Dict (newdict, false);
	}

	// Global functions

	bool isInstance (Object instance, Object kind)
	{
		int result = PyObject_IsInstance (instance, kind);
		if (result == -1)
			handleException ();

		return result? true : false;
	}
}
