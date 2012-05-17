function [a,b,c,d,f,da,db,dc,dd,df] = polydata(m,CellFormat)
%POLYDATA computes the polynomials associated with a given model.
%   [A,B,C,D,F] = POLYDATA(MODEL)
%
%   MODEL is a linear model - IDPOLY, IDSS, IDPROC, IDGREY or IDARX.
%
%   A, B, C, D, and F are returned as the corresponding polynomials
%   in the general input-output model. A, C and D are row
%   vectors. For single-input models, B and F are row vectors too.
%
%   Format of B and F polynomials in multi-input case:
%   For IDPOLY models, the format depends upon whether the model has been
%   configured to work in a backward compatibility mode or has been upgraded
%   to use cell arrays. See idpoly/setPolyFormat for more information. By
%   default (if setPolyFormat has not been called on the model), these
%   polynomials are returned as double matrices with Nu rows. For other
%   model types (IDSS, IDARX, IDGREY and IDPROC), the B and F polynomials
%   are returned as double matrices by default. If you want to retrieve
%   them as cell arrays, use:
%   [A, B, ..] = POLYDATA(MODEL, 'cell')
%   which causes B and F to be returned as cell arrays if number of inputs
%   is greater than 1.
%
%   [A,B,C,D,F,dA,dB,dC,dD,dF] = POLYDATA(MODEL)
%   also returns the standard deviations of the estimated polynomials.
%
%   See also IDPOLY, idpoly/setPolyFormat.

%   L. Ljung 10-1-86, 8-27-94
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $ $Date: 2009/12/05 02:03:36 $

na = m.na; nb = m.nb; nc = m.nc; nd = m.nd; nf = m.nf; nk = m.nk;
par = pvget(m.idmodel,'ParameterVector').';
T   = pvget(m.idmodel,'Ts');

if nargin<2
    CellFormat = pvget(m,'BFFormat');
elseif ischar(CellFormat)
    if strcmpi(CellFormat,'cell')
        CellFormat = 0;
    elseif strcmpi(CellFormat,'double')
        CellFormat = 1;
    else
        %error
        ctrlMsgUtils.error('Ident:analysis:polydataFormatValue');
    end
elseif ~isa(CellFormat,'double')
    ctrlMsgUtils.error('Ident:analysis:polydataFormatValue');
end

if nargout>5
    dpar = pvget(m.idmodel,'CovarianceMatrix');
    if ischar(dpar), dpar =[];end
    if ~isempty(dpar)
        dpar = sqrt(diag(dpar)).';
    end
end

nu = length(nb);
if isempty(par)
    a = 1; b = zeros(nu,0); c = 1; d = 1; f = ones(nu,1);
    %a=[];b=[];c=[];d=[];f=[];
    %da=[];db=[];dc=[];dd=[];df=[];
    da = zeros(1,0); db = b; dc = da; dd = da; df = b; %r.s.
    if CellFormat==0
        b = idmat2cell(b,T);
        f = idmat2cell(f,T);
    end
    return
end

Nacum = na;
Nbcum = Nacum+sum(nb);
Nccum = Nbcum+nc;
Ndcum = Nccum+nd;
%Nfcum = Ndcum+sum(nf);

a = [1 par(1:Nacum)];
c = [1 par(Nbcum+1:Nccum)];
d = [1 par(Nccum+1:Ndcum)];

% AR, ARMA
%if nu==0,
%  b=0; f=1;
%end

b   = zeros(nu,max(nb+nk));
nf1 = max(nf)+1;
f   = zeros(nu,nf1);
s   = 1;
s1  = 1;

for k=1:nu
    if T>0
        if nb(k) > 0
            b(k,nk(k)+1:nk(k)+nb(k)) = par(na+s:na+s+nb(k)-1);
        end
        if nf(k)>0
            f(k,1:nf(k)+1) = [1 par(Ndcum+s1:Ndcum+nf(k)+s1-1)];
        else
            f(k,1)=1;
        end
    else
        if nb(k) > 0
            b(k,end-nb(k)+1:end) = par(na+s:na+s+nb(k)-1);
        end
        
        if nf(k)>0
            f(k,nf1-nf(k):nf1) = [1 par(Ndcum+s1:Ndcum+nf(k)+s1-1)];
        else
            f(k,nf1)=1;
        end
    end
    s  = s  + nb(k);
    s1 = s1 + nf(k);
end
if nargout>5
    if isempty(dpar)
        da=zeros(1,0); db=zeros(nu,0); dc=zeros(1,0); dd=zeros(1,0); df=zeros(nu,0);
    else
        da = [0 dpar(1:Nacum)];
        dc = [0 dpar(Nbcum+1:Nccum)];
        dd = [0 dpar(Nccum+1:Ndcum)];
        
        db   = zeros(nu,max(nb+nk));
        nf1 = max(nf)+1;
        df   = zeros(nu,nf1);
        s   = 1;
        s1  = 1;
        
        for k=1:nu
            if T>0
                if nb(k) > 0
                    db(k,nk(k)+1:nk(k)+nb(k)) = dpar(na+s:na+s+nb(k)-1);
                end
                
                if nf(k)>0
                    df(k,1:nf(k)+1) = [0 dpar(Ndcum+s1:Ndcum+nf(k)+s1-1)];
                else
                    df(k,1)=0;
                end
            else
                if nb(k) > 0
                    db(k,end-nb(k)+1:end) = dpar(na+s:na+s+nb(k)-1);
                end
                
                if nf(k)>0
                    df(k,nf1-nf(k):nf1) = [0 dpar(Ndcum+s1:Ndcum+nf(k)+s1-1)];
                else
                    df(k,nf1)=0;
                end
            end
            s  = s  + nb(k);
            s1 = s1 + nf(k);
        end
    end
end

% Return b, f, db, df as cell arrays in multi-input case if CellFormat is
% TRUE
if CellFormat==0
    b = idmat2cell(b,T);
    f = idmat2cell(f,T);
    if nargout>5
        db = idmat2cell(db,T);
        df = idmat2cell(df,T);
        if ~isempty(dpar)
            if T==0 && nu>1
                % reintroduce leading zero to each row of df
                df = cellfun(@(x)[0,x],df,'UniformOutput',false);
            elseif iscell(df) && any(cellfun('isempty',df))
                % df can't be empty since f is at least 1
                df(cellfun('isempty',df)) = {0};
            end
        end
    end
end
