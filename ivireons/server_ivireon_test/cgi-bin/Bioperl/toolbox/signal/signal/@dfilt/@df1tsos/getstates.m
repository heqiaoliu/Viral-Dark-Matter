function zh = getstates(Hd,dummy)
%GETSTATES Overloaded get for the States property.

% This should be a private method

%   Author: R. Losada
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.4 $  $Date: 2004/06/06 16:54:40 $

zh = Hd.hiddenstates;

if ~isempty(zh),
	% Reshape to what users see
    zh.Numerator = reshape(zh.Numerator, 2, prod(size(zh.Numerator))/2);
    zh.Denominator = reshape(zh.Denominator, 2, prod(size(zh.Denominator))/2);
end

