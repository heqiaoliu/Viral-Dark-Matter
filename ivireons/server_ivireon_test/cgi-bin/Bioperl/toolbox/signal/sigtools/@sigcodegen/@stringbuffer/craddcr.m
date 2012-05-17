function craddcr(this, varargin)
%CRADDCR Adds string with a carriage-return (CR) before and after it
%   H.CRADDCR(STR) adds the string STR to the buffer between two CRs.
%
%   H.CRADDCR(FMT, VAR1, VAR2, ...) adds the formatted string to the buffer
%   between two CRs.
%
%   See also STRINGBUFFER/ADD, STRINGBUFFER/ADDCR, STRINGBUFFER/CRADD,
%   STRINGBUFFER/CR, SPRINTF.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:17:44 $

% Call the parser, so that we can error out before carriage returns are
% added.
[str, msg] = add_parser(this, varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

if isempty(this), this.cr; end

this.cr;
this.add(this.cr_parser(str,2));
this.cr;

% [EOF]
