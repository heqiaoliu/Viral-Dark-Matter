function varargout = fvtool(varargin) 
%FVTOOL Filter Visualization Tool (FVTool).
%   FVTool is a Graphical User Interface (GUI) that allows you to analyze
%   digital filters.  
%
%   FVTOOL(B,A) launches the Filter Visualization Tool and computes 
%   the Magnitude Response for the filter defined by numerator and denominator 
%   coefficients in vectors B and A. 
% 
%   FVTOOL(B,A,B1,A1,...) will perform an analysis on multiple filters. 
%
%   FVTOOL(Hd) will perform an analysis on a discrete-time filter (DFILT) 
%   object. 
%
%   If the Filter Design Toolbox is installed, FVTOOL(H,H1) can be used to
%   analyze fixed-pt filter objects, by setting the 'Arithmetic' property
%   to 'fixed, multirate filter objects, MFILTs, and adaptive filter
%   objects, ADAPTFILTs.
%
%   H = FVTOOL(...) returns the handle to FVTool.  This handle can be
%   used to interface with FVTool through the GET and SET commands as you
%   would with a normal figure, but with additional properties.  Some of
%   these properties are analysis-specific and will change whenever the 
%   analysis changes.  Execute GET(H) to see a list of FVTool's properties 
%   and current values.
%
%   FVTOOL(Hd,PROP1,VALUE1,PROP2,VALUE2, etc.) launches FVTool and sets
%   the specified properties to the specified values.
%
%   The following methods are defined for H, the handle to FVTool:
%
%   ADDFILTER(H, FILTOBJ) where filtobj is a DFILT object.  This will add
%   the new filter to FVTool without affecting the filters currently  being
%   analyzed.
%   
%   SETFILTER(H, FILTOBJ) replaces the filter in FVTool with FILTOBJ.
%
%   DELETEFILTER(H, INDEX) deletes the filter at specified INDEX from FVTool.
%
%   LEGEND(H, STRING1, STRING2, etc) creates a legend on FVTool by
%   associating STRING1 with Filter #1, STRING2 with Filter #2 etc.
%
%   ZOOM(H, [XMIN XMAX YMIN YMAX]) zoom into the area specified by XMIN,
%   XMAX, YMIN and YMAX.
%
%   ZOOM(H, 'x', [XMIN XMAX]) constrain the zoom to the x-axis.
%
%   ZOOM(H, 'y', [YMIN YMAX}) constrain the zoom to the y-axis.
%
%   ZOOM(H, 'default') restore the default axis limits.
%
%   ZOOM(H, 'passband') zoom into the passband.  This feature is only
%   available when all of the filters in FVTool were designed with an
%   FDESIGN object.
%
%   EXAMPLES:
%   % #1 Magnitude Response of an IIR filter
%   [b,a] = butter(5,.5);                                                 
%   h1 = fvtool(b,a);                                                     
%   Hd = dfilt.df1(b,a); % Discrete-time filter (DFILT) object            
%   h2 = fvtool(Hd);                                                      
%
%   % #2 Analysis of multiple FIR filters
%   b1 = firpm(20,[0 0.4 0.5 1],[1 1 0 0]); 
%   b2 = firpm(40,[0 0.4 0.5 1],[1 1 0 0]); 
%   fvtool(b1,1,b2,1);
%
%   % #3 Using FVTool's API
%   set(h1, 'Analysis', 'impulse'); % Change the analysis 
%   
%   Hd2 = dfilt.dffir(b2);                                                
%   addfilter(h2, Hd2);             % Add a new filter 
%
%   % Setting FVTool's analysis-specific properties
%   h = fvtool(Hd2,'Analysis','phase','PhaseDisplay','Continuous Phase');               
%
%   See also FDATOOL, SPTOOL.

%    Author(s): J. Schickler & P. Costa
%    Copyright 1988-2009 The MathWorks, Inc.
%    $Revision: 1.37.4.13 $  $Date: 2009/07/14 04:03:27 $ 

% Parse the inputs
error(nargchk(1,inf,nargin,'struct'));

if (isempty(varargin{1}))
    ME = MException(generatemsgid('EmptyInput'), 'Empty input is not supported. You must pass in a filter.');
    throwAsCaller(ME);
end

try
    % Instantiate the fvtool object.
    hObj = sigtools.fvtool(varargin{:});
catch ME
    throwAsCaller(ME);
end



% Turn FVTool on
set(hObj,'Visible','On');

% Turn off warnings, call drawnow to update the figure and then call
% refresh to fix g339805.  Warnings are being thrown from DRAWNOW on intel
% mac because of an HG issue.
w = warning('off');
drawnow
warning(w);
refresh(double(hObj));

% Return FVTools' handle
if nargout > 0,
    varargout{1} = hObj;
end

% [EOF]
