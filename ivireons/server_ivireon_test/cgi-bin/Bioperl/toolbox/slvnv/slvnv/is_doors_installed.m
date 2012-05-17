function result = is_doors_installed()

% Copyright 2004-2009 The MathWorks, Inc.

	result = false;
    if ispc
        try
		
			% This is the DOORS support recommended way of determining
			% if DOORS is installed.  The other option is to attempt to
			% create the COM object, the disadvantage of which is it will
			% launch the DOORS and ask you to login.  If this key doesn't
			% exist, the following will error out.
			winqueryreg('name', 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Telelogic\DOORS');
			result = true;
	
        catch Mex %#ok<NASGU>
            
            try
                % There is also a slight chance that DOORS is installed by
                % non-Admin user, we need to check this other key
                winqueryreg('name', 'HKEY_CURRENT_USER', 'SOFTWARE\Telelogic\DOORS');
                result = true;
                
            catch Mex %#ok<NASGU>
                % all failed
            end
        end
    end
