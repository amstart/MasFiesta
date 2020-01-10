m = ones(5,1)*(1:5);
slmin = 1;
slmax = size(m,2);
plot(m(:,1))
hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                'SliderStep',[1 1]./(slmax-slmin),'Value',1,...
                'Position',[20 20 200 20]);
set(hsl,'Callback',@(hObject,eventdata) plot(m(:,round(get(hObject,'Value')))) )