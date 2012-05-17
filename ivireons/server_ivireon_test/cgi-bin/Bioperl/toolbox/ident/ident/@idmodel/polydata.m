function [a,b,c,d,f,da,db,dc,dd,df] = polydata(sys, CellFormat)
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

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.11.4.8 $  $Date: 2009/10/16 04:55:21 $

if nargin<2
    CellFormat = 0;
elseif ischar(CellFormat)
    if strcmpi(CellFormat,'cell')
        CellFormat = 1;
    elseif strcmpi(CellFormat,'double')
        CellFormat = 0;
    else
        %error
        ctrlMsgUtils.error('Ident:analysis:polydataFormatValue');
    end
elseif ~isa(CellFormat,'double')
    ctrlMsgUtils.error('Ident:analysis:polydataFormatValue');
end

[ny,nu] = size(sys);
if ny>1
    ctrlMsgUtils.error('Ident:analysis:polydataCheck1')
end
if nargout < 6
    sys = pvset(sys,'CovarianceMatrix','None'); % to avoid unnecessary caluclations
end
idp = idpolget(sys,'d');
if ~isempty(idp)
    [a,b,c,d,f,da,db,dc,dd,df] = polydata(idp{1},CellFormat);
else
    T = pvget(sys,'Ts');
    [a,b,c,d,k] = ssdata(sys);
    %c=CC(iy,:);
    %de=DEf(iy,:);
    Apol = poly(a);
    Bpol = [];
    nZl = zeros(nu,1); nZt = nZl;
    for kk = 1:nu
        Bpol(kk,:) = poly(a-b(:,kk)*c)+(d(1,kk)-1)*Apol;
        
        bs = (abs(Bpol(kk,:))>10^-8*norm(Bpol));
        Bpol(kk,:) = bs.*Bpol(kk,:);
        
        nZli = find(Bpol(kk,:),1,'first');
        if ~isempty(nZli)
            nZl(kk) = nZli;
        else
            nZl(kk) = length(Bpol(kk,:));
        end
        nZti = find(Bpol(kk,:),1,'last');
        if ~isempty(nZti)
            nZt(kk) = nZti;
        else
            nZt(kk) = 1;
        end
    end
    
    %if strcmp(noises,'d')
    if pvget(sys,'NoiseVariance')==0
        Cpol = 1;
    else
        Cpol = poly(a-k(:,1)*c); %+(d(1,kk)-1)*Apol;%Bpol(nu+iy,:);
    end
    if T>0
        ic = find(abs(Cpol)>eps,1,'last'); Cpol = Cpol(1:ic); 
        ia = find(abs(Apol)>eps,1,'last'); Apol = Apol(1:ia);
        % remove trailing zeros from B
        Bpol = Bpol(:,1:max(nZt));
    else
        % remove leading zeros from B
        Bpol = Bpol(:,min(nZl):end);
    end
    
    a = Apol;
    b = Bpol;
    c = Cpol;
    d = 1;
    f = ones(nu,1);
    da = [];
    db = [];
    dc = [];
    dd = [];
    df = [];
    
    if CellFormat==1
        b = idmat2cell(b,T);
        f = idmat2cell(f,T);
        db = {};
        df = {};
    end
    
end
