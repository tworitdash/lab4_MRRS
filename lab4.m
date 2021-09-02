load('CorrectionCoefficients.mat');


for j = 1:4
    
    figure(j);
    
    [adcRaw2, settings] = readTIRawData_CCS_capture_demo('script-yellow.raw');

    %Angle = fft(adcRaw2(:, 1, 1))
    
    a=squeeze(adcRaw2(:,:,1)).* eval(['CorCoef_', num2str(j)]).';
    
    a = cat(1, a, zeros(2000-size(a, 1), size(a, 2)));

    Range_profile = fftshift(fft2(a),1);
    angle = linspace(-90, 90, size(a, 1));
    range = linspace(0, 10, size(a, 2));
    k = j + 4;
    l = j + 9;

    surf(angle, range, db(abs(Range_profile)).'); view(2); shading flat;
    
     xlabel('Angle (Degree)', 'FontSize', 12, 'FontWeight', 'bold');
     ylabel('Range (m)', 'FontSize', 12, 'FontWeight', 'bold');
     title(['Range/Angle Map with correction coefficient ', num2str(j)], 'FontSize', 12, 'FontWeight', 'bold');
     grid on;
    
    colorbar;
    caxis([50 100]);
     
     print(['Range_profile_', num2str(j)], '-depsc')
     figure(k)
    
    [h, c] = polarPcolor(range, angle, db(abs(Range_profile)).');
    colorbar;
    caxis([50 100]);
    %title(['Polar plot of Range/Angle map with correction coefficient ', num2str(j)])
    print(['Range_profile_polar_', num2str(j)], '-depsc')
     
    
    
    figure(l)
    plot(angle, db(abs(Range_profile(:, 83))./max(abs(Range_profile(:, 83))).'), 'LineWidth', 2);
    
     xlabel('Angle (Degree)', 'FontSize', 12, 'FontWeight', 'bold');
     ylabel('Mag(dB)', 'FontSize', 12, 'FontWeight', 'bold');
     title(['Angle cut at range = 3.4310 [m] with correction coefficient ', num2str(j)], 'FontSize', 12, 'FontWeight', 'bold');
     grid on;
     print(['Angle_cut_', num2str(j)], '-depsc');
     
    

end

% Finding our own calibration coefficient

Range_profile_1 = fft(adcRaw2, [], 2);

C = zeros(1, length(adcRaw2(:, 1, 1)));

for i = 1:8
    
    [k , l] = max(Range_profile_1(i, :, 1));

    Sensor = Range_profile_1(i, l, 1);
    
    C(i) = 1/Sensor; % elements of calibration coefficients 

end


a = squeeze(adcRaw2(:,:,1)).* C.';
    
a = cat(1, a, zeros(2000-size(a, 1), size(a, 2))); %zero padding 

Range_profile_j = fftshift(fft2(a),1);

figure(16);

angle = linspace(-90, 90, size(a, 1));
range = linspace(0, 10, size(a, 2));

surf(angle,range,db(abs(Range_profile_j)).'); view(2); shading flat;
xlabel('Angle (Degree)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Range (m)', 'FontSize', 12, 'FontWeight', 'bold');
title(['Range/Angle Map with after calibration'], 'FontSize', 12, 'FontWeight', 'bold');
grid on;
colorbar;
caxis([-50 0]);


print(['Range_profile_cal_'], '-depsc')
figure(17);

[h, c] = polarPcolor(range, angle, db(abs(Range_profile_j)).');
%title(['Polar plot of Range/Angle map after calibration ']);
colorbar;
caxis([-50 0]);

print(['Range_profile_cal_polar_'], '-depsc');

figure(20);
plot(angle, db(abs(Range_profile_j(:, 83))./max(abs(Range_profile_j(:, 83)))).', 'LineWidth', 2, 'Color', [.6 0 0]);
ylim([-50 0])
xlabel('Angle (Degree)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Mag(dB)', 'FontSize', 12, 'FontWeight', 'bold');
title(['Angle cut at range = 3.4310 [m] after calibration'], 'FontSize', 12, 'FontWeight', 'bold');
grid on;
print(['Angle_cut_cal'], '-depsc');
