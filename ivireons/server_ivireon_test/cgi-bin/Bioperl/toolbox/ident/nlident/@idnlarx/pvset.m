function sys = pvset(sys,varargin)
%PVSET  Set properties of IDNLARX models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.12 $ $Date: 2008/10/02 18:53:21 $

% Author(s): Qinghua Zhang

ni = nargin;
error(nargoutchk(1, 1, nargout, 'struct'));

[ny, nu] = size(sys);

if pvget(sys, 'Estimated')
    sys.EstimationInfo.Status = 'Model modified after last estimate';
end

% Arrange PV-pairs in the pre-defined order.
[pvlist, msg] = PVReordering(varargin);
error(msg)

for i=1:2:ni-1,
    % Set each Property Name/Value pair in turn.
    Property = pvlist{i};
    Value = pvlist{i+1};
    
    % Perform assignment
    switch Property
        case {'na', 'nb', 'nk'}
            sys.(Property) = Value;
            na = sys.na;
            nb = sys.nb;
            nk = sys.nk;
            if ~isequal(size(nb), [ny nu]) || ~isequal(size(nk), [ny nu]) || size(na,1)~=ny
                ctrlMsgUtils.error('Ident:idnlmodel:idnlarxPvset1')
            end
            error(nabkchck(na, nb, nk));
            sys.Nonlinearity = initreset(sys.Nonlinearity);
            sys = PropRest(sys, 0, {'NonlinearRegressors'});
            
        case 'CustomRegressors'
            [Value, msg] = CustomRegCheck(Value, sys);
            error(msg)
            
            oldcreg = sys.CustomRegressors;
            nlreg = sys.NonlinearRegressors;
            sys.CustomRegressors = Value;
            sys.Nonlinearity = initreset(sys.Nonlinearity);
            sys = PropRest(sys, 0, {'NonlinearRegressors'});
            % Restore NonlinearRegressors for non concerned channels.
            if ny==1
                if isequal(oldcreg, Value)
                    sys.NonlinearRegressors = nlreg;
                end
            else
                if iscell(oldcreg) && iscell(Value) && numel(oldcreg)==ny && numel(Value)==ny
                    for ky=1:ny
                        if ~isequal(oldcreg{ky}, Value{ky})
                            nlreg{ky} = 'all';
                        end
                    end
                    sys.NonlinearRegressors = nlreg;
                end
            end
            sys = linearnlrset(sys);  % Set NonlinearRegressors=[] for Nonlinearity=linear
            
        case 'NonlinearRegressors'
            [Value, msg] = NLRegCheck(Value, ny, getreg(sys), sys.Nonlinearity);
            error(msg)
            
            sys.NonlinearRegressors = Value;
            sys.Nonlinearity = initreset(sys.Nonlinearity);
            sys = PropRest(sys, 0);
            sys = linearnlrset(sys);  % Set NonlinearRegressors=[] for Nonlinearity=linear
            
        case 'Nonlinearity'
            [Value, msg] = nlobjcheck(Value, ny);
            error(msg)
            
            msg = regdimcheck(Value, sys);
            error(msg)
            
            sys.Nonlinearity = Value;
            sys = PropRest(sys, -1);
            sys = linearnlrset(sys);  % Set NonlinearRegressors=[] for Nonlinearity=linear
            
        case 'Focus'
            [Value, msg] = strchoice({'Prediction', 'Simulation'}, Value, 'EstimationFocus');
            error(msg);
            
            sys.Focus = Value;
            sys = PropRest(sys, -1);
            
        case 'Algorithm'
            [Value, msg] =  bbalgodef(Value);
            error(msg)
            
            % check Weighting matrix explicitly for its size
            val = Value.Weighting;
            %[sr,sc] = size(val);
            if (size(val,1) ~= ny)
                ctrlMsgUtils.error('Ident:general:incorrectWeighting1',ny)
            end
            
            sys.Algorithm = Value;
            sys = PropRest(sys, -1);
            
        case 'CovarianceMatrix'
            if ~isempty(Value) && isnumeric(Value)
                if ndims(Value)~=2
                    ctrlMsgUtils.error('Ident:idnlmodel:invalidCovarianceMatrix')
                end
                np = numel(getParameterVector(sys));
                [nrows, ncols] = size(Value);
                if nrows~=np || ncols~=np
                    ctrlMsgUtils.error('Ident:general:CovarianceMatrixNotSquare')
                end
            elseif ischar(Value)
                [value, msg] = strchoice({'estimate', 'none'}, Value, 'CovarianceMatrix');
                if ~isempty(msg)
                    ctrlMsgUtils.error('Ident:idnlmodel:invalidCovarianceMatrix')
                end
            end
            sys.CovarianceMatrix = Value;
            sys = PropRest(sys, -1);
            
        case 'EstimationInfo'
            sys.EstimationInfo = Value;
            
        case 'OptimMessenger'
            sys.idnlmodel = pvset(sys.idnlmodel,'OptimMessenger',Value);
            for ii = 1:length(sys.Nonlinearity)
                sys.Nonlinearity(ii).OptimMessenger = Value;
            end
            
        case 'Ts'
            % Ts>0 for IDNLARX models
            sys.idnlmodel = pvset(sys.idnlmodel,'Ts',Value);
            if Value==0
                ctrlMsgUtils.error('Ident:general:positiveNumPropVal','Ts')
            end
        otherwise
            % IDNLMODEL properties (other than Ts and OptimMessenger)
            
            % CustomReg argument names update when setting InputName or OutputName
            if ismember(Property, {'InputName', 'OutputName', 'TimeVariable'})
                sys = CustomRegArgUpdate(sys, Property, Value);
            end
            
            sys.idnlmodel = pvset(sys.idnlmodel, Property, Value);
            
            if ~strcmp(Property, 'Estimated')
                sys = PropRest(sys, -1);
            end
    end % switch
end % for

%=============================================
function sys = PropRest(sys, estimflag, props)
% Reset properties to default value
% props is a cellarray of property names
% props must be a cell array containing 'CustomRegressors', and/or
% 'NonlinearRegressors' strings.

if nargin>2
    for kp=1:length(props)
        switch props{kp}
            case 'CustomRegressors'
                sys = pvset(sys, 'CustomRegressors', {});
            case 'NonlinearRegressors'
                ny = size(sys,1);
                if ny>1
                    nlreg =cell(ny,1);
                    [nlreg{:}] = deal('all');
                else
                    nlreg = 'all';
                end
                sys = pvset(sys, 'NonlinearRegressors', nlreg);
        end
    end
    
    % Clear out CovarianceMatrix if necessary
    if estimflag==0 && isnumeric(sys.CovarianceMatrix)
        sys.CovarianceMatrix = [];
    end
end

% Set estimation flag
% Note: if Estimated==0, do not change its value.
% if pvget(sys, 'Estimated')
if pvget(sys, 'Estimated')
    sys = pvset(sys, 'Estimated', estimflag);
end

%--------------------------------------------------
function [Value, msg] = CustomRegCheck(Value, sys)

msg = struct([]);
ny = size(sys,'ny');

if isempty(Value)
    if ny>1
        Value = cell(ny,1);
        [Value{:}] = deal({});
    else
        Value = {}; % always use {} instead of [].
    end
    return
end

% Convert strings to object if necessary,
% and check dimension consistency
[Value,  msg] = str2customreg(Value, sys);
if ~isempty(msg)
    return
end
oinames = [pvget(sys, 'OutputName'); pvget(sys, 'InputName')];

if ny>1
    for ky = 1:ny
        [Value{ky}, msg] = SOCustomRegCheck(Value{ky}, oinames, pvget(sys, 'TimeVariable'), ny, ky);
        if ~isempty(msg)
            return
        end
    end
else
    [Value, msg] = SOCustomRegCheck(Value, oinames, pvget(sys, 'TimeVariable'), ny,1);
end

%--------------------------------------------------------------------------
function [Value, msg] = SOCustomRegCheck(Value, oinames, TimeVar, ny, ky)
% Single Output case of CustomRegCheck

msg = struct([]);

if isempty(Value)
    Value = {}; % Always use {} instead of []
    return
end

for kc=1:numel(Value)
    Arguments = Value(kc).Arguments;
    
    % Dimension consistency check
    nfargs = nargin(Value(kc).Function);
    ndelays = numel(Value(kc).Delays);
    if numel(Arguments)~=ndelays
        if numel(Value)==1
            if ny>1
                msg = sprintf('The sizes of the properties "Arguments" and "Delays" do not match in the specified custom regressor object for output ''%s''.',oinames{ky});
                msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg1a','message',msg);
            else
                msg = 'The sizes of the properties "Arguments" and "Delays" do not match in the specified custom regressor object.';
                msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg1b','message',msg);
            end
        else
            if ny>1
                msg = sprintf('The sizes of the properties "Arguments" and "Delays" do not match in the custom regressor no. %d for output ''%s''.',kc,oinames{ky});
                msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg1c','message',msg);
            else
                msg = sprintf('The sizes of the properties "Arguments" and "Delays" do not match in the custom regressor no. %d.',kc);
                msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg1d','message',msg);
            end
        end
        return
    end
    if nfargs>=0 && nfargs~=ndelays
        if numel(Value)==1
            if ny>1
                msg = sprintf('In the specified custom regressor object for output ''%s'', the length of the "Arguments" property value must be equal to the number of inputs arguments of the "Function" property value.',...
                    oinames{ky});
                msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg2a','message',msg);
            else
                msg = 'In the specified custom regressor object, the length of the "Arguments" property value must be equal to the number of inputs arguments of the "Function" property value.';
                msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg2b','message',msg);
            end
        else
            if ny>1
                msg = sprintf('In the custom regressor no. %d for output ''%s'', the length of the "Arguments" property value must be equal to the number of inputs arguments of the "Function" property value.',...
                    kc,oinames{ky});
                msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg2c','message',msg);
            else
                msg = sprintf('In the custom regressor no. %d, the length of the "Arguments" property value must be equal to the number of inputs arguments of the "Function" property value.',kc);
                msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg2d','message',msg);
            end
        end
        return
    end
    
    ChannelIndices = zeros(1, ndelays);
    
    for ki = 1:ndelays % ndelays=numel(Arguments)
        ind = strmatch(Arguments{ki}, oinames);
        if length(ind)>1
            if numel(Value)==1
                if ny>1
                    msg = sprintf(['In the custom regressor for output ''%s'', the value of the "Arguments" property is ambiguous. ',...
                        'Specify more characters to uniquely identify the arguments as one of model''s input or output variables.'],oinames{ky});
                    msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg3a','message',msg);
                else
                    msg = ['In the specified custom regressor object, the value of the "Arguments" property is ambiguous. ',...
                        'Specify more characters to uniquely identify the arguments as one of model''s input or output variables.'];
                    msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg3b','message',msg);
                end
            else
                if ny>1
                    msg = sprintf(['In the custom regressor no. %d for output ''%s'', the value of the "Arguments" property is ambiguous. ',...
                        'Specify more characters to uniquely identify the arguments as one of model''s input or output variables.'],kc,oinames{ky});
                    msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg3c','message',msg);
                else
                    msg = sprintf(['In the custom regressor no. %d, the value of the "Arguments" property is ambiguous. ',...
                        'Specify more characters to uniquely identify the arguments as one of model''s input or output variables.'],kc);
                    msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg3d','message',msg);
                end
            end
            return
        elseif isempty(ind)
            %msg = 'Incorrect custom regressor argument. Arguments must match the input/output names in the IDNLARX model.';
            if numel(Value)==1
                if ny>1
                    msg = sprintf('In the custom regressor for output ''%s'', the value of the "Arguments" property must be a cell array of model''s input/output variables.',...
                        oinames{ky});
                    msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg4a','message',msg);
                else
                    msg = 'In the specified custom regressor object, the value of the "Arguments" property must be a cell array of model''s input/output variables.';
                    msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg4b','message',msg);
                end
            else
                if ny>1
                    msg = sprintf('In the custom regressor no. %d for output ''%s'', the value of the "Arguments" property must be a cell array of model''s input/output variables.',...
                        kc,oinames{ky});
                    msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg4c','message',msg);
                else
                    msg = sprintf('In the custom regressor no. %d, the value of the "Arguments" property must be a cell array of model''s input/output variables.',kc);
                    msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg4d','message',msg);
                end
            end
            return
        end
        Arguments{ki} = oinames{ind};
        ChannelIndices(ki) = ind;
        
        % Check zero delay for output  (added on April 14, 2007)
        if ind<=ny && Value(kc).Delays(ki)==0
            msg = sprintf('In the specified custom regressor object(s), the delay corresponding to the output variable ''%s'' cannot be zero.',Arguments{ki});
            msg = struct('identifier','Ident:idnlmodel:illFormedCustomreg5','message',msg);
        end
    end
    if ~all(strcmp(Value(kc).Arguments, Arguments))
        Value(kc).Arguments = Arguments; %Replace partial I/O names with full names.
    end
    Value(kc).ChannelIndices = ChannelIndices;
    Value(kc).TimeVariable = TimeVar;
end

%--------------------------------------------------------------------------
function sys = CustomRegArgUpdate(sys, Property, Value)
% Update Arguments of CustomRegressors when setting InputName or OutputName or TimeVariable

if ischar(Value)
    Value = strtrim(cellstr(Value));
end
if ~iscellstr(Value)
    return % Incorrect name, do nothing.
end

oldname = pvget(sys, Property);
custregs = pvget(sys, 'CustomRegressors');
yname = pvget(sys,'OutputName');
if ~iscell(custregs) && ~isempty(custregs)
    custregs = {custregs};
    notcell = 1;
else
    notcell = 0;
end

mn = min(length(Value), length(oldname));
oldname = oldname(1:mn);

for ky=1:length(custregs)
    creg = custregs{ky};
    if ~isa(creg, 'customreg')
        continue
    end
    for kc=1:numel(creg)
        if strcmp(Property, 'TimeVariable')
            if iscell(Value) && ~isempty(Value)
                Value = Value{1};
            end
            creg(kc).TimeVariable = Value;
            updateflag = 1;
        else
            args = creg(kc).Arguments;
            updateflag = 0;
            for ka=1:length(args)
                ind = strmatch(args{ka}, oldname, 'exact');
                if length(ind)>1
                    ctrlMsgUtils.error('Ident:idnlmodel:ambiguousCustomRegProp',oldname,kc,yname{ky})
                end
                if ~isempty(ind) && ~strcmp(args{ka}, Value{ind})
                    args{ka} = Value{ind};
                    updateflag = 1;
                end
            end
            creg(kc).Arguments = args;
        end
        if updateflag
            % Clear the Display property made of old names
            creg(kc).Display = [];
        end
    end
    custregs{ky} = creg;
end

if notcell
    custregs = custregs{1};
end
% sys = pvset(sys, 'CustomRegressors', custregs);
sys.CustomRegressors = custregs;

%--------------------------------------------------------------------------
function [Value, msg] = NLRegCheck(Value, ny, regs, nlobj)

msg = struct([]);
if isempty(Value)
    if ny>1
        Value = cell(ny,1);
    else
        Value = [];
    end
    %return
end

if ischar(Value) && ny>1
    Vcell = cell(ny,1);
    [Vcell{:}] = deal(Value);
    Value = Vcell;
    clear Vcell
end

if ny>1 && (~iscell(Value) || length(Value)~=ny)
    msg = sprintf('The value of the "NonlinearRegressors" property must be a %d-by-1 cell array. Type "idprops idnlarx" for more information.',ny);
    msg = struct('identifier','Ident:idnlmodel:nlregSize','message',msg);
    return
end

% MO case
if ny>1
    for ky=1:ny
        [Value{ky}, msg] = ChannelNLRegCheck(Value{ky},regs{ky}, ny, nlobj(ky));
        if ~isempty(msg)
            return
        end
    end
    searchflag = strcmpi('search', Value);
    if any(searchflag) && ~all(searchflag)
        msg = 'Automatic search of nonlinear regressors must be done simultaneously for all output channels.';
        msg = struct('identifier','Ident:idnlmodel:nlregMOSearchOption',...
            'message',msg);
    end
else %ny==1
    [Value, msg] = ChannelNLRegCheck(Value,regs, 1, nlobj);
end

%--------------------------------------------------------------------------
function [Value, msg] = ChannelNLRegCheck(Value,regs, ny, nlobj)
% NLRegCheck for a (each) output channel

msg = struct([]);

if iscell(Value) && length(Value)==1
    % Tolerate single cell used for SO case
    Value = Value{1};
end

if isempty(Value)
    Value = [];
    %return
end

if ischar(Value)
    if strcmpi(Value, 'y')
        Value = 'output';
    elseif strcmpi(Value, 'u')
        Value = 'input';
    end
    [Value, msg] = strchoice({'input','output','standard','custom','all','search'}, Value, '');
    if ~isempty(msg)
        if ny>1
            msg = sprintf('The value of the "NonlinearRegressors" property must be a %d-by-1 cell array composed of positive integer vectors or the strings ''input'', ''output'', ''standard'', ''custom'', ''all'', ''search''.',ny);
            msg = struct('identifier','Ident:idnlmodel:nlregMOVal','message',msg);
        else
            msg = 'The value of the "NonlinearRegressors" property must be a positive integer vector or one of ''input'', ''output'', ''standard'', ''custom'', ''all'', ''search''.';
            msg = struct('identifier','Ident:idnlmodel:nlregSOVal','message',msg);
        end
    end
    if ~uselinearterm(nlobj)
        if ~(strcmpi(Value, 'search') || strcmpi(Value, 'all'))
            ctrlMsgUtils.warning('Ident:idnlmodel:idnlarxUselessNlreg', upper(class(nlobj)))
            
            if isa(nlobj, 'linear')
                Value = [];
            else
                Value = 1:length(regs);
            end
        end
    end
    
    return
end

% Now the integer vector case
if ~uselinearterm(nlobj)
    if isa(nlobj, 'linear')
        Value = [];
    else
        Value = 1:length(regs);
    end
    ctrlMsgUtils.warning('Ident:idnlmodel:idnlarxUselessNlreg', upper(class(nlobj)))
    return
end

if ~isempty(Value) && ~isnonnegintmat(Value)
    if ny>1
        msg = sprintf('The value of the "NonlinearRegressors" property must be a %d-by-1 cell array composed of positive integer vectors or the strings ''input'', ''output'', ''standard'', ''custom'', ''all'', ''search''.',ny);
        msg = struct('identifier','Ident:idnlmodel:nlregMOVal','message',msg);
    else
        msg = 'The value of the "NonlinearRegressors" property must be a positive integer vector or one of ''input'', ''output'', ''standard'', ''custom'', ''all'', ''search''.';
        msg = struct('identifier','Ident:idnlmodel:nlregSOVal','message',msg);
    end
    return
end

if ~isempty(Value) && (any(Value<1) || any(Value>length(regs)))
    if ny>1
        msg = 'The value of the "NonlinearRegressors" property must contain integer values between 1 and the number of regressors for the corresponding output.';
        msg = struct('identifier','Ident:idnlmodel:nlregMOIntVal','message',msg);
    else
        msg = 'The value of the "NonlinearRegressors" property must contain integer values between 1 and the number of regressors.';
        msg = struct('identifier','Ident:idnlmodel:nlregSOIntVal','message',msg);
    end
    return
end

if ~isempty(Value) && any(~diff(sort(Value)))
    msg = 'The indices used for the "NonlinearRegressors" property value must be unique.';
    msg = struct('identifier','Ident:idnlmodel:nlregNonUniqueVal','message',msg);
    return
end

%--------------------------------------------------------------------------
function [pvlist, msg] = PVReordering(pvlist)
% Arrange PV-pairs in the pre-defined order.

msg = struct([]);
npv = length(pvlist);
if ~iscellstr(pvlist(1:2:npv))
    msg = struct('identifier','Ident:general:invalidPropertyNames',...
        'message','Property names must be single-line strings.');
    return
end

% The pre-defined property order setting
orderedprops = {'na','nb','nk','TimeVariable','InputName','OutputName', ...
    'CustomRegressors','NonlinearRegressors'};
npops = length(orderedprops);
pvind = zeros(1,2*npops);
for kp=1:npops
    ind = strmatch(orderedprops{kp}, pvlist(1:2:npv), 'exact');
    if length(ind)==1
        pvind([2*kp-1, 2*kp]) = [2*ind-1, 2*ind];
    elseif length(ind)>1
        msg = sprintf('The specification for "%s" property of the %s model is not unique.',orderedprops{kp},'IDNLARX');
        msg = struct('identifier','Ident:general:ambiguousPropSpec','message',msg);
        return
    end
end

pvind = pvind(pvind~=0); % Eliminate zeros
pvind2 = setdiff(1:npv, pvind);
pvlist = pvlist([pvind, pvind2]);

% FILE END
