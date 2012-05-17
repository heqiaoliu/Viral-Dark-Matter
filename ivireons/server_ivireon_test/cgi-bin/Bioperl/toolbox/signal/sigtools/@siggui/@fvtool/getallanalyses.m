function names = getallanalyses(this)
%GETALLANALYSES   Get all the analyses tags.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:23:54 $

info  = rmfield(get(this, 'AnalysesInfo'), 'tworesps');
names = fieldnames(info);

% [EOF]
