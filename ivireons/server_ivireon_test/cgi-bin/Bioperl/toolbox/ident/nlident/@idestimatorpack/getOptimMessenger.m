function h = getOptimMessenger(Model)
% return optim messenger, if one exists for various SITB models

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/11/09 20:18:27 $


h = [];
if isa(Model,'idnlmodel')
    h = pvget(Model,'OptimMessenger');
elseif isa(Model,'idnlfun')
    h = Model(1).OptimMessenger; %Model may be vector valued
elseif isa(Model,'idmodel')
    ut = pvget(Model,'Utility');
    if isfield(ut,'OptimMessenger')
        h = ut.OptimMessenger;
    end
end
