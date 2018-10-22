%no popups
set(gcf, 'Visible', 'off');

%imports
addpath('./export_fig/');

%--------------------------------------------------------------------------
% Read audio File
%--------------------------------------------------------------------------
%Input characteristics:
% 16 bit per sample, at 44100 Hz, in stereo
[sampleData, sampleFrequency] = audioread('./sample.wav');

%--------------------------------------------------------------------------
% Segment signal
%--------------------------------------------------------------------------
segmentSize = 400; %This should come from the parameters.
Channel = 1; %This should come from the parameters.

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

prueba1 = abs(ifft(log(fft(v(10,:))).^2));
figure(1);
plot(prueba1);
%axis([0 400 0 60]);
hold on;
%--------------------------------------------------------------------------
% Multiplexing and Combining
%--------------------------------------------------------------------------
metaData = round(rand(segmentTotal,1)); %This should be real metaData.
metaData(10) = 1;

%H0(z) = 1 + a0*z^(-t0)
a0 = 1*10^20; %This could come from the parameters.
t0 = 100; %This could come from the parameters.

H0 = zeros(t0,1);
H0(1) = 1;
H0(t0) = a0;
h0 = impz(H0,1);
h0 = h0';

%H1(z) = 1 + a1*z^(-t1)
a1 = 5*10^20; %This could come from the parameters.
t1 = 300; %This could come from the parameters.

H1 = zeros(t1,1);
H1(1) = 1;
H1(t1) = a1;
h1 = impz(H1,1);
h1 = h1';

%figure;
%stem(h1);
%hold on
%stem(h0);

temp0 = zeros(1,segmentSize+t0-1);
temp1 = zeros(1,segmentSize+t1-1);

ex0 = zeros(1,t0-1);
ex1 = zeros(1,t1-1);

for i = 1:segmentTotal
    if(metaData(i))
        temp1 = conv(v(i,:),h1);
        for j = 1:segmentSize+t1-1
            if (j<=segmentSize)
                if (j>t1-1)
                    v(i,j) = temp1(j);
                else
                    v(i,j) = temp1(j)+ex1(j);
                end
            else
                ex1(j-segmentSize) = temp1(j);
            end
        end
    else
        temp0 = conv(v(i,:),h0);
        for j = 1:segmentSize+t0-1
            if (j<=segmentSize)
                if (j>t0-1)
                    v(i,j) = temp0(j);
                else
                    v(i,j) = temp0(j)+ex0(j);
                end
            else
                ex0(j-segmentSize) = temp0(j);
            end
        end
    end
end

prueba2 = abs(ifft(log(fft(v(10,:))).^2));
plot(prueba2);
axis([25 375 0 30]);
hold on;

%--------------------------------------------------------------------------
% Unifying segments
%--------------------------------------------------------------------------
index = 0;
for i = 1:segmentTotal
    for j = 1:segmentSize
        index = index+1;        
        if (index < signalSize(1))
            sampleData(index,Channel) = v(i,j);
        end
    end
end

% Adding this to remove warning from audiowrite function.
maxValue = max( abs(sampleData(:,Channel)) );
for i = 1:signalSize(1)
    sampleData(i,Channel) = sampleData(i,Channel)/maxValue;
end

%--------------------------------------------------------------------------
% Write audio file
%--------------------------------------------------------------------------
%Output characteristics:
% 16 bit per sample, at 44100 Hz, in stereo
audiowrite('./coded.wav', sampleData, sampleFrequency);
