%FSCANF Read formatted data from file.
%   [A,COUNT] = FSCANF(FID,FORMAT,SIZE) reads data from the file specified
%   by file identifier FID, converts it according to the specified FORMAT
%   string, and returns it in matrix A. COUNT is an optional output
%   argument that returns the number of elements successfully read. 
%   
%   FID is an integer file identifier obtained from FOPEN.
%   
%   SIZE is optional; it puts a limit on the number of elements that
%   can be read from the file; if not specified, the entire file 
%   is considered; if specified, valid entries are:
%
%       N      read at most N elements into a column vector.
%       inf    read at most to the end of the file.
%       [M,N]  read at most M * N elements filling at least an
%              M-by-N matrix, in column order. N can be inf, but not M.
%
%   If the matrix A results from using character conversions only and
%   SIZE is not of the form [M,N] then a row vector is returned.
%
%   FORMAT is a string containing ordinary characters and/or C language 
%   conversion specifications. Conversion specifications involve the 
%   character %, optional assignment-suppressing asterisk and width 
%   field, and conversion characters d, i, o, u, x, e, f, g, s, c, and 
%   [. . .] (scanset). Complete ANSI C support for these conversion 
%   characters is provided consistent with 'expected' MATLAB behavior. 
%   For a complete conversion character specification, see the Language 
%   Reference Guide or a C manual.
%
%   If %s is used an element read may cause several MATLAB matrix
%   elements to be used, each holding one character.  Use %c to read
%   space characters; the format %s skips all white space.
%
%   MATLAB reads characters using the encoding scheme associated with 
%   the file. See FOPEN for more information. If the format string 
%   contains ordinary characters, MATLAB matches each of those characters 
%   with a character read from the file after converting both to the 
%   MATLAB internal representation of characters.
%
%   Mixing character and numeric conversion specifications causes the
%   resulting matrix to be numeric and any characters read to show up
%   as their numeric values, one character per MATLAB matrix element.
%
%   FSCANF differs from its C language namesake in an important respect -
%   it is "vectorized" in order to return a matrix argument. The format
%   string is recycled through the file until an end-of-file is reached
%   or the amount of data specified by SIZE is read in.
%
%   Examples:
%       S = fscanf(fid,'%s')   reads (and returns) a character string.
%       A = fscanf(fid,'%5d')  reads 5-digit decimal integers.
%
%   See also FOPEN, FPRINTF, SSCANF, TEXTSCAN, FGETL, FGETS, FREAD, INPUT.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.13.4.6 $  $Date: 2009/11/16 22:26:45 $
%   Built-in function.

