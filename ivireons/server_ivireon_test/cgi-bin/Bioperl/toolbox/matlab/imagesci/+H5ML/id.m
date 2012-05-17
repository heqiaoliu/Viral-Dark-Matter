classdef id < handle
%HDF5ID An identifier class for HDF5 files.
%   This identifier class contains an HDF5 identifier.  When it is
%   destroyed, it will automatically call the appropriate HDF5 'close'
%   method, thus ensuring that it is not left in an open state.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4.2.1 $ $Date: 2010/06/24 19:34:25 $
    
  properties (GetAccess = public)
    identifier; 
  end   
  properties (Access = private)
    callback;
  end   
  
  methods       
    %------------------------------------------------------------------
    function obj = id(identifier, callback)    
        
        if nargin == 0
            % This is required since Matlab can call this constructor when
            % accounting for unassigned elements within an array of H5ML.ids
            obj.identifier = -1;
            obj.callback   = '';
            return;
        end
        if identifier < 0
            error('MATLAB:H5ML_id_id:invalidID', ...
                  'An invalid HDF5 identifier was returned from the HDF5 library.');
        end
        obj.identifier = identifier;
        obj.callback   = callback;
    end
    
    %------------------------------------------------------------------
    function delete(obj) 
        obj.close();
    end
    
    %------------------------------------------------------------------
    function close(obj, varargin) 
    %H5ML.id.close Close the contained HDF5 identifier.
    %   This function will call the appropriate HDF5 close function when the
    %   object which contains it goes out of scope.  It should not be called
    %   directly.

        if H5I.is_valid(obj)
            % Call the MEX-file directly to close the identifier.
            cb = obj.callback;
            id = obj.identifier;
            obj.identifier = -1;

            try
                H5ML.hdf5lib2(cb, id);
            catch ME
                % The H5T.lock if called on a H5T datatype instance makes it
                % non-destructible. The code below prevents error generated when
                % Matlab cleans up such a variable. H5T.close called excplicitly
                % will still generate an error since that is the right behavior.
                if ~strcmp('H5Tclose', cb) || ...
                     isempty(strfind(ME.message, 'immutable datatype'))
                    rethrow(ME);
                end
            end
        end       
    end
    
    %------------------------------------------------------------------
    function disp(obj) 
    %H5ML.id.disp Display the contained HDF5 identifier.
    %   This function will display the enclosed HDF5 identifier.
    %
    
        for j = 1:numel(obj)
            disp(obj(j).identifier);
        end
    end
    
    %------------------------------------------------------------------
    function id = double(obj) 
    %H5ML.id.double Return the contained HDF5 identifier as a double.
    %   This method returns the enclosed HDF5 identifier as a double.
    %
    
        id = double(obj.identifier);        
    end
    
  end
end
