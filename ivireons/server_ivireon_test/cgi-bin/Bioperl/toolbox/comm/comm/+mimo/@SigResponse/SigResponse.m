classdef SigResponse < mimo.BaseClass
    %SigResponse returns a signal response object for MIMO channels
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    %   $Revision: 1.1.6.3 $  $Date: 2009/05/23 07:48:37 $
    
    %===========================================================================
    % Public properties
    properties
        % Signal domain
        Domain = 0;
        % Signal values
        Values = 0;
    end
    
    %===========================================================================
    % Public methods
    methods
        function sig = SigResponse(sigvalues, domain)
            %SigResponse  Construct a signal response.
            %
            %   Inputs:
            %     sigvalues  - vector of signal values.
            %     domain     - domain of signal.
            
            error(nargchk(0, 2, nargin));
            
            switch nargin
                case 0
                    sig.Values = 0;
                    sig.Domain = 0;
                case 1
                    sig.Values = sigvalues;
                    sig.Domain = 0:length(sigvalues)-1;
                case 2
                    sig.Values = sigvalues;
                    sig.Domain = domain;
            end
        end
        %-----------------------------------------------------------------------
        function h = copy(this)
            mc = metaclass(this(1));
            props = mc.Properties;
            
            for q=1:length(this)
                h(q) = mimo.SigResponse; %#ok<AGROW>

                for p=1:length(props)
                    pr = props{p};
                    if (~pr.Dependent && ~pr.Transient)
                        h(q).(pr.Name) = this(q).(pr.Name); %#ok<AGROW>
                    end
                end
            end
        end
    end
    
    %===========================================================================
    % Set/Get methods
    methods
        function set.Domain(this, x)
            propName = 'Domain';
            validateattributes(x, {'double'}, {'row'}, ...
                [class(this) '.' propName], propName);
            
            this.Domain = x;
        end
        %-----------------------------------------------------------------------
        function set.Values(this, x)
            propName = 'Values';
            validateattributes(x, {'double'}, {'row'}, ...
                [class(this) '.' propName], propName);
            
            this.Values = x;
        end
    end
end