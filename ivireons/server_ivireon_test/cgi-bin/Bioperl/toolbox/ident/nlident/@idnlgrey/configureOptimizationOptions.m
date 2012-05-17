function option = configureOptimizationOptions(nlsys, algo, option, optimizer)
%CONFIGUREOPTIMIZATIONOPTIONS Configure model specific options to be used
%with given optimizer.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:53:44 $

option.NoiseVariance = pvget(nlsys,'NoiseVariance');

option.Display = algo.Display;
if strcmpi(algo.Display, 'full')
    option.Display = 'On';
end

% update Limit Error
lim = algo.LimitError;
par =  cat(1,{nlsys.Parameters.Value});
x0  =  cat(1, nlsys.InitialStates.Value);
%[x0, par] = var2obj(nlsys, optimizer.Info.Value);

% Compute prediction error.
[e, ysim, errflag] = getError(nlsys, optimizer.Data, x0, par);

if any(errflag)
    ctrlMsgUtils.error('Ident:estimation:infeasibleSimulation',nlsys.FileName);
end

e = cat(1, e{:}); % sum(n)-by-ny array.
lim = median(abs(e-ones(size(e, 1), 1)*median(e)))*lim/0.7;
if any(lim <= 0)
    lim = 0;
end

option.LimitError = lim;

% optimizer specific settings
switch class(optimizer)
    case 'idestimatorpack.lsqnonlin'
        option.TolX = algo.Advanced.MinParChange;
        
        % MaxFunEvals should be 'auto' or a number.
        m = algo.Advanced.MaxFunEvals;
        if isfloat(m)
            option.MaxFunEvals = m;
        end
    otherwise
        % nothing else required yet
end
