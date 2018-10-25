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
segmentSize = 10000;
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
cepstrum = rand(numberSegments,segmentSize);
for i = 1:numberSegments
    prueba = abs(ifft(log(fft(v(i,:))).^2));
    cepstrum(i,:) = prueba;
end

%%%% PLOT %%%%%
figure(2);
plot(cepstrum(10,:));
axis([0 segmentSize 0 6]);
hold on;
%%%%%%%%%%%%%%%%%

%--------------------------------------------------------------------------
% Sorter
%--------------------------------------------------------------------------
tolerance = 5;
a0 = 0.8;
t0 = 200;

a1 = 0.8;
t1 = 8000;

bits = zeros(numberSegments,1);
for i = 1:numberSegments
    t0_rxx = max(cepstrum(i,t0-tolerance:t0+tolerance));
    t1_rxx = max(cepstrum(i,t1-tolerance:t1+tolerance));
    if (t1_rxx > t0_rxx)
        bits(i) = 1;
    else
        bits(i) = 0;
    end    
end

bin_char = zeros(8,1);
for i = 1:8
    bin_char(i) = bits(i);
end

char = bin2dec(bits);


%--------------------------------------------------------------------------
% Write audio file
%--------------------------------------------------------------------------
%Output characteristics:
% 16 bit per sample, at 44100 Hz, in stereo
%audiowrite('./decoded.wav', sampleData, sampleFrequency);


