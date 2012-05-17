function long = labelstr( label )
%LONG = LABELSTR( LABEL)  Coverts space padded matrices to zero paded matrix

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.14.2.3 $  $Date: 2008/12/01 08:06:36 $
if isempty(label)
	long = '';
	return;
end
if ~ischar(label)
	if iscell(label)
		label = strrows(label{:});
	else
		error('Stateflow:UnexpectedError','Invalid label.');
	end
end

label = despace(label);
long  = strlong(label);
