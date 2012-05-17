function sout = convertstatestruct(hObj,sin)
%CONVERTSTATESTRUCT Convert to the lastest structure

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2005/06/16 08:39:03 $

strs  = getstatefield(hObj);
props = allprops(hObj);
sin   = sin.(getfreqtype(hObj)).(strs{1});

try
    
    % Set up the common props
    sout.Tag       = class(hObj);
    sout.Version   = 0;
    sout.freqUnits = sin.units;
    sout.Fs        = sin.fs;
    
    % Loop over allprops to fill in the rest
    for indx = 1:min([length(sin.(strs{2})) length(props)])
        sout.(props{indx}) = sin.(strs{2}){indx};
    end
catch
    
    % If something goes wrong, the structure is not complete.  Return []
    sout = [];
end

% [EOF]
