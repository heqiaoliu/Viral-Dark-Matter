function h = gaussfir(BT,NT,OF)
%GAUSSFIR   Gaussian FIR Pulse-Shaping Filter Design.
%   H=GAUSSFIR(BT) designs a low pass FIR gaussian pulse-shaping filter.
%   BT is the 3-dB bandwidth-symbol time product where B is the one-sided
%   bandwidth in Hertz and T is in seconds.
%
%   H=GAUSSFIR(BT,NT) NT is the number of symbol periods between the start
%   of the filter impulse response and its peak. If NT is not specified, 
%   NT = 3 is used.
%
%   H=GAUSSFIR(BT,NT,OF) OF is the oversampling factor, that is, the number
%   of samples per symbol. If OF is not specified, OF = 2 is used.
%
%   The length of the impulse response of the filter is given by 2*OF*NT+1.
%   Also, the coefficients H are normalized so that the nominal passband
%   gain is always equal to one.
%
%   % EXAMPLE: Design a Gaussian filter to be used in a GSM GMSK scheme.
%   BT = .3; % 3-dB bandwidth-symbol time
%   OF = 8;  % Oversampling factor (i.e., number of samples per symbol)
%   NT = 2;  % 2 symbol periods to the filters peak. 
%   h = gaussfir(BT,NT,OF); 
%   hfvt = fvtool(h,'impulse');
%
%   See also FIRRCOS.

%   References:
%   [1] Rappaport T.S., Wireless Communications Principles and Practice,  
%   2nd Ed., Prentice Hall, 2002.
%   [2] Krishnapura N., Pavan S., Mathiazhagan C., Ramamurthi B., "A
%   Baseband Pulse Shaping Filter for Gaussian Minimum Shift Keying,"
%   Proceedings of the 1998 IEEE International Symposium on Circuits and
%   Systems, 1998. ISCAS '98. 

%   Author: P. Costa
%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/09/13 07:14:17 $

% Validate number I/O arguments.
error(nargchk(1,3,nargin,'struct'));
error(nargoutchk(0,1,nargout,'struct'));

if nargin < 2, NT = 3; end
if nargin < 3, OF = 2; end

% Check for valid BT
[errid, errmsg] = chkBT(BT,'invalidBT','3-dB bandwidth-symbol time product');
if ~isempty(errmsg), error(errid, errmsg); end

% Convert to t in which to compute the filter coefficients
t= convert2t(OF,NT);

% Equation 6.53 of [1], page 290 is
% a = sqrt(log(2)/2)/B, here we use alpha = a/T
alpha = sqrt(log(2)/2)/(BT);

% Equation 5.54 of [1] is
% h = (sqrt(pi)/a)*exp(-(t1*pi/a).^2); 
% We use t = t1/T, alpha = a/T.  Then
% h = (sqrt(pi)*T/alpha)*exp(-(t*pi/alpha).^2); 
% But then we normalize, so T is not needed.
h = (sqrt(pi)/alpha)*exp(-(t*pi/alpha).^2); 
 
% Normalize coefficients
h = h./sum(h);


%--------------------------------------------------------------------------
function t = convert2t(OF,NT)

% Check for valid OF and NT
[errid, errmsg] = chkInput(OF,'invalidOSFactor','Oversampling factor');
if ~isempty(errmsg), error(errid, errmsg); end

[errid, errmsg] = chkInput(2*NT,'invalidNumSPeriods','Twice the number of symbol periods');
if ~isempty(errmsg), error(errid, errmsg); end

% Filter Length
filtLen = 2*OF*NT+1;
t = linspace(-NT,NT,filtLen);


%-----------------------------------------------------------------------
function [errid, errmsg] = chkBT(val,id,param)

errid = '';
errmsg = '';
if isempty(val) || length(val) > 1 || ~isa(val,'double') || ...
        ~isreal(val) || val<=0,
    errid = generatemsgid(id);
    errmsg = [param,' must be a real, positive scalar.'];
    return;
end

%-----------------------------------------------------------------------
function [errid, errmsg] = chkInput(val,id,param)

errid = '';
errmsg = '';
if isempty(val) || length(val) > 1 || ~isa(val,'double') || ...
        ~isreal(val) || val~=round(val) || val<=0,
    errid = generatemsgid(id);
    errmsg = [param,' must be a real, positive integer.'];
    return;
end


% [EOF]
