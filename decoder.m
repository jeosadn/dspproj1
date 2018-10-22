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
numberSegments = ceil(signalSize(1)/segmentSize);
v = rand(numberSegments,segmentSize);

index = 0;
for i = 1:numberSegments
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
%cepstrum = zeros(numberSegments,segmentSize);
%for i = 1:numberSegments
    prueba = abs(ifft(log(fft(v(10,:))).^2));
    %cepstrum(i) = prueba;
%end

%--------------------------------------------------------------------------
% Sorter
%--------------------------------------------------------------------------
%a0 = 0.2;
%t0 = 0.8;

%a1 = 0.8;
%t1 = 0.2;

figure(2);
plot(prueba);
%axis([295 305 0 60]);
hold on;
%plot(cepstrum(1));

%--------------------------------------------------------------------------
% Write audio file
%--------------------------------------------------------------------------
%Output characteristics:
% 16 bit per sample, at 44100 Hz, in stereo
%audiowrite('./decoded.wav', sampleData, sampleFrequency);


