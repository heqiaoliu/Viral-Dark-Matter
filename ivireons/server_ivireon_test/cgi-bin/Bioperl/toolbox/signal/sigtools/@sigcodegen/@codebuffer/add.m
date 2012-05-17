function add(this, varargin)
%ADD Add the strings to the buffer.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:17:37 $

[str, msg] = add_parser(this, varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

if ~isempty(this.buffer)
    str = {[this.buffer{end} str{1}], str{2:end}};
    this.buffer{end} = '';
end

% Add it to the buffer with the superclass method.
this.sb_add(this.format(str));

% [EOF]
