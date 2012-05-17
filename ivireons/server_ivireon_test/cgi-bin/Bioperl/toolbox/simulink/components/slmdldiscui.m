function disctoolhandle = slmdldiscui(varargin)
% GUI for discretizing a simulink model
%
%

% $Revision: 1.6.4.6 $ $Date: 2009/05/14 17:50:12 $
% Copyright 1990-2008 The MathWorks, Inc.

if (~usejava('Swing'))
  error('Simulink:ModelDiscretizer:GraphicDiscretizerNotSupported', 'Simulink Graphical Discretizer is not supported in the current platform.');
end

persistent DISCWINDOW;

n = nargin;
import com.mathworks.toolbox.mdldisc.*;
[discrules, type] = rules;
ctlmsg = 'Transfer Function, State-Space, Zero-Pole, LTI Block cannot be discretized without Control System Toolbox!';
dspmsg = 'Variable Transport Delay cannot be discretized without Signal Processing Blockset.';
if(type == 3)
    callDiagnosticViewer(sprintf('No control toolbox and dsp blockset. \n%s\n%s',ctlmsg,dspmsg));
    return;
elseif(type == 2)
    callDiagnosticViewer(sprintf('No control toolbox. \n%s',ctlmsg));
    return;
elseif(type == 1)
%     themdl = varargin{1};
%     if hasVariableTransportDelay(themdl)
%         callDiagnosticViewer(sprintf('No dsp blockset. \n%s',dspmsg));
%     end
end

if isempty(DISCWINDOW)
  if n == 1
    sys = varargin{1};    
    if (isstr(sys) && ~isvarname(sys))
      error(sprintf(['''' sys '''' ' is an invalid model name specification']));
    end
    MDLDISC = MdlDisc(getdiscdata(sys));
    DISCWINDOW = MdlDiscWindow(MDLDISC);
    DISCWINDOW.show;    
  end
  if n == 0
    MDLDISC = MdlDisc;
    DISCWINDOW = MdlDiscWindow(MDLDISC);
    DISCWINDOW.show;    
  end
  mlock;
end

if n > 1
    param1 = varargin{1};
    param2 = varargin{2};   
    switch lower(param2)
    case 'create'
        if isempty(DISCWINDOW)
            if n == 3
                sys = varargin{3};
                if (isstr(sys) && ~isvarname(sys))
                  error(sprintf(['''' sys '''' ' is an invalid model name specification']));
                end
                MDLDISC = MdlDisc(getdiscdata(sys));
                DISCWINDOW = MdlDiscWindow(MDLDISC);
            else
                MDLDISC = MdlDisc;
                DISCWINDOW = MdlDiscWindow(MDLDISC);
            end
            mlock;
        end        
    case 'show'
        DISCWINDOW.show;
    case 'close'
        DISCWINDOW.dispose;
        DISCWINDOW= [];
        munlock;
        clear slmdldiscui;
      case 'close_temp'
        foundMDL = find_system('type','block_diagram','name', param2);
        if(~isempty(foundMDL))
            bdclose(param2,0)
        end         
     otherwise      
    end
end

if nargout > 0 
    disctoolhandle = DISCWINDOW;
end

%end function slmdldiscui

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% show error or warning message
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  callDiagnosticViewer(errorText, varargin)

dv = DAStudio.DiagnosticViewer('Simulink Model Discretizer');

msg = DAStudio.DiagnosticMsg;
msg.type = 'Warning';
if(isempty(varargin))
    msg.sourceFullName = 'Simulink Model Discretizer';
    msg.sourceName =  'Simulink Model Discretizer';
else
    blockHandle = varargin{1};
    msg.sourceFullName = getfullname(blockHandle);
    msg.sourceName =  get_param(blockHandle,'Name');
end
msg.component = 'Simulink Model Discretizer';

% Here populate the first message's contents
c = msg.Contents;
c.Type = 'Open';
c.details = errorText;
slashes = find(errorText==sprintf('\n'));
sumr = errorText(1:slashes(1)-1);
c.summary = sumr;
dv.addDiagnosticMsg(msg);

% here make the diagnostic viewer visible
dv.javaEngaged = 1;
dv.Visible = 1;

%end function callDiagnosticViewer

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Check if there are any variable transport delay blocks in the model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = hasVariableTransportDelay(themdl)

if isempty(find_system('SearchDepth', 0, 'Name', themdl)) ...
    &  isempty(find_system('SearchDepth', 0, 'handle', themdl))
   if exist(themdl) == 4
      load_system(themdl);
   end
end

if isempty(find_system(themdl, 'BlockType', 'VariableTransportDelay'))
    ret = 0;
else
    ret = 1;
end

% end function hasVariableTransportDelay

%[EOF] slmdldiscui.m
