function plotTrackSlide(varargin)
hDFGui = getappdata(0,'hDFGui');
Options = getappdata(hDFGui.fig,'Options');
tracknum = str2num(get(hDFGui.eTrack, 'String'));
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);

figure
slmin = 1;
slmax = length(track.Data(:,2));

dimstr = strsplit(num2str(1:8));       
lDim1 = uicontrol('Tag','lDim1','String',dimstr,'Position',[150 5 30 20],'Style','popupmenu', 'Value',1);
lDim2 = uicontrol('Tag','lDim2','String',dimstr,'Position',[190 5 30 20],'Style','popupmenu', 'Value',2);
lDim3 = uicontrol('Tag','lDim3','String',dimstr,'Position',[230 5 30 20],'Style','popupmenu', 'Value',3);

plotTrack(tracknum, lDim1, lDim2, lDim3, 1);

hsl = uicontrol('Style','slider','Min',slmin,'Max',slmax,...
                'SliderStep',[1 1]./(slmax-slmin),'Value',1,...
                'Position',[20 5 100 20]);
set(hsl,'Callback',@(hObject,eventdata) plotTrack(tracknum, lDim1, lDim2, lDim3, hObject));

set(lDim1,'Callback',@(hObject,eventdata) plotTrack(tracknum, lDim1, lDim2, lDim3, hsl));
set(lDim2,'Callback',@(hObject,eventdata) plotTrack(tracknum, lDim1, lDim2, lDim3, hsl));
set(lDim3,'Callback',@(hObject,eventdata) plotTrack(tracknum, lDim1, lDim2, lDim3, hsl));

bFit = uicontrol('Style','pushbutton','String','Fit','Position',[300 5 60 20]);
bDelete = uicontrol('Style','pushbutton','String','Delete','Position',[400 5 60 20]);
bMark = uicontrol('Style','pushbutton','String','Mark','Position',[500 5 60 20]);
set(bFit,'Callback',@(hObject,eventdata) fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, 1));
set(bDelete,'Callback',@(hObject,eventdata) fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, 2));
set(bMark,'Callback',@(hObject,eventdata) fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, 3));

function plotTrack(tracknum, lDim1, lDim2, lDim3, hsl)
hDFGui = getappdata(0,'hDFGui');
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);
if ~isnumeric(hsl)
    frame = round(get(hsl,'Value'));
else
    frame = 1;
end
% dim1 = get(lDim1, 'Value');
% dim2 = get(lDim2, 'Value');
% dim3 = get(lDim3, 'Value');
dims = 1:6;
if ~isempty(track.itrace{frame})
    x = track.itrace{frame}(1,:);
    plot(x,track.itrace{frame}(2,:));
    if isnan(track.Data(frame,2))
        if frame+1 > size(track.Data,1)
            xlim([x(1) track.Data(frame-1,2)+500]);
        else
            xlim([x(1) track.Data(frame+1,2)+500]);
        end
    else
        xlim([x(1) track.Data(frame,2)+500]);
    end
    hold on
    datacursormode on
    title(['MT: ' num2str(track.MTIndex) ' track: ' num2str(track.TrackIndex)...
        '   frame: ' num2str(track.Data(frame,6,1))]);
    data = squeeze(track.FitData(frame,dims,:))';
    if data(end,1) == inf
        set(gca,'Color',[0.7 0.7 0.7]);
    else
        set(gca,'Color',[1 1 1]);
    end
    vline(track.Data(frame,2));
    if ~isnan(data(1))
    h1 = plot(x,fitFrame.fun2(x,data(:,1)));
    h2 = plot(x,fitFrame.fun2(x,data(:,2)));
    h3 = plot(x,fitFrame.fun2(x,data(:,3)));
    h4 = plot(x,fitFrame.fun2(x,data(:,4)));
    h5 = plot(x,fitFrame.fun2(x,data(:,5)));
    h6 = plot(x,fitFrame.fun1(x,data(:,6)));
    legend([h1 h2 h3 h4 h5 h6],...
    {['e=' num2str(data(10,1),3)],...
    ['A=' num2str(data(1,2),3) ' s=' num2str(data(2,2),3) 'e=' num2str(data(10,2),3)],...
    ['sh=' num2str(data(6,3),3) ' e=' num2str(data(10,3),3)],...
    ['sigdiff=' num2str(diff(data([2 7],4)),3) ' e=' num2str(data(10,4),3)],...
    ['sigdiff=' num2str(diff(data([2 7],5)),3) ' e=' num2str(data(10,5),3)],...
    [' s=' num2str(data(2,6),3) ' t=' num2str(data(8,6),3) ' e=' num2str(data(10,6),3)]},...
    'Location', 'southeast');
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

function fitFramedata(tracknum, lDim1, lDim2, lDim3, hsl, mode)
hDFGui = getappdata(0,'hDFGui');
Tracks = getappdata(hDFGui.fig,'Tracks');
track = Tracks(tracknum);
frame = round(get(hsl,'Value'));
% dim1 = get(lDim1, 'Value');
% dim2 = get(lDim2, 'Value');
% dim3 = get(lDim3, 'Value');
dims = 1:6;
if ~isempty(track.itrace{frame})
    if mode < 3
        track.FitData(frame,dims,:) = nan;
    end
    if mode == 1
        hdt = datacursormode;
        c_info = getCursorInfo(hdt);
        if isempty(c_info)
            pts = track.x_sel(frame,:);
        else
            pts = sort([c_info.DataIndex]);
        end
        x = track.itrace{frame}(1,pts(1):pts(end));
        y = track.itrace{frame}(2,pts(1):pts(end));
        [fits0] = fitFrame.para_fit_erf(x, y);
        [fits1] = fitFrame.para_fit_gauss1(x, y);
        [fits2] = fitFrame.para_fit_gauss2(x, y);
        [fits3] = fitFrame.para_fit_gauss3(x, y);
        [fits4] = fitFrame.para_fit_gauss4(x, y);
        [fits5] = fitFrame.para_fit_exp(x, y);
        fits = padcat(fits0, fits1, fits2, fits3, fits4, fits5);
        track.x_sel(frame,:) = pts([1 end]);
        track.FitData(frame,1:size(fits,1),1:size(fits,2)) = fits;
    end
    if mode == 3
        if track.FitData(frame,1,end) == inf
            track.FitData(frame,1,end) = nan;
        else
            track.FitData(frame,1,end) = inf;
        end
    end
    Tracks(tracknum) = track;
    setappdata(hDFGui.fig,'Tracks', Tracks);
    setappdata(0,'hDFGui',hDFGui);
    plotTrack(tracknum, lDim1, lDim2, lDim3, hsl)
end