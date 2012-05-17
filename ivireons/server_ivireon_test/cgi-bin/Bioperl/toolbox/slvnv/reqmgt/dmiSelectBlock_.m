function errMsg = dmiSelectBlock_(DOORSId, objString) %#ok<INUSL>
% This is only used when navigating from the Surrogate Module.
% Navigation from Requirements modules is using rmiobjnavigate()
%
% Copyright 2003-2010 The MathWorks, Inc.

	errMsg = rmisl.navDoorsToSl(objString);
    
    if ~isempty(errMsg)
        errordlg(errMsg, 'DOORS MATLAB Interface');
    end