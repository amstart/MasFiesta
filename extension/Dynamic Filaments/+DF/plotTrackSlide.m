function plotTrackSlide(varargin)
hDFGui = getappdata(0,'hDFGui');
Tracks = getappdata(hDFGui.fig,'Tracks');
Options = getappdata(hDFGui.fig,'Options');
track = Tracks(str2num(get(hDFGui.eTrack, 'String')));

figure
slmin = 1;
slmax = length(track.itrace);
plotTrack(track, 1);
hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                'SliderStep',[1 1]./(slmax-slmin),'Value',1,...
                'Position',[20 20 200 20]);
set(hsl,'Callback',@(hObject,eventdata) plotTrack(track, round(get(hObject,'Value'))))

function plotTrack(track, frame)
if ~isempty(track.itrace{frame})
    x = track.itrace{frame}(:,1);
    plot(x,track.itrace{frame}(:,2));
    hold on
    title([num2str(track.TrackIndex) '   frame: ' num2str(track.Data(frame,6,1))]);
    h1 = plot(x,convolutedExponential(x,track.Data(frame,7:end-1,2)'));
    h2 = plot(x,convolutedExponential(x,track.Data(frame,7:end-1,3)'));
    plot(track.x_sel{frame}([1 end]),[mean(ylim) mean(ylim)]);
    legend([h1, h2], {'x03', 'x05'});
    drawnow;
    hold off
end