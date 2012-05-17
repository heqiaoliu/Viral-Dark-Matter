function bool = thisisquantizable(Hd)
%THISISQUANTIZABLE Returns true if the dfilt object can be quantized

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:08:53 $

% This should be private

if length(Hd.Stage) > 1 & ~isa(Hd.Stage(1), 'dfilt.multistage'),
    bool = isa(Hd.Stage, class(Hd.Stage(1)));
else
    bool = false;
end

% [EOF]
