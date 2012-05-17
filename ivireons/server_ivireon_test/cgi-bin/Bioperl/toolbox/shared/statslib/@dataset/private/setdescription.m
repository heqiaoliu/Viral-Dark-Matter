function a = setdescription(a,newdescr)
%SETDESCRIPTION Set dataset array Description property.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2009/05/07 18:27:34 $

if nargin < 2
    error('stats:dataset:setdescription:TooFewInputs', ...
          'Requires at least two inputs.');
end

if nargin == 2
    if isempty(newdescr)
        a.props.Description = '';
        return
    end
    a.props.Description = newdescr;
end
