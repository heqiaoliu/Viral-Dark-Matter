function ft_syncGUIvals(h,d,arrayh)
%SYNCGUIVALS Sync values from frames.
%
%   Inputs:
%       h - handle to this object
%       d - handle to design method
%       arrayh - array of handles to frames


%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/15 00:27:48 $

specObjs = get(h,'specobjs');

for n = 1:length(specObjs),
	syncGUIvals(specObjs(n),d,arrayh);
end



