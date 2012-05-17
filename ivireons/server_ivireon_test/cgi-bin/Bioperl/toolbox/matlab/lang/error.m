%ERROR  Display message and abort function.
%   ERROR('MSGID', 'ERRMSG', V1, V2, ...) displays a descriptive message
%   ERRMSG when the currently-running M-file program encounters an error
%   condition. Depending on how the program code responds to the error,
%   MATLAB then either enters a catch block to handle the error condition,
%   or exits the program.
%
%   MSGID is a unique message identifier string that MATLAB attaches to the
%   error message to better identify the source of the error (see MESSAGE
%   IDENTIFIERS, below). 
%
%   ERRMSG is a character string that informs the user about the cause of
%   the error and can also suggest how to correct the faulty condition. 
%   The ERRMSG string may include predefined escape sequences, such as 
%   \n for newline, and conversion specifiers, such as %d for a decimal 
%   number.
%
%   Inputs V1, V2, etc. represent values or substrings that are to
%   replace conversion specifiers used in the ERRMSG string. The format 
%   is the same as that used with the SPRINTF function.
%
%   ERROR('ERRMSG', V1, V2, ...) reports an error without including a 
%   message identifier in the error report.
%
%   ERROR('ERRMSG') is the same as the above syntax, except that the ERRMSG
%   string contains no conversion specifiers, no escape sequences, and no
%   substitution value (V1, V2, ...) arguments.
%
%   The ERROR function also determines where the error occurred, and 
%   provides this information in the STACK property of the structure 
%   returned by MException.last. This field contains a structure array 
%   that has the same format as the output of the DBSTACK function. This 
%   stack points to the line where the ERROR function was called.
%
%   ERROR(MSGSTRUCT) reports the error using the MSGID and MESSAGE stored
%   in the scalar structure MSGSTRUCT. This structure contains a MSGID and
%   MESSAGE field, and may also include a STACK field. If MSGSTRUCT does
%   contain a STACK field, then MATLAB sets the STACK field of the error 
%   to the STACK field of MSGSTRUCT.
%  
%   If MSGSTRUCT is an empty structure, no action is taken and ERROR
%   returns without exiting the M-file.
% 
%   MESSAGE IDENTIFIERS
%   A message identifier is a string of the form
% 
%       [component:]component:mnemonic
% 
%   that enables MATLAB to identify with a specific error. The string
%   consists of one or more COMPONENT fields followed by a single
%   MNEMONIC field. All fields are separated by colons. Here is an
%   example identifier that has 2 components and 1 mnemonic.
% 
%       'myToolbox:myFunction:fileNotFound'
% 
%   The COMPONENT and MNEMONIC fields must begin with an 
%   upper or lowercase letter which is then followed by alphanumeric  
%   or underscore characters. 
% 
%   The COMPONENT field specifies a broad category under which 
%   various errors can be generated. The MNEMONIC field is a string 
%   normally used as a tag related to the particular message.
% 
%   From the command line, you can obtain the message identifier for an 
%   error that has been issued using the MException.last function. 
%
%   See also MException, MException/throw, TRY, CATCH, SPRINTF, DBSTOP,
%            ERRORDLG, WARNING, DISP, DBSTACK.
    
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.12.4.13 $  $Date: 2009/09/03 05:24:57 $
%   Built-in function.
