function plotTrackSlide(varargin)
hDFGui = getappdata(0,'hDFGui');
Options = getappdata(hDFGui.fig,'Options');
tracknum = str2num(get(hDFGui.eTrack, 'String'));
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);

figure
slmin = 1;
slmax = length(track.itrace);

dimstr = strsplit(num2str(1:8));       
lDim1 = uicontrol('Tag','lDim1','String',dimstr,'Position',[150 5 30 20],'Style','popupmenu');
lDim2 = uicontrol('Tag','lDim1','String',dimstr,'Position',[210 5 30 20],'Style','popupmenu', 'Value',2);

plotTrack(tracknum, lDim1, lDim2, 1);

hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                'SliderStep',[1 1]./(slmax-slmin),'Value',1,...
                'Position',[20 5 100 20]);
set(hsl,'Callback',@(hObject,eventdata) plotTrack(tracknum, lDim1, lDim2, hObject));

set(lDim1,'Callback',@(hObject,eventdata) plotTrack(tracknum, lDim1, lDim2, hsl));
set(lDim2,'Callback',@(hObject,eventdata) plotTrack(tracknum, lDim1, lDim2, hsl));

bFit = uicontrol('Style','pushbutton','String','Fit','Position',[300 5 60 20]);
set(bFit,'Callback',@(hObject,eventdata) fitFramedata(tracknum, lDim1, lDim2, hsl));


function plotTrack(tracknum, lDim1, lDim2, hsl)
hDFGui = getappdata(0,'hDFGui');
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);
if ~isnumeric(hsl)
    frame = round(get(hsl,'Value'));
else
    frame = 1;
end
dim1 = get(lDim1, 'Value');
dim2 = get(lDim2, 'Value');
if ~isempty(track.itrace{frame})
    x = track.itrace{frame}(:,1);
    plot(x,track.itrace{frame}(:,2));
    hold on
    title(['MT: ' num2str(track.MTIndex) ' track: ' num2str(track.TrackIndex)...
        '   frame: ' num2str(track.Data(frame,6,1))]);
    data = squeeze(track.Data(frame,7:end,[dim1 dim2]));
    if ~isnan(data(1))
        h1 = plot(x,fitFrame.fun1(x,data(:,1)));
        text(0.1,0.1,num2str(data(1,1)),'Units','normalized');
        legend(h1, {['dim' num2str(dim1)]});
    end
    if ~isnan(data(1,2))
        h2 = plot(x,fitFrame.fun2(x,data(:,2)));
        text(0.5,0.1,num2str(data(1,2)),'Units','normalized');
%         legend([h1, h2], {['dim' num2str(dim1)], ['dim' num2str(dim2)]});
    end
%     try
%         h1 = plot(x,convolutedExponential(x,track.Data(frame,7:end-1,dim1)'));
%         h2 = plot(x,convolutedExponential(x,track.Data(frame,7:end-1,dim2)'));
%     catch
%     end
%     plot(track.x_sel{frame}([1 end]),[mean(ylim) mean(ylim)]);
    drawnow;
    hold off
end

function fitFramedata(tracknum, lDim1, lDim2, hsl)
hDFGui = getappdata(0,'hDFGui');
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);
frame = round(get(hsl,'Value'));
dim1 = get(lDim1, 'Value');
dim2 = get(lDim2, 'Value');
if ~isempty(track.itrace{frame})
    hdt = datacursormode;
    c_info = getCursorInfo(hdt);
    if isempty(c_info)
        pts = track.x_sel(frame,:,dim1);
    else
        pts = sort([c_info.DataIndex]);
    end
    x = track.itrace{frame}(pts(1):pts(end),1);
    y = track.itrace{frame}(pts(1):pts(end),2);
    fits1 = fitFrame.para_fit_fun1(x, y);
    fits2 = fitFrame.para_fit_fun2(x, y);
    fits = padcat(fits1, fits2);
    if size(fits,1) == 1
        dim2 = [];
        track.x_sel(frame,:,dim1) = pts([1 end]);
    else
        track.x_sel(frame,:,[dim1 dim2]) = cat(3,pts([1 end]), pts([1 end]));
    end
    track.Data(frame,7:end,[dim1 dim2]) = nan;
    track.Data(frame,7:size(fits,2)+6,[dim1 dim2]) = fits';
    Tracks(tracknum) = track;
    setappdata(hDFGui.fig,'Tracks', Tracks);
    setappdata(0,'hDFGui',hDFGui);
    plotTrack(tracknum, lDim1, lDim2, hsl)
end