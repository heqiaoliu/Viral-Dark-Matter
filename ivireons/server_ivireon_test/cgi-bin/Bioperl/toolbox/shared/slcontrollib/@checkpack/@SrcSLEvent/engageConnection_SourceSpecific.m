function engageConnection_SourceSpecific(this) 
% ENGAGECONNECTION_SOURCESPECIFIC  overloaded
%
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/04/21 21:47:35 $

hSrc = this.ScopeCLI.ParsedArgs{1};
if isa(hSrc,'checkpack.checkblkviews.CheckBlockScopeVisData')
   %Set source properties based on parsed arguments
   this.EventSrc = hSrc;
   this.BlockHandle = handle(this.ScopeCLI.ParsedArgs{2});
   this.NameShort = this.BlockHandle.Name;
   this.Name = getFullName(this.BlockHandle);
      
   %Connect to object that will throw event
   this.Listener = {addlistener(hSrc,'DataChanged', @(hSrc,y) haveNewData(this,hSrc))};
   this.Data = checkpack.checkblkviews.SrcSLEventCoreData;
   
   %Connect source to controls status bar
   this.TimeStatus = this.Controls.StatusBar.findwidget({'StdOpts','Frame'});
   
   %Create listener for block deletion and save
   this.Listener = vertcat(this.Listener, ...
      {handle.listener(this.BlockHandle,'DeleteEvent', @(hSrc,hData) localDelete(this))}, ...
      {handle.listener(this.BlockHandle,'PreSaveEvent', @(hSrc,hData) localSave(this))});
   
   this.errorStatus = 'success';
   connectState(this);
else
   this.errorStatus = 'failure';
end
end

function localDelete(this)
%Helper function to manage block deletion events

this.Application.close
end

function localSave(this)
%Helper function to manage block save events

%Save viewer position with block
pos = get(this.Application.getGUI.WidgetHandle,'Position');
set(this.BlockHandle,'ViewDlgPos',mat2str(pos));
set(this.BlockHandle,'OpenViewOnLoad',get(this.Application.Parent,'Visible'));
end
