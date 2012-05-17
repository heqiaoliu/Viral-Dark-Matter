function OptimInfo = minimize(this)
%MINIMIZE  Runs the optimization algorithm to minimize the cost and
%   estimate the model parameters.

% Copyright 1986-2009 The MathWorks, Inc.
% $Revision: 1.1.10.8 $ $Date: 2009/10/16 04:56:49 $

% Initializations.
pinfo = this.Info;
p = pinfo.Value;
isDet = strcmpi(this.Options.Criterion,'det');

% apply inv(sqrtm(lambda)) scaling only for det criterion
%this.Options.doSqrlam = isDet; 

ComputeProj = this.Options.ComputeProjFlag;
this.Options.ProjectionFun = @LocalUpdateProjection;
InfeasibleJac = false;
InfiniteCost = false;

% Call minimizer.
[xnew, resnorm, ~, exitflag, output] = ...
    idminimizer(@LocalCostFun, p, pinfo.Minimum, pinfo.Maximum, this.Options, this);

if InfeasibleJac && ~InfiniteCost
    exitflag = -5;
end

% Output.
OptimInfo = struct('Cost',     resnorm, ...
    'X',        xnew, ...
    'ExitFlag', exitflag, ...
    'Output',   output );

this.info.Value = xnew; %may not be same if optim failed
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Nested function.                                                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function [cost, truelam, varargout] = LocalCostFun(x, varargin)
        % Compute residual vector and its Jacobian.
        JacRequest = (nargout > 2);

        if ComputeProj && JacRequest
            x = [];
        end

        this.Info.Value = x;

        [costmat, truelam, R, J] = ...
            getErrorAndJacobian(this.Model, this.Data, this.Info, this.Options, JacRequest);

        if isDet
            cost = real(det(costmat));
            
            if isfield(this.Options,'struc')
                % store innovations info for x0 estimation
                if ~any(costmat(:)) || ~all(isfinite(costmat(:))) || ...
                        norm(costmat)<eps || any(eig(costmat)<=0)
                    %% This is to protect from strange initial model
                    costmat = eye(size(costmat));
                end
                this.Options.struc.lambda = costmat;
            end
            
        else
            cost = real(trace(costmat));
        end

        if ~isfinite(cost)
            cost = Inf;
        elseif cost<0
            cost = 0;
        end

        if JacRequest
            if any(~isfinite(J(:)))
                % This can happen if Jacobian is divergent.  
                J = zeros(size(J));
                InfeasibleJac = true;
                InfiniteCost = isinf(cost);
            end
            
            if any(~isfinite(R(:)))
                R = inf(size(R));
            end
                
            varargout{1} = R;
            varargout{2} = J;
        end

    end %function

%--------------------------------------------------------------------
    function LocalUpdateProjection(x)
        % update Projection matrix for SSfree case
        if ComputeProj
             % update model parameters stored in struc
            struc = ssfrupd(x,this.Options.struc);
            
            % compute data-driven projection matrix
            Qperp = utComputeProjection(struc); % updates Qperp
            struc.Qperp = Qperp;
            this.Options.struc = struc;
        end
    end %function 
end %function