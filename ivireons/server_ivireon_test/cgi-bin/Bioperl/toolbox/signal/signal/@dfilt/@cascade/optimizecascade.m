function Href = optimizecascade(this,Href,fn,varargin)
% This should be a private method.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:32:23 $


% Test if Fixed-Point Toolbox is installed
if ~isfixptinstalled,
    error(generatemsgid('fixptTbxRq'), ...
        'The Fixed-Point Toolbox must be available to optimize the coefficients word length.');
end

% Test if response type is supported
[isresponsesupported, errormsg, errorid] = iscoeffwloptimizable(this);
if ~isresponsesupported,
    error(generatemsgid(errorid), errormsg);
end

N = nstages(Href);
if iscell(fn),
    WL = fn{2};
    fn = fn{1};
    
    if length(WL) == 1,
        WL = WL*ones(N,1);
    elseif length(WL) ~= N,
        error(generatemsgid('wlVecWrongSize'),...
            'Wordlength vector must have the same length as the number of stages in the filter.');
    end
    try
        for i=1:N,
            Href.Stage(i) = fn(Href.Stage(i),WL(i),varargin{:});
        end
    catch ME,
        throwAsCaller(ME);
    end
else
    try
        for i=1:N,
            Href.Stage(i) = fn(Href.Stage(i),varargin{:});
        end
    catch ME,
        throwAsCaller(ME);
    end
end

setfdesign(Href,getfdesign(this));
setfmethod(Href, getfmethod(this));
