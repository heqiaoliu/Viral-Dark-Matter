function eval(this)
%EVAL Evaluate the strings

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:26:15 $

eval(this.string);
w = whos;
w = {w.name};

for indx = 1:length(w)
    if ~strcmpi(w{indx}, 'this')
        assignin('caller', w{indx}, eval(w{indx}));
    end
end

% [EOF]
