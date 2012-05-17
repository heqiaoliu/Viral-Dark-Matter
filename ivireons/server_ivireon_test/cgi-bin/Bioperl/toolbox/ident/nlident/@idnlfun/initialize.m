function nlobj = initialize(nlobj,yvec,regmat,algo, hwcall)
%INITIALIZE initializes nonlinearity estimator
%
%  nlobj = initialize(nlobj,yvec,regmat,algo)
%
%  nlobj: nonlinearity estimator object array
%  yvec,regmat: cell arrays containing data
%  algo: Algorithm
%
%  hwcall: optional argument of logic value, true if called from IDNLHW
%  initialization functions.
%
% Note: each component of the object array nlobj is (re)initialized or not
% depending on its situation.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.7 $ $Date: 2008/10/02 18:53:32 $

% Author(s): Qinghua Zhang

if nargin<5
    hwcall = false;
end

ny = numel(nlobj);

idnlfunVecFlag = isa(nlobj,'idnlfunVector');

% Output dimension check
if ny~=numel(regmat)
    ctrlMsgUtils.error('Ident:estimation:nlEstimateCheck3')
end

% Input dimension check
for ky=1:ny
    nlky = getcomp(nlobj, ky);
    rdim = regdimension(nlky);
    if rdim>0 && rdim~=size(regmat{ky},2)
        % Reset initialization and retry
        nlky = initreset(nlky);
        rdim = regdimension(nlky);
        if rdim>0 && rdim~=size(regmat{ky},2)
            ctrlMsgUtils.error('Ident:estimation:nlEstimateCheck4')
        else
            nlobj = setcomp(nlobj, ky, nlky);
        end
    end
end

% Store RegressorRange
for ky=1:ny
    if idnlfunVecFlag
        nlobj.ObjVector{ky}.RegressorRange = [min(regmat{ky},[],1); max(regmat{ky},[],1)];
    else
        nlobj(ky).RegressorRange = [min(regmat{ky},[],1); max(regmat{ky},[],1)];
    end
end

randinitflag = isany(nlobj, 'ridgenet') || isany(nlobj, 'neuralnet');

if randinitflag
  % Back up current default random stream, and create a new one
  % with a fixed initial state.
  storedDflt = RandStream.setDefaultStream(RandStream('swb2712', 'seed', 100));  
end

% Process initialization of each component object of nlobj depending on its situation.
for ky=1:ny
    nlky = getcomp(nlobj, ky);
    if ~isdifferentiable(nlky)
        % Iterative esimation is impossible, always initialize.
        doInit = true;
    elseif isa(nlky, 'wavenet')
        switch lower(algo.IterWavenet)
            case {'auto', 'on'}
                doInit = ~isinitialized(nlky);
            case 'off'
                doInit = true;
            otherwise
                ctrlMsgUtils.error('Ident:utility:iterWavenetVal')
        end
    else
        doInit = ~isinitialized(nlky);
    end
    
    if doInit
        if isa(nlky, 'ridgenet')
            nlky = soinitialize(nlky,yvec{ky},regmat{ky},algo, hwcall);
        else
            nlky = soinitialize(nlky,yvec{ky},regmat{ky},algo);
        end
    end
    nlobj = setcomp(nlobj, ky, nlky);
end

if randinitflag
  % Restore backed up random stream
  RandStream.setDefaultStream(storedDflt);
end

% FILE END