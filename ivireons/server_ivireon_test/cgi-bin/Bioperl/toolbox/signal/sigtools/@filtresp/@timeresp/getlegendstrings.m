function strs = getlegendstrings(this, varargin)
%GETLEGENDSTRINGS Returns the legend strings

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.3 $  $Date: 2004/04/13 00:20:51 $

strs = getlegendstrings(this.FilterUtils, varargin{:});

% We need special code to take care of the imaginary part
imagStrs = repmat({''}, 1, length(strs));
eindx    = [];

Hd = get(this, 'Filters');
[dindx, qindx] = getfiltindx(Hd);
if ~showref(this.FilterUtils)
    dindx = sort([dindx qindx]);
    qindx = [];
end
nq = length(qindx);

for indx = 1:nq,

    if isreal(Hd(qindx(indx)).Filter),

        % If the filter is real add the index to a list to remove from imagStrs
        eindx = [eindx, 4*indx-2, 4*indx];
    else
        
        % If the filter isn't real add 'imaginary and real
        imagStrs{2*indx-1} = [strs{2*indx-1} ': Imaginary'];
        strs{2*indx-1}     = [strs{2*indx-1} ': Real'];
        imagStrs{2*indx}   = [strs{2*indx} ': Imaginary'];
        strs{2*indx}       = [strs{2*indx} ': Real'];
    end
end

for indx = 1:length(dindx),
    if ~isreal(Hd(dindx(indx)).Filter),
        imagStrs{2*nq+indx} = [strs{2*nq+indx} ': Imaginary'];
        strs{2*nq+indx}     = [strs{2*nq+indx} ': Real'];
    end
end

strs = {strs{:}; imagStrs{:}};
strs = {strs{:}};
indx = 1;
while indx <= length(strs)
    if isempty(strs{indx})
        strs(indx) = [];
    else
        indx = indx+1;
    end
end

% [EOF]
