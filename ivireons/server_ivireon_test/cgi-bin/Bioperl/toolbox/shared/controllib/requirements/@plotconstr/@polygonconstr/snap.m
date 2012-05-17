function snap(this,WhichEnd)
%SNAP  Method to align constraint in major compass point direction.

%   Authors: A. Stothert
%   Revised: 
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:32:58 $

iElement = this.SelectedEdge(1);
switch this.Orientation
   case 'horizontal'
      %Align y coordinates
      this.yCoords(iElement,WhichEnd) = this.yCoords(iElement,3-WhichEnd);
    case 'vertical'
      %Align x coordinates
      this.xCoords(iElement,WhichEnd) = this.xCoords(iElement,3-WhichEnd);
   otherwise
      if abs(diff(this.yCoords(iElement,:))) > abs(diff(this.xCoords(iElement,:))) 
         %Line is more 'vertical' than horizontal, align y coordinates
         this.xCoords(iElement,WhichEnd) = this.xCoords(iElement,3-WhichEnd);
      else
         %Line is more 'horizontal' than vertical, align y coordinates
         this.yCoords(iElement,WhichEnd) = this.yCoords(iElement,3-WhichEnd);
      end
end

this.send('DataChangeFinished');  %Notify listeners of change
moveptr(handle(this.Elements.Parent),'move',...
   unitconv(this.xCoords(iElement,WhichEnd), this.xUnits, this.getDisplayUnits('xUnits')), ...
   unitconv(this.yCoords(iElement,WhichEnd), this.yUnits, this.getDisplayUnits('yUnits')) );