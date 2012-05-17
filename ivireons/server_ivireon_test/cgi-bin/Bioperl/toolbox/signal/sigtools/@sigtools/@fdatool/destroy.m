function destroy(hFDA)
%DESTROY Destroy the session object

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2004/04/13 00:30:26 $

% Delete all the components.  Loop through them to call the correct destroy method.
% If called in vectorized form, it would call out to the base class destroy method.
hComps = allchild(hFDA);
delete(hComps);

% Delete the listeners
delete(hFDA.Listeners);

delete(hFDA.FigureHandle);
delete(hFDA);

% [EOF]
