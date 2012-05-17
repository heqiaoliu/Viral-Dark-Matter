function sys = pvset(sys,varargin)
%PVSET  Set properties of IDMODEL models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.28.4.17 $ $Date: 2009/10/16 04:55:23 $

% RE: PVSET is performing object-specific property value setting
%     for the generic LTI/SET method. It expects true property names.

ut = sys.Utility;
if isfield(ut,'Pmodel') || isfield(ut,'Idpoly') % To check if ynames etc shall be
    % updated in Utility models
    utupdate = 1;
else
    utupdate = 0;
end
pnflag = 0;
covflag =0;
ionameflag = 0;

for i=1:2:nargin-1,
    % Set each PV pair in turn
    Property = varargin{i};
    Value = varargin{i+1};
    if utupdate
        if any(strcmp(Property,{'InputName','OutputName','InputUnit','OutputUnit'}))
            try
                sys = utfix(sys,Property,Value);
            end
        end
    end
    % Set property values
    switch Property
        case 'Ts'
            if isempty(Value)
                Value = 1;
            end
            sys.Ts = idutils.utValidateTs(Value,false);
        case 'Name'
            if ~ischar(Value)
                ctrlMsgUtils.error('Ident:general:strPropType','Name')
            end
            sys.Name = Value;
        case 'InputName'
            sys.InputName = ChannelNameCheck(Value,'InputName',sys);
            ionameflag = 1;
            if ~isempty(idchnona(Value))
                ctrlMsgUtils.error('Ident:general:invalidChannelName')
            end
        case 'OutputName'
            sys.OutputName = ChannelNameCheck(Value,'OutputName',sys);
            ionameflag = 1;
            if ~isempty(idchnona(Value))
                ctrlMsgUtils.error('Ident:general:invalidChannelName')
            end
            
        case 'InputUnit'
            sys.InputUnit =  ChannelNameCheck(Value,'InputUnit',sys);
            
        case 'OutputUnit'
            sys.OutputUnit = ChannelNameCheck(Value,'OutputUnit',sys);
            
        case 'InputDelay'
            if ~isfloat(Value) || ~isreal(Value)
                ctrlMsgUtils.error('Ident:general:invalidInputDelay','idmodel')
            end
            Value = Value(:);
            sys.InputDelay = Value;
            
        case 'Notes'
            sys.Notes = Value;
            
        case 'UserData'
            sys.UserData = Value;
        case 'TimeUnit'
            sys.TimeUnit = Value;
            
        case 'Algorithm'
            [~,fie,typ,def] = iddef('algorithm');
            if ~isstruct(Value)
                ctrlMsgUtils.error('Ident:idmodel:invalidAlgoStruct','idmodel')
            end
            
            % backward compatibility check and update (before R2008a, ver 7.2 of SITB)
            Value = LocalUpdateBkCompatibility(Value,size(sys,1));
            fie2 = fieldnames(Value);
            val = struct2cell(Value);
            for kk = 1:length(fie)
                kf = find(strcmp(fie{kk},fie2)==1);
                if isempty(kf)
                    ctrlMsgUtils.error('Ident:idmodel:invalidAlgoStruct','idmodel')
                else
                    Value1 = checkalg(fie2{kf}, val{kf},fie,typ,def,sys);
                    Value.(fie2{kf}) = Value1;
                end
            end
            sys.Algorithm = Value;
            
        case 'EstimationInfo',
            sys.EstimationInfo = Value;
            
        case 'ParameterVector'
            sys.ParameterVector = Value(:);
        case 'PName'
            pnflag = 1;
            sys.PName =  ChannelNameCheck(Value,'PName',sys);
        case 'CovarianceMatrix'
            if ischar(Value),
                if lower(Value(1))=='e'
                    Value =[];
                else
                    Value = 'None';
                end
            end
            sys.CovarianceMatrix = Value;
            covflag = 1;
            
        case 'NoiseVariance'
            ny = size(sys,1);
            if max(abs(imag(diag(Value))))>eps
                ctrlMsgUtils.error('Ident:idmodel:invalidNoiDiag')
            end
            Value = (Value'+Value)/2;
            if size(Value,1)~=size(Value,2)
                ctrlMsgUtils.error('Ident:idmodel:incorrectNoiDim',ny,ny)
            end
            if any(~isfinite(Value(:))) % any(any(isnan(Value))) || any(any(isinf(Value)))
                Value = eye(size(Value));
                ctrlMsgUtils.warning('Ident:idmodel:nonfiniteNoi');
            end
            eigtest = min(eig(Value));
            if eigtest<0
                Value = Value + abs(eigtest)*eye(size(Value));
                ctrlMsgUtils.warning('Ident:idmodel:indefiniteNoi')
            end
            sys.NoiseVariance = Value;
        case 'Utility'
            sys.Utility = Value;
        case 'Version'
            sys.Version = Value;
        case 'OptimMessenger'
            if ~isempty(Value) && ~isa(Value,'nlutilspack.optimmessenger')
                ctrlMsgUtils.error('Ident:idmodel:invalidMessenger')
            end
            sys.Utility.OptimMessenger = Value;
        case 'CovarianceData'
            % A cell array of two matrices - Factor1 and Factor2
            % Explanation:
            % C = inv(J1'J1)*(J2'J2)*inv(J1'J1)
            %[Q1,R1] = qr(J1,0)
            %[Q2,R2] = qr(J2,0)
            %Factor1 = inv(R1)
            %Factor2 = R2
            %C = (Factor1*Factor1'*Factor2)'*(Factor1*Factor1'*Factor2);
            % so that
            %chol(C) = (Factor1*Factor1'*Factor2);
            
            
            
        otherwise
            [~,PropAlg,TypeAlg,DefValue] = iddef('algorithm');
            Value = checkalg(Property,Value,PropAlg,TypeAlg,DefValue,sys);
            %error(errormsg)
            Algorithm = sys.Algorithm;
            Algorithm.(Property) = Value; % setfield(Algorithm,Property,Value);
            sys.Algorithm = Algorithm;
    end % switch
end % for

np = length(sys.ParameterVector);
if np ~= length(sys.PName) && ~isempty(sys.PName)
    if pnflag
        ctrlMsgUtils.error('Ident:idmodel:PnamePvecLenMismatch')
    end
    sys.PName = defnum(sys.PName,'',np);
end

if sys.Ts
    if ~isempty(sys.InputDelay) && (any(sys.InputDelay~=round(sys.InputDelay)))
        ctrlMsgUtils.error('Ident:general:dtInputdelay','idmodel')
    end
end
if ionameflag
    %ChannelNameCheck([sys.InputName;sys.OutputName],'InputName/OutputName',sys);
    commonName = intersect(sys.InputName, sys.OutputName);
    if ~isempty(commonName) && ~all(strcmp(commonName,''))
        ctrlMsgUtils.error('Ident:general:IONameClash')
    end
end
if covflag
    cov = sys.CovarianceMatrix;
    if ~ischar(cov) && ~isempty(cov)
        [n1,n2] = size(cov);
        if n1~=np || n2~=np
            ctrlMsgUtils.error('Ident:idmodel:incorrectCovDim')
        end
    elseif (ischar(cov) && strcmpi(cov(1),'n')) || isempty(cov) % If covariance has been nullified the "variance models" should be deleted
        ut = sys.Utility;
        if isfield(ut,'Pmodel')
            ut.Pmodel = [];
        end
        if isfield(ut,'Idpoly')
            ut.Idpoly = [];
        end
        sys.Utility = ut;
    end
end
% Note: size consistency checks deferred to idss/pvset, idpoly/pvset,...
%       to allow resizing of the I/O dimensions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction ChannelNameCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = ChannelNameCheck(a,Name,sys)
% Checks specified I/O names
if isempty(a),
    a = a(:);   % make 0x1
    return
end

% Determine if first argument is an array or cell vector
% of single-line strings.
if ischar(a) && ndims(a)==2,
    % A is a 2D array of padded strings
    a = cellstr(a);
    
elseif iscellstr(a) && ndims(a)==2 && min(size(a))==1,
    % A is a cell vector of strings. Check that each entry
    % is a single-line string
    a = a(:);
    if any(cellfun('ndims',a)>2) || any(cellfun('size',a,1)>1)
        ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,upper(class(sys)))
    end
else
    ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,upper(class(sys)))
end

% Make sure that nonempty I/O names are unique
if ~strcmpi(Name(end-3:end),'unit') && length(a)>1
    nonemptya = setdiff(a,{''}); %removes duplicate entries in a as well as ''.
    eI = strcmp(a,'');
    if length(a)~=(sum(eI)+length(nonemptya))
        ctrlMsgUtils.error('Ident:general:nonUniqueNames',Name,upper(class(sys)))
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sys = utfix(sys,Property,Value)
ut = sys.Utility;
try
    ut.Pmodel = pvset(ut.Pmodel,Property,Value);
end
try
    idp = ut.Idpoly;
catch
    idp = [];
end
if ~isempty(idp)
    for ki = 1:length(idp)
        if strcmp(Property,'InputName');
            una = pvget(idp{ki},'InputName');
            if ~isa(Value,'cell'), Value={Value};end
            una(1:length(Value))=Value;
            Value1 = una;
        end
        if strcmp(Property,'OutputName')
            if isa(Value,'cell'),Value1 = Value{ki};end
        end
        idp{ki} = pvset(idp{ki},Property,Value1);
        if strcmp(Property,'OutputName')
            una = pvget(idp{ki},'InputName');
            ky = 0;
            for ks = 1:length(una)
                llna = una{ks};
                nr=findstr(llna,'@');
                if ~isempty(nr), ky=ky+1;
                    una{ks}=[llna(1:nr),Value{ky}];
                end
            end
            idp{ki} = pvset(idp{ki},'InputName',una);
        end
        
    end
    ut.Idpoly = idp;
end
sys.Utility = ut;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Value = checkalg(Property,Value,PropAlg,TypeAlg,DefValue,sys)
%errormsg = [];
switch Property
    case PropAlg
        if strcmp(Property,'SearchMethod') && strcmpi(Value,'gns')
            ctrlMsgUtils.warning('Ident:idmodel:obsoleteSearchMethodGNS')
            Value = 'gn';
        end
        
        focskip = 0;
        if strcmp(Property,'Focus')
            if isa(Value,'idmodel') || isa(Value,'lti') || iscell(Value)
                %focskip = 1;
                if iscell(Value)
                    if ~any(length(Value)==[2,4,5])%&length(Value)~=2&length(Value)~=5
                        ctrlMsgUtils.error('Ident:idmodel:invalidFocFilt1')
                    end
                else
                    [ny,nu]=size(Value);
                    if max(ny,nu)>1 || nu==0
                        ctrlMsgUtils.error('Ident:idmodel:invalidFocFilt2')
                    end
                end
                return
            end
            if isnumeric(Value),  %%TM
                if size(Value,2)==2 || size(Value,2)==1,
                    return
                end
            end
        end %focus
        
        if strcmp(Property,'Weighting')
            ny = size(sys,1);
            if ndims(Value)>2
                ctrlMsgUtils.error('Ident:general:incorrectWeighting1',ny);
            end
            
            [sr,sc]  = size(Value);
            if ny==0
                if ~isempty(Value)
                    ctrlMsgUtils.error('Ident:general:incorrectWeighting2');
                end
            elseif ny==1
                if isempty(Value) || ~(isscalar(Value) && isreal(Value) && isfinite(Value) && Value>0)
                    ctrlMsgUtils.error('Ident:general:positiveScalarAlgPropVal','Weighting');
                end
            elseif (sr~=sc) || (sr~=ny) || ~(~isempty(Value) && isrealmat(Value) && ...
                    all(isfinite(Value(:))) && (min(eig(Value))>=0))
                ctrlMsgUtils.error('Ident:general:incorrectWeighting1',ny);
            end
        end %Weighting
        
        nr = strcmp(Property,PropAlg);
        prop = PropAlg(nr);
        typ = TypeAlg(nr);
        if isempty(Value)
            Value = DefValue{nr};
            return
        end
        if strcmpi(prop,'Focus') && ~focskip
            try
                [Value,status]=pnmatchd(Value,typ{:},6);
            catch
                ctrlMsgUtils.error('Ident:idmodel:invalidFocus')
            end
        elseif strcmp(prop,'N4Horizon')
            if ischar(Value)
                Value = 'Auto';
            else
                [nr,nc] = size(Value);
                if nc == 1
                    Value = Value*ones(1,3);
                elseif nc~=3
                    ctrlMsgUtils.error('Ident:idmodel:invalidN4Horizon1');
                end
                if ~isempty(Value) && (ischar(Value) || ~isreal(Value) || any(Value(:)<0) ||...
                        any(fix(Value(:))~=Value(:)))
                    ctrlMsgUtils.error('Ident:idmodel:invalidN4Horizon2')
                end
                
            end
        elseif strcmp(prop,'N4Weight')
            typ = typ{1};
            
            try
                [Value,status] = pnmatchd(Value,{typ{:}},6);
            catch
                ctrlMsgUtils.error('Ident:idmodel:invalidN4Weight')
            end
        else
            typ = typ{1};
            if length(typ)>1
                try
                    [Value,status] = pnmatchd(Value,{typ{:}},6);
                catch E
                    %disp(['Possible values for ',prop{1},':'])
                    %disp(typ)
                    ctrlMsgUtils.error('Ident:idmodel:invalidAlgoPropVal',prop{1})
                end
            else
                switch typ{1}
                    case 'positive'
                        if ischar(Value) || ~isreal(Value) || ~isscalar(Value) || any(Value<0)
                            ctrlMsgUtils.error('Ident:general:nonnegativeNumAlgPropVal',Property)
                        end
                    case 'integer'
                        if strcmp(Property,'MaxSize') && (ischar(Value) || isempty(Value))
                            Value = 'Auto';
                        elseif strcmpi(Property,'MaxIter') && (Value==-1 || Value==0)
                            % do nothing
                        elseif ~isposintscalar(Value)
                            ctrlMsgUtils.error('Ident:general:positiveIntAlgPropVal',Property)
                        end
                        if strcmp(Property,'MaxSize') && ~ischar(Value)
                            if Value<50
                                ctrlMsgUtils.warning('Ident:idmodel:smallMaxSize')
                            end
                        end
                        
                    case 'intarray'
                        if ~strcmp(prop,'N4Horizon')
                            if ~isempty(Value) && ~isposintmat(Value)
                                ctrlMsgUtils.error('Ident:general:positiveIntArrayAlgPropVal',Property)
                            end
                        end
                    case 'structure'
                        if ~isstruct(Value)
                            ctrlMsgUtils.error('Ident:general:structAlgPropVal',Property)
                        end
                        % More tests could be added
                end
            end
        end
    otherwise
        ctrlMsgUtils.error('Ident:general:unknownAlgoProp',Property,'idmodel algorithm')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Value = LocalUpdateBkCompatibility(Value,ny)
% Check if Algorithm is of the old format: SearchDirection is place of
% Search Method, missing Criterion and Weighting

fie = fieldnames(Value);
val = struct2cell(Value);
Indr = strcmpi(fie,'SearchDirection');
if any(Indr) && ~any(strcmpi(fie,'SearchMethod'))
    ctrlMsgUtils.warning('Ident:idmodel:oldAlgorithm')
    fie{Indr} = 'SearchMethod';
    Value = cell2struct(val,fie);
end

if ~any(strcmp('Criterion',fie))
    Value.Criterion = 'det';
end

if ~any(strcmp('Weighting',fie))
    Value.Weighting = eye(ny);
end

% Rename Trace to Display
IndT = strcmpi('Trace',fie);
if any(IndT)
    fie{IndT} = 'Display';
    Value = cell2struct(val,fie);
end

% Replace GnsPinvTol with GnPinvConst
se = Value.Advanced.Search;
fie = fieldnames(se);
val = struct2cell(se);
Indr = strcmp(fie,'GnsPinvTol');
if any(Indr)
    fie{Indr} = 'GnPinvConst';
    val{Indr} = 1e4;
    se = cell2struct(val,fie);
    Value.Advanced.Search = se;
end
