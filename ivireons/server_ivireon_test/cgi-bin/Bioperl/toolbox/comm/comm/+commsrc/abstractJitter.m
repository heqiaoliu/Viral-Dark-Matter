classdef abstractJitter <  sigutils.sorteddisp & sigutils.pvpairs ...
         & sigutils.SaveLoad
%ABSTRACTJITTER Abstract class for jitter generators.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $  $Date: 2008/10/31 05:54:19 $

    %===========================================================================
    % Protected properties
    properties (SetAccess = protected)
        Type;   % Type of the class.  Read-only property.  Must be set at the 
                % construction time by the subclass.
    end

    %===========================================================================
    % Abstract public methods
    methods (Abstract)
        % Subclasses should implement this method to generate jitter.  The
        % method should accept number of output jitter samples.  Output is a
        % double vector of jitter samples.
        jitter = generate(this, N)
    end

end