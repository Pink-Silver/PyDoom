#!python3
#cython: language_level=3

# Copyright (c) 2016, Kate Fox
# All rights reserved.
#
# This file is covered by the 3-clause BSD license.
# See the LICENSE file in this program's distribution for details.

from cpython.mem cimport PyMem_Malloc, PyMem_Free
from libc.stdio cimport SEEK_SET, FILE, fopen, fread, fclose, fseek, sscanf
from libc.string cimport strcasecmp, memset

cdef enum namespaces:
    NS_GLOBAL = 0
    NS_SPRITES = 1
    NS_FLATS = 2

class BadWad (Exception):
    """This exception is returned to indicate the file is not a valid wad."""
    pass

def is_wadfile (filename):
    """is_wadfile (filename) -> bool
    
    Returns True if the file is a wad file."""
    
    encodedfn = filename.encode ("utf8")
    
    cdef const char *fn = encodedfn
    cdef char[4] magic
    cdef FILE *f = NULL
    
    f = fopen (fn, "rb")
    
    if not f:
        raise IOError ("Could not open " + filename)
    
    fread (magic, 1, 4, f)
    fclose (f)
    
    if ((magic[0] == b"I" or magic[0] == b"P") and magic[1] == b"W" and
    magic[2] == b"A" and magic[3] == b"D"):
        return True
    
    return False

cdef class WadEntry:
    cdef int index
    cdef char[9] name
    cdef int namespace
    cdef size_t size

    cdef size_t pos
    cdef char *data
    cdef bint datafilled
    cdef FILE *fileno
    
    @property
    def index (self):
        return self.index
    
    @property
    def name (self):
        return self.name
    
    @property
    def namespace (self):
        return self.namespace
    
    @property
    def size (self):
        return self.size
    
    def __cinit__ (self, size_t size):
        self.size = size
        self.data = <char *>PyMem_Malloc (size)
        self.datafilled = False
    
    def __dealloc__ (self):
        PyMem_Free (self.data)
    
    def read (self):
        if self.datafilled:
            return self.data[0:self.size]
        
        if not self.fileno:
            raise ValueError ("Wad has already been closed, cannot read data")
        
        fseek (self.fileno, self.pos, SEEK_SET)
        fread (self.data, 1, self.size, self.fileno)
        
        return self.data[0:self.size]

cdef class WadFile:
    cdef list entries
    cdef FILE *fileno
    
    def __cinit__ (self, filename):
        cdef const char *fn = NULL
        
        encodedfn = filename.encode ("utf8")
        fn = encodedfn
        
        self.fileno = fopen (fn, "rb")
        
    def __dealloc__ (self):
        fclose (self.fileno)
    
    def __init__ (self, filename):
        cdef int namespace = NS_GLOBAL
        cdef char[4] magic
        cdef unsigned char[8] header
        cdef bint badmagic = True
        
        cdef int numlumps = 0
        cdef int infotableofs = 0
        cdef unsigned char[4] lumppos_b
        cdef size_t lumppos = 0
        cdef unsigned char[4] lumpsize_b
        cdef size_t lumpsize = 0
        cdef char[9] lumpname
        cdef WadEntry direntry = None
        
        cdef (const char *)[4] namespaceName = (
            b"S_START",
            b"S_END",
            b"F_START",
            b"F_END"
        )
        
        cdef bint[4] namespaceIsStart = (
            True,
            False,
            True,
            False
        )
        
        cdef int[4] namespaceType = (
            NS_SPRITES,
            NS_SPRITES,
            NS_FLATS,
            NS_FLATS
        )
        
        if not self.fileno:
            raise IOError ("Could not open " + filename + " for reading")
        
        self.entries = []
        
        memset (magic, 0, 4)
        fread (magic, 1, 4, self.fileno)
        
        if ((magic[0] == b"I" or magic[0] == b"P") and magic[1] == b"W" and
        magic[2] == b"A" and magic[3] == b"D"):
            badmagic = False
        
        if badmagic:
            raise BadWad ("Magic doesn't correspond to any known wad file type")
        
        memset (header, 0, 8)
        fread (header, 1, 8, self.fileno)

        numlumps  = header[0]
        numlumps |= header[1] << 8
        numlumps |= header[2] << 16
        numlumps |= header[3] << 24
        
        infotableofs  = header[4]
        infotableofs |= header[5] << 8
        infotableofs |= header[6] << 16
        infotableofs |= header[7] << 24
        
        fseek (self.fileno, infotableofs, SEEK_SET)
        
        for curlump in range (numlumps):
            memset (lumppos_b, 0, 4)
            memset (lumpsize_b, 0, 4)
            memset (lumpname, 0, 9)
            
            fread (lumppos_b, 1, 4, self.fileno)
            
            lumppos  = lumppos_b[0]
            lumppos |= lumppos_b[1] << 8
            lumppos |= lumppos_b[2] << 16
            lumppos |= lumppos_b[3] << 24
            
            fread (lumpsize_b, 1, 4, self.fileno)
            
            lumpsize  = lumpsize_b[0]
            lumpsize |= lumpsize_b[1] << 8
            lumpsize |= lumpsize_b[2] << 16
            lumpsize |= lumpsize_b[3] << 24
            
            fread (lumpname, 1, 8, self.fileno)
            
            direntry = WadEntry (lumpsize)
            
            direntry.index = curlump
            direntry.name = lumpname
            direntry.pos = lumppos
            direntry.fileno = self.fileno
            
            for i in range(4):
                if not strcasecmp (direntry.name, namespaceName[i]):
                    # Change namespace for further entries
                    if namespaceIsStart[i] == True:
                        namespace = namespaceType[i]
                    else:
                        namespace = NS_GLOBAL
            
            if direntry.size > 0:
                direntry.namespace = namespace
            
            self.entries.append (direntry)
    
    def __del__ (self):
        cdef WadEntry entry
        for entry in self.entries:
            entry.fileno = NULL
    
    def FindFirstLump (self, name):
        if type(name) != bytes:
            encodedname = name.encode ("iso-8859-1")
        else:
            encodedname = name
        cdef const char *strname = encodedname
        
        cdef WadEntry entry
        for entry in self.entries:
            if not strcasecmp (strname, entry.name):
                return entry
        
        return None
    
    def FindAllLumps (self, name):
        if type(name) != bytes:
            encodedname = name.encode ("iso-8859-1")
        else:
            encodedname = name
        cdef const char *strname = encodedname
        
        matches = []
        
        cdef WadEntry entry
        for entry in self.entries:
            if not strcasecmp (strname, entry.name):
                matches.append (entry)
        
        return matches
