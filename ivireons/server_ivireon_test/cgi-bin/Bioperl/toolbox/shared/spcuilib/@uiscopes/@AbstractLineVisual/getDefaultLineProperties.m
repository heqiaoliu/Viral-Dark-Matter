function defaultProps = getDefaultLineProperties
%GETDEFAULTLINEPROPERTIES Get the defaultLineProperties.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/01/25 22:47:27 $

defaultProps.DisplayName     = '';
defaultProps.Color           = get(0, 'DefaultLineColor');
defaultProps.LineStyle       = get(0, 'DefaultLineLineStyle');
defaultProps.LineWidth       = get(0, 'DefaultLineLineWidth');
defaultProps.Marker          = get(0, 'DefaultLineMarker');
defaultProps.MarkerSize      = get(0, 'DefaultLineMarkerSize');
defaultProps.MarkerEdgeColor = get(0, 'DefaultLineMarkerEdgeColor');
defaultProps.MarkerFaceColor = get(0, 'DefaultLineMarkerFaceColor');
defaultProps.Visible         = get(0, 'DefaultLineVisible');

% [EOF]
