function updateplot(hFit,newlim)
%UPDATEPLOT Update the plot of this fit

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:22:07 $
%   Copyright 2003-2006 The MathWorks, Inc.

if isequal(hFit.fittype, 'smooth')
    if nargin==1
        updatesmoothplot(hFit);
    else
        updatesmoothplot(hFit,newlim);
    end
else
    if nargin==1
        updateparamplot(hFit);
    else
        updateparamplot(hFit,newlim);
    end
end

dfswitchyard('dfupdatelegend', dfgetset('dffig'));
