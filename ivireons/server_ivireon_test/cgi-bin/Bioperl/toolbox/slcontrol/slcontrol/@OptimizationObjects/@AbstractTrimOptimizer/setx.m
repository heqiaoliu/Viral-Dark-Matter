function xstruct = setx(this,x)
% SETX  Set the state structure given the states in a vector.  
%
 
% Author(s): John W. Glass 01-Mar-2005
% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/11/17 14:03:53 $

% Get the state structure
xstruct = this.statestructure;

% Loop over the structure elements to specify their values
offset = 0;
if ~isempty(xstruct)
    for ct = 1:length(xstruct.signals)
        xstruct.signals(ct).values = x((1:xstruct.signals(ct).dimensions)+offset);
        offset = offset + xstruct.signals(ct).dimensions;
    end
end