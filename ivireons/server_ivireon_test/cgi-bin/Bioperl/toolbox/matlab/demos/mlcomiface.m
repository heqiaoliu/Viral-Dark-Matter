%% Programming with COM on Windows(R)
% Component Object Model (COM), is a set of object-oriented technologies and
% tools that enable software developers to integrate application-specific
% components from different vendors into their own application solution.
%
% COM helps in integrating significantly different features into one
% application in a relatively easy manner. For example, using COM, a
% developer may choose a database access component by one vendor, a business
% graph component by another, and integrate these into a mathematical
% analysis package produced by yet a third.
%
% COM provides a framework for integrating reusable, binary software
% components into an application. Because components are implemented with
% compiled code, the source code may be written in any of the many
% programming languages that support COM. Upgrades to applications are
% simplified, as components can be simply swapped without the need to
% recompile the entire application. In addition, a component's location is
% transparent to the application, so components may be relocated to a 
% separate process or even a remote system without having to modify the
% application.
%
% Automation is a method of communication between COM clients and servers.
% It uses a single, standard COM interface called IDispatch. This interface
% enables the client to find out about, and invoke or access, methods and
% properties supported by a COM object. A client and server that
% communicate using IDispatch are known as an Automation client and
% Automation server. IDispatch is the only interface supported by MATLAB(R).
% Custom and dual interfaces are not supported. MATLAB can communicate with
% both Automation servers and controls.

% Copyright 1984-2008 The MathWorks, Inc.
% $Revision: 1.5.4.15 $ $Date: 2009/12/31 18:51:20 $

%% Demo Requirements
% This demo runs on Windows(R) systems only. 
%
% The MWSamp2 object is already registered during MATLAB installation. 
% However to get a better overview of how to work with COM components 
% in general, it is assumed in this demo that the user has to register the 
% control. It is also assumed that regsvr32.exe is located on the DOS path.
% The following are the steps needed to register a component on your
% machine. 
% 
% 1. Run the command "regsvr32 < path >" where < path > indicates the full
%    path to the ocx/dll file supplied with the component.
%
% 2. Restart MATLAB.

cmd = sprintf('regsvr32 /s "%s"', ...
    fullfile(matlabroot,'toolbox','matlab','winfun',computer('arch'),'mwsamp2.ocx'));

[s,c] = dos(cmd);
%
% This demo also requires Microsoft(R) Excel(R).

if ~ispc
  errordlg('COM Demonstration is for PC only.')                
  return                                                                  
end 

%% Creating COM Objects in MATLAB(R)
% The following commands create an Automation control object and an
% Automation server object in MATLAB:

% Create an Automation control object and put it in a figure.
hf = figure;
title('ActiveX Sample Control') 
set(gca,'Xtick',[],'Ytick',[],'Box','on')
fp = get(hf,'Position');
mwsampPosition = get(hf,'DefaultAxesPosition').*fp([3 4 3 4]) ;
mwsamp = actxcontrol('MWSAMP.MwsampCtrl.2', mwsampPosition+1, hf)

% Create an Automation server object.
hExcel = actxserver('excel.application')


%% Displaying Properties of COM Objects 
% The properties of COM objects can be displayed to the MATLAB command
% window using the GET function, and are displayed graphically using the
% property inspector. For a demonstration of the property inspector, take a
% look at the Graphical Interface section of this demo.

get(mwsamp)


%% Changing COM Object Properties
% Properties of a COM object can be changed using the SET function.

% This makes the Excel(R) Automation server application visible.
set(hExcel,'Visible',1)

%%
% The SET function returns a structure array if only the handle to the COM
% Object is passed as an argument.

out = set(mwsamp)

%%
% You can also use the SET function to simultaneously change multiple
% properties of COM objects.

set(mwsamp,'Label','Mathworks Sample Control','Radius',40)


%% Displaying and Changing Enumerated Property Types
% You can display and change properties with enumerated values using the SET
% and GET functions.

get(hExcel,'DefaultSaveFormat')

%%
% The SET function can be used to display all possible enumerated values for
% a specific property.

set(hExcel,'DefaultSaveFormat')

%%
% The SET function also enables you to set enumerated values for properties
% that support enumerated types.

set(hExcel,'DefaultSaveFormat','xlWorkbookNormal');


%% Creating Custom Properties for a COM Object
% You can create custom properties for a COM object in MATLAB. For
% instance, you can make the handle to the Excel COM object a property of
% the MWSamp2 control and also make the handle to the MWSamp2 control a
% property of the Excel COM Object.

addproperty(mwsamp,'ExcelHandle');
addproperty(hExcel,'mwsampHandle');
addproperty(mwsamp,'TestValue');

%%

set(mwsamp,'ExcelHandle',hExcel);
set(mwsamp,'TestValue',rand);
set(hExcel,'mwsampHandle',mwsamp);

%%

get(hExcel,'mwsampHandle')

%%

get(mwsamp,'ExcelHandle')

%%

get(mwsamp,'TestValue')

%%
% Custom properties that are created using the ADDPROPERTY function can also
% be removed.

deleteproperty(mwsamp,'TestValue');


%% Displaying Methods of COM Objects
% You can display methods of COM objects in MATLAB by using the INVOKE,
% METHODS and METHODSVIEW functions. METHODSVIEW provides a way to view the
% methods to the COM objects graphically. For a demonstration of the
% METHODSVIEW function, take a look at the Graphical Interface section of
% this demo.

invoke(hExcel)

%%

methods(mwsamp)

%%
% Calling methods of COM objects can be done in one of the following ways:
%
% Using the INVOKE function

hExcelWorkbooks = get(hExcel,'Workbooks');
hExcelw = invoke(hExcelWorkbooks, 'Add');

%%
% Using the method name

hExcelRange = Range(hExcel,'A1:D4');
set(hExcelRange,'Value',rand(4));


%% Passing Arguments by Reference
% Certain COM Objects expose methods with arguments that are also used as
% output. This is referred to as by-reference argument passing. In MATLAB,
% this is achieved by sending the output as the return from calling the
% method. 
%
% The GetFullMatrix method of a MATLAB Automation server is an example of a
% COM method that accepts arguments by reference. This example illustrates
% how passing arguments by reference is achieved in MATLAB.

% Register MATLAB session as the automation server version.
regmatlabserver;

hmatlab = actxserver('matlab.application.single')

%%

invoke(hmatlab)

%%

get(hmatlab)

%%
% Interact with the MATLAB running as an Automation server using the
% PutFullMatrix, Execute, and GetFullMatrix methods.

hmatlab.Execute('B2 = round(100*rand(1+round(10*rand)))');

%%
% In the next step, you can determine the size of the array to get from the
% MATLAB Automation server without needing to check manually.

Execute(hmatlab,'[r,c] = size(B2); B2_size = [r,c];');
[B_size, z_none] = GetFullMatrix(hmatlab,'B2_size','base',[0 0],[0,0]);

%%
% Since the size has been determined, you can just get the B2 data using the
% GetFullMatrix method.

[B, z_none] = GetFullMatrix(hmatlab,'B2','base',zeros(B_size),[0,0])

%%

delete(hmatlab)


%% Event Handling
% Events associated with Automation controls can be registered with event
% handler routines, and also unregistered after the Automation control
% object has been created in MATLAB. 

events(hExcel)

%%
% The following command registers five of the supported events for MWSamp2
% to the event handler, e_handler.m.

dbtype e_handler.m 1:3

%%

registerevent(mwsamp, {'Click' 'e_handler';...
   'DblClick' 'e_handler';...
   'MouseDown' 'e_handler';...
   'Event_Args' 'e_handler'})
eventlisteners(mwsamp)

%%
% Another way of doing this would be to first register all the events, and
% then unregister the events that are not needed. First, restore the
% Automation control to its original state before any events were
% registered.

unregisterallevents(mwsamp)
eventlisteners(mwsamp)

%%
% Now register all the events that this COM object supports to the event
% handler, e_handler.m.

registerevent(mwsamp,'e_handler')
eventlisteners(mwsamp)

%%
% Next unregister any events you will not be needing.

unregisterevent(mwsamp,{'Event_Args' 'e_handler';...
   'MouseDown' 'e_handler'})
eventlisteners(mwsamp)


%% Error Handling
% If there is an error when invoking a method, the error thrown shows the
% source, a description of the error, the source help file, and help context
% ID, if supported by the COM Object.

set(hExcelw,'Saved',1);
invoke(hExcelWorkbooks,'Close')
try
    Open(hExcelWorkbooks,'thisfiledoesnotexist.xls')
catch e
    disp(e.message)
end

%% Destroying COM Objects
% COM objects are destroyed in MATLAB when the handle to the object or the
% handle to one of the object's interfaces is passed to the DELETE function.
% The resources used by a particular object or interface are released when
% the handle of the object or interface is passed to the RELEASE function.
%
% By displaying the contents of the MATLAB workspace using the WHOS command,
% you can observe the COM object and interface handles before and after
% using the RELEASE and DELETE functions.

whos mwsamp hExcel

%%

release(hExcelw)
whos mwsamp hExcel

%%

Quit(hExcel)
delete(hExcel);
delete(mwsamp);
close
whos mwsamp hExcel


displayEndOfDemoMessage(mfilename)
