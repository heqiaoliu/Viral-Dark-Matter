function result = sf_evalin_base(varName,rowOrColumn,chart)


%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.6.2.3 $  $Date: 2008/02/20 01:34:00 $
	if(nargin<3)
		chart = [];
	end
	result = [];
	try,
		if(isempty(chart))
			value = evalin('base',varName);
		else
			blockH = sf('Private','chart2block',chart);
			chartBlockPath = getfullname(blockH);
			value = slResolve(varName,chartBlockPath);
		end
	catch,
		error(sprintf('%s not defined in MATLAB workspace',varName)); 
	end
	if(isa(value,'Simulink.Parameter'))
		result = value.Value;
	else
		result = value;
	end
	% cast it to double as MATLABs functions
    % such as sprintf and floor croak on non-doubles
	if isstruct(result) % Structures are ignored here
		return;
	end
    result = double(result);

	 if(nargin>1)
	     switch(rowOrColumn)
	     case 'row'
	         result = result(:)';
	     case 'column'
	         result = result(:);
	     case ''
	     		% do nothing
	     end
	 end
