function h = handles2vector(this)
%HANDLES2VECTOR Convert the handles structure to a vector

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.4 $  $Date: 2009/01/05 18:01:07 $

h = get(this,'Handles');

% The "controllers" are now uipanels.
if isfield(h, 'java')
    if isfield(h.java, 'controller')
        h.controller = h.java.controller;
    end
    h = rmfield(h, 'java');
end
    
h = convert2vector(h);

% Remove the non-handles.
h(~ishghandle(h)) = [];

% [EOF]
