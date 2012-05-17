function Out = pvset(dat,varargin)
%PVSET  Set properties of IDDATA objects.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.27.4.11 $ $Date: 2009/07/09 20:52:02 $

% RE: PVSET is performing object-specific property value setting
%     for the generic IDDATA/SET method. It expects true property names.

ni = nargin;
no = nargout;
if ~isa(dat,'iddata')
    % Call built-in SET. Handles calls like set(gcf,'user',ss)
    builtin('set',dat,varargin{:});
    return
end

if ni<=2,
    [AllProps,AsgnValues] = pnames(dat);
else
    AllProps = pnames(dat);
end


% Handle read-only cases
if ni==1,
    if strcmpi(dat.Domain,'frequency')
        AllProps(13:16)={'Fs';'Fstart';'SamplingFrequencies';'FrequencyUnit'};
        AsgnValues(13:16)={ 'Scalar  (Sampling frequency, empty if non-equal sampling)';...
            'Scalar  (First frequency)';...
            'N-by-1 matrix (leave empty if equidistant sampling)';...
            'String'};
    end
    
    % SET(DAT) or S = SET(DAT)
    if no,
        Out = cell2struct(AsgnValues,AllProps,1);
    else
        disp('Necessary properties:')
        for i=[1 3 6]
            disp(['  ',AllProps{i},':  ',AsgnValues{i}])
        end
        disp(' ')
        disp('Optional output properties:')
        for i=[4 5 ]
            disp(['  ',AllProps{i},':  ',AsgnValues{i}])
        end
        disp(' ')
        disp('Optional input properties:')
        for i=[ 7 8 9]
            disp(['  ',AllProps{i},':  ',AsgnValues{i}])
        end
        text=AsgnValues{10};
        disp(['  ',AllProps{10},':  ',text{1}])
        disp(['        ',text{2}])
        
        disp(' ')
        disp('Optional sampling properties:')
        for i=[11 12 13 14]
            disp(['  ',AllProps{i},':  ',AsgnValues{i}])
        end
        disp(' ')
        disp('Optional user properties:')
        for i=[2 15 16 17]
            disp(['  ',AllProps{i},':  ',AsgnValues{i}])
        end
        
        disp(' ')
        disp('Type "idprops iddata" for more details.')
    end % if no
    return
    
elseif ni==2,
    % SET(DAT,'Property') or STR = SET(DAT,'Property')
    Property = varargin{1};
    if ~ischar(Property),
        ctrlMsgUtils.error('Ident:general:invalidPropertyNames')
    end
    
    % Return admissible property value(s)
    [Property,imatch] = pnmatchd(Property,AllProps,7);
    
    if no,
        Out = AsgnValues{imatch};
    else
        disp(AsgnValues{imatch})
    end
    return
end


% Now left with SET(DAT,'Prop1',Value1, ...)
name = inputname(1);
if isempty(name),
    ctrlMsgUtils.error('Ident:general:invalidSetTarget')
elseif rem(ni-1,2)~=0,
    ctrlMsgUtils.error('Ident:general:CompletePropertyValuePairs','IDDATA','iddata/set')
end
%datnew=dat;
flag=zeros(1,20);

for i=1:2:ni-1,
    % Set each PV pair in turn
    
    Property = varargin{i};
    Value = varargin{i+1};
    [nrv,ncv]=size(Value);nrtest=min(nrv,ncv);
    
    switch Property
        case 'Domain'
            if length(varargin)==2
                ctrlMsgUtils.warning('Ident:dataprocess:dataDomainChange')
            end
            if ~(strcmpi(Value(1),'t') || strcmpi(Value(1),'f'))
                ctrlMsgUtils.error('Ident:iddata:invalidDataDomain')
            end
            if lower(Value(1))=='t'
                Value = 'Time';
            else
                Value = 'Frequency';
                % warning('All features for frequency domain data currently not supported.');
            end
            dat.Domain=Value;
            flag(1)=1;
        case 'Name'
            if ~ischar(Value)
                ctrlMsgUtils.error('Ident:general:strPropType','Name')
            end
            dat.Name = Value;
            flag(2)=1;
        case 'OutputData'
            [Value,error_struct] = datachk(Value,'OutputData');
            error(error_struct)
            dat.OutputData=Value;
            flag(3)=1;
            
        case 'OutputName'
            dat.OutputName = ChannelNameCheck(Value,'OutputName');
            if ~isempty(idchnona(Value))
                ctrlMsgUtils.error('Ident:general:invalidChannelName')
            end
            flag(5)=1;
        case 'OutputUnit'
            dat.OutputUnit = ChannelNameCheck(Value,'OutputUnit');
            flag(6)=1;
            
        case 'InputData'
            [Value,error_struct] = datachk(Value,'InputData');
            error(error_struct)
            dat.InputData=Value;
            flag(7)=1;
            
        case 'InputName'
            dat.InputName = ChannelNameCheck(Value,'InputName');
            if ~isempty(idchnona(Value))
                ctrlMsgUtils.error('Ident:general:invalidChannelName')
            end
            flag(9)=1;
        case 'InputUnit'
            dat.InputUnit = ChannelNameCheck(Value,'InputUnit');
            flag(10) = 1;
        case 'Period'
            [Value,error_struct] = datachk(Value,'Period');
            error(error_struct)
            if any(Value{1}<0) % Check also the others
                ctrlMsgUtils.error('Ident:iddata:invalidPeriod')
            end
            dat.Period = Value;
            %%LL Checks
            flag(18)=1;
        case 'InterSample'
            %[Value,stat] = cstrchk(Value,'InterSample');error(stat)
            if ~ischar(Value) && ~iscell(Value)
                ctrlMsgUtils.error('Ident:iddata:invalidInterSampleFormat')
            end
            if ischar(Value)
                Value={Value};
            end
            [n1,n2]=size(Value);
            for k1=1:n1
                for k2=1:n2
                    Name = Value{k1,k2};
                    if ~any(strcmp(Name,{'zoh','foh','bl'}) )
                        ctrlMsgUtils.error('Ident:iddata:incorrectInterSample')
                    end
                end
            end
            if ischar(Value)
                Value = {Value};
            end
            dat.InterSample = Value;
            flag(19)=1;
        case 'Ts',
            if ~iscell(Value), Value = {Value}; end
            dat.Ts = Value;
            flag(13) = 1;
        case 'Tstart'
            % The value check is deferred to the exit checks due to the
            % Unit/Tstart duality
            Tstartold = dat.Tstart;
            dat.Tstart = Value;
            flag(14) = 1;
            
        case 'SamplingInstants'
            if dat.Domain(1)=='F'
                str = 'The Frequency Vector';
            else
                str = 'The Sampling instants vector';
            end
            [Value,error_struct] = datachk(Value,str);
            error(error_struct)
            dat.SamplingInstants = Value; % Check column or row?
            flag(15) = 1;
        case 'TimeUnit'
            if ~ischar(Value) || size(Value,1)>1
                ctrlMsgUtils.error('Ident:general:singlestrPropType','TimeUnit')
            end
            dat.TimeUnit = Value;
            flag(16) = 1;
        case 'ExperimentName'
            [Value,stat] = cstrchk(Value,'ExperimentName');
            error(stat)
            if nrtest>1
                ctrlMsgUtils.error('Ident:iddata:invalidMultiExpPropLen','ExperimentName')
            end
            if ischar(Value), Value = {Value}; end
            dat.ExperimentName = Value;
            flag(17) = 1;
        case 'Notes'
            dat.Notes = Value;
            
        case 'UserData'
            dat.UserData = Value;
        case 'Utility'
            dat.Utility = Value;
        otherwise
            %Property
            %Value
            ctrlMsgUtils.error('Ident:general:unknownProp',...
                Property,'IDDATA','iddata')
            
    end % switch
end % for


% EXIT CHECKS:
if any(flag([5 9])) % i/o name
    if ~isempty(intersect(dat.InputName, dat.OutputName))
        ctrlMsgUtils.error('Ident:general:IONameClash')
    end
    %ChannelNameCheck([dat.InputName;dat.OutputName],'InputName/OutputName');
end
dom = dat.Domain;

%{
if strcmpi(dom,'frequency')
    sampi = 'frequencies';
    strts = 'Sampling Frequency';
else
    sampi = 'Sampling Instants';
    strts = 'Sampling Interval';
end
%}

% First check te consistencies of the data sizes
dat = timemark(dat);
if any(flag([3,7])) % New data have been defined
    Ney = length(dat.OutputData);
    Neu = length(dat.InputData);
    if isempty(dat.OutputData{1})
        ny = size(dat.OutputData{1},2);
        for kk = 1:Neu
            N = size(dat.InputData{kk},1);
            y{kk} = zeros(N,ny);
        end
        Ney = Neu; dat.OutputData = y; %
    end
    if isempty(dat.InputData{1})
        nu = size(dat.InputData{1},2);
        for kk = 1:Ney
            N = size(dat.OutputData{kk},1);
            u{kk} = zeros(N,nu);
        end
        Neu = Ney; dat.InputData = u;
    end
    if Neu~=length(dat.ExperimentName)
        dat.ExperimentName = defnum(dat.ExperimentName,'Exp',Neu);
    end
    if ~all(Neu == [Ney,length(dat.ExperimentName)])
        ctrlMsgUtils.error('Ident:iddata:IOExpNameCellLen')
    end
    for kk = 1:Neu
        [Nu,nuk] = size(dat.InputData{kk});
        [Ny,nyk] = size(dat.OutputData{kk});
        if kk == 1
            nu1 = nuk; ny1 = nyk;
        end
        if Nu~=Ny
            ctrlMsgUtils.error('Ident:iddata:IORowNum')
        end
        if nuk ~=nu1 || nyk ~= ny1
            ctrlMsgUtils.error('Ident:iddata:unequalIODimInMultiExp')
        end
    end
end % End of the new data checks (flag 3, 7)

Ne=length(dat.InputData);

if ~flag(13)
    if length(dat.Ts)<Ne
        for kk=length(dat.Ts)+1:Ne
            dat.Ts(kk)=dat.Ts(1);
        end
    elseif length(dat.Ts)>Ne
        dat.Ts=dat.Ts(1:Ne);
    end
end
if ~flag(14)
    if length(dat.Tstart)<Ne
        for kk=length(dat.Tstart)+1:Ne
            dat.Tstart(1,kk)=dat.Tstart(1);
        end
    elseif length(dat.Tstart)>Ne
        dat.Tstart=dat.Tstart(1:Ne);
    end
end

Sampl=dat.SamplingInstants;Ts=dat.Ts;Tstart=dat.Tstart;
if strcmpi(dom,'time')
    if flag(13) % Ts has been set
        if Ne>1
            if length(Ts)==1
                Tst=Ts;
                for kk=1:Ne
                    Ts(kk)=Tst;
                end
            elseif Ne~=length(Ts)
                ctrlMsgUtils.error('Ident:iddata:invalidMultiExpPropLen','Ts')
            end
        end
        for kk=1:Ne
            if ~isempty(Ts{kk})
                Nk=size(dat.InputData{kk},1);
                Sampl{kk}=zeros(Nk,0);
            elseif isempty(Sampl{kk})
                ctrlMsgUtils.error('Ident:iddata:emptyTsAndSamp')
            end
        end
        Ts = idutils.utValidateTs(Ts,true,true);
    end
    if flag(14) % Tstart has been set
        [Tstart,error_struct] = datachk(Tstart,'Tstart');
        error(error_struct)
        for kk = 1:length(Tstart)
            if ~ischar(Tstart{kk}) && length(Tstart{kk})>1 % Check also the others
                ctrlMsgUtils.error('Ident:iddata:invalidTStart')
            end
        end
        
        if Ne>1
            if length(Tstart)==1
                Tstartt=Tstart;
                for kk=1:Ne
                    Tstart(kk)=Tstartt;
                end
            elseif Ne~=length(Tstart)
                ctrlMsgUtils.error('Ident:iddata:invalidMultiExpPropLen','Tstart')
            end
        end
        for kexp = 1:Ne
            if isempty(Ts{kexp}) && ~isempty(Tstart{kexp})
                ctrlMsgUtils.error('Ident:iddata:TStartWithoutTs')
            end
        end
    end
    if Ne>1
        if length(Sampl)==1
            Samplt=Sampl;
            for kk=1:Ne
                Sampl(kk)=Samplt;
            end
        elseif Ne~=length(Sampl)
            ctrlMsgUtils.error('Ident:iddata:invalidMultiExpPropLen','SamplingInstants')
        end
    end
    for kk=1:Ne
        Nk=size(dat.InputData{kk},1);
        if isempty(Sampl{kk})
            Sampl{kk}=zeros(Nk,0);
        end
        Samplkk = Sampl{kk};
        if ~isempty(Samplkk) && (numel(Samplkk)~=Nk)
            ctrlMsgUtils.error('Ident:iddata:incorrectSampDim')
        end
        if ~isempty(Samplkk)
            % First check if it is equal sampling:
            ds = diff(Samplkk);
            if isempty(ds),ds=1;end
            if norm(ds(1)-ds)<(0.00001/max(ds)) % This might be tuned
                Ts{kk} = ds(1); Tstart{kk}=Samplkk(1);
                Samplkk = zeros(Nk,0);
            else
                %disp('Warning: Ts and Tstart have been set to [].')
                Ts{kk} = []; Tstart{kk} = [];
            end
            Sampl{kk} = Samplkk(:);
        elseif isempty(Ts{kk})
            ctrlMsgUtils.error('Ident:iddata:emptyTsAndSamp')
        end
    end
else %% Here are the tests in the frequency domain case
    if isempty(Sampl{1})
        ctrlMsgUtils.error('Ident:iddata:noFreqSpec')
    end
    if flag(14) % Tstart = unit has been set
        if ischar(Tstart)
            tss = Tstart;clear Tstart
            for kexp = 1:Ne
                Tstart{1,kexp} = tss;
            end
        end
        
        [Tstart,errorstruct] = cstrchk(Tstart,'Unit');
        error(errorstruct)
        try
            dispw = 0;
            for kexp = 1:length(Tstart)
                if lower(Tstart{kexp}(1))~=lower(Tstartold{kexp}(1))
                    dispw = 1;
                end
            end
            if dispw
                tsw = sprintf('%s ',Tstart{:});
                tsw = tsw(1:end-1);
                if length(Tstart)>1
                    tsw = ['{',tsw,'}'];
                end
                ctrlMsgUtils.warning('Ident:iddata:freqUnitChanged',tsw)
            end
        end
        
        if length(Tstart)~=Ne
            ctrlMsgUtils.error('Ident:iddata:invalidMultiExpPropLen','Unit')
        end
    end
    if flag(15) % SamplingInstants = Frequency has been set
        if Ne>1
            if length(Sampl)==1
                Samplt=Sampl;
                for kk=1:Ne
                    Sampl(kk)=Samplt;
                end
            elseif Ne~=length(Sampl)
                ctrlMsgUtils.error('Ident:iddata:invalidMultiExpPropLen','Frequency')
            end
        end
        for kk=1:Ne
            Nk=size(dat.InputData{kk},1);
            %             if isempty(Sampl{kk})
            %                 Sampl{kk}=zeros(Nk,0);
            %             end
            Sampl{kk}=Sampl{kk}(:);  %%LL
            if size(Sampl{kk},1)~=Nk
                ctrlMsgUtils.error('Ident:iddata:incorrectFreqDim')
            end
        end
    end
    if flag(13) % Ts has been set
        if Ne>1
            if length(Ts)==1
                Tst=Ts;
                for kk=1:Ne
                    Ts(kk)=Tst;
                end
            elseif Ne~=length(Ts)
                ctrlMsgUtils.error('Ident:iddata:invalidMultiExpPropLen','Ts')
            end
        end
        Ts = idutils.utValidateTs(Ts,true,false);
    end
end
dat.Ts=Ts;dat.SamplingInstants=Sampl;dat.Tstart=Tstart;
nu=size(dat.InputData{1},2);ny=size(dat.OutputData{1},2);

yname = dat.OutputName;
uname = dat.InputName;
yunit = dat.OutputUnit;
uunit = dat.InputUnit;
expname = dat.ExperimentName;
if length(yname)~=ny
    if flag(5)
        ctrlMsgUtils.error('Ident:general:incorrectYPropLen','OutputName',ny)
    else
        yname = defnum(yname,'y',ny);
        dat.OutputName = yname;
    end
end
if length(yunit)~=ny
    if flag(6)
        ctrlMsgUtils.error('Ident:general:incorrectYPropLen','OutputUnit',ny)
    else
        yunit = defnum(yunit,'',ny);
        dat.OutputUnit = yunit;
    end
end
%end

%if nu>0
if length(uname)~=nu
    if flag(9)
        ctrlMsgUtils.error('Ident:general:incorrectUPropLen','InputName',nu)
    else
        uname = defnum(uname,'u',nu);
        dat.InputName = uname;
    end
end
if length(uunit)~=nu
    if flag(10)
        ctrlMsgUtils.error('Ident:general:incorrectUPropLen','InputUnit',nu)
    else
        uunit = defnum(uunit,'',nu);
        dat.InputUnit = uunit;
    end
end
%end
if length(expname)~=Ne
    if flag(17)
        ctrlMsgUtils.error('Ident:iddata:invalidMultiExpPropLen','ExperimentName')
    else
        expname = defnum(expname,'Exp',Ne);
        dat.ExperimentName = expname;
    end
end

if nu>1 && length(unique(uname)) ~= nu
    ctrlMsgUtils.error('Ident:iddata:nonUniqueUNam')
end

if ny>1 && length(unique(yname)) ~= ny
    ctrlMsgUtils.error('Ident:iddata:nonUniqueYNam')
end

if Ne>1 && length(unique(expname)) ~= Ne
    ctrlMsgUtils.error('Ident:iddata:nonUniqueExpNam')
end

if any(flag([18 19 3 7]))
    Np=length(dat.Period);
    [nui,Ni]=size(dat.InterSample);
    if Np~=Ne
        if flag(18)
            ctrlMsgUtils.error('Ident:iddata:invalidMultiExpPropLen','Period')
        elseif Np>Ne
            dat.Period=dat.Period(1:Ne);
        else
            for kk=Np+1:Ne
                dat.Period{kk}=inf*ones(nu,1);
            end
        end
    end
    if (Ne~=Ni || nui~=nu) && (nu>0) %%LL%%
        if flag(19)
            ctrlMsgUtils.error('Ident:iddata:incorrectInterSampleDim')
        elseif Np>Ne
            dat.InterSample=dat.InterSample(:,1:Ne);
        else
            for kk=1:Ne
                if nu==0
                    dat.InterSample = cell(0,Ne);
                end
                
                for ku=1:nu
                    dat.InterSample{ku,kk}='zoh'; %%LL only new values here!
                end
            end
        end
    end
    
    for ke=1:Ne
        [nup,nitest]=size(dat.Period{ke});
        if nitest~=1 || nup~=nu
            if flag(18)
                ctrlMsgUtils.error('Ident:iddata:incorrectPeriodDim')
            elseif nu<nup
                dat.Period{ke}=dat.Period{ke}(1:nu,1);
            else
                dat.Period{ke}(nup+1:nu,1)=inf*ones(nu-nup,1);
            end
        end
    end
end
%Dito expname

Out = dat;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunction ChannelNameCheck
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = ChannelNameCheck(a,Name)
% Checks specified I/O names
if isempty(a),
    a = a(:);   % make 0x1
    return
end

% Determine if first argument is an array or cell vector
% of single-line strings.
if ischar(a) && ndims(a)==2
    % A is a 2D array of padded strings
    a = cellstr(a);
    
elseif iscellstr(a) && ndims(a)==2 && min(size(a))==1,
    % A is a cell vector of strings. Check that each entry
    % is a single-line string
    a = a(:);
    if any(cellfun('ndims',a)>2) || any(cellfun('size',a,1)>1)
        ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,'IDDATA')
    end
else
    ctrlMsgUtils.error('Ident:general:cellstrPropType',Name,'IDDATA')
end

%{
% Make sure that nonempty I/O names are unique
if ~strcmpi(Name(end-3:end),'unit') && length(a)>1
    nonemptya = setdiff(a,{' ',''});
    if length(unique(nonemptya))~=length(nonemptya)
        ctrlMsgUtils.error('Ident:general:nonUniqueNames',Name,'IDDATA')
    end
end
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
