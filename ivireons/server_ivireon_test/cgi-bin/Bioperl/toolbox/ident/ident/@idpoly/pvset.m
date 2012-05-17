function sys = pvset(sys,varargin)
%PVSET  Set properties of IDPOLY models.
%
%   SYS = PVSET(SYS,'Property1',Value1,'Property2',Value2,...)
%   sets the values of the properties with exact names 'Property1',
%   'Property2',...
%
%   See also SET.

%  Copyright 1986-2009 The MathWorks, Inc.
%  $Revision: 1.20.4.12 $ $Date: 2009/12/05 02:03:39 $

[a,b,c,d,f] = polydata(sys,1); % check

nu = numel(sys.nb);
if any(sys.nb>0) && isempty(b)
    b = zeros(nu,max(sys.nb));
end

abcdf = zeros(1,6);  % keeps track of which state-space matrices are reset
nabcdfk = zeros(1,6);
parflag = 0;
%covflag = 0;
tsflag = 0;
ni=length(varargin);
IDMProps = zeros(1,ni-1);  % 1 for P/V pairs pertaining to the LTI parent

for i = 1:2:nargin-1
    % Set each PV pair in turn
    Property = varargin{i};
    Value = varargin{i+1};
    
    % Set property values
    switch Property
        case 'na'
            if ~isscalar(Value) || any(fix(Value)~=Value | Value<0) || any(~isfinite(Value)) || ~isreal(Value)
                ctrlMsgUtils.error('Ident:general:nonnegativeIntPropVal','na')
            end
            
            sys.na = Value;
            nabcdfk(1) = 1;
        case 'nb'
            if (~isempty(Value) && ~isrealrowvec(Value)) || ~all(fix(Value)==Value) || any(Value<0) || size(Value,1)>1 || any(~isfinite(Value))
                ctrlMsgUtils.error('Ident:general:nonnegIntRowPropVal','nb')
            end
            %Value = Value(:).';
            sys.nb = Value;
            nabcdfk(2) = 1;
        case 'nc'
            if ~isnonnegintscalar(Value)
                ctrlMsgUtils.error('Ident:general:nonnegativeIntPropVal','nc')
            end
            
            sys.nc = Value;
            nabcdfk(3)=1;
        case 'nd'
            if ~isnonnegintscalar(Value)
                ctrlMsgUtils.error('Ident:general:nonnegativeIntPropVal','nd')
            end
            
            sys.nd = Value;
            nabcdfk(4)=1;
        case 'nf'
            if (~isempty(Value) && ~isrealrowvec(Value)) || ~all(fix(Value)==Value) || any(Value<0) || size(Value,1)>1 || any(~isfinite(Value))
                ctrlMsgUtils.error('Ident:general:nonnegIntRowPropVal','nf')
            end
            % Value = Value(:).';
            sys.nf = Value;
            nabcdfk(5)=1;
        case 'nk'
            if (~isempty(Value) && ~isrealrowvec(Value)) || ~all(fix(Value)==Value) || any(Value<0) || any(~isfinite(Value))
                ctrlMsgUtils.error('Ident:general:nonnegIntRowPropVal','nk')
            end
            Value = Value(:).';
            
            sys.nk = Value;
            nabcdfk(6)=1;
        case 'a'
            a = Value;
            abcdf(1) = 1;
        case 'b'
            b = Value;
            abcdf(2) = 1;
        case 'c'
            c = Value;
            abcdf(3) = 1;
        case 'd'
            d = Value;
            abcdf(4) = 1;
        case 'f'
            f = Value;
            abcdf(5) = 1;
        case {'da','db','dc','dd','df'}
            ctrlMsgUtils.error('Ident:idmodel:setStdDev')
        case 'InitialState'
            PossVal = {'Estimate';'Zero';'Backcast';'Auto'};
            try
                Value = pnmatchd(Value,PossVal,2);
            catch
                ctrlMsgUtils.error('Ident:idmodel:idpolyIncorrectIni')
            end
            
            sys.InitialState = Value;
        case 'BFFormat'
            % should be -1, 0 or 1.
            sys.BFFormat = Value;
            
        case 'ParameterVector',
            Value = Value(:);
            sys.idmodel = pvset(sys.idmodel,'ParameterVector', Value);
            parflag = 1;
            
        case 'idmodel'
            sys.idmodel = Value;
            
        otherwise
            IDMProps([i i+1]) = 1;
            varargin{i} = Property;
            %{
            if strcmp(Property,'CovarianceMatrix')
                covflag = 1;
            end
            %}
            if strcmp(Property,'Ts');
                tsold = pvget(sys,'Ts');
                tsnew = varargin{i+1};
                if ~isempty(tsnew) && ((tsold>0 && tsnew==0) || (tsold==0 && tsnew>0))
                    tsflag = 1; %then we need to recompute orders
                end
            end
    end %switch
    
end % for
IDMProps = find(IDMProps);
if ~isempty(IDMProps)
    sys.idmodel = pvset(sys.idmodel,varargin{IDMProps});
end

sys = timemark(sys);
if ~any([nabcdfk,abcdf,parflag,tsflag])
    sys.idmodel = idmcheck(sys.idmodel,[1,nu]);
    return
end
Est = pvget(sys.idmodel,'EstimationInfo');
if strcmp(Est.Status(1:3),'Est')
    Est.Status = 'Model modified after last estimate';
    sys.idmodel = pvset(sys.idmodel,'EstimationInfo',Est);
end

%
if parflag
    nn = length(pvget(sys.idmodel,'ParameterVector'));
    if nn~=sum([sys.na sys.nb sys.nc sys.nd sys.nf])
        ctrlMsgUtils.error('Ident:idmodel:pvecOrderMismatch')
    end
end

if nabcdfk(2)
    if isempty(sys.nf), sys.nf = zeros(size(sys.nb)); end
    if isempty(sys.nk), sys.nk = ones(size(sys.nb));  end
end

nu1 = size(sys.nb,2); nu2 = size(sys.nk,2); nu3 = size(sys.nf,2);
if ~all(nu1 == [nu2 nu3])
    ctrlMsgUtils.error('Ident:idmodel:idpolyOrderCheck1')
end
nu = nu1;

ParEmpt = isempty(pvget(sys.idmodel,'ParameterVector'));
if  ~parflag && ~ParEmpt
    if any(nabcdfk)
        Ts = pvget(sys,'Ts');
        abcdf(1) = 1;
        
        if nabcdfk(6) && Ts==0
            ctrlMsgUtils.error('Ident:idmodel:CTNkSet')
        end
        if nabcdfk(1)
            a = ordmod(a,sys.na,1,[],Ts);
        end
        
        if  nabcdfk(2) && ~nabcdfk(6)
            %nb was specified but not nk; nk must be derived from b
            if Ts>0
                if iscell(b)
                    b = idcell2mat(b,Ts);
                end
                sys.nk = zeros(1,nu);
                for ku = 1:nu
                    NK_ = find(b(ku,:),1,'first')-1;
                    if ~isempty(NK_)
                        sys.nk(ku) = NK_;
                    end
                end
            end
        end
        
        if nabcdfk(2) || nabcdfk(6)
            try
                b = ordmod(b,sys.nb,0,sys.nk,Ts);
            catch
                b = [];
            end
        end
        if nabcdfk(3)
            c = ordmod(c,sys.nc,1,[],Ts);
        end
        if nabcdfk(4)
            d = ordmod(d,sys.nd,1,[],Ts);
        end
        if nabcdfk(5)
            f = ordmod(f,sys.nf,1,nan,Ts);
        end
        
        if isempty(b), f = zeros(0,1); end % r.s. 
    end
end

if any(abcdf) && parflag
    ctrlMsgUtils.error('Ident:idmodel:idpolySetCheck1')
end

if (any(abcdf) || (tsflag && ~ParEmpt)) 
    npar = length(pvget(sys.idmodel,'ParameterVector'));
    [na,nb,nc,nd,nf,nk,par,nu] = polychk(a,b,c,d,f,[],sys.idmodel.Ts);
    
    sys.na = na; sys.nb = nb; sys.nc = nc;
    sys.nd = nd; sys.nf = nf; sys.nk = nk;
    % $$$    cov = pvget(sys.idmodel,'CovarianceMatrix');
    % $$$    if size(cov,1)~=length(par)
    % $$$        if covflag
    % $$$            error(sprintf(['You cannot change the size of the ParameterVector and set the',...
    % $$$                    '\nCovarianceMatrix at the same time.']))
    % $$$        end
    % $$$        if ~isempty(cov)
    % $$$            warning('CovarianceMatrix has been set to the empty matrix.')
    % $$$        end
    sys.idmodel = pvset(sys.idmodel,'ParameterVector',par);
    if npar~=length(par) && ~strcmpi(pvget(sys.idmodel,'CovarianceMatrix'),'none')
        sys.idmodel = pvset(sys.idmodel,'CovarianceMatrix',[]);
    end
    
end
sys.idmodel = idmcheck(sys.idmodel,[1,nu]);

%{
if ~isequal(size(sys.idmodel.Algorithm.Weighting,1),1)
    sys.idmodel.Algorithm.Weighting = eye(1); %would be eye(ny) in future
end
%}

%--------------------------------------------------------------------------
function p = ordmod(p1,np,stab,nk,Ts)
% use nk = nan to denote f polynomial

if iscell(p1)
    p1 = idcell2mat(p1,Ts);
end
K = 1;
%B and F should handle trailing zeros in identical manner; idpoly(1,[1
%0],'nb',2) and idpoly(1,1,'f',[1 0],'nf', 1) should be analogous. Hence F
% and B are identified specifically: non-empty nk implies B and NaN nk
% implies F.
isF = false; 
if isnan(nk)
    nk = [];
    isF = true;
end

if isempty(p1)
    if ~isempty(nk) %r.s.
        % B 
        p1 = zeros(size(np,2),0);
    else
        % A, C, D or F
        if isF
            p1 = ones(size(np,2),1);
        else
            p1 = 1;
        end
    end
end

nr = size(p1,1);
p = zeros(nr,0);
for kk = 1:nr
    pol = p1(kk,:);
    if ~isempty(nk)
        % B polynomial
        polnr = find(pol~=0);
        if Ts>0
            %strip leading and trailing zeros for discrete polynomial
            polst = pol(min(polnr):max(polnr));%pol(find(pol~=0));
        else
            %strip leading zeros only
            polst = pol(min(polnr):end);
        end
        
        np1 = length(polst);
        if np1>np(kk)
            if Ts>0
                po = polst(1:np(kk));
            else
                po = polst(end-np(kk)+1:end);
                % replace leading zeros after truncation with eps
                po(1:find(po,1,'first')-1) = K*eps;
            end
            
            %if stab, po = fstab(po); end %this line should never be executed
            
        elseif np1<np(kk)
            if Ts>0
                po = [polst,K*eps*ones(1,np(kk)-np1)];%[pol,eps*ones(1,np(kk)-np1)];
            else
                po = [K*eps*ones(1,np(kk)-np1),polst];
            end
        else
            po = polst;
        end
        po = [zeros(1,nk(kk)),po];
    else
        % A, C, D or F polynomial
        % trailing zeros must be removed from F in DT case
        np1 = length(pol)-1;
        
        if np1>np(kk)
            if Ts>0
                po = pol(1:np(kk)+1);
                % replace traling zeros with eps to maintain order
                po(find(po,1,'last')+1:end) = eps;
            else
                po = pol(end-np(kk):end);
                if po(1)~=0
                    po = po/po(1);
                else
                    po(1) = 1; %make monic; truncation destroys polynomial anyway
                end
            end
            if stab, po = fstab(po); end
        else
            % Always append trailing eps regardless of Ts to keep
            % polynomial monic
            if isF && Ts>0
                % remove trailing zeros from F first
                pol = pol(1:find(pol,1,'last'));
                np1 = length(pol)-1;
            end
            po = [pol,K*eps*ones(1,np(kk)-np1)];
            
        end
    end
    if Ts>0
        p(kk,1:length(po)) = po;
    else
        if length(po)>size(p,2)
            p = [zeros(nr,length(po)-size(p,2)),p];
            p(kk,:) = po;
        else
            p(kk,end-length(po)+1:end) = po;
        end
    end
end
