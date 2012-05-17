function copySelection(this)

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.page.datamgr.linkedplots.*;
import com.mathworks.page.datamgr.utils.*;
import com.mathworks.mlservices.*;
import com.mathworks.mde.cmdwin.*;


sibs = findobj(get(this.HGHandle,'Parent'),'-Property','Brushdata','HandleVisibility','on');
sibs = findobj(sibs,'-function',@(x) ~isempty(get(x,'Brushdata')));
if length(sibs)==1
    ClipBoardManager.copySelectionToClip(datamanager.var2string(this.getArraySelection));
else
    datamanager.disambiguate(handle(sibs),{@localMultiObjCallback});
end


function localMultiObjCallback(gobj)

import com.mathworks.page.datamgr.brushing.*;

this = getappdata(double(gobj),'Brushing__');
ClipBoardManager.copySelectionToClip(datamanager.var2string(this.getArraySelection));

