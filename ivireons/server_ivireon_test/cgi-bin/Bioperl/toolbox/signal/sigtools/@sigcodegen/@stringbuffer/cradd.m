function cradd(this, varargin)
%CRADD Adds string with a carriage-return (CR) before it
%   H.CRADD(STR) adds a CR and then the string STR to the buffer.
%
%   H.CRADD(FMT, VAR1, VAR2, ...) adds a CR and then the formatted string.
%
%   See also STRINGBUFFER/ADD, STRINGBUFFER/ADDCR, STRINGBUFFER/CRADDCR,
%   STRINGBUFFER/CR, SPRINTF.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:17:43 $

[str, msg] = add_parser(this, varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

if isempty(this), this.cr; end

this.cr;
this.add(this.cr_parser(str));

% [EOF]
