function [sfd,spur,frq] = sfdr(this,varargin)
%SFDR Spurious Free Dynamic Range. 
%   SFD = SFDR(H) computes the spurious free dynamic range, in dB, of the
%   DSPDATA.MSSPECTRUM object H.
%
%   [SFD,SPUR,FRQ]= SFDR(H) also returns the magnitude of the highest
%   spur and the frequency FRQ at which it occurs.
%
%   [...] = SFDR(H,'MINSPURLEVEL',MSL) ignores spurs that are below the
%   MINSPURLEVEL MSL. Specifying MSL level may help in reducing the
%   processing time. MSL is a  real valued scalar specified in dB. The
%   default value of MSL is -Inf.  
%
%   [...] = SFDR(H,'MINSPURDISTANCE',MSD) considers only spurs that are at
%   least separated by MINSPURDISTANCE MSD, to compute spurious free
%   dynamic range. MSD is a real valued positive scalar specified in
%   frequency units. This parameter may be specified to ignore spurs that
%   may occur in close proximity to the carrier. For example, if the
%   carrier frequency is Fc, then all spurs in the range (Fc-MSD, Fc+MSD)
%   are ignored. If not specified, MSD is assigned a value equal to the
%   minimum distance between two consecutive frequency points in the
%   mean-square spectrum estimate.
%
%   EXAMPLE
%      f1 = 0.5; f2 = 0.52; f3 = 0.9; f4 = 0.1; n = 0:255; 
%      x = 10*cos(pi*f1*n)' + 6*cos(pi*f2*n)' + 0.5*cos(pi*f3*n)' + ...
%          + 0.5*cos(pi*f4*n)';
%      H = spectrum.periodogram;
%      h = msspectrum(H,x); 
%      [sfd, spur, freq] =  sfdr(h);
%
%      % To ignore peak at 0.52 rad/sample
%      [sfd, spur, freq] =  sfdr(h,'MinSpurDistance',0.1); 
%                                                         
%   See also DSPDATA/FINDPEAKS                

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/08/11 15:48:21 $

error(nargchk(1,5,nargin,'struct'));

hopts = uddpvparse('dspopts.sfdr',{'sfdropts',this},varargin{:});

ML = hopts.MinSpurLevel;
ML = 10^(ML/10);
MD = hopts.MinSpurDistance;

F = this.frequencies;

clear actError;

exp_id1 = 'signal:dspdata:abstractps:findpeaks:largePeakDistance';
exp_id2 = 'signal:findpeaks:largeMinPeakHeight';

try 
    warning('off','signal:findpeaks:noPeaks');
    [pks,frqs] = findpeaks(this,'MinPeakHeight',ML,'MinPeakDistance',MD);
catch actError
    warning('on','signal:findpeaks:noPeaks');
    act_id = actError.identifier;
    if(strcmp(act_id,exp_id1))
         sdmsgid = generatemsgid('largeSpurDistance');
         error(sdmsgid,strcat('MinSpurDistance is very large. Specify value in the range (',...
               num2str(0), ',', num2str((max(F)-min(F))), ').'));
    elseif(strcmp(act_id,exp_id2))
         shmsgid = generatemsgid('largeSpurLevel');
         error(shmsgid,'MinSpurLevel is very large. There are no data points greater than MinSpurLevel.')
    else
         rethrow(actError);
    end
end
warning('on','signal:findpeaks:noPeaks');

if(length(pks) <= 1)
    spmsgid = generatemsgid('noSpurs');
    error(spmsgid,'No spurs found. Try changing MinSpurLevel or MinSpurDistance, if specified.');
else
    carrierIdx = find(pks==max(pks));
    carrier    = pks(carrierIdx);
    carrierdB  = db(carrier,'power');
    pks(carrierIdx) = 0;

    highestspurIdx = find(pks==max(pks));
    spurdB = db(pks(highestspurIdx),'power');

    sfd = carrierdB-spurdB;
    if nargout > 1
        spur = db(pks(highestspurIdx),'power');
        frq = frqs(highestspurIdx);
    end
end



% [EOF]
