function h = designwfs(f)
%DESIGNWFS Design filter and construct a dfiltwfs object 

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2007/03/13 19:50:10 $

h = design(f);

if strcmpi(f.freqUnits, 'normalized (0 to 1)'),
    fs = [];
else
    fs = convertfrequnits(get(f, 'Fs'), get(f, 'FreqUnits'), 'Hz');
end

h = dfilt.dfiltwfs(h, fs, sprintf('%s %s', xlate(get(f, 'ResponseType')), ...
    xlate(get(f, 'Tag'))));

% [EOF]
