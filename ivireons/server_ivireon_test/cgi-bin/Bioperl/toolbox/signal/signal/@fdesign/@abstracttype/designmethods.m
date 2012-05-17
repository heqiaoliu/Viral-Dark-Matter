function varargout = designmethods(this, varargin)
%DESIGNMETHODS   Returns a cell of design methods.

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.13 $  $Date: 2010/05/20 03:10:11 $

if any(strcmpi('default', varargin))
    d = defaultmethod(this);
    if any(strcmpi('full', varargin))
        switch lower(d) 
            case 'ellip'
                d = 'Elliptic';
            case 'butter'
                d = 'Butterworth';
            case 'cheby1'
                d = 'Chebyshev type I';
            case 'cheby2'
                d = 'Chebyshev type II';
            case 'kaiserwin'
                d = 'Kaiser window';
            case {'equiripple', 'window'}
                d = [upper(d(1)) d(2:end)];
            case 'firls'
                d = 'FIR least-squares';
            case 'fircls'
                d = 'FIR constrained least-squares';
            case 'ifir'
                d = 'Interpolated FIR';
            case 'iirlpnorm'
                d = 'IIR least p-norm';
            case 'freqsamp'
                d = 'Frequency sampling';
            case 'multistage'
                d = 'Multistage equiripple';
            case 'iirlinphase'
                d = 'IIR quasi-linear phase';
            case 'maxflat'
                d = 'Maximally flat';
            case 'ansis142'
                d = 'ANSI S1.42 weighting';
        end
    end
    d = {d};
    type = 'Default';
else
    [d, isfull, type] = thisdesignmethods(this, varargin{:}); %#ok<ASGLU>
    type = upper(type);
end

if nargout,
    varargout = {d};
else
    if ~isempty(type)
        type = sprintf('%s ', type);
    end
    fprintf(1, '\n\n');
    fprintf('%sDesign Methods for class %s (%s):\n', type, ...
        class(this), get(this, 'Specification'));
    fprintf(1, '\n\n');
    for indx = 1:length(d),
        disp(d{indx});
    end
    fprintf(1, '\n');
end

% [EOF]
