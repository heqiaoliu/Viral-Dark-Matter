function out = util_remove_html(in)

%   Copyright 2007-2010 The MathWorks, Inc.

    out = strrep(in,'<br>','');
    out = strrep(out,'<b>','');
    out = strrep(out,'</b>','');
    out = strrep(out,'<font color="red">','');    
    out = strrep(out,'<font color="green">','');
    out = strrep(out,'<font color="blue">','');
    out = strrep(out,'<font color="orange">','');
    out = strrep(out,'</font>','');
    out = strrep(out,'&nbsp;','  ');
