function varargout = sfcdplayergui(varargin)
% SFCDPLAYERGUI M-file for sfcdplayergui.fig
%      SFCDPLAYERGUI, by itself, creates a new SFCDPLAYERGUI or raises the existing
%      singleton*.
%
%      H = SFCDPLAYERGUI returns the handle to a new SFCDPLAYERGUI or the handle to
%      the existing singleton*.
%
%      SFCDPLAYERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SFCDPLAYERGUI.M with the given input arguments.
%
%      SFCDPLAYERGUI('Property','Value',...) creates a new SFCDPLAYERGUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sfcdplayergui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sfcdplayergui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sfcdplayergui

% Last Modified by GUIDE v2.5 30-May-2008 11:45:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sfcdplayergui_OpeningFcn, ...
                   'gui_OutputFcn',  @sfcdplayergui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before sfcdplayergui is made visible.
function sfcdplayergui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sfcdplayergui (see VARARGIN)

% Choose default command line output for sfcdplayergui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

initialize_gui(hObject, handles, false);

% UIWAIT makes sfcdplayergui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sfcdplayergui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected object changed in unitgroup.
function unitgroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in unitgroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if (hObject == handles.english)
    set(handles.text4, 'String', 'lb/cu.in');
    set(handles.text5, 'String', 'cu.in');
    set(handles.text6, 'String', 'lb');
else
    set(handles.text4, 'String', 'kg/cu.m');
    set(handles.text5, 'String', 'cu.m');
    set(handles.text6, 'String', 'kg');
end

% --------------------------------------------------------------------
function initialize_gui(fig_handle, handles, isreset)


% --- Executes on button press in OFF.
function OFF_Callback(hObject, eventdata, handles)
% hObject    handle to OFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(~get(hObject,'Value'))
  % force the push button to stay down 
   set(hObject,'Value',1);
   return;
end
sfcdplayerhelper('set_radio_request',RadioRequestMode.OFF);
% Hint: get(hObject,'Value') returns toggle state of OFF



% --- Executes on button press in CD.
function CD_Callback(hObject, eventdata, handles)
% hObject    handle to CD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(~get(hObject,'Value'))
  % force the push button to stay down 
   set(hObject,'Value',1);
   return;
end
sfcdplayerhelper('set_radio_request',RadioRequestMode.CD);
% Hint: get(hObject,'Value') returns toggle state of CD


% --- Executes on button press in FM.
function FM_Callback(hObject, eventdata, handles)
% hObject    handle to FM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FM
if(~get(hObject,'Value'))
  % force the push button to stay down 
   set(hObject,'Value',1);
   return;
end
sfcdplayerhelper('set_radio_request',RadioRequestMode.FM);


% --- Executes on button press in AM.
function AM_Callback(hObject, eventdata, handles)
% hObject    handle to AM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AM
if(~get(hObject,'Value'))
  % force the push button to stay down 
   set(hObject,'Value',1);
   return;
end
sfcdplayerhelper('set_radio_request',RadioRequestMode.AM);


% --- Executes on button press in EJECT.
function EJECT_Callback(hObject, eventdata, handles)
% hObject    handle to EJECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of EJECT
sfcdplayerhelper('set_eject_disc');


% --- Executes on button press in STOP.
function STOP_Callback(hObject, eventdata, handles)
% hObject    handle to STOP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of STOP
if(~get(hObject,'Value'))
  % force the push button to stay down 
   set(hObject,'Value',1);
   return;
end
sfcdplayerhelper('set_cd_request',CdRequestMode.STOP);


% --- Executes on button press in PLAY.
function PLAY_Callback(hObject, eventdata, handles)
% hObject    handle to PLAY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PLAY
if(~get(hObject,'Value'))
  % force the push button to stay down 
   set(hObject,'Value',1);
   return;
end
sfcdplayerhelper('set_cd_request',CdRequestMode.PLAY);

% --- Executes on button press in REW.
function REW_Callback(hObject, eventdata, handles)
% hObject    handle to REW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of REW
if(~get(hObject,'Value'))
  % force the push button to stay down 
   set(hObject,'Value',1);
   return;
end
sfcdplayerhelper('set_cd_request',CdRequestMode.REW);


% --- Executes on button press in FF.
function FF_Callback(hObject, eventdata, handles)
% hObject    handle to FF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FF
if(~get(hObject,'Value'))
  % force the push button to stay down 
   set(hObject,'Value',1);
   return;
end
sfcdplayerhelper('set_cd_request',CdRequestMode.FF);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in InsertDisc.
function InsertDisc_Callback(hObject, eventdata, handles)
% hObject    handle to InsertDisc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sfcdplayerhelper('set_insert_disc');


% --- Executes on button press in EjectDisc.
function EjectDisc_Callback(hObject, eventdata, handles)
% hObject    handle to EjectDisc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sfcdplayerhelper('set_eject_disc');

