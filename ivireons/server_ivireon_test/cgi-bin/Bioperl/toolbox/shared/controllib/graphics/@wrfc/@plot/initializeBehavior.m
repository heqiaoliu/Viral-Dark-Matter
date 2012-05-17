function initializeBehavior(this)
%initializeBehavior  Initializes the behavior for plot edit and propertyeditor
%   for the @plot instance.

%  Author(s): C. Buhr
%   Copyright 1986-2008 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:29:29 $

% Overload this method to specify behavior for plot

% hgaxes = getaxes(this.AxesGrid);
% 
% % Plot Edit Behavior
% bh = hgbehaviorfactory('PlotEdit');
% bh.EnableCopy = false;
% bh.EnablePaste = false;
% bh.EnableMove = false;
% bh.EnableDelete = false;
% hgaddbehavior(hgaxes(:),bh);



