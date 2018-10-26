function [dataDecoded] = decoder(a0,t0,a1,t1,segmentSize,Channel,decoder_delay_tolerance)
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
    plot(cepstrum(11,:));
    axis([0 segmentSize 0 6]);
    hold on;
    %%%%%%%%%%%%%%%%%

    %--------------------------------------------------------------------------
    % Sorter
    %--------------------------------------------------------------------------
    %tolerance = 5;
    %a0 = 0.8;
    %t0 = 2000;

    %a1 = 0.2;
    %t1 = 8000;

    dataDecoded = zeros(numberSegments,1);
    for i = 1:numberSegments
        t0_rxx = max(cepstrum(i,t0-decoder_delay_tolerance:t0+decoder_delay_tolerance));
        t1_rxx = max(cepstrum(i,t1-decoder_delay_tolerance:t1+decoder_delay_tolerance));
        if (t1_rxx > t0_rxx)
            dataDecoded(i) = 1;
        else
            dataDecoded(i) = 0;
        end    
    end

    %bin_char = zeros(8,1);
    %for i = 1:8
    %    bin_char(i) = bits(i);
    %end

    %char = bin2dec(bits);
end