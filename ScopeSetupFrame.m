function ScopeSetupFrame(visaObj, chan, autoscale)
fopen(visaObj);

if autoscale
    writeline(visaObj, ':AUTOSCALE');
    pause(1)
    return
end

switch chan
    case 1
        writeline(visaObj, ':TRIGGER:SOURCE CHAN1');
        writeline(visaObj, ':TRIGGER:EDGE:SLOPE POSITIVE');
        % writeline(visaObj, ':TRIGGER:LEVEL 0.5');
        % writeline(visaObj, ':TRIGGER:SWEEP NORM');
        
        writeline(visaObj,':TIMebase:SCALe 200e-6');
        writeline(visaObj,':TIMebase:POSition 862e-6');

        writeline(visaObj,':CHAN1:SCALe 34e-3');
        writeline(visaObj,':CHAN1:OFFSet 57.8e-3');

    case 2
        writeline(visaObj, ':TRIGGER:SOURCE CHAN2');
        writeline(visaObj, ':TRIGGER:EDGE:SLOPE POSITIVE');
        % writeline(visaObj, ':TRIGGER:LEVEL 0.5');
        % writeline(visaObj, ':TRIGGER:SWEEP NORM');
        
        writeline(visaObj,':TIMebase:SCALe 100e-6');
        writeline(visaObj,':TIMebase:POSition 416e-6');

        writeline(visaObj,':CHAN2:SCALe 10e-3');
        writeline(visaObj,':CHAN2:OFFSet 0e-3');


    case 3
        writeline(visaObj, ':TRIGGER:SOURCE CHAN3');
        writeline(visaObj, ':TRIGGER:EDGE:SLOPE POSITIVE');
        % writeline(visaObj, ':TRIGGER:LEVEL 0.5');
        writeline(visaObj, ':TRIGGER:SWEEP NORM');
        
        writeline(visaObj,':TIMebase:SCALe 300e-6');
        writeline(visaObj,':TIMebase:POSition 862e-6');

        writeline(visaObj,':CHAN3:SCALe 200e-3');
        writeline(visaObj,':CHAN3:OFFSet 2.5');
        writeline(visaObj, 'TRIGGER:FORCE')

    case 4
        writeline(visaObj, ':TRIGGER:SOURCE CHAN4');
        writeline(visaObj, ':TRIGGER:EDGE:SLOPE POSITIVE');
        % writeline(visaObj, ':TRIGGER:LEVEL 0.5');
        % writeline(visaObj, ':TRIGGER:SWEEP NORM');
        
        writeline(visaObj,':TIMebase:SCALe 100e-6');
        writeline(visaObj,':TIMebase:POSition 416e-6');

        writeline(visaObj,':CHAN4:SCALe 10e-3');
        writeline(visaObj,':CHAN4:OFFSet 0e-3');
end
pause(1)

end
