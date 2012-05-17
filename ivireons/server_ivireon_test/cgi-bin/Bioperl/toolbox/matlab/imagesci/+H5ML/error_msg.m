function errString = error_msg()
%H5ML.error_msg  Retrieves error message from error stack.
%   This function walks the default error stack and retrieves the last
%   (outermost) error message.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/04/15 15:21:16 $

    errString = '';

	% We know that this is the correct value for H5E_WALK_UPWARD.  Were 
	% we to retrieve it using H5ML.get_constant_value, this would have 
	% the effect of clearing the error stack and defeating the entire
	% purpose for this routine.
	direction = H5ML.get_constant_value('H5E_WALK_UPWARD');
    H5E.walk(direction, @errorIterator);


    % Print the specifics of the HDF5 error iterator.
    function output = errorIterator(n, H5err_struct) %#ok<INUSL>
        errString = sprintf('\n"%s"', H5err_struct.desc);
        output = 1;
    end

end
