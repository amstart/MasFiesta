function [x_vec, y_vec] = get_plot_vectors(Options, Tracks, xy)
vector = cell(1,2);
selected_methods = [Options.lMethod_TrackValue.val, Options.lMethod_TrackValueY.val];
if Options.cSwitch.val
    selected_vars = [Options.lPlot_XVarT.val, Options.lPlot_YVarT.val];
else
    selected_vars = [Options.lPlot_XVar.val, Options.lPlot_YVar.val];
end
selected_dims = [Options.lPlot_XVardim.val, Options.lPlot_YVardim.val];
for m = xy
    vector{m} = nan(length(Tracks),1);
    for n = 1:length(Tracks) % {'median', 'mean', 'end-start', 'minimum', 'maximum', 'standard dev', 'linear fit (only for velocity) or sum (only for MAP count)'}
        if isfield(Tracks(n), 'X')
            if m==1
                data = Tracks(n).X;
            else
                data = Tracks(n).Y;
            end
        else
            try
                if Options.cSwitch.val
                    if length(Tracks(n).FitData) > 1
                    data = fitFrame.getPlotData(Tracks(n),selected_dims(m));
                    data = data(:,selected_vars(m));
                    else
                        data = nan;
                    end
                else
                    data = Tracks(n).Data(:,selected_vars(m));
                end
            catch
                return
            end
        end
        if length(data) < 2
            continue
        end
        switch selected_methods(m)
            case 1
                vector{m}(n) = nanmedian(data);
            case 2
                vector{m}(n) = nanmean(data);
            case 3
                if selected_vars(m) == 3
                    vector{m}(n) = Tracks(n).Startendvel;
                else
                    data = data(~isnan(data));
                    vector{m}(n) = data(end) - data(1);
                end
            case 4
                vector{m}(n) = min(data);
            case 5
                vector{m}(n) = max(data);
            case 6
                if isfield(Tracks(n), 'X')
                    vector{m}(n) = (data(end) - data(1))/(Tracks(n).Z(end)-Tracks(n).Z(1));
                end
            case 7
%                 if selected_vars(m) == 3
                    x = 1:length(data);
                    y = data';
                    x = x(~isnan(data));
                    y = y(~isnan(data));
                    p = polyfit(x,y,1);
                    vector{m}(n) = p(1);
%                 else
%                     vector{m}(n) = nansum(data);
%                 end
        end
    end
end
x_vec = vector{1};
y_vec = vector{2};