function [mdum,z,p,fixflag,fixp1] = arxdecod(varargin)
%ARXDECOD  Decodes the input arguments to arx (iv etc) to honor
%          various syntaxes

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.15.4.10 $ $Date: 2009/12/22 18:53:57 $

% First a quick exit if this is a class from inival or iv:

fixflag = 0;
fixp1 =[];
DataName = varargin{end};
varargin = varargin(1:end-1);
nl = length(varargin);
p=1;
if nl==5 && ~ischar(varargin{5}) && ~ischar(varargin{4})
    p = varargin{5};
    z = varargin{1};
    mdum = varargin{2};
    return
end

% Allow order confusion between model and data:

if isa(varargin{2},'iddata') || isa(varargin{2},'frd') || isa(varargin{2},'idfrd')
    varargin = varargin([2 1 3:nl]);
    DataName = '';
end
z = varargin{1};
if isa(z,'idfrd') || isa(z,'frd')
    z = iddata(idfrd(z));
    %     if pvget(mdum,'InitialState')=='Estimate'
    %         warning('InitialState Changed to ''Zero'', since data is an IDFRD.')
    %     end
    varargin{nl+1} = 'InitialState';
    varargin{nl+2} = 'Zero';
    nl = nl+2;
end

if isa(z,'iddata')
    z = setid(z);
    z = estdatch(z,1);
    z = nyqcut(z);

    [N,nyd,nud] = size(z);
    if nyd == 0
        ctrlMsgUtils.error('Ident:general:noOutputChannel')
    end
    nzd = nyd+nud;
    iddatflag = 1;
else
    [N,nzd]=size(z);
    if N<nzd
        z = z.';
        [N,nzd] = size(z);
    end
    iddatflag= 0;
end
switch class(varargin{2})
    case {'idpoly','idarx'}
        mdum = varargin{2};
        if nl>2
            [args,datapv] = pnsortd(varargin(3:end));
            if~isempty(datapv) && isa(z,'iddata'), z = pvset(z,datapv{:});end
            if ~isempty(args),set(mdum,args{:});end
        end
        ny = size(mdum,'ny');
    case 'char' % syntax arx(data,'na',na,...)
        [args,datapv] = pnsortd(varargin(2:end));
        if~isempty(datapv) && isa(z,'iddata'), z = pvset(z,datapv{:});end
        ntes = varargin{3};
        if iddatflag && size(ntes,1)~= nyd
            ctrlMsgUtils.error('Ident:estimation:orderRows')
        end
        if size(ntes,1)>1
            mdum = idarx;
        else
            mdum = idpoly;
        end
        if ~isempty(args)
            set(mdum,args{:})
        end
        if isa(mdum,'idpoly')
            if pvget(mdum,'nc')>0 || pvget(mdum,'nd')>0 || any(pvget(mdum,'nf')>0)
                ctrlMsgUtils.error('Ident:estimation:invalidARXOrders')
            end
        end
        if size(pvget(mdum,'nb'),2)>0
            if size(pvget(mdum,'nb'),2)~=nud || size(pvget(mdum,'nk'),2)~=nud
                ctrlMsgUtils.error('Ident:estimation:arxOrderColumns')
            end
        end
    case 'double' % syntax arx(data,[na nb nk],...)
        nn = varargin{2};
        [ny,nc] = size(nn);
        if iddatflag
            ts = pvget(z,'Ts');ts = ts{1};
            if ny~=nyd
                ctrlMsgUtils.error('Ident:estimation:orderRows2')
            end
            if ts==0
                if nyd>1
                    ctrlMsgUtils.error('Ident:estimation:arxCTMO')
                end
                if nud>0 && nud==(nc-ny)/2
                    ctrlMsgUtils.warning('Ident:estimation:nkWithCTdata')
                   nn(nud+2:end) = zeros(1,nud);
                else
                    nn=[nn,zeros(1,nud)];
                    nc = nc+nud;
                end
                if nud~=(nc-ny)/2
                    ctrlMsgUtils.error('Ident:estimation:arxCTOrderFormat')
                end
            end
            if nud~=(nc-ny)/2
                ctrlMsgUtils.error('Ident:estimation:arxOrderFormat')
            end
        else
            ts = 1;
            nud = (nc-ny)/2;
            if fix(nud)~=nud || nud+ny~=nzd
                ctrlMsgUtils.error('Ident:estimation:arxOrderFormat')
            end
        end

        na = nn(1:ny,1:ny);
        nb = nn(1:ny,ny+1:nud+ny);
        nk = nn(1:ny,ny+nud+1:end);
        if ny>1
            mdum = idarx;
        else
            %mdum = idpoly;
            was = ctrlMsgUtils.SuspendWarnings('Ident:idmodel:idpolyUseCellForBF');
            mdum = idpoly(1,ones(nud,1),'Ts',ts);
            delete(was)
        end
        mdum = pvset(mdum,'na',na,'nb',nb,'nk',nk,'ParameterVector',...
            zeros(sum(sum(na)')+sum(sum(nb)'),1));
        if nl>2
            switch class(varargin{3})
                case 'double' % This is the old syntax
                    maxsize = varargin{3};
                    if nl>3
                        Tsm = varargin{4};
                    else
                        Tsm = 1;
                    end

                    mdum = pvset(mdum,'MaxSize',maxsize,'Ts',Tsm);
                case 'char' % This is arx(data,[na nb nk], PVpairs)
                    [args,datapv] = pnsortd(varargin(3:end));
                    if~isempty(datapv) && isa(z,'iddata')
                        z = pvset(z,datapv{:});
                    end
                    % check if ts is in the list
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
                    if ~isempty(args)
                        set(mdum,args{:});
                    end
                otherwise
                    ctrlMsgUtils.error('Ident:estimation:CompleteOptionsValuePairs')
            end
        end
end
if ~isa(z,'iddata')
    z = iddata(z(:,1:ny),z(:,ny+1:end),pvget(mdum,'Ts'));
end

fixp1 = pvget(mdum,'FixedParameter');
fixp = fixp1;
if ~isempty(fixp) && isa(mdum,'idpoly')
    if isa(fixp,'double') % parameter numbers
        pna = setpname(mdum,2); %idpoly defaults
        fixp = pna(fixp);
    end
    if ~iscell(fixp),fixp = {fixp};end
    fixp = setpname(fixp,3); % convert to idarx names
    fixflag = 1;
    pars = pvget(mdum,'ParameterVector');
    if norm(pars)==0 % This is to allow the translation without stripping orders
        mdum = parset(mdum,(1:length(pvget(mdum,'ParameterVector')))');
    end
    mdum = idarx(mdum);
    if norm(pars) == 0
        mdum =  parset(mdum,zeros(length(pvget(mdum,'ParameterVector')),1));
    end
    mdum = pvset(mdum,'FixedParameter',fixp);
    mdum = setpname(mdum);
end

if isempty(pvget(z,'Name'))
    z = pvset(z,'Name',DataName);
end

% Now check Ts and Tsm
