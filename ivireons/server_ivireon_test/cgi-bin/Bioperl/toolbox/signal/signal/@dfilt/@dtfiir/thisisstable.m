function isstableflag = thisisstable(Hd)
%THISISSTABLE  True if filter is stable.
%   THISISSTABLE(Hd) returns 1 if discrete-time filter Hd is stable, and 0
%   otherwise. 

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $ $Date: 2002/07/29 21:42:33 $

% This should be private

isstableflag = false; % Assume unstable by default

if isfir(Hd),
    
    % Section is FIR, always stable
    isstableflag = true;
    
elseif signalpolyutils('isstable',Hd.Denominator),

    isstableflag = true;
end

    
            

