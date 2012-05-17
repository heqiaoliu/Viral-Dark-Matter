function [varstrout,substrout] = parsedatasource(h,srcName)

% Parse the constring contained in an xDataSource or yDataSource into a 
% variable name and a subreferencing string
strin = get(h.HGHandle,srcName);
ind = strfind(strin,'(');
substrout = '(:)';
 
if ~isempty(ind)
    substrout = strin(ind:end);
    varstrout = strin(1:ind-1);
else
    varstrout = strin;
end

