function setElement(x,val,varargin)
%SETELEMENT Internal use only: set an individual indexed element of x to a given value (val)
%   setElement(x, val, index1, index2, ... , indexN) sets an individual
%   indexed element of x at the position specified by the set of indices
%   (index1, index2, .. indexN), to the value specified by 'val'. 'val' may
%   be a fi object or a double.  
%   This function helps to bypass the indexing issue with Fi objects 
%   (see record ID 549571).
%
%   Example:
%   For an example, see getElement.
%
%   See also EMBEDDED.FI/GETELEMENT

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/28 20:18:57 $

error(nargchk(3,inf,nargin));
if ~isscalar(val)
    error('fi:setElement:valMustBeScalar','Value input must be a scalar');
end
overall_idx = elementGetSetChecksAndSingleIndex(x, varargin{:});
x.set_element(overall_idx,val);
