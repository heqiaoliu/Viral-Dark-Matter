function  varargout = manswitch(varargin)
%MANSWITCH Manual switch helper function.

%   Author(s): D. Orofino, L.Dean
%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.17.2.14 $

% NOTE: The Manual Switch block's open function sets
%       action='1'.  Otherwise, it is '0'.

if (nargin==2)
    msg = manswitcherrorhandler(varargin{1},varargin{2});
    varargout{1} = msg;
    return; 
elseif (nargin==1)
    switch varargin{1}
      case 'Open'
        if strcmp(get_param(bdroot(gcbh),'BlockDiagramType'),'library') && ...
                strcmp(get_param(bdroot(gcbh),'Lock'),'on'),
            errordlg(['Manual Switch block must be placed in a model or ' ...
                      'unlocked library in order to operate.'])
        else
            blk = gcbh;
            mdl = bdroot(blk);
            if(~isFlipActionAllowed(mdl))
                [x,y] = manSwitchGetIconValues(blk, get_param(blk,'sw'));
                varargout{1} = x;
                varargout{2} = y;
                return
            end
            set_param(gcbh,'action','1');
        end
    end
    
    return
end

blk = gcbh;
sw  = get_param(blk,'sw');

if (sw ~= '0' && sw ~= '1')
    %tmp = display('Warning: Any nonzero input for parameter ''sw'' will be considered as ''1''.');
    sw = '1';
    set_param(blk,'sw','1');
end
    

% Only toggle switch if OpenFcn got us here:
if (get_param(blk,'action') == '1'),
  set_param(blk,'action','0');
  if sw=='1', sw='0'; else sw='1'; end
  set_param(blk,'sw',sw);
end

switchBlock=find_system(blk            , ...
                      'LookUnderMasks','all' , ...
                      'FollowLinks'   ,'on'  , ...
                      'Name'          ,'SwitchControl'  ...
                      );

if isempty(switchBlock)
  sfcnBlock= find_system(blk            , ...
                          'LookUnderMasks','all' , ...
                          'FollowLinks'   ,'on'  , ...
                          'Name'          ,'SimValue'  ...
                          );
else 
  sfcnBlock = [];
end

if ~isempty(switchBlock)
  if sw=='1'
    newSwitchVal = 'uint8(0)';
  else
    newSwitchVal = 'uint8(1)';
  end
  % Returns true if the switch parameter can be changed
  reduced =  sl('getIsBlockReducedAtSim', switchBlock);
  if ~reduced
    % Only do the switch if the value changes.
    curSwitchVal = get_param(switchBlock,'Threshold');
    if (~strcmp(newSwitchVal, curSwitchVal))
        set_param(switchBlock,'Threshold', newSwitchVal);
    end
  end
  set_param(switchBlock,'OutputVariableDimensions',get_param(blk,'varsize'));

elseif ~isempty(sfcnBlock)
    rtwblk = sprintf('%s/RTWValue',gcb);
    set_param(sfcnBlock,'Parameters',['boolean(',sw,')']);
    try
      % protect against inline parameters
      set_param(rtwblk,'Value',['boolean(',sw,')']);
    catch %#ok<CTCH>
    end
else
  stepBlock=find_system(blk            , ...
			'LookUnderMasks','all' , ...
			'FollowLinks'   ,'on'  , ...
			'Name'          ,'Step'  ...
			);
  if ~isempty(stepBlock)
    set_param(stepBlock,'After',sw);
  else
    constBlock=find_system(blk            , ...
			   'LookUnderMasks','all' , ...
			   'FollowLinks'   ,'on'  , ...
			   'BlockType'     ,'Constant'  ...
			   );
    if ~isempty(constBlock)
      set_param(constBlock,'Value',sw)
    end
  end
  DAStudio.warning('Simulink:blocks:oldVersionOfManualSwitchBlock', strrep(getfullname(blk),sprintf('\n'),' '));

end
[x,y] = manSwitchGetIconValues(blk,sw);
varargout{1} = x;
varargout{2} = y;

% [EOF] manswitch.m


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% manSwitchGetIconValues %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x,y] = manSwitchGetIconValues(blk, sw)
% Construct switch icon:
%
% --- Switch stub circles:
BlockPos=get_param(blk,'Position');
Width=BlockPos(3)-BlockPos(1);
Height=BlockPos(4)-BlockPos(2);

PortInfo=get_param(blk,'PortConnectivity');
PortPos=cat(1,PortInfo.Position);
% Port locations in global Simulink coordinates
x=PortPos(:,1);
y=PortPos(:,2);
% Move locations inside of block icon (still global coordinates)
x = x + 5*(x < BlockPos(1)) - 5*(x > BlockPos(3));
y = y + 5*(y < BlockPos(2)) - 5*(y > BlockPos(4));
% Convert to plot coordinates
x = x - BlockPos(1);
y = BlockPos(4) - y;
PortPos=[x y];

Radius=ceil(min(Height,Width)/15);
LineLength=min(6,10*Radius/3);
Offset=Radius+LineLength;

switch get_param(blk,'Orientation'),
  case 'down',
    OutportX=PortPos(3,1);
    OutportY=PortPos(3,2)+Offset;
    Inport1X=PortPos(1,1);
    Inport1Y=PortPos(1,2)-Offset;
    Inport2X=PortPos(2,1);
    Inport2Y=PortPos(2,2)-Offset;
    ConnectLinesX=[Inport1X Inport1X NaN ...
                   Inport2X Inport2X NaN ...
                   OutportX OutportX ];
    ConnectLinesY=[Height-LineLength Height     NaN ...
                   Height-LineLength Height     NaN ...
                   0                 LineLength ];
    FlapiX=OutportX;
    FlapiY=OutportY+Radius;

    if sw=='0',
      [FlapfX,FlapfnY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport2X,Inport2Y,Radius,'XLow');
    else
      [FlapfX,FlapfnY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport1X,Inport1Y,Radius,'XHigh');
    end
    FlapfY=FlapfnY+3*Radius/4;
    FlapfX=FlapiX+(FlapfX-FlapiX)*(abs(FlapfY-FlapiY)/abs(FlapfnY-FlapiY));

  case 'up',
    OutportX=PortPos(3,1);
    OutportY=PortPos(3,2)-Offset;
    Inport1X=PortPos(1,1);
    Inport1Y=PortPos(1,2)+Offset;
    Inport2X=PortPos(2,1);
    Inport2Y=PortPos(2,2)+Offset;
    ConnectLinesX=[Inport1X Inport1X NaN ...
                   Inport2X Inport2X NaN ...
                   OutportX OutportX ];
    ConnectLinesY=[0                 LineLength NaN ...
                   0                 LineLength NaN ...
                   Height-LineLength Height     ];

    FlapiX=OutportX;
    FlapiY=OutportY-Radius;

    if sw=='0',
      [FlapfX,FlapfnY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport2X,Inport2Y,Radius,'XLow');
    else
      [FlapfX,FlapfnY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport1X,Inport1Y,Radius,'XHigh');
    end
    FlapfY=FlapfnY-3*Radius/4;
    FlapfX=FlapiX+(FlapfX-FlapiX)*(abs(FlapfY-FlapiY)/abs(FlapfnY-FlapiY));

  case 'left',
    OutportX=PortPos(3,1)+Offset;
    OutportY=PortPos(3,2);
    Inport1X=PortPos(1,1)-Offset;
    Inport1Y=PortPos(1,2);
    Inport2X=PortPos(2,1)-Offset;
    Inport2Y=PortPos(2,2);
    ConnectLinesX=[Width-LineLength Width      NaN ...
                   Width-LineLength Width      NaN ...
                   0                LineLength ];
    ConnectLinesY=[Inport1Y Inport1Y NaN ...
                   Inport2Y Inport2Y NaN ...
                   OutportY OutportY ];
    FlapiX=OutportX+Radius;
    FlapiY=OutportY;

    if sw=='0',
      [FlapfnX,FlapfY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport2X,Inport2Y,Radius,'YHigh');
    else
      [FlapfnX,FlapfY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport1X,Inport1Y,Radius,'YLow');
    end
    FlapfX=FlapfnX+3*Radius/4;
    FlapfY=FlapiY+(FlapfY-FlapiY)*(abs(FlapfX-FlapiX)/abs(FlapfnX-FlapiX));

  case 'right',
    OutportX=PortPos(3,1)-Offset;
    OutportY=PortPos(3,2);
    Inport1X=PortPos(1,1)+Offset;
    Inport1Y=PortPos(1,2);
    Inport2X=PortPos(2,1)+Offset;
    Inport2Y=PortPos(2,2);
    ConnectLinesX=[0                LineLength NaN ...
                   0                LineLength NaN ...
                   Width-LineLength Width      ];
    ConnectLinesY=[Inport1Y Inport1Y NaN ...
                   Inport2Y Inport2Y NaN ...
                   OutportY OutportY ];

    FlapiX=OutportX-Radius;
    FlapiY=OutportY;

    if sw=='0',
      [FlapfnX,FlapfY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport2X,Inport2Y,Radius,'YHigh');
    else
      [FlapfnX,FlapfY] = ...
        LocalCalcRot(FlapiX,FlapiY,Inport1X,Inport1Y,Radius,'YLow');
    end
    FlapfX=FlapfnX-3*Radius/4;
    FlapfY=FlapiY+(FlapfY-FlapiY)*(abs(FlapfX-FlapiX)/abs(FlapfnX-FlapiX));
end

t=(0:20)/20*2*pi;   CircX=cos(t)*Radius;   CircY=sin(t)*Radius;
AllCircX=[CircX+Inport1X NaN CircX+Inport2X NaN CircX+OutportX ];
AllCircY=[CircY+Inport1Y NaN CircY+Inport2Y NaN CircY+OutportY ];

% --- Switch Flap:
FlapX=[FlapiX FlapfX];
FlapY=[FlapiY FlapfY];

% --- Icon coordinate vectors:
x=[ConnectLinesX NaN AllCircX NaN FlapX];
y=[ConnectLinesY NaN AllCircY NaN FlapY];




%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalCalcRot %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%
function [X,Y]=LocalCalcRot(FlapX,FlapY,CircX,CircY,Radius,LowHigh)

% (CircX-X)^2+(CircY-Y)^2=Radius^2
% (FlapX-CircX)(X-CircX)+(FlapY-CircX)(Y-CircY)=Radius^2
%
% Solving:

R2=Radius^2;

S = (FlapY-CircY)/(FlapX-CircX);
S2=S^2;

b = R2/(FlapY-CircY);
c = (CircY^2)+((b^2)*S2-R2+2*CircY*b*S2)/(S2+1);
d = CircY+b*S2/(S2+1);

pmterm=sqrt(d^2-c);
Yminus = d-pmterm;
Yplus  = d+pmterm;

Xminus = R2/(FlapY-CircY)*S-Yminus*S+CircY*S+CircX;
Xplus  = R2/(FlapY-CircY)*S-Yplus*S+CircY*S+CircX;

switch LowHigh,
  case 'XLow',
    if Xminus<Xplus,
      X=Xminus;Y=Yminus;
    else
      X=Xplus;Y=Yplus;
    end

  case 'YLow',
    if Yminus<Yplus,
      X=Xminus;Y=Yminus;
    else
      X=Xplus;Y=Yplus;
    end

  case 'XHigh',
    if Xminus>Xplus,
      X=Xminus;Y=Yminus;
    else
      X=Xplus;Y=Yplus;
    end

  case 'YHigh',
    if Yminus>Yplus,
      X=Xminus;Y=Yminus;
    else
      X=Xplus;Y=Yplus;
    end

end  % switch

%%%%%%%%%%%%%%%%%%%%%%%%%%
%  isFlipActionAllowed   %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = isFlipActionAllowed(mdl)
% Returns true if the icon should be changed
out =  sl('getModelSimStateTunability', mdl);

% end of isFlipActionAllowed

%*********************************************************************
% Function Name:    manswitcherrorhandler
% Description:      Deal with errors in the block
% Inputs:           block handle and ID
% Return Values:    New message
%*********************************************************************
function msg = manswitcherrorhandler(blk, id)
% Error callback function (ErrFcn) for manual switch

% If we are not producing any error return the last error
lerr = sllasterror;
msg = lerr.Message;

% Check for error thrown from the internal switch block
try 
    fname = [lerr.MessageID];
    findstrStatus = findstr(fname,'SwitchTurnOnVarDimsMode');
    if(~isempty(findstrStatus))
        msg = DAStudio.message('Simulink:blocks:SlSwitchTurnOnVarDimsMode');
    end
catch
end
