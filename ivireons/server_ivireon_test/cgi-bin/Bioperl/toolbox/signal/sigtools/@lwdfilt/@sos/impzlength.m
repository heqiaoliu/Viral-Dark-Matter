function len = impzlength(this, varargin)
%IMPZLENGTH Length of the impulse response for a digital filter.

%   Author: R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:17:34 $

error(nargchk(1,2,nargin,'struct'));

[msgid,msg] = warnsv(this);
if ~isempty(msg),
    warning(msgid,msg);
end

% Initialize length
firlen=1;
iirlen=1;

% Convert the filter to a transfer function.
for k=1:nsections(this)
    
    % Get the transfer function coefficients
    b=this.sosMatrix(k,1:3);
    a=this.sosMatrix(k,4:6);
    
    if signalpolyutils('isfir',b,a),
        % Add the length of each FIR section
        firlen = firlen + length(b) - 1;
    else 
        
        % Keep the maximum length of all IIR sections
        iirlen = max(iirlen, impzlength(b,a,varargin{:}));
    end
end

% Use the longest of FIR or IIR
len=max(firlen,iirlen);
