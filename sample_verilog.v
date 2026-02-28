// Qucs modularOPAMPmodel:
// Default parameters are for a typical UA741.
//
// This is free software; you can redistribute it and/or modify
// it under the terms of theGNUGeneral Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// Copyright (C), Mike Brinson, mbrin72043@yahoo.co.uk, November 2007.
//
‘include ”disciplines .vams”
‘include ”constants.vams”
//
modulemodamp (in p, in n, out p);
inout in p, in n, out p;
electrical in p, in n, out p;
electrical n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12;
//
‘define attr(txt) (∗txt∗)
//
parameter real GBP=1e6 from [1 : inf ]
‘attr(info=”Gain bandwidth product (Hz)”);
parameter real AOLDC=106.0 from [0.01 : inf ]
‘attr(info=”Open loopDC gain (dB)”);
parameter real FP2=3e6 from [0.01 : inf ]
‘attr(info=”Second pole frequency (Hz)”);
parameter real RO=75 from [0.01 : inf ]
‘attr(info=”Output resistance (Ohm)”);
parameter real CD=1e−12 from [1e−20 : inf ]
‘attr(info=”Differential input capacitance (F)”);
parameter real RD=2e6 from [0.01 : inf ]
‘attr(info=”Differential input resistance (Ohm)”);
parameter real IOFF=20e−9 from [1e−20 : inf ]
‘attr(info=”Input offset current (A)”);
parameter real IB=80e−9 from [1e−20 : inf ]
‘attr(info=”Input bias current (A)”);
parameter real VOFF=7e−4 from [0 : inf ]
‘attr(info=”Input voltage offset (A)”);
parameter real CMRRDC=90.0 from [1 : inf ]
‘attr(info=”Commonmode rejection ratio at DC (dB)”);
parameter real FCM=200 from [0.01 : inf ]
‘attr(info=”Commonmode zero corner frequency (Hz)”);
parameter real PSRT=5e5 from [1 : inf ]
‘attr(info=”Positive slew rate (V/s)”);
3
parameter real NSRT = 5e5 from [1 : inf ]
‘ attr ( info=”Negative slew rate (V/s)”);
parameter real VLIMP = 14 from [0.01 : inf ]
‘ attr ( info=”Positve output
voltage limit (V)”);
parameter real VLIMN = −14 from [−inf : 0]
‘ attr ( info=”Negative output
voltage limit (V)”);
parameter real ILMAX = 35e−3 from [1e−9 : inf ]
‘ attr ( info=”Maximum
DCoutput
current (A)”);
parameter real CSCALE = 50 from [0 : inf ]
‘ attr ( info=”Current
l i mit scaling factor ”);
//
real RP1, CP1, RP2, CP2;
real Rdiff , Voffset ;
real CMRR0, CMgain, CCM;
real Slewratepositive , Slewratenegative ;
real MTWOPI;
//
analog begin
//
// Constants
//
MTWOPI = 6.28318530717958647693;
//
// Design equations
//
Voffset = VOFF∗5;
Rdiff = RD/2;
CMRR0 = pow(10, CMRRDC/20);
CMgain = 1e6/CMRR0;
CCM = 1.0/(MTWOPI∗1e6∗FCM);
RP1 = pow(10, AOLDC/20);
CP1 = 1/(MTWOPI∗GBP);
RP2 = 1;
CP2 = 1/(MTWOPI∗FP2);
Slewratepositive = PSRT/(MTWOPI∗GBP);
Slewratenegative = NSRT/(MTWOPI∗GBP);
//
// Input voltage offset
//
I ( in
p , n7) <+ V(in
I ( in
p , n7);
p , n7) <+ Voffset ;
//
//
I ( in
I ( in
n , n9) <+ V(in
n , n9);
n , n9) <+ −Voffset ;
// Input bias currents
//
I (n7) <+ IB;
I (n9) <+ IB;
//
// Input current offset
//
I (n7 ,n9) <+ IOFF/2;
//
// Input differential resistance and capacitance
//
I (n7 , n8) <+ V(n7, n8)/Rdiff ;
I (n9 , n8) <+ V(n9, n8)/Rdiff ;
I (n7 , n9) <+ ddt(CD∗V(n7, n9));
//
// Common mode stage
//
4
I (n6) <+ −CMgain∗V(n8);
I (n6) <+ V(n6);
I (n6 , n10) <+ V(n6, n10)/1e6;
I (n6 , n10) <+ ddt(CCM∗V(n6, n10));
I (n10) <+ V(n10);
//
// Differential mode and common mode signal adder stage
//
I (n11) <+ −V(n10);
I (n11) <+ −V(n7, n9);
I (n11) <+ V(n11);
//
// Slew rate limiting stage
//
i f (V(n11) > Slewratepositive)
I (n12) <+ −Slewratepositive ;
else if (V(n11) < −Slewratenegative)
I (n12) <+ Slewratenegative ;
else I(n12) <+ −V(n11);
I (n12) <+ V(n12);
//
// First pole
//
I (n3) <+ −V(n12);
I (n3) <+ V(n3)/RP1;
I (n3) <+ ddt(CP1∗V(n3));
//
// Second pole
//
I (n5) <+ −V(n3);
I (n5) <+ V(n5)/RP2;
I (n5) <+ ddt(CP2∗V(n5));
//
// Current limiter stage
//
i f (V(n2, out p) >= ILMAX)
begin
I (n4) <+ −V(n5);
I (n4) <+ CSCALE∗V(n5)∗(V(n2, out p) − ILMAX);
I (n4) <+ V(n4);
end
else if (V(n2, out p) <= −ILMAX)
begin
I (n4) <+ −V(n5);
I (n4) <+ −CSCALE∗V(n5)∗(V(n2, out p) + ILMAX);
I (n4) <+ V(n4);
end
else
begin
I (n4) <+ −V(n5);
I (n4) <+ V(n4);
end
//
// Output resistance
//
I (n4 , n2) <+ V(n4, n2)/(RO−1);
I (n2 , out p) <+ V(n2, out p);
//
//
// Voltage limiter stage
//
5
i f (V(out p) > VLIMP)
begin
I ( out p) <+ −10.0∗VLIMP;
I ( out p) <+ 10.0∗V(out p);
end
else if (V(out p) < VLIMN)
begin
I ( out p) <+ −10.0∗VLIMN;
I ( out p) <+ 10.0∗V(out p);
end
end
endmodule