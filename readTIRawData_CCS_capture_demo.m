function [adcRaw2, settings] = readTIRawData_CCS_capture_demo(fileName)
% Reads TI RAW data file created using CCS Capture Demo
%   IN:     - file name: including full path
%   OUT:    - adcRaw2 - [NTx x NRx (N virtual antennas), NSamples, NSweeps (N chirps per loop per Tx channel), [NFrames]] array of beat-signals (complex)
%           - settings - structure containing radar settings (See mmwave SDK user guide chapter 3.4)    
%   PJA 02/2019        
%% Load radar settings from powershell script
% [fileName,path] = uigetfile('*.ps1','Select the script file containing the radar config'); % select data file to load
fid = fopen(['script.ps1']);
c = textscan(fid,'%s','delimiter','\n');
fclose(fid);

% channel config
channelCfgStr = string(c{1,1}(~cellfun(@isempty,strfind(c{1,1},'channelCfg'))));
channelCfg = double(regexp(channelCfgStr,'(\d+,)*\d+(\.\d*)?', 'match'));

rxChannelEn = channelCfg(1);
txChannelEn = channelCfg(2);
nRxEn = length(strfind(dec2bin(rxChannelEn),'1'));
nTxEn = length(strfind(dec2bin(txChannelEn),'1'));

% profile config
profileCfgStr = string(c{1,1}(~cellfun(@isempty,strfind(c{1,1},'profileCfg'))));
profileCfg = double(regexp(profileCfgStr,'(\d+,)*\d+(\.\d*)?', 'match'));

startFr = profileCfg(2);            % GHz
idleTime = profileCfg(3);           % us 
adcStartTime = profileCfg(4);       % us
rampEndTime = profileCfg(5);        % us
freqSlopeConst = profileCfg(8);     % MHz/us
txStartTime = profileCfg(9);        % us
numAdcSamples = profileCfg(10);
digOutSampleRate =  profileCfg(11); % kHz

% chirp config
chirpCfgStr = string(c{1,1}(~cellfun(@isempty,strfind(c{1,1},'chirpCfg'))));
nChirps = size(chirpCfgStr,1);
for n = 1:nChirps
    chirpCfg(n,:) = double(regexp(chirpCfgStr(n),'(\d+,)*\d+(\.\d*)?', 'match'));
end

% frame config
frameCfgStr = string(c{1,1}(~cellfun(@isempty,strfind(c{1,1},'frameCfg'))));
frameCfg = double(regexp(frameCfgStr,'(\d+,)*\d+(\.\d*)?', 'match'));
nTxOn = abs(frameCfg(2)-frameCfg(1))+1;
nLoops = frameCfg(3);
nFrames = frameCfg(4);
framePeriodicity = frameCfg(5); % ms

%% Load TI RAW data file
NSamp = numAdcSamples; % samples per chirp
NChirps = nLoops; % chirps per loop per Tx channel
NTx = nTxOn;
NRx = nRxEn;
NFrames = nFrames;

% [fileName,path] = uigetfile('*.dat','Select the data file'); % select data file to load
fid = fopen([fileName],'r');
adcRaw = fread(fid,'int16');
fclose(fid);

adcRaw = adcRaw(1:2:end)+1i*adcRaw(2:2:end); % interleaved IQ

% reshape data array
adcRaw2 = reshape(adcRaw,[NRx,NTx*NSamp,NChirps,NFrames]);
if NTx==2
    adcRaw2 = [adcRaw2(:,1:NSamp,:,:);adcRaw2(:,NSamp+1:end,:,:)];
elseif NTx==3
    adcRaw2 = [adcRaw2(:,1:NSamp,:,:);adcRaw2(:,NSamp+1:2*NSamp,:,:);adcRaw2(:,2*NSamp+1:end,:,:)];
end

settings.startFr = startFr;                     % GHz
settings.idleTime = idleTime;                   % us 
settings.adcStartTime = adcStartTime;           % us
settings.rampEndTime = rampEndTime;             % us
settings.freqSlopeConst = freqSlopeConst;       % MHz/us
settings.txStartTime = txStartTime;             % us
settings.numAdcSamples = numAdcSamples;
settings.digOutSampleRate =  digOutSampleRate;  % kHz
settings.framePeriodicity = framePeriodicity;   % ms


