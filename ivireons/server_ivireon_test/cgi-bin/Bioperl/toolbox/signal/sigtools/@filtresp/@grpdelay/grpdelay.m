function h = grpdelay(varargin)
%GROUPDELAY Construct a groudelay object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/09/16 21:40:45 $

h = filtresp.grpdelay;

set(h, 'Name', 'Group Delay');

allPrm = h.frequencyresp_construct(varargin{:});

createparameter(h, allPrm, 'Group Delay Units', 'grpdelay', {'Samples', 'Time'});

% [EOF]
