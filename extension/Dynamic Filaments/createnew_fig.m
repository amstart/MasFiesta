function createnew_fig(cb,evendata)
%cb is the handle of the axes that was clicked
%click on the whitespace within and axes and not on the line object
%copy the axes object to the new figure
hh = copyobj(cb,figure);
%for the new figure assign the ButtonDownFcn to empty
set(hh,'ButtonDownFcn',[]);
%resize the axis to fill the figure
set(hh, 'Position', get(0, 'DefaultAxesPosition'));