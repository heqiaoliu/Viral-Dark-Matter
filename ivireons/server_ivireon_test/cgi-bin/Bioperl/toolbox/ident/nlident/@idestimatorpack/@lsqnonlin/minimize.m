function OptimInfo = minimize(this)
% MINIMIZE  Runs the optimization algorithm to minimize the cost and
%    estimate the model parameters.

% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.9 $ $Date: 2009/10/16 04:56:51 $

% Initializations.
pinfo = this.Info;
p = pinfo.Value;
InfeasibleJac = false;

%this.Options.doSqrlam = false;
if strcmpi(this.Options.Criterion, 'det')
    
    % Model may be a nonlinearity estimator, in which case, there is no
    % "Algorithm"
    if isa(this.Model,'idmodel') || isa(this.Model,'idnlmodel')
        this.Model.Algorithm.Criterion = 'trace';
    end
    
    if size(this.Options.Weighting,1)>1
        % multi-output case
        ctrlMsgUtils.warning('Ident:estimation:detNotSupportedLSQNONLIN')
    end
    
    this.Options.Criterion = 'trace';
end

% Call minimizer.
Displ = this.Options.Display;
this.Options.Display = 'off';
[xnew, resnorm, ~, exitflag, output] = ...
    lsqnonlin(@LocalCostFun, p, pinfo.Minimum, pinfo.Maximum, this.Options, this);
this.Options.Display = Displ;

if InfeasibleJac && exitflag==1
    exitflag = -5;
end

% Output.
OptimInfo = struct('Cost',     resnorm, ...
    'X',        xnew, ...
    'ExitFlag', exitflag, ...
    'Output',   output);

this.info.Value = xnew; %may not be same if optim failed

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Nested function.                                                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [R, J] = LocalCostFun(x, varargin)
        % Compute residual vector and its Jacobian.
        JacRequest = (nargout > 1);
        
        if ~JacRequest
            ctrlMsgUtils.error('Ident:estimation:unsupportedOptimAlgorithm',...
                length(x),sum(this.Options.DataSize))
        end
        
        this.Info.Value = x;
        
        [~, ~, R, J] = ...
            getErrorAndJacobian(this.Model, this.Data, this.Info, this.Options, JacRequest);
        
        if any(~isfinite(J(:)))
            % This can happen if Jacobian is divergent.
            J = zeros(size(J));
            InfeasibleJac = true;
        end
        
        if any(~isfinite(R(:)))
            R = realmax*ones(size(R));
        end
    end
end