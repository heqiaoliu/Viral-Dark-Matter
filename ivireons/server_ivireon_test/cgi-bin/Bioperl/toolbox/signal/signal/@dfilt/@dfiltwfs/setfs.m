function setfs(Hd, fs)
%SETFS Set the FS of the filter/filters

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2007/12/14 15:08:27 $

if ~iscell(fs),
    set(Hd, 'Fs', fs);
else
    if length(fs) ~= length(Hd),
        error(generatemsgid('InvalidDimensions'),'Fs cell array must be the same length as the filters.');
    end
    
    for indx = 1:length(Hd),
        set(Hd(indx), 'Fs', fs{indx});
    end
end

send(Hd(1), 'NewFs', handle.EventData(Hd(1), 'NewFs'));

% [EOF]
