function schema 
% SCHEMA  Class definition for SrcSLEvent
%
 
% Author(s): A. Stothert
% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2010/03/26 17:51:13 $

pk = findpackage('checkpack');
inc = findclass(findpackage('scopeextensions'),'AbstractSrcSL');
c = schema.class(pk,'SrcSLEvent',inc);

p = schema.prop(c,'EventSrc','mxArray');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c,'Listener','mxArray');   %MCOS listeners
p.AccessFlags.PublicSet = 'off';
p.Visible = 'off';

p = schema.prop(c,'BlockHandle','mxArray');
p.AccessFlags.PublicGet = 'on';
p.AccessFlags.PublicSet = 'off';

p = schema.prop(c,'FlashTimer','mxArray');
p.FactoryValue = [];
p.Visible = 'off';