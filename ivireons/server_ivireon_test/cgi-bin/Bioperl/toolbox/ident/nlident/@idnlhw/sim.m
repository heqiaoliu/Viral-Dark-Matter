function  z = sim(sys, data, varargin)
%SIM simulates a dynamic system with an IDNLHW model.
%
%  YS = SIM(MODEL, U)
%
%  MODEL: the IDNLHW model object.
%  U: the input data for simulation, an IDDATA object (where only the
%    input channels are used) or a matrix.
%  YS: the simulated output, an IDDATA object If DATA is an IDDATA
%    object, a matrix otherwise.
%
%  YS = SIM(MODEL,U,'Noise') produces a noise corrupted simulation with an
%    additive Gaussian noise scaled according to the value of the
%    NoiseVariance property of MODEL. (For particular user-chosen noise
%    sequences, see below.)
%
%  YS = SIM(MODEL, U, 'InitialState', INIT) allows to specify the
%    initialization.
%
%  INIT: initial condition specification, one of
%
%    - X0: a real column vector, for the initial state vector. To build an
%      initial state vector from a given set of input-output data or to
%      generate equilibrium states, see IDNLHW/FINDSTATES and IDNLHW/FINDOP.
%      For multi-experiment DATA, X0 may be a matrix whose columns give
%      different initial states for different experiments.
%
%    - 'z', zero initial state, equivalent to a zero vector of appropriate
%      size. This is the default value.
%
%  To make noisy simulations with particular user-chosen noises, the noise
%  signals E should be an IDDATA object or a matrix, in accordance with the
%  input data U. Let Ny be the number of outputs of MODEL. In the IDDATA
%  case, E contains Ny noises channels as input data, whereas its output
%  data is empty. In the matrix case, E has Ny columns corresponding to the
%  noise channels. In both cases the noisy simulation is made by
%  SIM(MODEL, [U E]).
%
%
%  See also IDNLHW/PREDICT, IDNLHW/FINDOP, IDNLHW/FINDSTATES, IDNLARX/SIM,
%  IDNLGREY/SIM, IDMODEL/SIM.

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2008/10/02 18:54:23 $

% Author(s): Qinghua Zhang

no = nargout;
was = warning;
warning('off','Ident:iddata:MoreOutputsThanSamples');
warning('off','Ident:iddata:MoreInputsThanSamples');
try
    if no==0
        LocalSim(sys,data,varargin{:})
    else
        z = LocalSim(sys,data,varargin{:});
    end
catch E
    warning(was)
    rethrow(E)
end
warning(was)

%--------------------------------------------------------------------------
function z = LocalSim(sys,data,varargin)
ni = nargin;
no = nargout;
error(nargchk(2,inf,ni, 'struct'));

if ni>2
    [xinit, defaultnoise] = ...
        simpredictoptions({'Noise', 'InitialState'}, {'z', 'm'}, varargin{:});
else
    % Default values
    xinit = 'z';
    defaultnoise = false;
end

% Interchange model and data arguments if necessary
if isa(sys,'iddata') && isa(data, 'idnlhw')
    tempo = sys;
    sys = data;
    data = tempo;
    clear tempo
end

if ~isa(sys,'idnlhw')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','sim','IDNLHW');
end

if ~isestimated(sys)
    ctrlMsgUtils.error('Ident:utility:nonEstimatedModel','sim','nlhw')
end

[ny, nu] = size(sys);

iddataflag = isa(data, 'iddata');

% Return trivial result if empty data.
if isempty(data)
    if iddataflag
        z = data;
        z.u = [];
    else
        z = zeros(0,ny);
    end
    if no==0
        utidplot(sys,zz,'Simulated')
        clear z
    end
    ctrlMsgUtils.warning('Ident:analysis:simEmptyData')
    return
end

if ~iddataflag && ~(isnumeric(data) && ndims(data)==2 ...
        && all(all(isfinite(data))))
    ctrlMsgUtils.error('Ident:general:invalidData')
end

% Prepare noisy simulation
noisysim = false;
if iddataflag
    [nsamp, nyd, nud, nex] = size(data);
    if nud==nu+ny
        noisysim = true;
        noisecell = pvget(data(:,:,nu+1:nu+ny), 'InputData');
        data = data(:,:,1:nu); % Remove noise data
    elseif nud~=nu
        ctrlMsgUtils.error('Ident:analysis:simDataModelDimMismatch',nu,nu+ny)
    end
else
    [nsamp,nud] = size(data);
    nex = 1;
    if nud==nu+ny
        noisysim = true;
        noisecell = {data(:,nu+1:nu+ny)}; % Note: cell array is used for multi-exp data.
        data = data(:,1:nu);
    elseif nud~=nu
        ctrlMsgUtils.error('Ident:analysis:simDataModelDimMismatch',nu,nu+ny)
    end
end

% Double noise warning
if defaultnoise && noisysim
    ctrlMsgUtils.warning('Ident:analysis:simWithNoise')
end

% Warning on data properties
if iddataflag
    msg = datapropwarns(data, sys, ...
        {'Ts', 'InputName', 'InputUnit', 'TimeUnit'});
    % Note: 'OutputName', 'OutputUnit' are not checked for simulation.
    for km=1:length(msg)
        %todo
        warning('Ident:general:dataModelPropMismatch', msg{km});
    end
end

if defaultnoise && ~noisysim
    % Fill noisecell with default noise.
    noisysim = true;   % defaultnoise --> noisysim
    noisecell = cell(nex,1);
    for kex=1:nex
        noisecell{kex} = randn(nsamp(kex), ny);
    end
end

wstatus = warning('off', 'Ident:general:dataModelPropMismatch');
z = predict(sys, data, 1, 'InitialState', xinit);
warning(wstatus);

% Add noise
if noisysim
    % Scaling noise by NoiseVariance
    noisevar = pvget(sys, 'NoiseVariance');
    if all(isfinite(noisevar(:))) && all(size(noisevar)==ny)
        sqrnoisevar = sqrtm(noisevar);
        if all(isfinite(sqrnoisevar(:))) && isreal(sqrnoisevar)
            for kex=1:nex
                noisecell{kex} = noisecell{kex}*sqrnoisevar;
            end
        end
    end
    
    if iddataflag
        ydata = pvget(z,'OutputData');
        for kex=1:nex
            ydata{kex} = ydata{kex} + noisecell{kex};
        end
        z = pvset(z, 'OutputData', ydata);
    else
        z = z + noisecell{1};
    end
end

if no==0
    utidplot(sys,z,'Simulated')
    clear z
end

% FILE END