classdef SaveLoad < handle
%SaveLoad Class definition for save and load utility
%   SaveLoad class provides tools to save and load MATLAB objects. Classes that
%   inherit from this class must use IsLoading_ flag to disable resets based on
%   property set actions.  If property set functions reset property values, we
%   may overwrite already loaded property values.
%
%   This utility collects all the public data automatically. Inheriting classes
%   may implement localLoadobj and localSaveobj to add more data to the default
%   save structure. 
%
%   See COMMSRC.PATTERN for an example subclass of SIGUTILS.PVPAIRS.
%
%   See also SIGUTILS, SIGUTILS.SORTEDDISP.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2008/10/31 06:58:08 $


%NOTE: once the MCOS bug is fixed and in Acomms, we can remove convertToSaveStr
%and restoreFromSaveStr.

    
    %===========================================================================
    % Protected properties
    properties (SetAccess = private, GetAccess = protected)
        % This property should be used to control is reset method can be
        % executed.  During load operation, reset method should be disables to
        % avoid already loaded property values to be reset, when we set another
        % property that triggers reset.
        IsLoading_ = false;
    end
    
    %===========================================================================
    % Static/Hidden methods
    methods (Static, Hidden)
        function h = loadobj(s)
            h = eval(s.class);
            s = rmfield(s, 'class');
            
            % Disable reset
            h.IsLoading_ = true;
            
            % Set public properties
            fn = fieldnames(s.public);
            for p=1:length(fn)
                h.(fn{p}) = s.public.(fn{p});
            end
            
            % Call the local load object function to do the rest
            h = localLoadobj(h, s.protected);

            % Enable reset
            h.IsLoading_ = false;
        end
    end
    
    %===========================================================================
    % Protected methods
    methods (Access = protected)
        function s = saveobj(this)
            mc = metaclass(this);
            props = mc.Properties;
            
            % Store the class type in a structure
            s.class = class(this);
            
            % Determine public properties to be saved and create an intermediate
            % structure
            publicProps = struct;
            for p=1:length(props)
                pr = props{p};
                if (strcmp(pr.SetAccess, 'public') && strcmp(pr.GetAccess, 'public'))
                    publicProps.(pr.Name) = this.(pr.Name);
                end
            end
            s.public = publicProps;
            
            % Get non-public data from class itself
            s.protected = localSaveobj(this);

            % Remove IsLoading_ if exists
            if isfield(s.protected, 'IsLoading_')
                s.protected = rmfield(s.protected, 'IsLoading_');
            end
            
        end
        %-----------------------------------------------------------------------
        function s = localSaveobj(this) %#ok<MANU>
            % localSaveobj return a structure of protected or any other data to
            % be saved
            s = [];
        end
        %-----------------------------------------------------------------------
        function localLoadobj(this, s) %#ok<INUSD,MANU>
            % localLoadobj load protected or any other data
        end
    end
end
