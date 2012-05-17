function [pe,maxnr] = pexcit(d,maxo,thr,maxsize)
%PEXCIT Test degree of persistence of excitation for the input.
%
%   PED = PEXCIT(DATA)
%
%   DATA: AN IDDATA object. Both time and frequency domain data can be
%         tested.
%
%   PED: Degree of excitation of the input(s) in DATA.
%        A row vector of integers
%
%   [PED,MAXNR] = PEXCIT(DATA,MAXNR,THRESHOLD,MAXSIZE)
%   gives MAXNR = the maximum degree tested. and THRESHOLD =
%   the threshold of the singular values of the input covariance
%   matrix. MAXSIZE sets the limit for the size of any matrix formed.
%   Default MAXNR is min(N/3,50), where N is the number of data,
%           THRESHOLD = 1e-9
%           MAXSIZE = IDMSIZE(sum(size(d,'N')))
%
%   Note that PEXCIT only tests the excitation of the individual
%   inputs. Joint excitation of multi-inputs is not tested.
%
%   See also IDDATA/ADVICE and IDDATA/FEEDBACK.

%   L. Ljung 11-01-02
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.2.6.11 $ $Date: 2009/04/21 03:22:14 $

d = idutils.utValidateData(d, [], 'both', true, 'pexcit');

nu = size(d,'nu');
if nu==0
    ctrlMsgUtils.error('Ident:analysis:pexcit1')
end

if nargin<3
    thr = [];
end
if isempty(thr)
    thr = 1e-9;
end

N = sum(size(d,'N'));
if nargin<2
    maxo =[];
end
if isempty(maxo)
    maxnr = floor(min(N/3,50));
else
    maxnr = maxo;
end
if nargin < 4
    maxsize = idmsize(N);
end

maxnr = floor(min(N/2,maxnr));

if strcmpi(pvget(d,'Domain'),'Time')
    if maxnr*N>1e6
        df = fft(d);
        [pe,maxnr] = pexcit(df,maxnr,thr,maxsize);
        return
    end
    u = pvget(d,'InputData');
    if maxnr==0
        M = Inf; %idfrd case
    else
        M = floor(maxsize/maxnr);
    end
    for ku = 1:nu
        R1 = zeros(0,maxnr);
        for kexp = 1:length(u)
            uu = u{kexp}(:,ku);
            N = size(uu,1);
            for kM = maxnr:M:N
                jj = kM:min(N,kM-1+M);
                phiu = zeros(length(jj),maxnr);
                for k1 = 1:maxnr
                    phiu(:,k1) = uu(jj+1-k1,:);
                end
                R1 = triu(qr([R1;phiu]));[nRr,nRc]=size(R1);
                R1 = R1(1:min(nRr,nRc),:);
            end
        end
        sv = svd(R1);
        try
            pe(ku) = find(sv/sv(1)>thr, 1, 'last' );
        catch
            pe(ku) = 0;
        end
    end
else
    d = complex(d);
    u = pvget(d,'InputData');
    fre = pvget(d,'SamplingInstants');
    
    for ku=1:nu
        freku = [];
        for kexp = 1:length(fre)
            freku = [freku;fre{kexp}(abs(u{kexp}(:,ku))>thr)];
        end
        pe(ku) = length(unique(freku));
    end
end
