function varargout = quantizecoeffs(q,varargin)
% Quantize coefficients


%   Author(s): R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/07/27 20:31:22 $

error(nargchk(2,5,nargin,'struct'));

varargout{1} = single(double(varargin{1}));

if nargin > 2,
    varargout{2} = single(double(varargin{2}));
end

if nargin > 3,
    varargout{3} = single(double(varargin{3}));
end

if nargin > 4,
    varargout{4} = single(double(varargin{4}));
end


