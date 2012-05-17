function sys = pvset(sys,varargin)
%PVSET  Set properties of IDFRD models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.15.2.6 $  $Date: 2008/10/02 18:47:26 $

unitsChanged = 0;
freqChanged = 0;
ionameflag = 0;
for i=1:2:nargin-1,
    % Set each PV pair in turn
    Property = varargin{i};
    Value = varargin{i+1};

    % Set property values
    switch Property
        case 'Ts'
            if isempty(Value)
                Value = 1;
            end
            Value = idutils.utValidateTs(Value,false);
            sys.Ts = Value;

        case 'InputName'
            sys.InputName = ChannelNameCheck(Value,'InputName');
            if ~isempty(idchnona(Value))
                ctrlMsgUtils.error('Ident:general:invalidChannelName')
            end
            ionameflag = 1;

        case 'OutputName'
            sys.OutputName = ChannelNameCheck(Value,'OutputName');
            if ~isempty(idchnona(Value))
                ctrlMsgUtils.error('Ident:general:invalidChannelName')
            end
            ionameflag = 1;

        case 'InputUnit'
            sys.InputUnit =  ChannelNameCheck(Value,'InputUnit');

        case 'OutputUnit'
            sys.OutputUnit = ChannelNameCheck(Value,'OutputUnit');

        case 'Notes'
            sys.Notes = Value;

        case 'UserData'
            sys.UserData = Value;

        case 'EstimationInfo',
            sys.EstimationInfo = Value;

        case 'ResponseData'
            sys.ResponseData = Value;

        case 'CovarianceData'
            sys.CovarianceData = Value;

        case 'SpectrumData'
            sys.SpectrumData = Value;

        case 'NoiseCovariance'
            sys.NoiseCovariance = Value;

        case 'Frequency'
            nd = ndims(Value);
            m = min(size(Value));
            if nd~=2 || m ~= 1
                ctrlMsgUtils.error('Ident:idfrd:invalidFreq')
            end
            if any(Value<0) || any(imag(Value)~=0)
                ctrlMsgUtils.error('Ident:idfrd:invalidFreq')
            end

            sys.Frequency = Value(:);
            freqChanged = 1;

        case 'Units'
            if ~ischar(Value),
                ctrlMsgUtils.error('Ident:general:singlestrPropType','Units')
                %elseif strncmpi(Value,'r',1)
                %Value = 'rad/s';
            elseif strncmpi(Value,'h',1)
                Value = 'Hz';
            elseif ~any(lower(Value(1))==['r','c','1']) || isempty(findstr(Value,'/'))
                ctrlMsgUtils.error('Ident:idfrd:incorrectUnits')
            end
            if ~strcmp(sys.Units,Value)
                unitsChanged = 1;
                sys.Units = Value;
            end

        case 'InputDelay'
            if ~isa(Value,'double') || ~isreal(Value)
                ctrlMsgUtils.error('Ident:general:invalidInputDelay','idfrd')
            end
            Value = Value(:);
            sys.InputDelay = Value;
        case 'Version'
            sys.Version = Value;
        case 'Notes'
            sys.Notes = Value;
        case 'UserData'
            sys.UserData = Value;
        case 'Utility'
            sys.Utility = Value;
        case 'Name'
            sys.Name = Value;
        otherwise
            ctrlMsgUtils.error('Ident:general:unknownProp',...
                Property,'IDFRD','idfrd')
    end % switch
end % for

%%%% Consistency checks
sys = timemark(sys);
Nf = length(sys.Frequency);
Value = sys.ResponseData;
nd = ndims(Value);
if Nf>1
    if nd == 2
        nd = min(size(Value));
    end
    if ~any(nd==[0 1 3])
        ctrlMsgUtils.error('Ident:idfrd:incorrectRespMatrix')
    end
    if nd == 1
        Va = zeros(1,1,length(Value));
        Va(1,1,:) = Value;
        sys.ResponseData = Va;
    end
end

[nyr,nur,Nr] = size(sys.ResponseData);

Value = sys.CovarianceData;
if ~isempty(Value)
    nd = ndims(Value);
    if nd~=5
        ctrlMsgUtils.error('Ident:idfrd:incorrectCov')
    end
    [n1,n2,n3,n4,n5]=size(Value);
    if ~(n4==2 && n5==2) || n3~=Nf || nyr~=n1 || n2~=nur
        ctrlMsgUtils.error('Ident:idfrd:incorrectCov')
    end
end

Value = sys.SpectrumData;
if ~isempty(Value)
    if Nf>1
        nd = ndims(Value);
        if nd == 2
            nd = min(size(Value));
        end
        if ~(nd==1 || nd==3)
            ctrlMsgUtils.error('Ident:idfrd:incorrectSpec1')
        end
        if nd == 1
            Va = zeros(1,1,length(Value));
            Va(1,1,:) = Value;
            sys.SpectrumData = Va;
        end
    end
    [nys,nus,nfs]= size(sys.SpectrumData);
    if nys~=nus || nfs~=Nf
        ctrlMsgUtils.error('Ident:idfrd:incorrectSpec2')
    end
    if nyr>0
        if nys~=nyr
            ctrlMsgUtils.error('Ident:idfrd:incorrectSpec3')
        end
    end
else
    nys = 0;
end
Value = sys.NoiseCovariance;
if ~isempty(Value)
    if Nf > 1
        nd = ndims(Value);
        if nd ==2
            nd = min(size(Value));
        end
        if ~(nd==1 || nd==3)
            ctrlMsgUtils.error('Ident:idfrd:incorrectNoi1')
        end
        if nd == 1
            Va = zeros(1,1,length(Value));
            Va(1,1,:) = Value;
            sys.NoiseCovariance = Va;
        end
        [nyn,nun,nfn]= size(sys.NoiseCovariance);
        if nyn~=nun || nyn~=nys || nfn ~= Nf
            ctrlMsgUtils.error('Ident:idfrd:incorrectNoi2')
        end
    end
end

ny = max(nys,nyr);
sys = idmcheck(sys,[ny,nur]);
if unitsChanged && ~freqChanged
    ctrlMsgUtils.warning('Ident:iddata:freqUnitChanged',sys.Units);
end

if sys.Ts
    if any(sys.InputDelay~=fix(sys.InputDelay))
        ctrlMsgUtils.error('Ident:general:dtInputdelay','idfrd')
    end
end

if ionameflag
    if ~isempty(intersect(sys.InputName, sys.OutputName))
        ctrlMsgUtils.error('Ident:general:IONameClash')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction ChannelNameCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = ChannelNameCheck(a,Name)
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
    if any(cellfun('ndims',a)>2) || any(cellfun('size',a,1)>1),
        ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,'IDFRD')
    end

else
    ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,'IDFRD')
end

% Make sure that I/O names are unique
if ~strcmpi(Name(end-3:end),'unit') && length(a)>1
    if length(unique(a))~=length(a)
        ctrlMsgUtils.error('Ident:general:nonUniqueNames',Name,'IDFRD')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
