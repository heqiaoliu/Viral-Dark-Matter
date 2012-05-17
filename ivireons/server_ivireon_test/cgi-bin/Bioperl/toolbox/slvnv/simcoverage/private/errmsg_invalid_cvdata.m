function msg = errmsg_invalid_cvdata(argNum)

	if nargin>0
		s = sprintf('Input argument %d is an invalid CVDATA object.',argNum);
	else
		s = 'Invalid CVDATA object.';
	end

	msg = [s char(10) 'CVDATA objects become invalid when their associated models' ...
           char(10) 'are closed or modified so that the data is inconsistent']; 
