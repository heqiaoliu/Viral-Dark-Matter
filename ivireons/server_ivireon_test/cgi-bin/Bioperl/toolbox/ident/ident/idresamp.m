function [zd,decr] = idresamp(data,r,nfilt,tol)
%IDRESAMP Resamples data by decimation and interpolation.
%   ZD = IDRESAMP(Z,R)
%
%   Z  : The output-input data as a matrix or as an IDDATA object.
%   ZD : The resampled data.  If Z is IDDATA, so is ZD. Otherwise the
%        columns of ZD correspond to those of Z.
%   R  : The resampling factor. The new data record ZD will correspond
%        to a sampling interval of R times that of the original data.
%        R > 1 thus means decimation and R < 1 means interpolation.
%        Any positive number for R is allowed, but it will be replaced
%        by a rational approximation.
%
%   [ZD, ACT_R] = IDRESAMP(Z,R,ORDER,TOL) gives access to the following
%   options: ORDER determines the filter orders used at decimation
%   and interpolation (Default 8). TOL gives the tolerance of the
%   rational approximation (Default 0.1). ACT_R is the actually used
%   resampling factor.
%   See also IDFILT.

%   L. Ljung 3-3-95.
%   The code is adopted from the routines DECIMATE and INTERP
%   in Signal Processing Toolbox, written by L. Shure.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.7.4.6 $  $Date: 2009/04/21 03:21:58 $

error(nargchk(2,Inf,nargin,'struct'))

data = idutils.utValidateData(data,[],'time',false,'idresamp');

if issignalinstalled
    ctrlMsgUtils.warning('Ident:dataprocess:idresampSignalAlert')
end

if nargin<4
    tol = [];
    if nargin<3
        nfilt = [];
    end
end

%if isempty(tol),tol=0.1;end
if isempty(nfilt),nfilt=8;end

if isempty(r) || ~isscalar(r) || ~isreal(r) || ~isfloat(r) || r<=0
    ctrlMsgUtils.error('Ident:dataprocess:idresampNonPositiveFactor')
end

if isa(data,'iddata')
    iddataflag = 1;

    y = pvget(data,'OutputData');
    Nexp = length(y);
    u = pvget(data,'InputData');
    Ts = pvget(data,'Ts');
else
    iddataflag = 0;
    zdat = data;
    Nexp = 1;
    Ts{1} = 1;
end

for kexp = 1:Nexp
    if iddataflag
        ny = size(y{kexp},2);
        %nu = size(y{kexp},2);
        zdat = [y{kexp},u{kexp}];
    end
    [ndat,nyu]=size(zdat);

    if ndat<nyu
        ctrlMsgUtils.error('Ident:dataprocess:errTransposedData')
    end
    if ndat<10
        ctrlMsgUtils.error('Ident:dataprocess:idresamp1',10)
    end
    if isempty(tol)
        [numr,denr] = rat(r);
    else
        [numr,denr] = rat(r,tol);
    end
    if numr==0
        [numr,denr] = rat(r,tol/2);
    end

    decr = numr/denr;
    if numr == 1 && denr == 1
        zd = pvset(data,'Notes',{},'UserData',[]);
        
        if ~isempty(data.Name)
            zd.Name = [data.Name,'_Resampled'];
        end
        return
    end
    
    if denr>1
        l = nfilt/2;
        alpha = .5;
        % calculate AP and AM matrices for inversion
        s1 = toeplitz(0:l-1) + eps;
        s2 = hankel(2*l-1:-1:l);
        s2p = hankel([1:l-1 0]);
        s2 = s2 + eps + s2p(l:-1:1,l:-1:1);
        s1 = sin(alpha*pi*s1)./(alpha*pi*s1);
        s2 = sin(alpha*pi*s2)./(alpha*pi*s2);
        ap = s1 + s2;
        am = s1 - s2;
        ap = inv(ap);
        am = inv(am);

        % now calculate D based on INV(AM) and INV(AP)
        d = zeros(2*l,l);
        d(1:2:2*l-1,:) = ap + am;
        d(2:2:2*l,:) = ap - am;
        % set up arrays to calculate interpolating filter B
        x = (0:denr-1)/denr;
        yy = zeros(2*l,1);
        yy(1:2:2*l-1) = (l:-1:1);
        yy(2:2:2*l) = (l-1:-1:0);
        X = ones(2*l,1);
        X(1:2:2*l-1) = -ones(l,1);
        XX = eps + yy*ones(1,denr) + X*x;
        yy = X + yy + eps;
        h = .5*d'*(sin(pi*alpha*XX)./(alpha*pi*XX));
        b = zeros(2*l*denr+1,1);
        b(1:l*denr) = h';
        b(l*denr+1) = .5*d(:,l)'*(sin(pi*alpha*yy)./(pi*alpha*yy));
        b(l*denr+2:2*l*denr+1) = b(l*denr:-1:1);
        for kc = 1:nyu
            idata = zdat(:,kc);
            % Use the filter B to perform the interpolation
            odata = zeros(denr*ndat,1);
            odata(1:denr:ndat*denr) = idata;
            
            % Filter a fabricated section of data first
            od = zeros(2*l*denr,1);
            od(1:denr:(2*l*denr)) = 2*idata(1)-idata((2*l+1):-1:2);
            [od,zi] = filter(b,1,od);
            [odata,zf] = filter(b,1,odata,zi);
            odata(1:(ndat-l)*denr) = odata(l*denr+1:ndat*denr);

            od = zeros(2*l*denr,1);
            od(1:denr:(2*l)*denr) = ...
                2*idata(ndat)-(idata((ndat-1):-1:(ndat-2*l)));
            od = filter(b,1,od,zf);
            odata(ndat*denr-l*denr+1:ndat*denr) = od(1:l*denr);
            zd(:,kc) = odata;
        end
        zdat = zd;
        [ndat,~] = size(zdat);
    end
    if numr>1
        nout = ceil(ndat/numr);
        if ndat<3*nfilt
            ctrlMsgUtils.error('Ident:dataprocess:idresamp1',3*nfilt)
        end
        odata = idfilt(zdat,nfilt,0.8/numr);
        nbeg = numr - (numr*nout - ndat);
        zd = odata(nbeg:numr:ndat,:);
    end
    yd{kexp} = zd(:,1:ny);
    ud{kexp} = zd(:,ny+1:end);
    Ts{kexp} = Ts{kexp} *decr;
    clear zd
end %kexp

if iddataflag
    zd = pvset(data,'OutputData',yd,'InputData',ud,'Ts',Ts,...
        'Notes',{},'UserData',[]);
    
    if ~isempty(data.Name)
        zd.Name = [data.Name,'_Resampled'];
    end
end
