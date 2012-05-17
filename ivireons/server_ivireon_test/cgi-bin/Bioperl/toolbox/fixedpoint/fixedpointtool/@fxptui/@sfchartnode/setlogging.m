function setlogging(h, varargin)
%LOGREFERENCED turn signal logging on for all logged signals in this
%instance of the referenced model

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/08 12:52:53 $


if(strcmp('OUTPORT', varargin{2}))
  h.setlogging_outports(varargin{1});
  return;
end

if strcmp('All',varargin{2}) || strcmp('NAMED',varargin{2}) || strcmp('UNNAMED',varargin{2})
  ch = h.getHierarchicalChildren;
  for i = 1:length(ch)
      if isa(ch(i).daobject,'Simulink.SubSystem')
          % If the child is a simulink subsystem, turn on logging in that system first.
          ch(i).setlogging(varargin{1},varargin{2},1);
      end
      hch = ch(i).getHierarchicalChildren;
      for k = 1:length(hch)
          if ~isempty(find(hch(k).daobject,'-isa','Simulink.SubSystem'))
              hch(k).setlogging(varargin{1},varargin{2},varargin{3});
          end
      end
  end
end

% All stateflow signals are named. So, if you are enabling logging of unnamed signals,
% skip this part.
if ~strcmp(varargin{2},'UNNAMED')
    blk = fxptds.getpath(h.daobject.getFullName);
    sigprops = get_param(blk, 'AvailSigsInstanceProps');
    for idx = 1:numel(sigprops.Signals)
        sigprops.Signals(idx).LogSignal = strcmpi('On', varargin{1});
    end
    set_param(blk, 'AvailSigsInstanceProps', sigprops);
end


% [EOF]
