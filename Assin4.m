close all; 
clear all;
clc;

load Assignment4.mat


% Collections in the form of [sensor X fast-time] 

c=299792458; %speed of light
%data_to_process= eval(['Collection_', num2str(i)]); 

data_to_process= BS_TCR_0_20; %change to CollectionB, CollectionC and CollectionD
NSamp = size(data_to_process,2);

NFFTA = 1024; % FFT length angle
NFFTR = 1024; % FFT length range
% Range axis
Ts  = Radar_settings.Chirp_time - Radar_settings.Reset_time - Radar_settings.DwellTime;    % Duration of the ramp section of the chirp in s (Sweep Time)
S = Radar_settings.BW/Ts;
Range  = c/(2*S)*linspace(0,Radar_settings.Fs,NFFTR);      % in meters

%% Start writing your code ....

    a = cat(1, data_to_process, zeros(2000-size(data_to_process, 1), size(data_to_process, 2)));

    data_to_sample_fft = fftshift(fft2(a), 1);

    Angle = linspace(-90, 90, 2000);
    
    %[value_1, index_1] = max(a(40, :));

    figure(1);
    [h,c]=polarPcolor(Range(:, 1:58),Angle, db(abs(data_to_sample_fft(:, 1:58))).');

    colorbar;
    caxis([-20 0]);

    print(['Range_profile_ex4_polar_20'], '-depsc');

    %colorbar
    

    figure(2);

    surf(Angle, Range, db(abs(data_to_sample_fft)).'); view(2); shading flat;
    ylim([0 10]);
    xlabel('Angle (Degree)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Range (m)', 'FontSize', 12, 'FontWeight', 'bold');
    title(['Range/Angle Map with after calibration'], 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    colorbar;
    caxis([-20 0]);
    print(['Range_profile_ex4_20'], '-depsc')

    %Angle cut
    
    figure;
    plot(Angle, db(abs(data_to_sample_fft(:, 39))).', 'LineWidth', 2);
    grid on;
    
    xlabel('Angle (Degree)', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Mag(dB)', 'FontSize', 12, 'FontWeight', 'bold');
    title(['Angle cut'], 'FontSize', 12, 'FontWeight', 'bold');
    grid on;
    print(['Angle_cut_ex4_20'], '-depsc');
   
