function examples = getexamples(this)
%GETEXAMPLES   Get the examples.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:29:08 $

examples = {{...
    'Complex Bandpass Filter',...
    'f=fdesign.arbmagnphase(''N,F,H'',7);',...
    'design(f,''iirls'');',...
    }};


% [EOF]
