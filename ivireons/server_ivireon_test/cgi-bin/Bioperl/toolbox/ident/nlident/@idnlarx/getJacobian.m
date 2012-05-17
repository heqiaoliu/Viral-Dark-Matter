function [y,jac] = getJacobian(sys,u,X,Delays,LenCust,StdRegGains,CustRegGains)
%GETJACOBIAN Compute model output (at next sample) and derivative w.r.t.
%input for given input and state values. 

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/03/13 17:24:28 $

error(nargchk(3, 7, nargin,'struct'))
doJac = nargout>1; 
[ny,nu] = size(sys);

NL = sys.Nonlinearity;
CustReg = sys.CustomRegressors;
if ~iscell(CustReg)
    CustReg = {CustReg};
end

if nargin<4
    % Compute channel delays
    Delays = getDelayInfo(sys);
end

if nargin<5
    % Compute LenCust
    LenCust = zeros(1,ny);
    if ~isempty(CustReg)
        for ky = 1:ny
            LenCust(ky) = numel(CustReg{ky});
        end
    end
end

Nx = sum(Delays); % number of states
CumInd = [1,cumsum(Delays(1:end-1))+1];
XU = [X(:); u(:)];

if nargin<6
    % Compute [X;U] to regressor converter (matrix gain) for each output
    StdRegGains = state2stdreg(sys,Nx,CumInd);
end

if nargin<7
    % ny-by-1 cell array of 1-by-LenCust(ky) cell arrays
    CustRegGains = state2customreg(sys,CumInd,Nx,LenCust);
end

% initialize output and jacobian
y   = zeros(ny,1);
if doJac
    jac = zeros(ny,Nx+nu);
end

% Compute custom-reg contribution to regressor set
yC = cell(ny,1);
cumDel = CumInd-1;
for i = 1:ny
    if LenCust(i)>0
        yC{i} = utEvalCustomReg(sys, XU, cumDel, Nx, ny, i);
    end
end

% Compute output and derivative for each nonlinearity
for i = 1:ny
    regi = [ StdRegGains{i}*XU; yC{i} ]';
    if ~doJac
        %y(i) = getJacobian(NL(i), regi, false);
        y(i) = soevaluate(NL(i), regi);
    else
        [y(i),dum_,dy_dR] = getJacobian(NL(i), regi, false);
        dR_dXU = StdRegGains{i};

        if LenCust(i)>0
            Ci = CustReg{i};
            for j = 1:LenCust(i)
                Cij = Ci(j);

                % Matrix gain that selects a subset of
                % [X;U] as Arguments of Cij
                Kj = CustRegGains{i}{j};

                % Calculate derivative of Cij w.r.t. its arguments
                dCij_A = numjac(Cij,(Kj*XU)');

                % Calculate derivative of Cij w.r.t. [X;U]:
                dCij_XU = dCij_A*Kj;

                % Update dR_dXU by adding a new row for this custom
                % regressor
                dR_dXU = [dR_dXU; dCij_XU]; %#ok<AGROW>
            end
        end % if LenCust(i)>0

        % derivative w.r.t [X;U] for this output
        jac(i,:) = dy_dR*dR_dXU;
    end
end
