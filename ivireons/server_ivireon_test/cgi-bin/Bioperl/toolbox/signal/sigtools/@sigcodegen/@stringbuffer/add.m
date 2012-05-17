function add(this, varargin)
%ADD Concatenate string to end of string buffer
%   H.ADD(STR) adds the string STR to end of the buffer.
%
%   H.ADD(FMT, VAR1, VAR2, ...) adds formatted string.  See SPRINTF for
%   more information about formatting strings.
%
%   See also STRINGBUFFER/ADDCR, STRINGBUFFER/CRADD, STRINGBUFFER/CRADDCR,
%   STRINGBUFFER/CR, SPRINTF.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/05/31 23:28:00 $

%  Call SB_ADD so subclasses can overload.
sb_add(this, varargin{:});

% [EOF]