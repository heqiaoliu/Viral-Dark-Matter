function h = resultreport(result)
%RESULTREPORT Construct a RESULTREPORT object
%   

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:50:08 $

error(nargchk(1, 1, nargin));

h = fxptui.resultreport;
h.result = result;
h.listeners = handle.listener(h.result, 'ObjectBeingDestroyed', @(s,e)cleanup(h));

function cleanup(h)
dlgs = DAStudio.ToolRoot.getOpenDialogs(h);
h.listeners = [];
delete(dlgs);

% [EOF]