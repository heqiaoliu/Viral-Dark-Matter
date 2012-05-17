function detarget(h,Constr)
%DETARGET  Detargets edit dialog when deleting constraint.

%   Authors: P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:12 $

% RE: h = @tooleditor handle

if isequal(h.Container,h.Dialog.Container)
    % Deleted constraint belongs to currently targeted container: retarget as appropriate
    h.Dialog.target(h.Container);
end

