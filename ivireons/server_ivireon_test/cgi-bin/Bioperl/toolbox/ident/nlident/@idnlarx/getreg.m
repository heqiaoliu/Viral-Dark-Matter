function reg = getreg(sys, subset, data, xinit, initv)
%GETREG Get string expressions or values of regressors of an IDNLARX model.
%
% Obtaining String Expressions for Model Regressors:
%   RS = GETREG(MODEL)
%   RS = GETREG(MODEL, SUBSET)
%
%   returns the regressors of an IDNLARX model, MODEL, represented by a
%   cell array of strings for a single output model, or by an ny-by-1 cell
%   array of cell arrays of strings for a model with ny outputs. Each
%   string describes the formula for a regressor expressed as a function of 
%   input, output, and time variables.
%
%   RS = GETREG(MODEL) returns all the regressors of MODEL.
%   RS = GETREG(MODEL, SUBSET) where SUBSET is one of:
%     'all', 'input','output','standard','custom','linear' or 'nonlinear'
%     returns the subset of regressors specified by the string.
%     SUBSET = 'all' by default.
%     SUBSET = 'input' means the standard regressors composed of delayed
%     inputs. 
%     The other strings have similar meanings.
%     'nl' can be used as abbreviation of 'nonlinear'.
%
%   The order in which the regressor strings appear in RS = GETREG(MODEL) 
%   defines the regressor indices, as used in MODEL.NonlinearRegressors.
%
% Obtaining Numerical Values of Regressors for a Given Data:
%   RM = GETREG(MODEL, SUBSET, DATA)
%
%   computes the regression matrix RM containing the numerical values of
%   model regressors corresponding to input-output data in the IDDATA
%   object DATA. RM is a matrix for single output MODEL and single
%   experiment DATA. It is a cell array of matrices for multiple outputs
%   MODEL and single experiment DATA. When DATA contains multiple
%   experiments, RM is a cell array containing regressor values
%   corresponding to each of the data experiments.
%
%   RM = GETREG(MODEL, SUBSET, DATA, 'InitialState', INIT)
%   RM = GETREG(MODEL, SUBSET, DATA, INIT)
%   
%   allows specification of initial conditions INIT for computation of
%   regressor matrices. INIT can take one of the following values:
%
%    - X0: a real column vector, for the state vector corresponding to a
%          certain number of output and input data samples prior to the
%          first data sample contained in DATA. To build an initial state
%          vector from a given set of input-output data, see 
%          IDNLARX/DATA2STATE. For multi-experiment DATA, X0 may be a 
%          matrix whose columns give different initial states for different
%          experiments. 
%
%    - 'z': zero initial state, equivalent to a zero vector of appropriate
%           size (default).
%
%    - an IDDATA object, containing output and input data samples prior to
%           the first data sample contained in DATA. If it contains more
%           data samples than necessary, only the last samples are taken
%           into account. The minimum number of samples required is equal
%           to max(getDelayInfo(MODEL)).
%
%   Whenever DATA appears in the input arguments of GETREG, the output
%   argument returns regression matrices RM, otherwise the regressor
%   strings RS are returned. SUBSET specifies a subset of regressors, in
%   both the string and the matrix cases.
%
%   Each regression matrix contained in RM has as many rows as the data
%   samples contained in DATA. The values in  the first few rows of each
%   regression matrix are influenced by the specified initial conditions.
%   The number of such rows is equal to the maximum delay in the regressors
%   used for each output (see idnlarx/getDelayInfo). 
%
%   A typical use of regression matrices built by GETREG is to generate the
%   input data for EVALUATE method of nonlinearity estimator objects such
%   as WAVENET. The two commands:
%       RM = GETREG(MODEL, 'all', DATA), and
%       EVALUATE(MODEL.NL, RM) 
%   are equivalent to:
%       PREDICT(MODEL,DATA, 1,'z').
%
%   Type IDPROPS('IDNLARX','REGRESSOR') for information on model regressors.
%
%   See also ADDREG, EVALUATE, getDelayInfo.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.9 $ $Date: 2008/12/04 22:34:42 $

% Author(s): Qinghua Zhang

ni = nargin;
error(nargchk(1, 5, ni, 'struct'));

if ni<2 || isempty(subset)
    subset = 'all';
end
strlist = {'input','output','standard','custom','all','linear','nonlinear','nl'};
[subset, msg] = strchoice(strlist, subset, 'Subset');
error(msg)

if strcmpi(subset, 'nonlinear')
    subset = 'nl';
end

if ni>2 && ~(isa(data, 'iddata') || isrealmat(data))
    ctrlMsgUtils.error('Ident:analysis:getregCheck1')
end

badInitValue = false;
if ni==3
    xinit = 'z';
elseif ni>3
    lthxinit = length(xinit);
    if isValidInitValueType(xinit) % isa(xinit, 'iddata') || isrealmat(xinit) || (ischar(xinit) && strcmpi(xinit, 'z'))
        % Do nothing
    elseif ni==5 && ischar(xinit) && lthxinit>2 && strncmpi(xinit, 'InitialState', lthxinit)
        if isValidInitValueType(initv)
            xinit = initv;
        else
            badInitValue = true;
        end
    elseif ni==5
        ctrlMsgUtils.error('Ident:analysis:getregCheck2')
    else
        badInitValue = true;
    end
end
if badInitValue
    ctrlMsgUtils.error('Ident:analysis:getregCheck3')
end

% Special no output argument case
if nargout==0 && ni<3
    disp(RegressorDisplay(sys, subset))
    return
end

% Get data from the IDNLARX object.
na      = pvget(sys, 'na');
nb      = pvget(sys, 'nb');
nk      = pvget(sys, 'nk');
InName  = pvget(sys, 'InputName');
OutName = pvget(sys, 'OutputName');
CustReg = pvget(sys, 'CustomRegressors');
TimeVar = pvget(sys, 'TimeVariable');
[ny, nu] = size(sys);

nlr = pvget(sys, 'NonlinearRegressors');
nlr = nlregstr2ind(sys, nlr);
if ny==1
    nlr = {nlr};
end

% Put the SO customreg object into cellarray
if isa(CustReg, 'customreg')
    CustReg = {CustReg};
end

% Dimensions of customreg arrays
if isempty(CustReg)
    custdims = zeros(ny, 1);
else
    custdims = cellfun(@length, CustReg);
end

reg = cell(ny, 1);
for i = 1:ny
    
    % Handle the case of subset='nl' and nlr='search'
    if strcmpi(subset, 'nl') && ischar(nlr{i}) &&  strcmpi(nlr{i}, 'search')
        reg{i} = {'search'};
        continue
    end
    
    reg{i} = cell(sum(na(i,:),2)+sum(nb(i,:),2)+custdims(i), 1);
    pt = 0;
    
    if ismember(subset, {'output','standard','all','linear','nl'})
        % Add output-related regressors.
        for j = 1:ny
            for k = 1:na(i, j)
                pt = pt+1;
                reg{i}{pt} = [OutName{j} '(' TimeVar '-' num2str(k) ')'];
            end
        end
    end
    
    if ismember(subset, {'input','standard','all','linear','nl'})
        % Add input-related regressors.
        for j = 1:nu
            for k = 0:nb(i, j)-1
                pt = pt+1;
                if k+nk(i, j)==0
                    reg{i}{pt} = [InName{j} '(' TimeVar  ')'];
                else
                    reg{i}{pt} = [InName{j} '(' TimeVar '-' num2str(k+nk(i, j)) ')'];
                end
            end
        end
    end
    
    if ismember(subset, {'custom','all','linear','nl'})
        % Add custom regressors.
        if custdims(i)>0 && ~isa(CustReg{i}, 'customreg')
            ctrlMsgUtils.error('Ident:idnlmodel:invalidCustomRegVal')
        end
        for j = 1:custdims(i)
            creg = CustReg{i}(j);
            custstr = strexpression(creg);
            pt = pt+1;
            reg{i}{pt} = custstr;
        end
    end
    
    reg{i} = reg{i}(1:pt); % To remove trailing empty cells.
    
    if strcmpi(subset, 'nl')
        reg{i} = reg{i}(nlr{i});
    elseif strcmpi(subset, 'linear')
        reg{i} = reg{i}(setdiff(1:numel(reg{i}), nlr{i}));
    end
end

if ni<3 % Returning reg strings
    
    % Strip one cell array layer in case of a single output model.
    if ny==1
        reg = reg{1};
    end
    
else % Returning reg data
    
    reg = getRegData(sys, reg, data, xinit);
    
end

%======================================
function txt = RegressorDisplay(sys, subset)
%DISPLAY regressors

[ny, nu] = size(sys);

switch subset
    case 'nl'
        txt = sprintf('Nonlinear regressors:\n');
    case 'all'
        txt = sprintf('Regressors:\n');
    otherwise
        txt = sprintf('%s regressors:\n', subset);
        txt(1) = upper(txt(1));
end

if ny==1
    txt = [txt soDisplay(sys, subset)];
elseif ny>1
    txt = [txt moDisplay(sys, subset)];
end

%----------------------------------
function txt = soDisplay(sys, subset)

regs = getreg(sys, subset);
txt = '';
if isempty(regs)
    txt = [txt, sprintf('    none\n')];
else
    for kr=1:numel(regs)
        txt = [txt, sprintf('    %s\n',regs{kr})];
    end
end

%------------------------------------
function txt = moDisplay(sys, subset)

ny = size(sys, 'ny');
regs = getreg(sys, subset);

txt = '';
for ky=1:ny
    txt = [txt, sprintf('  For output %d:\n', ky)];
    if isempty(regs{ky})
        txt = [txt, sprintf('    none\n')];
    else
        for kr=1:numel(regs{ky})
            txt = [txt, sprintf('    %s\n',regs{ky}{kr})];
        end
    end
end

%------------------------------------------
function st = isValidInitValueType(xinit)

st = isa(xinit, 'iddata') || isrealmat(xinit) || (ischar(xinit) && strcmpi(xinit, 'z'));

%----------------------------------------
function regdata = getRegData(sys, reg, data, xinit)
% Build regression matrix data

na = pvget(sys, 'na');
nb = pvget(sys, 'nb');
nk = pvget(sys, 'nk');
custregs = pvget(sys, 'CustomRegressors');
maxidelay = reginfo(na, nb, nk, custregs);
maxd = max(maxidelay);
allmaxd = getDelayInfo(sys, 'all');
nx = sum(allmaxd);
[ny, nu] = size(sys);

% Data check and Convert matrix to iddata if necessary.
[data, errmsg] = datacheck(data, ny, nu);
error(errmsg)

[nsamp, nyd, nud, nex] = size(data);

% Initial state processing
if ischar(xinit) && strcmpi(xinit,'z')
    xinit = zeros(nx,1);
end
if maxd==0
    if isrealmat(xinit) && ~isempty(xinit)
        ctrlMsgUtils.warning('Ident:analysis:modelWithNoStates')
    end
    %xinit = [];
elseif isrealmat(xinit) % Using state vector
    [xir, xic] = size(xinit);
    if nx~=xir
        ctrlMsgUtils.error('Ident:analysis:x0Size', nx)
    end
    if xic~=1 && xic~=nex
        if nex==1
            ctrlMsgUtils.error('Ident:analysis:x0Size', nx)
        else
            ctrlMsgUtils.error('Ident:analysis:x0SizeMultiExp')
        end
    end
    if xic<nex
        xinit = xinit(:,ones(1,nex)); % expand to multi-experiments.
    end
    
    wstatus = warning;
    warning('off','Ident:iddata:MoreOutputsThanSamples');
    warning('off','Ident:iddata:MoreInputsThanSamples');
    
    zinit = cell(1,nex);
    for kex = 1:nex
        yinit = zeros(maxd, ny);
        uinit = zeros(maxd, nu);
        pt = 0;
        for ky=1:ny
            chs = allmaxd(ky);
            yinit(maxd:-1:(maxd-chs+1),ky) = xinit(pt+1:pt+chs,kex);
            pt = pt + chs;
        end
        for ku=1:nu
            chs = allmaxd(ny+ku);
            uinit(maxd:-1:(maxd-chs+1),ku) = xinit(pt+1:pt+chs,kex);
            pt = pt + chs;
        end
        zinit{kex} = iddata(yinit, uinit);
    end
    if nex>1
        zinit = merge(zinit{:});
    else
        zinit = zinit{1};
    end
    
    % data = [zinit; data];  % Cannot get this line work. Replaced by the following loop.
    cdata = cell(nex,1);
    for kex=1:nex
        cdata{kex} = [getexp(zinit, kex); getexp(data, kex)];
    end
    data = merge(cdata{:});
    clear cdata
    
    warning(wstatus)
    
elseif isa(xinit,'iddata')
    [ininsamp, ininyd, ininud, ininex] = size(xinit);
    if ininyd~=ny
        ctrlMsgUtils.error('Ident:analysis:idnlarxInitIODim')
    end
    if ininud~=nu
        ctrlMsgUtils.error('Ident:analysis:idnlarxInitIODim')
    end
    if nex>1 && ininex==1
        [mxinit{1:nex}] = deal(xinit);
        xinit = merge(mxinit{:});
    elseif nex~=ininex
        ctrlMsgUtils.error('Ident:analysis:getRegInitNex')
    end
    
    % if xinit has less than maxd samples, error out
    if min(ininsamp)<maxd
        ctrlMsgUtils.error('Ident:analysis:idnlarxInitNsamp',maxd)
    end
    
    % Keep the last maxd samples
    TStart = pvget(data,'Tstart');
    Tsdat = pvget(data,'Ts');
    zinit = cell(1,nex);
    for kex = 1:nex
        zinitk = getexp(xinit, kex);
        zinitk.Tstart = TStart{1};
        zinitk.Ts = Tsdat;
        zinitk = zinitk(end-maxd+1:end);
        zinit{kex} = zinitk;
    end
    if nex>1
        zinit = merge(zinit{:});
    else
        zinit = zinit{1};
    end
    % data = [zinit; data]; % Cannot get this line work. Replaced by the following loop.
    cdata = cell(nex,1);
    for kex=1:nex
        cdata{kex} = [getexp(zinit, kex); getexp(data, kex)];
    end
    data = merge(cdata{:});
    clear cdata
    
else
    ctrlMsgUtils.error('Ident:analysis:idnlmodelINITval','getreg','idnlarx/getreg')
end
%End of Initial state processing

allregstr = getreg(sys);
if ny==1;
    allregstr = {allregstr};
end

regdata = cell(1,nex);
for kex = 1:nex
    [yvec, regmat, msg] = makeregmat(sys, data);
    error(msg)
    
    for ky=1:ny
        %regmat{ky} = regmat{ky}((maxd-maxidelay(ky)+1):end,:);
        regmat{ky} = regmat{ky}((end-nsamp+1):end,:);
        
        % Extract selected regressors
        colmask = ismember(allregstr{ky}, reg{ky});
        regmat{ky} = regmat{ky}(:, colmask);
    end
    
    if ny==1
        regdata{kex} = regmat{1};
    else
        regdata{kex} = regmat;
    end
end
if nex==1
    regdata = regdata{1};
end

% FILE END
