function sys = pvset(sys,varargin)
%PVSET  Set properties of IDPROC models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.14.4.10 $ $Date: 2009/12/22 18:53:53 $

% RE: PVSET is performing object-specific property value setting
%     for the generic IDMODEL/SET method. It expects true property names.

parflag = 0;
ni=length(varargin);
IDMProps = zeros(1,ni-1);  % 1 for P/V pairs pertaining to the IDMODEL parent
%Knew = [];
%Xnew = [];
typec = i2type(sys);
[Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz,dmpar] = procpar(sys);%deal
%procp = [Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz]';
%procp=procp(:);
flags=zeros(1,13);
fa = pvget(sys,'FileArgument');
dm=fa{3};

%dmflag = 0;
for i=1:2:nargin-1,
    % Set each PV pair in turn
    Property = varargin{i};
    Value = varargin{i+1};
    
    % Set property values
    switch Property
        case 'Type'
            if ~iscell(Value),
                Value={Value};
            end
            nu = length(Value);
            if nu~=length(typec)
                ctrlMsgUtils.error('Ident:idmodel:idprocTypeCheck1')
            end
            for ku = 1:nu
                type = Value{ku};
                Type ='';
                if ~ischar(type) || lower(type(1))~='p'
                    ctrlMsgUtils.error('Ident:idmodel:idprocTypeCheck2')
                end
                Type(1)='P';
                if any(findstr(type,'0'))
                    Type(2)='0';
                    %npar = 1;
                elseif any(findstr(type,'1'))
                    Type(2)='1';
                    %npar = 2;
                elseif any(findstr(type,'2'))
                    Type(2)='2';
                    %npar = 3;
                elseif any(findstr(type,'3'))
                    Type(2)='3';
                    %npar = 4;
                else
                    ctrlMsgUtils.error('Ident:idmodel:idprocTypeCheck3')
                end
                nr=3;
                if any(findstr(lower(type),'d'))
                    Type(nr) ='D';
                    nr = nr+1;
                    %npar = npar +1;
                end
                if any(findstr(lower(type),'z'))
                    Type(nr) = 'Z';
                    nr = nr+1;
                    %npar = npar +1;
                end
                if any(findstr(lower(type),'i'))
                    Type(nr) = 'I';
                    nr = nr+1;
                end
                if any(findstr(lower(type),'u'))
                    Type(nr) = 'U';
                    %nr = nr+1;
                end
                typec{ku} = Type;
            end % for ku
            flags(1)=1;
        case 'Kp'
            if isnumeric(Value)
                Kp = Value(:);
            else
                [Value,Kp] = errchk(Value,'Kp',sys.Kp,Kp);
                sys.Kp = Value;
            end
            flags(2)=1;
        case 'Td'
            if isnumeric(Value)
                Td = Value(:);
            else
                [Value,Td] = errchk(Value,'Td',sys.Td,Td);
                sys.Td = Value;
            end
            flags(8)=1;
        case 'Tp1'
            if isnumeric(Value)
                Tp1 = Value(:);
            else
                [Value,Tp1] = errchk(Value,'Tp1',sys.Tp1,Tp1);
                sys.Tp1 = Value;
            end
            flags(3)=1;
        case 'Tp2'
            if isnumeric(Value)
                Tp2 = Value(:);
            else
                [Value,Tp2] = errchk(Value,'Tp2',sys.Tp2,Tp2);
                sys.Tp2 = Value;
            end
            flags(4)=1;
        case 'Tw'
            if isnumeric(Value)
                Tw = Value(:);
            else
                [Value,Tw] = errchk(Value,'Tw',sys.Tw,Tw);
                sys.Tw = Value;
            end
            flags(5) =1;
        case 'Zeta'
            if isnumeric(Value)
                zeta = Value(:);
            else
                [Value,zeta] = errchk(Value,'Zeta',sys.Zeta,zeta);
                sys.Zeta = Value;
            end
            flags(6) = 1;
        case 'Tp3'
            if isnumeric(Value)
                Tp3 = Value(:);
            else
                [Value,Tp3] = errchk(Value,'Tp3',sys.Tp3,Tp3);
                sys.Tp3 = Value;
            end
            flags(7) = 1;
        case 'Tz'
            if isnumeric(Value)
                Tz = Value(:);
            else
                [Value,Tz] = errchk(Value,'Tz',sys.Tz,Tz);
                sys.Tz = Value;
            end
            flags(9)=1;
        case 'InputLevel'
            if isnumeric(Value)
                sys.InputLevel.value = Value(:)';
            else
                [Value,ulev] = errchk(Value,'InputLevel',sys.InputLevel,sys.InputLevel.value);
                sys.InputLevel = Value;
                nr= find(strcmpi(Value.status,'zero'));
                sys.InputLevel.value(nr) = zeros(size(nr));
                
            end
            flags(13) = 1;
        case 'Integration'
            if ~iscell(Value);
                Value = {Value};
            end
            for ku = length(Value)
                if ~ischar(Value{ku}) || ~any(strcmpi(Value{ku},{'on','off'}))
                    ctrlMsgUtils.error('Ident:idmodel:idprocIntegCheck')
                end
            end
            sys.Integration = Value;
        case 'InputDelay'
            sys.idgrey = pvset(sys.idgrey,'InputDelay',Value(:));
            flags(10) = 1;
        case 'ParameterVector',
            if ~isa(Value,'double')
                ctrlMsgUtils.error('Ident:idmodel:idmodelParamCheck','IDPROC')
            end
            Value=Value(:);
            sys.idgrey=pvset(sys.idgrey,'ParameterVector', Value);
            parflag=1;
        case 'InitialState'
            grey = sys.idgrey;
            grey = pvset(grey,'InitialState',Value);
            sys.idgrey = grey;
        case 'DisturbanceModel'
            PossVal = {'None'; 'Estimate'; 'ARMA1'; 'ARMA2'; 'Zero'; 'Fixed'};
            model =[];
            
            if isa(Value,'idpoly');
                model = Value;
                Value = 'Estimate';
            end
            if iscell(Value)
                if length(Value)>1
                    model = Value{2};
                end
                Value = Value{1};
            end
            
            try
                Value = pnmatchd(Value,PossVal,5);
            catch
                ctrlMsgUtils.error('Ident:idmodel:idprocIncorrectDist1')
            end
            
            if strcmpi(Value,'Zero')
                Value = 'None';
            end
            
            flags(11) = 1;
            if strcmpi(Value,'Estimate')
                dm = 'ARMA2';
            else
                dm = Value;
            end
            if ~isempty(model)
                err = 0;
                if ~isa(model,'idpoly')
                    err=1;
                elseif pvget(model,'na')>2 || any(pvget(model,'nb')>0) || pvget(model,'nd')>0 ||...
                        pvget(model,'nc')>2 || any(pvget(model,'nf')>0) || pvget(model,'Ts')>0
                    err = 1;
                else
                    pmod = pvget(model,'ParameterVector');
                    if any(pmod<0)
                        err = 1;
                    end
                end
                if err
                    ctrlMsgUtils.error('Ident:idmodel:idprocIncorrectDist2')
                end
                
                ut = pvget(sys,'Utility');
                ut.NoiseModel = model;
                sys = uset(sys,ut);
                nr = max(pvget(model,'na'),pvget(model,'nc'));
                dm = ['ARMA',int2str(nr)];
                a = pvget(model,'a'); a = [a,0];
                c = pvget(model,'c'); c = [c,0];
                dmpar = [a(2:nr+1),c(2:nr+1)];
                dmpar = dmpar(:);
            end
            
            if strcmpi(dm,'ARMA1') && length(dmpar)~=2
                dmpar =zeros(2,1);
            elseif strcmpi(dm,'ARMA2') && length(dmpar)~=4
                dmpar = zeros(4,1);
            elseif any(strcmpi(Value,{'Fixed','None'}))
                %dmpar1 = dmpar;
                %dmpar =zeros(0,1);
                dm = Value;
            elseif strcmpi(Value,'None')
                dmpar = zeros(0,1);
            end
            
            if strcmpi(Value(1:2),'AR')
                Value = 'Estimate';
            end
            
            grey = sys.idgrey;
            grey = pvset(grey,'DisturbanceModel',Value);
            sys.idgrey = grey;
            
        case 'Ts'
            if Value~=0
                ctrlMsgUtils.error('Ident:idmodel:idprocInvalidTs')
            end
            
        case 'X0'
            grey = sys.idgrey;
            grey = pvset(grey,'X0',Value);
            sys.idgrey = grey;
        case 'idmodel'
            grey = sys.idgrey;
            grey = pvset(grey,'idmodel',Value);
            sys.idgrey = grey;
            flags(12)=1;
        case 'FixedParameter'
            if isnumeric(Value)
                pnam = pvget(sys,'PName');
                Value = pnam(Value);
            end
            if ~iscell(Value)
                Value = {Value};
            end
            for k1 = 1:length(Value)
                prop = Value{k1};
                k1p = find(prop=='(');
                if ~isempty(k1p)
                    nr = prop(k1p+1:end-1);
                    prop = prop(1:k1p-1);
                    gg = sys.(prop);
                    gg.status{eval(nr)} = 'fixed';
                else
                    gg = sys.(prop);
                    gg.status = {'fixed'};
                end
                sys.(prop) = gg;
            end
            
        otherwise
            IDMProps([i i+1]) = 1;
            varargin{i} = Property;
            
    end %switch
    
end % for
IDMProps = find(IDMProps);
model = pvget(sys,'idmodel');
if ~isempty(IDMProps)
    model = pvset(model,varargin{IDMProps});
end
sys = timemark(sys,'l');
Est = pvget(model,'EstimationInfo');
if strcmpi(Est.Status(1:3),'Est') && ~any(strcmp(varargin,'EstimationInfo'))
    Est.Status='Model modified after last estimate';
    model = pvset(model,'EstimationInfo',Est);
end

sys.idgrey = pvset(sys.idgrey,'idmodel',model);

if parflag && any(flags)
    ctrlMsgUtils.error('Ident:idmodel:idprocSetCheck1')
end
if flags(8) && flags(10)
    ctrlMsgUtils.error('Ident:idmodel:idprocSetCheck2')
end

if flags(10)
    Td = pvget(sys,'InputDelay');
end

if flags(10) || flags(8)
    Tdd = Td;
    Tdd(isnan(Td)) = 0;
    sys.idgrey = pvset(sys.idgrey,'InputDelay',Tdd);
end

file = pvget(sys.idgrey,'FileArgument');
if parflag
    [Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz,dmpar] = procpar(sys);%deal
    Tdd = Td;
    Tdd(isnan(Td)) = 0;
    sys.idgrey = pvset(sys.idgrey,'InputDelay',Tdd);
end

if any(flags)
    if flags(1)
        sys = type2stat(sys,typec);
        %pvset(sys,'CovarianceMatrix',[]);
    end
    try
        procp = [Kp,Tp1,Tp2,Tw,zeta,Tp3,Td,Tz]';
        procp = procp(:);
    catch
        nu = length(typec);
        ctrlMsgUtils.error('Ident:idmodel:idprocSetCheck3',nu);
    end
    
    if flags(11)
        file{3} = dm;
        file{4} = dmpar;
    end
    if flags(13)
        if sys.InputLevel.status{1}(1)=='z'
            ut = pvget(sys,'Utility');
            if isfield(ut,'X0')
                ut = rmfield(ut,'X0');
            end
            sys = pvset(sys,'Utility',ut);
        end
    end
    tpflag = flags(3:6);
    for ku = 1:length(sys.Tp1.status)
        stat = [strcmpi(sys.Tp1.status{ku},'zero'),strcmpi(sys.Tp2.status{ku},'zero'),...
            strcmpi(sys.Tw.status{ku},'zero'),strcmpi(sys.Zeta.status{ku},'zero')];
        if (stat(1) && tpflag(1))% Tp1 has been set to zero
            sys.Tp2.status{ku} = 'zero';
        end
        if (~stat(1) && tpflag(1)) || (~stat(2) && tpflag(2))% Tp1 or Tp2 has been set to non-zero
            sys.Tw.status{ku} = 'zero';
            sys.Zeta.status{ku} = 'zero';
            if ~stat(2) && tpflag(2) && stat(1) % Tp2 has been set to non-zero while Tp1 is zero
                sys.Tp1.status{ku} = 'est';
            end
        end
        if (~stat(3) && tpflag(3)) || (~stat(4) && tpflag(4))% Tw or Zeta has been set to non-zero
            sys.Tp1.status{ku} = 'zero';
            sys.Tp2.status{ku} = 'zero';
            if ~stat(3) && tpflag(3) && stat(4) % Tw has been set to non-zero while Zeta is zero
                sys.Zeta.status{ku} = 'est';
            end
            if ~stat(4) && tpflag(4) && stat(3) % Zeta has been set to non-zero while Tw is zero
                sys.Tw.status{ku} = 'est';
            end
        end
    end
    typec = i2type(sys);
    [par,Type,pnr,dnr] = parproc(procp,typec); %%LL
    par = [par;dmpar];
    file{5} = pnr;
    file{1} = Type;%%%%%LL060409
    sys.idgrey = pvset(sys.idgrey,'ParameterVector',par,'FileArgument',file);
    [sys,par] = considp(sys,flags(3:6));
    
    file{1} = i2type(sys);
    file{5} = pnr;
    file{6} = dnr;
    file{8} = sys.InputLevel;
    pna = cell(length(par),1);
    pna(:)={''};
    pna1 = setpname(sys,0);
    pna(1:length(pna1))=pna1;
    cov = pvget(sys.idgrey,'CovarianceMatrix');
    if ~ischar(cov) && length(par)~=length(cov)
        sys.idgrey = pvset(sys.idgrey,'ParameterVector',par,'FileArgument',file,...
            'PName',pna,'CovarianceMatrix',[]);
    else
        sys.idgrey = pvset(sys.idgrey,'ParameterVector',par,'FileArgument',file,...
            'PName',pna);
    end
    
end

% correction for EstimationInfo.Status
if any(strcmp(varargin,'EstimationInfo'))
   sys.idgrey = pvset(sys.idgrey,'EstimationInfo', Est);
end
%--------------------------------------------------------------------------
function [Value,par] = errchk(Value,pna,prop,par1)
nu = length(prop.status);
if iscell(Value) % This is when assigning status to several inputs
    % or when using pvset(..,'kp',{'max',3})
    if ischar(Value{1})
        sw = lower(Value{1});
        if length(sw)<2,
            sw=[sw,' '];
        end
        switch sw(1:2)
            case 'va'
                par = Value{2};
                pp = prop;
                pp.value = par;
                Value = pp;
            case 'st'
                Value = Value(2:end);
            case 'mi'
                pp = prop;
                pp.min = Value{2};
                pp.value = par1(:);
                Value = pp;
            case 'ma'
                pp = prop;
                pp.max = Value{2};
                pp.value = par1(:);
                Value = pp;
        end
    end
end
if iscell(Value)
    if ischar(Value{1});
        pp = prop;
        pp.status = Value;
        pp.value = par1(:)';%%LL was without '
        Value = pp;
    end
end
if ischar(Value)
    pp  = prop;
    pp.status = Value;
    pp.value = par1(:);
    Value = pp;
end
if ~isstruct(Value) || ~isequal(fieldnames(Value),{'status';'min';'max';'value'})
    ctrlMsgUtils.error('Ident:idmodel:idprocSetCheck4',pna)
end


ms = Value.status;
if ~iscell(ms),
    ms={ms};
end
if length(ms)~=nu
    ctrlMsgUtils.error('Ident:idmodel:idprocStatusCheck1',pna)
end
if strcmpi(pna,'Kp') && any(strncmpi(ms,'z',1))
    if nu>1
        ctrlMsgUtils.error('Ident:idmodel:idprocStatusCheck2b')
    else
        ctrlMsgUtils.error('Ident:idmodel:idprocStatusCheck2a')
    end
end
for ku = 1:length(ms)
    mss = ms{ku};
    if ~ischar(mss)
        ctrlMsgUtils.error('Ident:idmodel:idprocStatusCheck3',pna)
    end
    mm = lower(mss(1));
    switch mm
        case 'e'
            ms{ku} = 'estimate';
        case 'z';
            ms{ku} = 'zero';
        case 'f'
            ms{ku} = 'fixed';
        otherwise
            ctrlMsgUtils.error('Ident:idmodel:idprocStatusCheck4',mss,pna)
    end
end

Value.status = ms;

mv = Value.value;
if any(~isnan(mv) & ~isa(mv,'double'))
    ctrlMsgUtils.error('Ident:idmodel:idprocSetCheck5','value',pna)
end

par = mv(:);
if ~strcmp(pna,'InputLevel')
    Value = rmfield(Value,'value');
end

mv = Value.min;
if any(~isnan(mv) & ~isa(mv,'double'))
    ctrlMsgUtils.error('Ident:idmodel:idprocSetCheck5','min',pna)
end

mv = Value.max;
if any(~isnan(mv) & ~isa(mv,'double'))
    ctrlMsgUtils.error('Ident:idmodel:idprocSetCheck5','max',pna)
end
