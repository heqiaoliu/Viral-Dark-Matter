function [m, xunits] = objspecificdraw(this)
%OBJSPECIFICDRAW   Draw and set up axis for the frequency response.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:29:38 $

xunits='';
m=1;

if isempty(this.Spectrum), return; end

inputs = getdatainputs(this);

[H,W] = getdata(this.Spectrum, inputs{:});

if isempty(H), return; end

if ~iscell(H), H = {H}; W = {W}; end

if strcmpi(this.NormalizedFrequency,'off'),
    % Determine the correct engineering units to use for the x-axis.
    update_range(this,W{:});  % Doesn't need a cell array.
    [W, m, xunits] = cellengunits(W);
else
    for indx = 1:length(W)
        W{indx} = W{indx}/pi;
    end
    update_range(this,W{:});  % Doesn't need a cell array.
end
plotline(this,W,H);

% [EOF]
