function schema
% Defines properties for @looptransfer class 
% (form for defining SISO loop transfer functions)

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:40:23 $
c = schema.class(findpackage('sisodata'),'looptransfer');
c.Handle = 'off';

% Transfer type (G,C,L,P for open-loop transfers or T for closed-loop transfer)
schema.prop(c,'Type','string');
% Indices needed to extract transfer function
schema.prop(c,'Index','MATLAB array');
% Description to appear in plot legend
schema.prop(c,'Description','string');
% Export name
schema.prop(c,'ExportAs','string');
% Style in plot (style string, e.g., 'r--')
schema.prop(c,'Style','string');
