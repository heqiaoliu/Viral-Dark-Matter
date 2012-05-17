function a = setactive(h, a);
%SETACTIVE  Set active flag of multipath axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/27 20:27:51 $

if a
    vis = 'on';
else
    vis = 'off';
end
setvisible(get(h.AxesHandle, 'child'), vis);
setvisible(h.AuxObjHandles, vis);
setvisible(h.AxesHandle, vis);
setvisible(get(h.AxesHandle,'xlabel'),vis);
setvisible(get(h.AxesHandle,'ylabel'),vis);
setvisible(get(h.AxesHandle,'title'),vis);

%--------------------------------------------------------------------------
function setvisible(h, vis)
if ~isempty(h), set(h, 'visible', vis); end
