function status = exist(hFDA)
%EXIST Determines if FDATool is still open
%   EXIST(HFDA) determines if the FDATool associated with HFDA is 
%   still open.

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2009/01/05 18:02:01 $

error(nargchk(1,1,nargin,'struct'));

hFig = get(hFDA,'figureHandle');
status = ishghandle(hFig);

% [EOF]
