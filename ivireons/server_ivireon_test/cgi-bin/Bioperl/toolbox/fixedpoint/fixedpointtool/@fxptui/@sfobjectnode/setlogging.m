function setlogging(h, varargin)
%SETLOGGING Turn on/off signal logging on the underlying subsys node if any

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/08/08 12:52:56 $

 if(strcmp('All',varargin{2})) || strcmp('NAMED',varargin{2}) || strcmp('UNNAMED',varargin{2})
     hch = h.getHierarchicalChildren;
     for k = 1:length(hch)
         if isa(hch(k).daobject,'Simulink.SubSystem')
             % Turn on all signals in that system and then all signals under
             hch(k).setlogging(varargin{1},varargin{2},1);
             hch(k).setlogging(varargin{1},varargin{2},varargin{3});
         end
     end
end

% [EOF]
