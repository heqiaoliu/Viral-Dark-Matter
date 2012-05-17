function [I, T] = computeimpz(this, varargin)
%COMPUTEIMPZ   

%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/14 06:46:09 $


[N, Fs] = timezparse(varargin{:});
if isempty(N),  N  = lclimpzlength(this); end
if isempty(Fs), Fs = 1;              end

T = (0:N-1)'/Fs;
x = [1;zeros(N-1,1)];

% Filter to compute impz
I = sosfilt(this.sosMatrix,x);

I = I*prod(this.ScaleValues);

%--------------------------------------------------------------------------
function len = lclimpzlength(this)

% Initialize length
firlen=1;
iirlen=1;

% Convert the filter to a transfer function.
for k=1:size(this.sosMatrix,1)
    
    % Get the transfer function coefficients
    b=this.sosMatrix(k,1:3);
    a=this.sosMatrix(k,4:6);
    
    if signalpolyutils('isfir',b,a),
        % Add the length of each FIR section
        firlen = firlen + length(b) - 1;
    else 
        
        % Keep the maximum length of all IIR sections
        iirlen = max(iirlen, impzlength(b,a));
    end
end

% Use the longest of FIR or IIR
len=max(firlen,iirlen);

% [EOF]
