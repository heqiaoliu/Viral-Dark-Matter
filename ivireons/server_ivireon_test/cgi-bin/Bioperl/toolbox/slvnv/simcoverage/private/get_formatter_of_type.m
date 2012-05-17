function id = get_formatter_of_type(types),
% GET_CAPTION_OF_TYPE
% Find the caption object in the data dictionary which 
% the specified enumeration value, TYPE.

%   Bill Aldrich
%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/19 07:54:53 $

if ischar(types)
	[m,n] = size(types);
	numTypes = zeros(1,m);
	for i= 1:m
  		numTypes(1,i) = find_formatter_type(types(i,:));
	end
	types = numTypes;
end

id = [];
for type = types(:)',
	id = [id cv('find','all','formatter.keyNum',type)];
end
