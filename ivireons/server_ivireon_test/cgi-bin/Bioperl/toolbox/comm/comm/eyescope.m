function varargout = eyescope(varargin)
%EYESCOPE Eye diagram scope
%   EYESCOPE(H) launches an eye diagram scope for the eye diagram object H.  Eye
%   diagram scope displays the information stored in H in a graphical user
%   interface (GUI).
%
%   EYESCOPE launches an empty eye diagram scope.  
%
%   See also COMMSCOPE, COMMSCOPE/EYEDIAGRAM, SCATTERPLOT.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/03/30 23:24:06 $

if nargin == 1
    % Called with an argument, determine create eye diagram object structure
    hEyeDiagram = varargin{1};
    
    % Check if this is an eye diagram
    if ~isa(hEyeDiagram, 'commscope.eyediagram')
        error('comm:eyescope:InputNotAnEyeDiagramObj', ['Input ' ...
            'argument must be a commscope.eyediagram object.']);
    end
    
    % Assign the same name to the input eye diagram object as the caller
    % workspace and remove the temporary handles hEyeDiagram and h
    workSpaceName = inputname(1);
    if isempty(workSpaceName)
        warning(generatemsgid('NoInputName'), ['Cannot determine eye ' ...
            'diagram object name. Assigned the default name: eyeDiagramObj.']);
        workSpaceName = 'eyeDiagramObj';
    end
    eval([workSpaceName '= varargin{1};'])
    clear('hEyeDiagram');

    % Call constructor with the workspace variable
    eval(['hEyeGui = commscope.eyediagramgui(' workSpaceName ');']);
elseif nargin == 0
    hEyeGui = commscope.eyediagramgui;
else
    error('comm:eyescope:InvalidArgumentNumber', ['Too many input ' ...
        'arguments. Type ''help eyescope'' for correct usage.']);
end

if nargout == 1
    varargout{1} = hEyeGui.FigureHandle;
end
