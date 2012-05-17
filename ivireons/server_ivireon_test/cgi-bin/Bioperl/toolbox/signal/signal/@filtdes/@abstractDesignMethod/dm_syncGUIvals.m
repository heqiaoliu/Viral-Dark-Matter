function dm_syncGUIvals(d,arrayh)
%SYNCGUIVALS Sync values from frames.
%
%   Inputs:
%       d - handle to this object
%       arrayh - array oh handles to objects


%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2007/12/14 15:11:53 $

error(nargchk(2,2,nargin,'struct'));

% Get information from filter type
h = get(d,'responseTypeSpecs');
syncGUIvals(h,d,arrayh);





