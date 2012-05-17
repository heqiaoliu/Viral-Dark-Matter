function a = setactive(h, a);
%SETACTIVE  Set active flag of multipath axes object.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:21:35 $

if a
    vis = 'on';
else
    vis = 'off';
end
setvisible(get(h.AxesHandle, 'child'), vis);
setvisible(h.AuxObjHandles, vis);
setvisible(h.AxesHandle, vis);

%--------------------------------------------------------------------------
function setvisible(h, vis)
if ~isempty(h), set(h, 'visible', vis); end
