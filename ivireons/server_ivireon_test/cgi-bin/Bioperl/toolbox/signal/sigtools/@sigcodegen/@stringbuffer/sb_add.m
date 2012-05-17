function sb_add(this, varargin)
%SB_ADD Concatenate string to end of string buffer
%
% See ADD for help.  This method is only here so that we can overload ADD
% in the subclasses.  Will be removed for R14LCS.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:17:46 $

[str, msg] = add_parser(this, varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

if ~iscell(str), str = {str}; end

% This is an append, so concat string to last string in buffer
if this.isempty,
    if isempty(str{1})
        if ~ischar(str{1}),
            this.cr;
        end
    else
        this.buffer = str(1);
    end
    str(1) = [];
end

for indx = 1:length(str)
    
    % If the entry is empty and a non string, this is a queue from the
    % parser that there used to be a \n there.  put it back
    if isempty(str{indx}) && ~ischar(str{indx}),
        this.cr;
    else
        this.buffer{end} = [this.buffer{end} str{indx}];
    end
end

% [EOF]
