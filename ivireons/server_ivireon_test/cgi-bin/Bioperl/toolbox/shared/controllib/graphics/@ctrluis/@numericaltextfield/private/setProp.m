function setProp(this,prop,propValue) 
% FINDPROP private method to return property value
%
 
% Author(s): A. Stothert 17-Mar-2006
% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:51 $

errStr = '';
switch lower(prop)
   case 'backgroundcolor'
      newColor = java.awt.Color(...
         propValue(1), ...
         propValue(2), ...
         propValue(3));
      awtinvoke(java(this.hJava),'setBackground(Ljava.awt.Color;)',newColor)
   case 'children'
      errStr = sprintf('Cannot set the ''Children'' property of a numerical text field.');
   case 'enable'
      awtinvoke(java(this.hJava),'setEnabled(Z)',localStr2Bool(propValue))
   case 'extent'
      pos = get(this.hContainer,'position');
      pos(3:4) = propValue(3:4);
      set(this.hContainer,'position',pos);
   case 'fontangle'
      this.hJava.setFontAngle(propValue)
   case 'fontsize'
      this.hJava.setFontSize(propValue)
   case 'fontweight'
      this.hJava.setFontWeight(propValue)
   case 'foregroundcolor'
      newColor = java.awt.Color(...
         propValue(1), ...
         propValue(2), ...
         propValue(3));
      awtinvoke(java(this.hJava),'setForeground(Ljava.awt.Color;)',newColor)
   case 'handlevisibility'
      set(this.hContainer,'handlevisibility',propValue);
   case 'parent'
      set(this.hContainer,'parent',propValue)
   case 'position'
      set(this.hContainer,'position',propValue);
   case 'string'
      this.hJava.setText(propValue);
   case 'tag'
      this.hJava.setName(propValue);
      set(this.hContainer,'Tag',propValue);
   case 'tooltipstring'
      awtinvoke(java(this.hJava),'setToolTipText(Ljava.lang.String;)',propValue);
   case 'units'
      set(this.hContainer,'units',propValue);
   case 'userdata'
      this.UserData = propValue;
   case 'value'
      this.hJava.setValue(propValue);
   case 'visible'
      awtinvoke(java(this.hJava),'setVisible(Z)',localStr2Bool(propValue));
   case {'fontunits', 'fontname','hittest', 'horizontalalignment', 'max', 'min', 'style', 'selected'}
         errStr = sprintf('Cannot set the ''%s'' property of a numerical text field.',prop);      
   otherwise
      errStr = sprintf('There is no ''%s'' property for numerical text fields.',prop);
end

if ~isempty(errStr)
    ctrlMsgUtils.error('Controllib:general:UnexpectedError',errStr);
end

%--------------------------------------------------------------------------
function bool = localStr2Bool(str)

if strcmpi(str,'on'), bool = true;
else bool = false;
end
      

      