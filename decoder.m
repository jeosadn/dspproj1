%no popups
set(gcf, 'Visible', 'off');

%imports
addpath('./export_fig/');

%--------------------------------------------------------------------------
% Read audio File
%--------------------------------------------------------------------------
%Input characteristics:
% 16 bit per sample, at 44100 Hz, in stereo
[sampleData, sampleFrequency] = audioread('./coded.wav');

%--------------------------------------------------------------------------
% Segment signal
%--------------------------------------------------------------------------
segmentSize = 400;
Channel = 1;

signalSize = size(sampleData(:,Channel));
segmentTotal = ceil(signalSize(1)/segmentSize);
v = rand(segmentTotal,segmentSize);

index = 0;
for i = 1:segmentTotal
    for j = 1:segmentSize
        index = index+1;
        if (index < signalSize(1))
            v(i,j) = sampleData(index,Channel);
        else
            v(i,j) = 0;   
        end
    end
end

%--------------------------------------------------------------------------
% Cepstrum autocorrelation
%--------------------------------------------------------------------------
for i = 1:segmentTotal
    cepstrum = ifft(log(fft(v(i)))^2);
end

%--------------------------------------------------------------------------
% Sorter
%--------------------------------------------------------------------------
a0 = 0.2;
t0 = 0.8;

a1 = 0.8;
t1 = 0.2;

%--------------------------------------------------------------------------
% Write audio file
%--------------------------------------------------------------------------
%Output characteristics:
% 16 bit per sample, at 44100 Hz, in stereo
%audiowrite('./decoded.wav', sampleData, sampleFrequency);


