function sys = linearize(nlsys,u0,x0)
%LINEARIZE Linearize Nonlinear ARX (IDNLARX) model.
%
% SYS = LINEARIZE(NLSYS, U0, X0) linearizes the IDNLARX model NLSYS about
% the operating point specified by input (U0) and state (X0) values. To
% determine U0 and X0 values from specifications, use commands such as
% FINDOP and FINDSTATES.
%
% SYS is returned as an LTI object of Control System Toolbox(TM) if that
% toolbox is available. Otherwise, SYS is returned as an IDPOLY or IDARX
% model of System Identification Toolbox(TM).
%
% LINEARIZE provides a linear model that is the best linear approximation
% for inputs that vary in a small neighbourhood of a constant input u(t) =
% U. This is the common linearization based on function expansion (also
% known as tangent linearization). For linear approximations over larger
% input ranges, it might be better to use the LINAPP command.
%
% See also IDNLARX/LINAPP, IDNLARX/FINDOP, IDNLARX/OPERSPEC,
% IDNLARX/FINDSTATES, IDNLHW/LINEARIZE.

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.10 $ $Date: 2009/12/05 02:04:33 $

error(nargchk(3, 3, nargin,'struct'))

% Model size
[ny,nu] = size(nlsys);

% Compute maximum channel delays
Delays = getDelayInfo(nlsys,'channelwise');
MaxDelays = max(Delays,[],1);
Nx = sum(MaxDelays);
CumInd = [1,cumsum(MaxDelays(1:end-1))+1];

[u0,x0] = LocalValidateData(u0,x0,nu,Nx);

% Compute Jacobian w.r.t states and input vector:[x0;u0]
%   y: ny-by-1 vector
%   jac: ny-by-(Nx+nu) matrix
[y,jac] = getJacobian(nlsys,u0,x0,MaxDelays);

% Compute A and B polynomials for each output
Acell = cell(ny);
Bcell = cell(ny,nu);

for ky = 1:ny
    [Acell(ky,:), Bcell(ky,:)] = ...
        LocalGetPolyCoeff(jac(ky,:),Delays(ky,:),CumInd,ky,nu,ny,Nx);
end

cstbinstalled = iscstbinstalled;
Ts = pvget(nlsys,'Ts');
Nam = inputname(1);
if isempty(Nam)
    Notes = sprintf('Obtained by linearization of IDNLARX model on %s',datestr(clock));
else
    Notes = sprintf('Obtained by linearization of IDNLARX model ''%s'' on %s',...
        Nam,datestr(clock));
end

commonPV = {'InputName',pvget(nlsys,'InputName'),...
    'OutputName',pvget(nlsys,'OutputName'),...
    'Name',pvget(nlsys,'Name'),'Notes',Notes};

idmodelPV =   {'InputUnit',pvget(nlsys,'InputUnit'),...
    'OutputUnit',pvget(nlsys,'OutputUnit')};

if ny==1
    if cstbinstalled && nu>0
        sys = tf(Bcell,Acell,Ts,'Variable','z^-1',commonPV{:});
    else
        %B = LocalCell2Poly(Bcell);
        if nu>0
            sys = idpoly(1,Bcell,[],1,Acell,'Ts',Ts,...
                commonPV{:},idmodelPV{:});
            sys = pvset(sys,'BFFormat',-1);
        else
            % time series 
            sys = idpoly(Acell{1},[],'Ts',Ts,commonPV{:},idmodelPV{:});
        end
        if cstbinstalled
            % time series model
            sys = tf(sys('noise'));
        end
    end
else
    if cstbinstalled
        if nu>0 && all(all(cellfun(@(x)isempty(x)||all(x==0), Acell) | diag(true(size(Acell,1),1))))
            % off diagonal elements of Acell are zero or empty = > outputs
            % are decoupled;
            %(diagonal polynomials are never empty or zero.)
            den =  repmat(diag(Acell),1,nu);
            sys =  tf(Bcell,den,Ts,'Variable','z^-1',commonPV{:});
        else
            [A,B] = LocalCell2Mat3D(Acell,Bcell);
            sys = idarx(A,B,Ts,commonPV{:},idmodelPV{:});
            if nu>0
                sys = ss(sys('meas'));
            else
                % time series model
                sys = ss(sys('noise'));
            end
        end
    else
        [A,B] = LocalCell2Mat3D(Acell,Bcell);
        sys = idarx(A,B,'Ts',Ts,commonPV{:},idmodelPV{:});
    end
end

%--------------------------------------------------------------------------
function [u0,x0] = LocalValidateData(u0,x0,nu,Nx)
% validate data u0 and x0 provided by user

if ~isrealvec(u0) || ~isequal(length(u0),nu) || any(~isfinite(u0))
    ctrlMsgUtils.error('Ident:transformation:linearizeInvalidInput',nu)
else
    u0 = u0(:);
end

if ~(isempty(x0) && Nx==0) && ~(isrealvec(x0) && isequal(length(x0),Nx) && all(isfinite(x0)))
    ctrlMsgUtils.error('Ident:transformation:linearizeInvalidStates',Nx)
else
    x0 = x0(:);
end

%--------------------------------------------------------------------------
function [A, B] = LocalGetPolyCoeff(jac,Delays,CumInd,yInd,nu,ny,Nx)
% separate out A and B polynomials from jac (row) vector

A = cell(1,ny);
B = cell(1,nu);

for ky = 1:ny
    % get number of states corresponding to this output in chosen jac
    del = Delays(ky);
    A{ky} = [ky==yInd, -jac(CumInd(ky):CumInd(ky)+del-1)];
end

for ku = 1:nu
    del = Delays(ny+ku);
    B{ku} = [jac(Nx+ku), jac(CumInd(ny+ku):CumInd(ny+ku)+del-1)];
end

%--------------------------------------------------------------------------
function [A,B] = LocalCell2Mat3D(Acell,Bcell)
% convert into IDARX format

[ny,nu] = size(Bcell);
La = cellfun('length',Acell);
A = zeros(ny,ny,max(La(:)));

for i = 1:ny
    for j = 1:ny
        A(i,j,1:La(i,j)) = Acell{i,j};
    end
end

Lb = cellfun('length',Bcell);
B = zeros(ny,nu,max(Lb(:)));
for i = 1:ny
    for j = 1:nu
        B(i,j,1:Lb(i,j)) = Bcell{i,j};
    end
end
