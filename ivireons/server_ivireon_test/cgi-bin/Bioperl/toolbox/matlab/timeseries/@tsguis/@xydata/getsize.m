function s = getsize(this)

% Copyright 2004 The MathWorks, Inc.

if size(this.Ydata,1)==size(this.Xdata,1)
    s = [size(this.Ydata,2) size(this.Xdata,2)];
else % Create a data exception if the two time series have differing lengths
    s = inf;
end





