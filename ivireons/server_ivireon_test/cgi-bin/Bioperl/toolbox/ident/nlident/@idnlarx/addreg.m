function  sys = addreg(sys, varargin)
%ADDREG adds custom regressors to an IDNLARX model.
%
%   M = ADDREG(M, R)
%
%   M: IDNLARX object
%   R: custom regressors to be added, in different forms depending on the
%   number of outputs of M.
%
%   For single output M, R is a CUSTOMREG object array or a cell array of
%   strings.
%
%   For multiple outputs M with ny outputs, R is a 1-by-ny cell array of
%   CUSTOMREG objects or a 1-by-ny cell array of cell arrys of strings.
%   The content of the each of the ny cells is added to the corresponding
%   output channel of M.
%
%   For multiple outputs M the following syntax can also be used:
%
%  M = ADDREG(M, R, I)
%
%  where R is a CUSTOMREG object array or a cell array of strings and I is
%  a vector of integers indicating the output channels to which R should be
%  added. If I is omitted, then R is added to all the output channels.
%  Multiple regressor-index pairs can also be used similarly:
%
%  M = ADDREG(M, R1, I1, R2, I2, ..., Rn, In).
%
%  Type "idprops idnlarx regressors" for information on regressors.
%
%   See also GETREG, CUSTOMREG, POLYREG, IDNLARX, NLARX.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:53:01 $

% Author(s): Qinghua Zhang

nin = nargin;
error(nargchk(2, inf, nin, 'struct'))

% Keep NonlinearRegressors to restore non concerned channels.
nlr = sys.NonlinearRegressors;

ny = size(sys, 'ny');

% Detect the basic case: M = ADDREG(M, R)
basicflag = false;
if nin==2
    reg = varargin{1};
    
    if isempty(reg)
        return % Nothing to do.
    end
    
    if ny==1
        if ischar(reg) || iscellstr(reg) || isa(reg, 'customreg')
            basicflag = true;
        end
    else %ny>1
        if iscell(reg) && numel(reg)==ny && ...
                all(cellfun(@isempty, reg(:)) | cellfun(@ischar, reg(:)) | ...
                cellfun(@iscellstr, reg(:)) | cellfun('isclass', reg(:), 'customreg'))
            basicflag = true;
        end
    end
    
    if ~basicflag && ~(ischar(reg) || iscellstr(reg) || isa(reg, 'customreg'))
        if ny==1
            ctrlMsgUtils.error('Ident:idnlmodel:addregSO')
        else
            ctrlMsgUtils.error('Ident:idnlmodel:addregMO', ny)
        end
    end
end

if rem(nin,2)==0
    % Add the omitted last index.
    varargin{end+1} = 1:ny;
    nri = nin;
else
    nri = nin-1;
end


if ~basicflag  % Non basic case
    channelflag = false(ny,1); % The channels where regeressors are added
    
    % Pre-processing of customreg
    for kp=1:2:nri
        try
            reg = PairPreProcessing(kp+1, varargin{kp:kp+1}, ny);
        catch E
            rethrow(E)
        end
        varargin{kp} = reg;
        
        % The validity of nch=varargin{kp+1} is already checked in PairPreProcessing
        channelflag(varargin{kp+1}) = true;
    end
    
else % Basic case
    channelflag = true(ny,1); % The channels where regeressors are added
end

% Old customreg
reg0 = pvget(sys, 'CustomRegressors');

for  kp=1:2:nri
    reg = varargin{kp};
    
    % Pre-checking
    [reg, msg] = custregprecheck(reg, ny);
    error(msg);
    
    % String conversion if necessary
    
    [reg,  msg] = str2customreg(reg, sys);
    error(msg)
    
    if ny==1
        reg0 = [reg0(:); reg(:)];
    else
        for ky=1:ny
            reg0{ky} = [reg0{ky}(:); reg{ky}(:)];
        end
    end
end

sys = pvset(sys, 'CustomRegressors',  reg0);

% Restore NonlinearRegressors for non concerned channels.
for ky=1:ny
    if channelflag(ky)
        if ny==1
            nlr = 'all';
        elseif  iscell(nlr) && numel(nlr)>=ky
            nlr{ky} = 'all';
        end
    end
end
sys.NonlinearRegressors = nlr;

% Set NonlinearRegressors=[] for Nonlinearity=linear
sys = linearnlrset(sys);

%======================================================================
function reg = PairPreProcessing(argind, reg, nch, ny)
% Pre-processing of customreg

if isempty(nch)
    nch = 1:ny;
end

if isempty(reg)
    reg = cell(ny,1);
    return
end

if ~(ischar(reg) || iscellstr(reg) || isa(reg, 'customreg'))
    if argind==2
        ctrlMsgUtils.error('Ident:idnlmodel:addreg1a')
    else
        ctrlMsgUtils.error('Ident:idnlmodel:addreg1b',argind)
    end
end

if ~(isposintmat(nch) && isvector(nch) && all(nch<=ny))
    if argind==2
        ctrlMsgUtils.error('Ident:idnlmodel:addreg2a')
    else
        ctrlMsgUtils.error('Ident:idnlmodel:addreg2b',argind+1)
    end
elseif ~all(diff(sort(nch)) )
    ctrlMsgUtils.error('Ident:idnlmodel:addreg3',argind+1)
end

% Put reg into appropriate channels with duplication if necessary.
regobj = reg;
reg = cell(ny,1);
if isa(regobj, 'customreg') || iscellstr(regobj)
    for ky=nch
        reg{ky} = regobj;
    end
else % ischar(regobj)
    for ky=nch
        reg{ky} = {regobj};
    end
end

% FILE END
