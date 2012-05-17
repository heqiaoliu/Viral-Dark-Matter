%TEXTSCAN Read formatted data from text file or string.
%   C = TEXTSCAN(FID,'FORMAT') reads data from an open text file identified
%   by FID into cell array C. Use FOPEN to open the file and obtain FID. 
%   The FORMAT is a string of conversion specifiers enclosed in single 
%   quotation marks. The number of specifiers determines the number of 
%   cells in the cell array C.  For more information, see "Format Options."
%   
%   C = TEXTSCAN(FID,'FORMAT',N) reads data from the file, using the FORMAT
%   N times, where N is a positive integer. To read additional data from 
%   the file after N cycles, call TEXTSCAN again using the original FID.
%
%   C = TEXTSCAN(FID,'FORMAT','PARAM',VALUE) accepts one or more
%   comma-separated parameter name/value pairs. For a list of parameters 
%   and values, see "Parameter Options."
%
%   C = TEXTSCAN(FID,'FORMAT',N,'PARAM',VALUE) reads data from the 
%   file, using the FORMAT N times, and using settings specified by pairs
%   of PARAM/VALUE arguments.
%
%   C = TEXTSCAN(STR,...) reads data from string STR. You can use the 
%   FORMAT, N, and PARAM/VALUE arguments described above with this syntax.
%   However, for strings, repeated calls to TEXTSCAN restart the scan from 
%   the beginning each time. (To restart a scan from the last position, 
%   request a POSITION output.  See also Example 3.)
%
%   [C, POSITION] = TEXTSCAN(...) returns the file or string position at 
%   the end of the scan as the second output argument. For a file, this is 
%   the value that FTELL(FID) would return after calling TEXTSCAN. For a 
%   string, POSITION indicates how many characters TEXTSCAN read.  
%
%   Notes:
%
%   When TEXTSCAN reads a specified file or string, it attempts to match 
%   the data to the format string. If TEXTSCAN fails to convert a data 
%   field, it stops reading and returns all fields read before the failure. 
%
%   Format Options:
%
%   The FORMAT string is of the form:  %<WIDTH>.<PREC><SPECIFIER>
%       <SPECIFIER> is required; <WIDTH> and <PREC> are optional.
%       <WIDTH> is the number of characters or digits to read.
%       <PREC> applies only to the family of %f specifiers, and specifies 
%       the number of digits to read to the right of the decimal point. 
%
%   Supported values for SPECIFIER:
%
%       Numeric Input Type   Specifier   Output Class
%       ------------------   ---------   ------------
%       Integer, signed        %d          int32
%                              %d8         int8
%                              %d16        int16
%                              %d32        int32
%                              %d64        int64
%       Integer, unsigned      %u          uint32
%                              %u8         uint8
%                              %u16        uint16
%                              %u32        uint32
%                              %u64        uint64
%       Floating-point number  %f          double
%                              %f32        single
%                              %f64        double
%                              %n          double
%
%       TEXTSCAN converts numeric fields to the specified output type
%       according to MATLAB rules regarding overflow, truncation, and the 
%       use of NaN, Inf, and -Inf.  For example, MATLAB represents an
%       integer NaN as zero.
%
%       TEXTSCAN imports any complex number as a whole into a complex 
%       numeric field, converting the real and imaginary parts to the 
%       specified type (such as %d or %f). Do not include embedded white
%       space in a complex number.
%
%       Character Strings  Specifier  Details
%       -----------------  ---------  -------------------------
%       Strings              %s       String
%                            %q       String, possibly double-quoted
%                            %c       Single character, including delimiter
%       Pattern-matching     %[...]   Read only characters in the brackets,
%                                     until the first nonmatching 
%                                     character. To include ] in the set, 
%                                     specify it first: %[]...].
%                            %[^...]  Read only characters not in the
%                                     brackets, until the first matching
%                                     character. To exclude ], specify it
%                                     first: %[^]...].
%
%       For each character (%c) specifier, TEXTSCAN returns a char array.
%       Other string specifiers return a cell array of strings.
%
%   Skipping fields or parts of fields:
%
%       Specifier  Action Taken
%       ---------  ------------
%         %*...    Skip the field. TEXTSCAN does not create an output cell.
%         %*N...   Ignore N characters of the field, where N is an integer
%                  less than or equal to the number of characters in the
%                  field.
%
%       Alternatively, include literal text to ignore in the specifier.
%       For example, 'Level%u8' reads 'Level1' as 1.
%
%       TEXTSCAN does not include leading white-space characters in the
%       processing of any data fields. When processing numeric data, 
%       TEXTSCAN also ignores trailing white space.
%
%       If you use the default (white space) field delimiter, TEXTSCAN 
%       interprets repeated white-space characters as a single delimiter. 
%       If you specify a nondefault delimiter, TEXTSCAN interprets repeated
%       delimiter characters as separate delimiters, and returns an empty 
%       value to the output cell.
%
%   Parameter Options:
%
%        Parameter      Value                               Default
%        ---------      -----                               -------
%        BufSize        Maximum string length in bytes      4095
%
%        CollectOutput  If true, TEXTSCAN concatenates      0 (false)
%                       consecutive output cells with the
%                       same data type into a single array.
%
%        CommentStyle   Symbol(s) designating text to       None
%                       ignore. Specify a single string
%                       (such as '%') to ignore characters
%                       following the string on the same
%                       line. Specify a cell array of two 
%                       strings (such as {'/*', '*/'}) to 
%                       ignore characters between the
%                       strings. TEXTSCAN checks for
%                       comments only at the start of each
%                       field, not within a field.
%
%        Delimiter      Field delimiter character(s)        White space 
%
%        EmptyValue     Value to return for empty numeric   NaN
%                       fields in delimited files
%
%        EndOfLine      End-of-line character               Determined 
%                                                           from file: 
%                                                           \n, \r, or \r\n
%
%        ExpChars       Exponent characters                 'eEdD'
%
%        Headerlines    Number of lines to skip. Includes   0
%                       the remainder of the current line.
%
%        MultipleDelimsAsOne                                0 (false)
%                       If true, TEXTSCAN treats 
%                       consecutive delimiters as a single 
%                       delimiter. Only valid if you 
%                       specify the 'Delimiter' option.
%
%        ReturnOnError  Determines behavior when TEXTSCAN   1 (true)
%                       fails to read or convert.  If true,
%                       TEXTSCAN terminates without error
%                       and returns all fields read.  If 
%                       false, TEXTSCAN terminates with an
%                       error and does not return an output
%                       cell array.
%
%        TreatAsEmpty	String(s) in the data file to       None
%                       treat as an empty value. Can be a
%                       single string or cell array of
%                       strings. Only applies to numeric
%                       fields.
%
%        Whitespace     White-space characters              ' \b\t'
%
%   Examples:
%
%   Example 1: Read each column of a text file.
%       Suppose the text file 'mydata.dat' contains the following:
%           Sally Level1 12.34 45 1.23e10 inf Nan Yes 5.1+3i
%           Joe   Level2 23.54 60 9e19 -inf  0.001 No 2.2-.5i
%           Bill  Level3 34.90 12 2e5   10  100   No 3.1+.1i
%
%       Read the file:
%           fid = fopen('mydata.dat');
%           C = textscan(fid, '%s%s%f32%d8%u%f%f%s%f');
%           fclose(fid);
%
%       TEXTSCAN returns a 1-by-9 cell array C with the following cells:
%           C{1} = {'Sally','Joe','Bill'}            %class cell
%           C{2} = {'Level1'; 'Level2'; 'Level3'}    %class cell
%           C{3} = [12.34;23.54;34.9]                %class single
%           C{4} = [45;60;12]                        %class int8
%           C{5} = [4294967295; 4294967295; 200000]  %class uint32
%           C{6} = [Inf;-Inf;10]                     %class double
%           C{7} = [NaN;0.001;100]                   %class double 
%           C{8} = {'Yes','No','No'}                 %class cell
%           C{9} = [5.1+3.0i; 2.2-0.5i; 3.1+0.1i]    %class double
%
%       The first two elements of C{5} are the maximum values for a 32-bit 
%       unsigned integer, or intmax('uint32').
%
%   Example 2: Read a string, truncating each value to one decimal digit.
%       str = '0.41 8.24 3.57 6.24 9.27';
%       C = textscan(str, '%3.1f %*1d');
%       
%       TEXTSCAN returns a 1-by-1 cell array C:
%           C{1} = [0.4; 8.2; 3.5; 6.2; 9.2]
%
%   Example 3: Resume a text scan of a string.
%       lyric = 'Blackbird singing in the dead of night';
%       [firstword, pos] = textscan(lyric,'%9c', 1);      %first word
%       lastpart = textscan(lyric(pos+1:end), '%s');      %remaining text
%
%   For additional examples, type "doc textscan" at the command prompt.
%
%   See also FOPEN, FCLOSE, LOAD, IMPORTDATA, UIIMPORT, DLMREAD, XLSREAD, FSCANF, FREAD.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.19 $ $Date: 2009/10/24 19:18:21 $

%   Package: libmwbuiltins
%   Built-in function.

