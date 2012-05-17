function setlogging(h, varargin)
%LOGREFERENCED turn signal logging on for all logged signals in this
%instance of the referenced model

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/07/31 20:00:20 $

if(strcmp('OUTPORT', varargin{2}))
  h.setlogging_outports(varargin{1});
  return;
end
h.daobject.DefaultDataLogging = varargin{1};

% [EOF]
