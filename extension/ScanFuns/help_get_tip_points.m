function [ Filament ] = help_get_tip_points( Filament, ScanOptions )
%HELP_GET_TIP_POINTS This function interpolates Filament tracks such to get
%the filament position between two frames (to later get the intensity at
%that spot)
max_points = ScanOptions.help_get_tip_points.max_points;
for m = 1:length(Filament)
    for frame = 1:size(Filament(m).Results, 1) - 1; %leave last data element unchanged
        %this has basically been copied from Felix's code for FitmissingFrames
        %(in fDataGui)
        idx = [frame frame+1];
        n = Filament(m).Results(idx(1),1) + ScanOptions.help_get_tip_points.GFP_frame_where; %we want to know where the filament is when the GFP frame has been taken
        c = (n-Filament(m).Results(idx(1),1))/(Filament(m).Results(idx(2),1)-Filament(m).Results(idx(1),1));
        num_points = [min(max_points, size(Filament(m).Data{idx(1)},1)) min(max_points, size(Filament(m).Data{idx(2)},1))];
        points{1} = Filament(m).Data{idx(1)}(1:num_points(1),1:2); %points which are going to be modified
        points{2} = Filament(m).Data{idx(2)}(1:num_points(2),1:2); %points in next available frame
        fX = zeros(max(num_points),2);
        fY = zeros(max(num_points),2);
        for n = 1:2
            if num_points(n) ~=max(num_points) %if the number of points is less than in the other frame then interpolate to right number of points
                new_vector = 1:(num_points(n)-1)/(max(num_points)-1):num_points(n);
                old_vector = 1:num_points(n);
                fX(:,n) = interp1(old_vector,points{n}(:,1),new_vector);
                fY(:,n) = interp1(old_vector,points{n}(:,2),new_vector);
            else
                fX(:,n) = points{n}(:,1);
                fY(:,n) = points{n}(:,2);
            end
        end
        Filament(m).Data{idx(1)} = [(fX(:,1)*(1-c) + fX(:,2)*c) (fY(:,1)*(1-c) + fY(:,2)*c)]; %save average positions
    end
end