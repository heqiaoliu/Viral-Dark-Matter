function signals = initsignals(varargin)
%INITSIGNALS   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 19:59:19 $

if(isempty(varargin))
	signals = {};
else
	signals = varargin{1};
end

% [EOF]
