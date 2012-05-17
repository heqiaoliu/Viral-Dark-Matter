function propValue = findProp(this,prop) 
% FINDPROP private method to return property value
%
 
% Author(s): A. Stothert 17-Mar-2006
% Copyright 2006-2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:16:50 $

switch lower(prop)
   case 'backgroundcolor'
      propValue = this.hJava.getBackground;
      propValue = [...
         propValue.getRed, ...
         propValue.getGreen, ...
         propValue.getBlue]/255;
   case 'children'
      propValue = [];
   case 'enable'
      propValue = localBool2Str(this.hJava.isEnabled);
   case 'extent'
      propValue = get(this.hContainer,'position');
      propValue(1:2) = 0;
   case 'fontangle'
      propValue = 'normal';
      if this.hJava.getFont.isItalic
         propValue = 'italic';
      end
   case 'fontsize'
      propValue = this.hJava.getFont.getSize;
   case 'fontname'
      propValue = this.hJava.getFont.getFamily;
   case 'fontunits'
      propValue = 'points';
   case 'fontweight'
      propValue = 'normal';
      if this.hJava.getFont.isBold
         propValue = 'bold';
      end
   case 'foregroundcolor'
      propValue = this.hJava.getForeground;
      propValue = [...
         propValue.getRed, ...
         propValue.getGreen, ...
         propValue.getBlue]/255;
   case 'handlevisibility'
      propValue = get(this.hContainer,'handlevisibility');
   case 'hittest'
      propValue = 'on';
   case 'horizontalalignment'
      propValue = 'right';
   case {'max','min'}
      propValue = 1;
   case 'parent'
      propValue = get(this.hContainer,'Parent');
   case 'position'
      propValue = get(this.hContainer,'position');
   case 'selected'
      propValue = localBool2Str(this.hJava.isFocusOwner);
   case 'string'
      propValue = char(this.hJava.getText);
   case 'style'
      propValue = 'edit';
   case 'tag'
      propValue = char(this.hJava.getName);
   case 'tooltipstring'
      propValue = char(this.hJava.getToolTipText);
   case 'units'
      propValue = get(this.hContainer,'units');
   case 'userdata'
      propValue = this.UserData;
   case 'value'
      propValue = ctrluis.convertJavaComplexToDouble(this.hJava.getValue);
   case 'visible'
      propValue = localBool2Str(this.hJava.isVisible);
   otherwise
      errStr = sprintf('There is no ''%s'' property for numerical text fields.',prop);
      ctrlMsgUtils.error('Controllib:general:UnexpectedError',errStr);
end

%--------------------------------------------------------------------------
function str = localBool2Str(Bool)

if Bool, str = 'on';
else str = 'off';
end

      