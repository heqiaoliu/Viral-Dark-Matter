function applystyle(this,varargin)
%APPLYSTYLE  Applies style settings to @waveform instance.

%  Author(s): John Glass
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:27:50 $
rdim = this.RowIndex; 
cdim = this.ColumnIndex; 
style = this.Style;

% Apply to each view
for ct=1:length(this.View)
    this.View(ct).applystyle(style,rdim,cdim,ct);
end

% Apply to wave characteristics
for c=this.Characteristics'
   for ct = 1:length(c.View)
      c.View(ct).applystyle(style,rdim,cdim,ct);
   end
end

% Update legend info
this.updateGroupInfo;