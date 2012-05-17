function render(Constr,varargin)
%RENDER sets the vertices, X and Y data properties of the patch and markers.

%   Author(s): P. Gahinet, A. Stothert
%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2009/10/16 06:33:26 $

hGroup  = Constr.Elements;
HostAx  = handle(hGroup.Parent);
HostFig = HostAx.Parent;
Xlim    = HostAx.Xlim;   
Ylim    = HostAx.Ylim;

if ~Constr.Activated
   % Initialize when constraint is not activated yet (preset for Activated=1)
   % Construct the constraint patch
   Patch = patch( ...
      'Parent', double(hGroup), ...
      'XlimInclude','off',...
      'YlimInclude','off',...        
      'LineStyle', 'none',...
      'CDataMapping','Direct', ...
      'FaceColor', Constr.PatchColor, ...
      'FaceAlpha', 0.75, ...
      'HelpTopicKey', Constr.HelpData.CSHTopic,...
      'UIContextMenu', Constr.addmenu(HostFig),...
      'ButtonDownFcn',Constr.ButtonDownFcn,...
      'Tag','ConstraintPatch');
   
   % Constraint 'inside edge'
   EdgeInfeasible = line(...
      'Parent', double(hGroup), ...
      'Color', Constr.EdgeColor, ...
      'LineWidth', 2, ...
      'Tag','ConstraintInfeasibleEdge', ...
      'Visible','on',...
      'XlimInclude','on',...
      'YlimInclude','on',...
      'HitTest','on',...
      'HelpTopicKey', Constr.HelpData.CSHTopic,...
      'ButtonDownFcn', Constr.ButtonDownFcn);
   
   % Construct markers
   Markers = line(...
      'Parent', double(hGroup),...
      'XlimInclude','off',...
      'YlimInclude','off',...        
      'LineStyle','none', ...
      'Marker','s', ...
      'MarkerSize',4, ... 
      'MarkerFaceColor','k', ...
      'MarkerEdgeColor','k', ...
      'Visible',Constr.Selected,...
      'Tag', 'ConstraintMarkers',...
      'HitTest','off');
end

% Constraint rendering
if Constr.Ts,
   % Discrete time: the z-domain curve for w0 is parameterized as
   %    exp(-w0*Ts*exp(j*phi))  with |phi|<=phi0 
   % and
   %    phi0 = pi/2 if pi/w0/Ts>1, asin(pi/w0/Ts) otherwise
   w0 = Constr.Ts * Constr.Frequency;
   if w0<pi
      phi0 = pi/2;
   else
      phi0 = asin(pi/w0);
   end
   phi = phi0 * (-1:1/64:1);
   nP = length(phi);
   Z0 = exp(-w0 * exp(1i*phi));
   
   % Construct X, Y data for the patch
   thetaS = atan2(imag(Z0(1)),real(Z0(1)));
   thetaE = atan2(imag(Z0(end)),real(Z0(end)));
   if strcmp(Constr.Type,'upper')
      %Anti-Clockwise region enclosed
      thetaE = thetaE+2*pi;  
   end
   theta = thetaE:(thetaS-thetaE)/(nP-1):thetaS;
   if abs(Z0(1)-Z0(end)) < sqrt(eps) && strcmp(Constr.Type,'upper')
      PatchXData = real(Z0);
      PatchYData = imag(Z0);
   else
      PatchXData = [real(Z0), cos(theta)];
      PatchYData = [imag(Z0), sin(theta)];
      nP = numel(PatchXData);
   end
   % Plot left and right constraint selection markers in new position
   r0 = exp(-w0);
   hChildren = hGroup.Children;
   Tags = get(hChildren,'Tag');
   idx = strcmp(Tags,'ConstraintInfeasibleEdge');
   set(hChildren(idx),'XData',real(Z0),...
      'YData',imag(Z0),'ZData',Constr.Zlevel(ones(size(Z0)))+0.1, ...
      'Color',Constr.EdgeColor,...
      'LineWidth', Constr.Weight(1)*2+eps)
   idx = strcmp(Tags,'ConstraintMarkers');
   set(hChildren(idx),'XData',r0,'YData',0,'ZData',Constr.Zlevel+0.1)
else
   % Continuous time: half circle of radius Constr.Frequency
   theta = pi*(0.5:1/64:1.5);
   w0 = Constr.Frequency;
   
   % Construct X, Y data for the patch
   X = cos(theta);   Y = sin(theta);
   PatchXData = w0*X;
   PatchYData = w0*Y;
   if strcmp(Constr.Type,'upper')
      Ybot = min([Ylim -w0]);
      Ybot = Ybot*(1-0.5*sign(Ybot));
      Ytop = max([Ylim w0]);
      Ytop = Ytop*(1+0.5*sign(Ytop));
      Xleft = Xlim(1)*(1-0.5*sign(Xlim(1)));
      PatchXData = [PatchXData(:); 0; Xleft; Xleft; 0];
      PatchYData = [PatchYData(:); Ybot; Ybot; Ytop; Ytop];
   end
   nP = numel(PatchXData);
   
   % Plot markers and inside edge
   hChildren = hGroup.Children;
   Tags = get(hChildren,'Tag');
   idx = strcmp(Tags,'ConstraintInfeasibleEdge');
   set(hChildren(idx),...
      'XData', w0*X, ...
      'YData', w0*Y,...
      'ZData',Constr.Zlevel(ones(size(X)))+0.1,...
      'Color',Constr.EdgeColor,...
      'LineWidth', Constr.Weight(1)*2+eps)
   idx = strcmp(Tags,'ConstraintMarkers');
   set(hChildren(idx),'XData',-w0,'YData',0,'ZData',Constr.Zlevel+0.1)
  
end

% Set patch parameters
idx = strcmp(Tags,'ConstraintPatch');
Vertices = [PatchXData(:) PatchYData(:) Constr.Zlevel(ones(nP,1),:)];
Faces = 1:nP;
set(hChildren(idx),'Faces',Faces,'Vertices',Vertices, ...
   'FaceColor',Constr.PatchColor)

