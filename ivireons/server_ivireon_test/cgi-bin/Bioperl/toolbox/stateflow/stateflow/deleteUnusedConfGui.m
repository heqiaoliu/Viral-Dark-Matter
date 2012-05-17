function varargout = deleteUnusedConfGui(varargin)
% DELETEUNUSEDCONFGUI M-file for deleteUnusedConfGui.fig
%      DELETEUNUSEDCONFGUI, by itself, creates a new DELETEUNUSEDCONFGUI or raises the existing
%      singleton*.
%
%      H = DELETEUNUSEDCONFGUI returns the handle to a new DELETEUNUSEDCONFGUI or the handle to
%      the existing singleton*.
%
%      DELETEUNUSEDCONFGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DELETEUNUSEDCONFGUI.M with the given input arguments.
%
%      DELETEUNUSEDCONFGUI('Property','Value',...) creates a new DELETEUNUSEDCONFGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before deleteUnusedConfGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to deleteUnusedConfGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%   Copyright 2009 The MathWorks, Inc.

% Edit the above text to modify the response to help deleteUnusedConfGui

% Last Modified by GUIDE v2.5 02-Oct-2009 13:14:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @deleteUnusedConfGui_OpeningFcn, ...
                   'gui_OutputFcn',  @deleteUnusedConfGui_OutputFcn, ...
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


% --- Executes just before deleteUnusedConfGui is made visible.
function deleteUnusedConfGui_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to deleteUnusedConfGui (see VARARGIN)

% Choose default command line output for deleteUnusedConfGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

obj = varargin{1};
set(hObject, 'UserData', obj);
% UIWAIT makes deleteUnusedConfGui wait for user response (see UIRESUME)
% uiwait(handles.qbox);


% --- Outputs from this function are returned to the command line.
function varargout = deleteUnusedConfGui_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in delButton.
function delButton_Callback(hObject, eventdata, handles) %#ok<DEFNU,INUSD>
% hObject    handle to delButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
obj = get(get(hObject, 'Parent'), 'UserData');
delete(obj);
close(get(hObject, 'Parent'));

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(get(hObject, 'Parent'));

% --- Executes on button press in qPref.
function qPref_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to qPref (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of qPref
on = get(hObject, 'Value');
if(on)
    sfpref('showDeleteUnusedConfGui', 0);
end
