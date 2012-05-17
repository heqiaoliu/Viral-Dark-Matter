function [mdum,z,order,args] = pemdecod(call,varargin)
%PEMDECOD  Decodes the input arguments to pem to honor
%          various syntaxes

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.21.4.15 $ $Date: 2009/12/22 18:53:58 $

% First a quick exit if this is a class from inival or iv:
mdum = [];
order =[];
args ={};
ny = [];
DataName = varargin{end};
varargin = varargin(1:end-1);
nl = length(varargin);

% Allow order confusion between model and data
if isa(varargin{2},'iddata') || isa(varargin{2},'idfrd') || isa(varargin{2},'frd')
    varargin = varargin([2 1 3:nl]);
    DataName = '';
end

z = varargin{1};
if isa(z,'frd')
    z = idfrd(z);
end

if isa(z,'idfrd')
    z = iddata(z);
end

if isa(z,'iddata')
    setid(z);
    z = nyqcut(z);
    [N,nyd,nud] = size(z);
    if nyd==0
        ctrlMsgUtils.error('Ident:general:noOutputChannel')
    end
    nzd = nyd+nud;
    iddatflag = 1;
    dom = pvget(z,'Domain');
    dom = lower(dom(1));
else
    dom = 't';
    [N,nzd] = size(z);
    if N<nzd
        ctrlMsgUtils.error('Ident:general:badDataFormat')
    end
    iddatflag= 0;
end

% FD time series data not accepted
if dom=='f' && nud == 0
    ctrlMsgUtils.error('Ident:estimation:freqDataTimeSeriesModel2',call)
end
createmdum = 1;
switch class(varargin{2})
    case 'idpoly'
        createmdum = 0;
        mdum = varargin{2};
        if iddatflag && nyd~=1
            ctrlMsgUtils.error('Ident:estimation:multiOutputPolyModel')
        end

        if nl>2
            args = oldtest(varargin(3:end),-1,call);
            [args,datarg] = pnsortd(args);
            if ~isempty(datarg) && iddatflag, z = pvset(z,datarg{:});end
            if length(args)>1,set(mdum,args{:});end
        end
    case 'cell' % Multiinput process model
        mdum = varargin{2}; order = mdum;
        args = varargin(3:end);
        return
    case 'char' % syntax pem(data,'na',na,...)
        if varargin{2}(1)=='P' % process model
            mdum = varargin{2}; order = mdum;
            args = varargin(3:end);
            return
        end
        args = varargin(2:end);
        % First check if state space model is indicated
        kf = find(strcmpi('nx',args(1:2:end)));
        if ~isempty(kf) % Then a state space model is indicated
            kf = kf(1);
            order = args{2*kf};
            args=args([1:kf*2-2,kf*2+1:end]);
            mdum=idss([],zeros(0,nud),zeros(nyd,0),zeros(nyd,nud));
        else
            mdum = idpoly;
            mdum = pvset(mdum,'NoiseVariance',1);
        end
        if ~isempty(args)
            [args,datarg] = pnsortd(args);
            if ~isempty(datarg) && iddatflag
                z = pvset(z,datarg{:});
            end
            if length(args)>1
                set(mdum,args{:});
            end
            ktc = strcmpi('nk',args(1:2:end));
            ts = pvget(z,'Ts');
            tcflag = (dom=='f'&ts{1}==0);
            if any(ktc) && tcflag
                ctrlMsgUtils.warning('Ident:estimation:nkWithCTdata')
            end

        end
    case 'double' % syntax arx(data,[na nb nk],...)
        nn = varargin{2};
        [ny,nc] = size(nn); %check nonnegative integers
        switch nc
            case 1 %state space model
                order = nn;
                mdum = idss;
                if nl>2
                    args = oldtest(varargin(3:end),-1,call);
                end
                [args,datarg] = pnsortd(args);
                if ~isempty(datarg) && iddatflag, z = pvset(z,datarg{:});end
            otherwise % polynomial models
                if iddatflag
                    if nyd~=1
                        ctrlMsgUtils.error('Ident:estimation:multiOutputPolyModel')
                    end
                else
                    nud = nzd-1;
                    %nyd = 1;
                end
                
                try
                    ts = pvget(z,'Ts');
                catch
                    ts ={1};
                end
                tcflag = (dom=='f' && ts{1}==0);
                
                was = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:idpolyUseCellForBF');
                mdum = idpoly(1,zeros(nud,1),'Ts',ts{1});
                delete(was)
                mdum = pvset(mdum,'NoiseVariance',1);
                
                %{
                txt = '';
                if dom=='f'
                    ts = pvget(z,'Ts');ts=ts{1};
                    if ts==0
                        nn = [nn,zeros(1,nud)];
                        nc = size(nn,2);
                        txt = ['For time continuous frequency domain data ',...
                            'nk has no meaning and shall be omitted.'];
                    end
                end
                %}
                switch call
                    case 'pem'
                        nrcheck = 3+3*nud;
                        if nud==0,nrcheck = 2; end
                        if ~tcflag
                            if nc ~= nrcheck
                                ctrlMsgUtils.error('Ident:estimation:pemIncorrectOrders')
                            end
                        else %tcflag
                            if nc == nrcheck
                                ctrlMsgUtils.warning('Ident:estimation:nkWithCTdata')
                            elseif nc == nrcheck - nud % correct
                                nn = [nn,zeros(1,nud)];
                            else % wrong orders
                                ctrlMsgUtils.error('Ident:estimation:pemIncorrectOrdersCTData')
                            end
                        end
                        if nud>0
                            nb=nn(2:1+nud); % This is to set nf's to zero, where nb are zero
                            if sum(abs(nb)) == 0
                                %error('This model structure does not make sense if all B-orders are zero.')
                            end
                            kz=find(nb(1:nud)==0);
                            if ~isempty(kz),nn(nud+kz+3)=zeros(1,length(kz));end
                        end
                        if nud==0
                            if sum(nn(1:2))==0
                                ctrlMsgUtils.error('Ident:estimation:zeroOrder')
                            end
                            mdum = pvset(mdum,'na',nn(1),'nc',nn(2));
                        else
                            if sum(nn(1:2*nud+3))==0
                                ctrlMsgUtils.error('Ident:estimation:zeroOrder')
                            end
                            mdum = pvset(mdum,'na',nn(1),'nb',nn(2:nud+1),'nc',nn(nud+2:nud+2),...
                                'nd',nn(nud+3:nud+3),'nf',nn(nud+4:2*nud+3),'nk',nn(2*nud+4:3*nud+3));
                        end
                    case 'oe'
                        if nud==0
                            ctrlMsgUtils.error('Ident:estimation:OEforTimeSeries')
                        end
                        nrcheck = 3*nud;
                        if tcflag % continuous time data
                            if (nc == nrcheck)
                                ctrlMsgUtils.warning('Ident:estimation:nkWithCTdata')
                                nn(2*nud+1:3*nud) = zeros(1,nud);
                            elseif (nc == nrcheck-nud) % correct
                                nn = [nn,zeros(1,nud)];
                            else
                                ctrlMsgUtils.error('Ident:estimation:oeIncorrectOrdersCTData')
                            end
                        else % no tcflag

                            if (nc ~= nrcheck)
                                ctrlMsgUtils.error('Ident:estimation:oeIncorrectOrders')
                            end
                        end
                        nb = nn(1:nud); % This is to set nf's to zero, where nb are zero
                        if sum(abs(nb)) == 0
                            ctrlMsgUtils.error('Ident:estimation:zeroNb')
                        end
                        kz=find(nb(1:nud)==0);
                        if ~isempty(kz),nn(nud+kz)=zeros(1,length(kz));end
                        mdum = pvset(mdum,'nb',nn(1:nud),...
                            'nf',nn(nud+1:2*nud),'nk',nn(2*nud+1:3*nud));

                    case 'armax'
                        if dom=='f'
                            ctrlMsgUtils.error('Ident:estimation:armaxFreqData')
                        end
                        nrcheck = 2+2*nud;
                        if nud==0,nrcheck = 2; end
                        if nc ~= nrcheck
                            ctrlMsgUtils.error('Ident:estimation:armaxIncorrectOrders')
                        end
                        if nud==0
                            mdum = pvset(mdum,'na',nn(1),'nc',nn(2));
                        else
                            mdum = pvset(mdum,'na',nn(1),'nb',nn(2:nud+1),'nc',nn(nud+2:nud+2),...
                                'nk',nn(nud+3:2*nud+2));
                        end
                    case 'bj'
                        if dom=='f'
                            ctrlMsgUtils.error('Ident:estimation:bjFreqData')
                        end
                        if nud==0
                            ctrlMsgUtils.error('Ident:estimation:BJforTimeSeries')
                        end

                        nrcheck = 2+3*nud;
                        if nc ~= nrcheck,
                            ctrlMsgUtils.error('Ident:estimation:bjIncorrectOrders')
                        end

                        nb = nn(1:nud); % This is to set nf's to zero, where nb are zero
                        if sum(abs(nb)) == 0
                            ctrlMsgUtils.error('Ident:estimation:zeroNb')
                        end

                        kz = find(nb(1:nud)==0);
                        if ~isempty(kz)
                            nn(nud+kz+2) = zeros(1,length(kz));
                        end
                        mdum = pvset(mdum,'nb',nn(1:nud),'nc',nn(nud+1:nud+1),...
                            'nd',nn(nud+2:nud+2),'nf',nn(nud+3:2*nud+2),'nk',nn(2*nud+3:3*nud+2));
                end

                if nl>2
                    npar = sum(nn(1:end-nud));
                    args = oldtest(varargin(3:end),npar,call);
                    [args,datarg] = pnsortd(args);
                    if ~isempty(datarg) && iddatflag
                        z = pvset(z,datarg{:});
                    end
                    
                    % discard Ts specification unless data is double and
                    % Ts value >0
                    nr = find(strcmp(args,'ts'));
                    if ~isempty(nr) 
                        if iddatflag 
                            ctrlMsgUtils.warning('Ident:estimation:IdpolyEstTsSpecIgnored');
                            args(nr:nr+1) = [];
                        else
                            Tsspec = args{nr+1};
                            if isscalar(Tsspec) && isfloat(Tsspec)&& Tsspec==0
                                ctrlMsgUtils.error('Ident:estimation:idpolyCTModelWithTimeData')
                            end
                        end
                    end
                    if length(args)>1
                        set(mdum,args{:});
                    end
                end % if nl
        end % case nc

end % switch varargin{2}
try
    [dum,nutest] = size(mdum);
    nbtest = pvget(mdum,'nb');
catch
    nutest = 0;
    nbtest = 1;
end
if sum(nbtest)==0 && nutest>0
    ctrlMsgUtils.error('Ident:estimation:zeroNb')
end

modtsflag = 0;
if nl > 2
    try
        cht = args(1:2:end);
    catch
        ctrlMsgUtils.error('Ident:general:CompleteOptionsValuePairs',call,call)
    end

    kts = find(strcmpi('ts',cht));
    if isempty(kts)
        Tsm = 1;
    else
        Tsm = args{2*kts};
        modtsflag = 1;
    end
end

if ~isa(z,'iddata')
    if isempty(ny) || nc==1
        ny = 1;
        if nzd>2
            ctrlMsgUtils.warning('Ident:general:doubleDataNyAmbiguity')
        end
    end
    z = iddata(z(:,1:ny),z(:,ny+1:end),pvget(mdum,'Ts'));
else
    Ts = pvget(z,'Ts'); Ts = Ts{1};
    if modtsflag && Tsm~=Ts && Tsm~=0
        ctrlMsgUtils.warning('Ident:estimation:dataPVTsMismatch',...
            sprintf('%f',Tsm),sprintf('%f',Ts))
    end

    if isa(mdum,'idmodel')
        Tm = pvget(mdum,'Ts');
        if Tm~=0 && Ts==0 % CT data and discrete model
            if ~createmdum
                ctrlMsgUtils.warning('Ident:estimation:CTDataDTModel')
            end

            try
                mdum = d2c(mdum);
            catch
                mdum = pvset(mdum,'Ts',Ts);
            end

        end

        if Tm==0 && Ts>0 % discrete data and continuous model
            if ~createmdum
                ctrlMsgUtils.warning('Ident:estimation:DTDataCTModel')
            end
            try % This is to handle trivial models
                mdum = c2d(mdum,Ts);
            catch
                mdum = pvset(mdum,'Ts',Ts);
            end
        end
        if ~createmdum && (abs(Ts-Tm)>eps) && Tm*Ts~=0
            ctrlMsgUtils.warning('Ident:general:dataModelTsMismatch',...
            sprintf('%g',Tm),sprintf('%g',Ts));
        end
        mdum = pvset(mdum,'Ts',Ts);

    end
end
ut = pvget(z,'Utility');
try
    % (try block is necessary, else set(mdum,args) will error out if PV
    % pairs are used during estimation, such as 'nk',2)
    if isfield(ut,'idfrd') && ut.idfrd && strcmpi(pvget(z,'Domain'),'Frequency');
        if ~isempty(args)
            [args,datarg] = pnsortd(args);
            if ~isempty(datarg) && iddatflag, z = pvset(z,datarg{:});end
            if length(args)>1,set(mdum,args{:});end % Just to get the right message below
        end
        ini = pvget(mdum,'InitialState');
        if any(lower(ini(1))==['e','b'])
            ctrlMsgUtils.warning('Ident:estimation:X0EstFreqData')
        end
        mdum = pvset(mdum,'InitialState','Zero');
        args = [args,{'InitialState','Zero'}];
    end
end
try
    z = estdatch(z,pvget(mdum,'Ts'));
end

if isempty(pvget(z,'Name'))
    z = pvset(z,'Name',DataName);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function args = oldtest(argold,npar,call)

ml = length(argold);
if (ml==1 && strcmp(argold{1},'trace')) || (~ischar(argold{1}) && ~iscell(argold{1}))
    % This is the old syntax
    if strcmp(call,'pem')
        prop = {'fixedpar','maxiter','tol','lim','maxsize','Ts'};
    else
        prop = {'maxiter','tol','lim','maxsize','Ts'};
        npar = -1;
    end
    for kk=1:ml
        if strcmp(argold(kk),'trace');
            args{2*kk-1}='Display';args{2*kk}='Full';
        else
            if kk==1 && ~isempty(argold{kk}) && npar>=0
                argold{kk}=indinvert(argold{kk},npar); %npar
            end

            args{2*kk-1}=prop{kk};
            args{2*kk}=argold{kk};

        end % if trace
    end %for
else
    args = argold;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ind3 = indinvert(ind1,npar)
if npar==0
    ctrlMsgUtils.error('Ident:general:oldSyntax1')
end

ind2 = (1:npar)';
indt = ind2*ones(1,length(ind1))~=ones(npar,1)*ind1(:)';
if size(indt,2)>1
    indt = all(indt');
end
ind3 = ind2(indt);
