function [fbck,fbck0,nudir] = feedback(d)
%IDDATA/FEEDBACK Test possible output feedback in data.
%
%   [FBCK,FBCK0,NUDIR] = FEEDBACK(DATA)
%
%   DATA: AN IDDATA object.
%   FBCK is an Ny-by-Nu matrix indicating the feedback.
%        The ky-by-ku entry is a measure of feedback from output
%        ky to input ku. The value is a probability P in percent.
%        Its interpretation is that if the hypothesis that there is no
%        feedback from output ky to input ku were tested at the level P, it
%        would be rejected. Thus, the larger the P the greater the
%        indication of feedback. Often only values over 90% would be taken
%        as clear indications. In this test a direct dependence of  u(t) on
%        y(t) (a "direct term") is not viewed as a feedback effect.
%   FBCK0: same as FBCK but this test views direct terms as feedback
%        effects.
%
%   NUDIR is a vector containing those input numbers that appear to have
%       a direct effect on some of the outputs, i.e. no delay from input
%       to output.
%
%   See also IDDATA/ADVICE, PEXCIT.

%   L. Ljung 11-01-02
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.11 $ $Date: 2009/04/21 03:22:07 $

d = idutils.utValidateData(d, [], 'both', true, 'feedback');

if size(d,'nu')==0
    ctrlMsgUtils.error('Ident:analysis:feedbackNoInput')
elseif size(d,'ny')==0
    ctrlMsgUtils.error('Ident:analysis:feedbackNoOutput')
end

ped = pexcit(d);
if ped<=4
    ctrlMsgUtils.warning('Ident:analysis:feedbackcheck1')
    fbck = 0 ; fbck0 = 0; nudir = [];
    return
end
was = warning('off'); [lw,lwid] = lastwarn;
try
    [y,t,ysd] = impulse(impulse(d)); %check pe order first
catch E
    warning(was), lastwarn(lw,lwid)
    rethrow(E)
end
warning(was), lastwarn(lw,lwid)

t0 = find(t==0);
[lt,ny,nu] = size(y);
dirterm = zeros(ny,nu);
fbck = zeros(ny,nu);
fbck0 = fbck;
for ky = 1:ny
    for ku = 1:nu
        y0 = y(t0,ky,ku);
        if abs(y0)>max(3*ysd(t0,ky,ku),sqrt(eps)*norm(y(:,ky,ku),Inf))
            dirterm(ky,ku) = 1;
        end
        if any(abs(y(t<0,ky,ku))>sqrt(eps)*norm(y(:,ky,ku),Inf))
            x = y(t<0,ky,ku)./ysd(t<0,ky,ku);
            fbck(ky,ku) = 100*idchi2(real(x'*x),length(find(t<0)));
        end
        
        x0 = y(t<=0,ky,ku)./ysd(t<=0,ky,ku);
        fbck0(ky,ku) = 100*idchi2(real(x0'*x0),length(find(t<=0)));
        
    end
end

nudir = find(sum(dirterm==1));
