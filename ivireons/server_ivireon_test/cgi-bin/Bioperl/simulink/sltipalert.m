function sltipalert(action, arg1, dialogtitle, helptag, prefkey, actionLabel, actionCall)
% SLTIPALERT Manages and displays the Simulink tip alert window
%
%   SLTIPALERT('CREATE', DIALOGDESC, DIALOGTITLE, HELPTAG, FEATURETIPPRESKEY, 
%               ATIONSTR, ACTION)
%    Creates the TipAlert dialog:
%      DIALOGDESC is the description of the feature tip
%      DIALOGTITLE is the dialog title
%      HELPTAG is the tag that the Help button should pass to the Simulink Help
%      FEATURETIPPRESKEY is the preference key setting
%      (optional parameters)
%      ACTIONSTR is the label to put on the action button.
%      ACTION is a cell array containing the function and arguments to give 
%             feval to perform some action. If actionstr is empty action is 
%             ignored.
%
%   SLTIPALERT('SHOW', FEATURETIPPRESKEY)  sets feature tip to on.
%   SLTIPALERT('NEVER', FEATURETIPPRESKEY) sets the feature tip to off.

%   Copyright 2001-2010 The MathWorks, Inc.
%   $Revision: 1.4.2.9 $

error(nargchk(2, 7, nargin));

if ~usejava('mwt')
    DAStudio.error('Simulink:tools:FunctionRequiresJava', mfilename);
end

action = lower(action);

switch (action)
  case 'create'
    % We need exactly 5 or 7 inputs for creating the dialog.  arg1 is the
    % message string.
    error(nargchk(5, 7, nargin));
    if nargin < 7
        error(nargchk(5,5, nargin));
        actionCall = {};
        actionLabel  = '';
    end
    
    pref = com.mathworks.services.Prefs.getBooleanPref(prefkey,true);
    if pref
        % Launch the TipAlert dialog
        i_create(arg1, dialogtitle, helptag, prefkey, actionLabel, actionCall);
    end
    
  case 'never'
    error(nargchk(2, 2, nargin));
    % arg1 is the Preference key
    com.mathworks.services.Prefs.setBooleanPref(arg1,0);
    
  case 'show'
    error(nargchk(2, 2, nargin));
    % arg1 is the Preference key
    com.mathworks.services.Prefs.setBooleanPref(arg1,1);
  otherwise
    DAStudio.error('Simulink:utility:invalidInputArgs',mfilename)

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  i_create( strDlgDesc, strTitle, strHelpTag, strPrefsKey, actionLabel, actionCall)

AlertFig=dialog(                                    ...
    'Visible'         ,'off'                       ,...
    'Name'            , strTitle                   ,...
    'Pointer'         ,'arrow'                     ,...
    'Units'           ,'points'                    ,...
    'UserData'        , strPrefsKey                ,...
    'IntegerHandle'   ,'off'                       ,...
    'Resize'          ,'off'                       ,...
    'WindowStyle'     ,'normal'                    ,...
    'HandleVisibility','callback'                  ,...
    'Tag'             ,'TipAlert'                   ...
);
set(AlertFig, 'KeyPressFcn', {@i_keypress,AlertFig});
set(AlertFig, 'DeleteFcn', {@i_delete,AlertFig});

BtnFontSize=get(0,'FactoryUIControlFontSize');
BtnFontName=get(0,'FactoryUIControlFontName');


% Buttons
OkButtonString=DAStudio.message('Simulink:dialog:DCDOK');
ButtonTag='OK';
ok_btn = uicontrol(AlertFig             ,...
    'Style'              ,'pushbutton'                      ,...
    'Units'              ,'points'                          ,...
    'String'             ,OkButtonString                    ,...
    'HorizontalAlignment','center'                          ,...
    'FontUnits'          ,'points'                          ,...
    'FontSize'           ,BtnFontSize                       ,...
    'FontName'           ,BtnFontName                       ,...
    'Tag'                ,ButtonTag                         ,...
    'Callback'           ,{@i_ok,AlertFig}              ,...
    'KeyPressFcn'        ,{@i_keypress,AlertFig}             ...
);
OkSize = get(ok_btn,'extent');
        
helpButtonString=DAStudio.message('Simulink:dialog:DCDHelp');
ButtonTag='Help';
help_btn = uicontrol(AlertFig               ,...
    'Style'                ,'pushbutton'        ,...
    'Units'                ,'points'            ,...
    'CallBack'             ,{@i_help}           ,...
    'String'               , helpButtonString   ,...
    'HorizontalAlignment'  ,'center'            ,...
    'FontUnits'            ,'points'            ,...
    'FontSize'             ,BtnFontSize         ,...
    'FontName'             ,BtnFontName         ,...
    'Tag'                  ,ButtonTag           ,...
    'UserData'             ,strHelpTag           ... 
);
HelpSize = get(help_btn,'extent');

if ~isempty(actionLabel)
    ButtonTag = 'Action';
    action_btn = uicontrol(AlertFig, ...
                           'Style'                ,'pushbutton'        ,...
                           'Units'                ,'points'            ,...
                           'CallBack'             ,{@i_action}         ,...
                           'String'               , actionLabel        ,...
                           'HorizontalAlignment'  ,'center'            ,...
                           'FontUnits'            ,'points'            ,...
                           'FontSize'             ,BtnFontSize         ,...
                           'FontName'             ,BtnFontName         ,...
                           'Tag'                  ,ButtonTag           ,...
                           'UserData'             ,actionCall           ... 
                           );
    ActionSize = get(action_btn,'extent');
else
    ActionSize = [0 0 0 0];
end

% Text control for the message
MsgHandle=uicontrol(AlertFig             ,...
    'Style'              ,'text'         ,...
    'Units'              ,'points'       ,...
    'Tag'                ,'strDlgDesc'   ,...
    'FontUnits'          ,'points'       ,...
    'FontSize'           ,BtnFontSize    ,...
    'FontName'           ,BtnFontName    ,...
    'HorizontalAlignment','left'          ...
);

% Checkbox
dontShowAgainStr = DAStudio.message(...
    'Simulink:utility:DoNotShowThisMessageAgain');
checkbox = uicontrol(AlertFig                      ,...
    'Style'              ,'checkbox'               ,...
    'Units'              ,'points'                 ,...
    'String'             , dontShowAgainStr        ,...  
    'Tag'                ,'DontShowAgain'          ,...
    'HorizontalAlignment','left'         , ...    
    'FontUnits'          ,'points'       , ...
    'FontWeight'         ,'bold'         , ...
    'FontSize'           ,BtnFontSize    , ...
    'FontName'           ,BtnFontName     ...
);

% Now calculate positions.  First determine how wide the message will be if
% we allow 65 columns.
[MsgString,MsgSize] = textwrap(MsgHandle,cellstr(strDlgDesc),65);
MsgPos = [10 60 MsgSize(3) MsgSize(4)];
set(MsgHandle,'String',MsgString,'Position',MsgPos);

% Now the button sizes.
% Allow enough columns that the checkbox doesn't try to wrap.
[~,CheckboxSize] = textwrap(checkbox,cellstr(dontShowAgainStr),...
    numel(dontShowAgainStr)+1);

xPadding = 10;
yPadding = 7;

CheckboxWidth = CheckboxSize(3) + 20;
BtnWidth = max([OkSize(3), HelpSize(3), ActionSize(3)])+ 20;
BtnHeight = max([OkSize(4), HelpSize(4), ActionSize(4)]) + 3;

% Allow enough space for the wider of the message,the checkbox, or the buttons
FigWidth = max([MsgSize(3),CheckboxWidth, (BtnWidth*3 + xPadding*2)]) + (xPadding*2);

% Position the buttons at the bottom right.
set(help_btn, 'Position', ...
    [FigWidth - BtnWidth - xPadding, yPadding, BtnWidth, BtnHeight]);
set(ok_btn, 'Position', ...
    [FigWidth - (BtnWidth*2) - (xPadding*2), yPadding, BtnWidth, BtnHeight]);

if ~isempty(actionLabel)
    set(action_btn,'Position', ...
        [FigWidth - ((BtnWidth + xPadding) *3), yPadding, BtnWidth, BtnHeight]);           
end

yCounter = yPadding*2 + BtnHeight;
% Position the checkbox above them, at the left hand side.
set(checkbox, 'Position', ...
    [xPadding, yCounter, CheckboxWidth, CheckboxSize(4)]);

yCounter = yCounter + CheckboxSize(4) + yPadding;
% Position the message above that, at the left hand size.
set(MsgHandle, 'Position', ...
    [xPadding, yCounter, MsgSize(3), MsgSize(4)]);

yCounter = yCounter + MsgSize(4) + yPadding;

FigHeight = yCounter;

FigPos=get(0,'DefaultFigurePosition');
FigPos(3:4)=[FigWidth FigHeight];

% Use screen size to position the Figure              
ScreenUnits=get(0,'Units');
set(0,'Units','points');
ScreenSize=get(0,'ScreenSize');
set(0,'Units',ScreenUnits);

FigPos(1)=(ScreenSize(3)-FigWidth)/2;
FigPos(2)=(ScreenSize(4)-FigHeight)/2;

set(AlertFig ,'Position',FigPos);
set(AlertFig ,'Visible','on');
drawnow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_help(fig, ~)

% Our help tag is the user data on the Help button.
handles = guihandles(fig);
helptag = get(handles.Help,'UserData');
helpview(fullfile(docroot,'mapfiles','simulink.map'), helptag)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_ok(~,~,fig)

% Our preferences key is the user data on the figure itself
handles = guihandles(fig);
strPrefsKey = get(handles.TipAlert,'UserData');
if (get(handles.DontShowAgain,'Value'))
    com.mathworks.services.Prefs.setBooleanPref(strPrefsKey,0)
else
    com.mathworks.services.Prefs.setBooleanPref(strPrefsKey,1)
end
i_delete([],[],fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_delete(~,~,fig)

delete(fig);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return and space dismiss the dialog as if "OK" was clicked.  Escape
% dismissed the dialog as if the "x" in the top-right was clicked.  This
% means that we ignore the state of the "Don't show again" checkbox.
function i_keypress(~,evd,fig)
switch(evd.Key)
  case {'return','space'}
      i_ok([],[],fig);
  case 'escape'
      i_delete([],[],fig);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function i_action(obj, ~)

action = get(obj,'UserData');
feval(action{:});
fig = get(obj,'parent');
i_ok([],[], fig);

% LocalWords:  DIALOGDESC DIALOGTITLE HELPTAG FEATURETIPPRESKEY ATIONSTR
% LocalWords:  ACTIONSTR actionstr mwt UI DCDOK DCD Dlg Dont mapfiles
