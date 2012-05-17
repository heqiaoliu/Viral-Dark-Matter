function pj = restoreui( pj, Fig )
%RESTOREUI Remove Images used to mimic user interface controls in output.
%   When printing a Figure with Uicontrols, the user interface objects
%   can not be drawn in the output. So Images were created to fill in 
%   for the Uicontrols in the output. We now remove those Images.
%
%   Ex:
%      pj = RESTOREUI( pj, h ); %removes Images from Figure h, modifes pj
%
%   See also PRINT, PRINTOPT, PREPAREUI, RESTORE, RESTOREUI.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.6.4.5 $  $Date: 2009/12/28 04:17:51 $

error( nargchk(2,2,nargin) )

if (~useOriginalHGPrinting())
    error('MATLAB:Print:ObsoleteFunction', 'The function %s should only be called when original HG printing is enabled.', upper(mfilename));
end

if ~isequal(size(Fig), [1 1]) | ~isfigure( Fig )
    error('MATLAB:print:InvalidHandle', 'Need a handle to a Figure object.' )
end
    

%UIData is empty if never saved mimiced any controls because 
%user requested we don't print them or becaus ef previously
%found and reported problems.
if isempty( pj.UIData )
    return
end

if ~strcmp(get(Fig, 'Visible'), pj.UIData.OldFigVisible)
    set( Fig, 'Visible', pj.UIData.OldFigVisible );
end

if ~isempty(pj.UIData.UICHandles)
  set(pj.UIData.UICHandles,{'Units'},pj.UIData.UICUnits);
  set(pj.UIData.UICHandles,'visible','on');
end
delete(pj.UIData.AxisHandles(find(ishandle(pj.UIData.AxisHandles))));
set(Fig, 'Colormap', pj.UIData.OldFigCMap );

if pj.UIData.MovedFigure
    set(Fig, 'Position', pj.UIData.OldFigPosition );
end

pj.UIData = [];

