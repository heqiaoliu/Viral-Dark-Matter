function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:29:15 $

examples = {{...
    'Complex Bandpass Filter',...
    'f=fdesign.arbmagnphase(''Nb,Na,F,H'',7,7);',...
    'design(f,''iirls'');',...
    }};


% [EOF]
