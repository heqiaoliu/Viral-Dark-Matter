function h = iotable(varargin)
%IOTABLE
%
%   Authors: James G. Owen
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/12/15 20:56:20 $

mlock
persistent thistable;
    
if nargin>=1
    % Create if table object if necessary
    if isempty(thistable)
        thistable = tsguis.iotable;
    end
    % (re)target table model to the right table 
    thistable.initialize(varargin{:})
end % Get the persistent var for debugging reasons   
h = thistable;
