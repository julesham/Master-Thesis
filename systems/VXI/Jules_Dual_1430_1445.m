 %// Initialise the global varaibles
 disp('used local DUAL File')
  
InitGlob;
global ANNA
M = 14;
ANNA.Simul                        = false;
ANNA.DBsession                    = 0;
ANNA.SyntheticData                = false;				%// logical(1) if the data is to be loaded in the DB 

DivFac = 2^2;  % clock = 10e6/DivFac Hz
BlockLength = 2^12;

%// Open the default VISA session
OpenDef;

%// den DUT
IndexNext;
G_Dev(IndexGet).RsrcId 				    = 'DUT';
G_Dev(IndexGet).Name                    = 'DUTPt1';
[Status,G_Dev(IndexGet).session]        = DUT_Open('DutPt1');
DutRef(1)                               = IndexGet;

%// den DUT
IndexNext;
G_Dev(IndexGet).RsrcId 				    = 'DUT';
G_Dev(IndexGet).Name                    = 'DUTPt2';
[Status,G_Dev(IndexGet).session]        = DUT_Open('DutPt2');
DutRef(2)                               = IndexGet;

%// CLOCK Generators
IndexNext;
G_Dev(IndexGet).RsrcId 				    = 'vxi0::128';
G_Dev(IndexGet).Name                    = 'CLKMaster';
[Status,G_Dev(IndexGet).session]        = hpe1430('init',G_Dev(IndexGet).RsrcId,0,0);CheckOpenStatus(G_viDefaultRM,Status,G_Dev(IndexGet).Name);
CLKRef(1)                               = IndexGet;

IndexNext;
G_Dev(IndexGet).RsrcId 				    = 'vxi0::128';
G_Dev(IndexGet).Name                    = 'CLKSlave';
[Status,G_Dev(IndexGet).session]        = hpe1430('init',G_Dev(IndexGet).RsrcId,0,0);CheckOpenStatus(G_viDefaultRM,Status,G_Dev(IndexGet).Name);
CLKRef(2)                               = IndexGet;

IndexNext;
G_Dev(IndexGet).RsrcId 				    = 'vxi0::104';
G_Dev(IndexGet).Name                    = 'CLKSlave';
[Status,G_Dev(IndexGet).session]        = hpe1430('init',G_Dev(IndexGet).RsrcId,0,0);CheckOpenStatus(G_viDefaultRM,Status,G_Dev(IndexGet).Name);
CLKRef(3)                               = IndexGet;

IndexNext;
G_Dev(IndexGet).RsrcId				    = 'vxi0::85';
G_Dev(IndexGet).Name              = 'CLKAWG';
[Status,G_Dev(IndexGet).session]	= viOpen(G_viDefaultRM,G_Dev(IndexGet).RsrcId);CheckStatus(G_viDefaultRM,Status);
CLKRef(4)                         = IndexGet; 

%// TRIGGER Generators
IndexNext;
G_Dev(IndexGet).RsrcId 				    = 'vxi0::85';
G_Dev(IndexGet).Name              = 'TRIGMaster';
[Status,G_Dev(IndexGet).session]	= viOpen(G_viDefaultRM,G_Dev(IndexGet).RsrcId);CheckStatus(G_viDefaultRM,Status);
TRIGRef(1)                        = IndexGet;

IndexNext;
G_Dev(IndexGet).RsrcId 				    = 'vxi0::128';
G_Dev(IndexGet).Name              = 'TRIGSlave';
[Status,G_Dev(IndexGet).session]	= hpe1430('init',G_Dev(IndexGet).RsrcId,0,0);CheckOpenStatus(G_viDefaultRM,Status,G_Dev(IndexGet).Name);
TRIGRef(2)                        = IndexGet;

% IF generators: AWG
IndexNext;
G_Dev(IndexGet).RsrcId 		     	  = 'vxi0::85';
[Status,G_Dev(IndexGet).session]	= viOpen(G_viDefaultRM,G_Dev(IndexGet).RsrcId);CheckStatus(G_viDefaultRM,Status);
IFGenRef(1)                       = IndexGet;

% ACQUISITION
IndexNext;
G_Dev(IndexGet).RsrcId 				    = 'vxi0::128';
[Status,G_Dev(IndexGet).session]	= hpe1430('init',G_Dev(IndexGet).RsrcId,0,0);CheckStatus(G_viDefaultRM,Status);
AcqRef(1)                         = IndexGet;

IndexNext;
G_Dev(IndexGet).RsrcId 				    = 'vxi0::104';
[Status,G_Dev(IndexGet).session]	= hpe1430('init',G_Dev(IndexGet).RsrcId,0,0);CheckStatus(G_viDefaultRM,Status);
AcqRef(2)                         = IndexGet;

% PORT DEFINITION
IndexNext;
G_Dev(IndexGet).RsrcId				= 'port1';
G_Dev(IndexGet).session				= 1;
PortRef(1)                    = IndexGet;
IndexNext;
G_Dev(IndexGet).RsrcId				= 'port2';
G_Dev(IndexGet).session				= 2;
PortRef(2)                    = IndexGet;


%================ CONNECTIONS DEFINITION SECTION =============================================================

% CONVENTION:  Inputs and output are defined by the standard energy flow through the device

% port connections
G_Dev(PortRef(1)).ClkSsn     = NO_SESSION;			% No clock connection
G_Dev(PortRef(1)).OutClk     = 'NON';						% No clock generation ('NON','EXT','INT','VXI')
G_Dev(PortRef(1)).TrigSsn    = NO_SESSION;			% No trigger
G_Dev(PortRef(1)).OutTrig    = 'NON';						% No trigger generation ('NON','EXT','INT','VXI')
G_Dev(PortRef(1)).InSsn      = IFGenRef(1);		% This is a generator
G_Dev(PortRef(1)).OutSsn     = [NO_SESSION,NO_SESSION,NO_SESSION,AcqRef(1),NO_SESSION];
																								% A-wave(a), B-wave(b) DUT(d), Voltage(v) and Current(i) port as output
																								% WARNING : THE ORDER IS VITAL ! UNEXISTANT NODES ARE PADDED WITH NO_SESSION
G_Dev(PortRef(1)).SubSsn     = NO_SESSION;			% Card is not divided in channels
G_Dev(PortRef(1)).Type       = 'PORT';					% port type
G_Dev(PortRef(1)).Name       = 'PORT1';

% port connections
G_Dev(PortRef(2)).ClkSsn     = NO_SESSION;			% No clock clock
G_Dev(PortRef(2)).OutClk     = 'NON';						% No clock generation ('NON','EXT','INT','VXI')
G_Dev(PortRef(2)).TrigSsn    = NO_SESSION;			% No trigger
G_Dev(PortRef(2)).OutTrig	   = 'NON';						% No trigger generation ('NON','EXT','INT','VXI')
G_Dev(PortRef(2)).InSsn      = NO_SESSION;			% No generator present
G_Dev(PortRef(2)).OutSsn     = [NO_SESSION,NO_SESSION,NO_SESSION,AcqRef(2),NO_SESSION];
																								% A-wave(a), B-wave(b) DUT(d), Voltage(v) and Current(i) port as output
																								% WARNING : THE ORDER IS VITAL ! UNEXISTANT NODES ARE PADDED WITH NO_SESSION
G_Dev(PortRef(2)).SubSsn     = NO_SESSION;			% Card is not divided in channels
G_Dev(PortRef(2)).Type       = 'PORT';					% port type
G_Dev(PortRef(2)).Name       = 'PORT2';

%// DUT connections
G_Dev(DutRef(1)).ClkSsn     = NO_SESSION;				%// No clock clock
G_Dev(DutRef(1)).OutClk     = 'NON';						%// No clock generation ('NON','EXT','INT','VXI')
G_Dev(DutRef(1)).TrigSsn    = NO_SESSION;				%// No trigger
G_Dev(DutRef(1)).OutTrig    = 'NON';						%// No trigger generation ('NON','EXT','INT','VXI')
G_Dev(DutRef(1)).InSsn      = PortRef(1);			%// Who is connected to port2?
G_Dev(DutRef(1)).OutSsn     = NO_SESSION;
																								%// A-wave(a), B-wave(b) DUT(d), Voltage(v) and Current(i) port as output
																								%// WARNING : THE ORDER IS VITAL ! UNEXISTANT NODES ARE PADDED WITH NO_SESSION
G_Dev(DutRef(1)).SubSsn     = 1;								%// Card is not divided in channels
G_Dev(DutRef(1)).Type       = 'DUT';						%// port type

%// DUT connections
G_Dev(DutRef(2)).ClkSsn     = NO_SESSION;				%// No clock clock
G_Dev(DutRef(2)).OutClk     = 'NON';						%// No clock generation ('NON','EXT','INT','VXI')
G_Dev(DutRef(2)).TrigSsn    = NO_SESSION;				%// No trigger
G_Dev(DutRef(2)).OutTrig    = 'NON';						%// No trigger generation ('NON','EXT','INT','VXI')
G_Dev(DutRef(2)).InSsn      = PortRef(2);			%// Who is connected to port2?
G_Dev(DutRef(2)).OutSsn     = NO_SESSION;
																								%// A-wave(a), B-wave(b) DUT(d), Voltage(v) and Current(i) port as output
																								%// WARNING : THE ORDER IS VITAL ! UNEXISTANT NODES ARE PADDED WITH NO_SESSION
G_Dev(DutRef(2)).SubSsn     = 2;								%// Card is not divided in channels
G_Dev(DutRef(2)).Type       = 'DUT';						%// port type

%// CLOCK connections
%// CLKMaster
G_Dev(CLKRef(1)).ClkSsn				= NO_SESSION ;    %// Generates its own reference clock
G_Dev(CLKRef(1)).OutClk				= 'VXI';					%// Generates an external clock ('NON','EXT','INT','VXI')
G_Dev(CLKRef(1)).TrigSsn			= NO_SESSION;     %// We do not support sweeping, hence no trigger
G_Dev(CLKRef(1)).OutTrig			= 'NON';					%// No trigger generation ('NON','EXT','INT','VXI')
G_Dev(CLKRef(1)).InSsn				= NO_SESSION;     %// This is a clock generator
G_Dev(CLKRef(1)).OutSsn				= NO_SESSION;		  %// This is a clock generator
G_Dev(CLKRef(1)).SubSsn				= NO_SESSION;		  %// Card is not divided in channels
G_Dev(CLKRef(1)).Type         =	'CLK';          %// clock type

%// CLKSlave
G_Dev(CLKRef(2)).ClkSsn				= CLKRef(1);	    %// Takes its reference from the clkmaster
G_Dev(CLKRef(2)).OutClk				= 'INT';					%// Generates an external clock ('NON','EXT','INT','VXI')
G_Dev(CLKRef(2)).TrigSsn			= NO_SESSION;     %// We do not support sweeping, hence no trigger
G_Dev(CLKRef(2)).OutTrig			= 'NON';					%// No trigger generation ('NON','EXT','INT','VXI')
G_Dev(CLKRef(2)).InSsn				= NO_SESSION;     %// This is a clock generator
G_Dev(CLKRef(2)).OutSsn				= NO_SESSION;		  %// This is a clock generator
G_Dev(CLKRef(2)).SubSsn				= NO_SESSION;		  %// Card is not divided in channels
G_Dev(CLKRef(2)).Type         =	'CLK';          %// clock type


%// CLKSlave
G_Dev(CLKRef(3)).ClkSsn				= CLKRef(1) ;			%// Takes its reference clock from the clockmaster
G_Dev(CLKRef(3)).OutClk				= 'INT';					%// Generates an backplane clock ('NON','EXT','INT','VXI')
G_Dev(CLKRef(3)).TrigSsn			= NO_SESSION;     %// We do not support sweeping, hence no trigger
G_Dev(CLKRef(3)).OutTrig			= 'NON';					%// No trigger generation ('NON','EXT','INT','VXI')
G_Dev(CLKRef(3)).InSsn				= NO_SESSION;     %// This is a clock generator
G_Dev(CLKRef(3)).OutSsn				= NO_SESSION;			%// This is a clock generator
G_Dev(CLKRef(3)).SubSsn				= NO_SESSION;		  %// Card is not divided in channels
G_Dev(CLKRef(3)).Type         =	'CLK';          %// clock type

%// CLKAWG
G_Dev(CLKRef(4)).ClkSsn				= CLKRef(1);	    %// Takes its reference from the clkmaster
G_Dev(CLKRef(4)).OutClk				= 'INT';					%// Generates an external clock ('NON','EXT','INT','VXI')
G_Dev(CLKRef(4)).TrigSsn			= NO_SESSION;     %// We do not support sweeping, hence no trigger
G_Dev(CLKRef(4)).OutTrig			= 'NON';					%// No trigger generation ('NON','EXT','INT','VXI')
G_Dev(CLKRef(4)).InSsn				= NO_SESSION;     %// This is a clock generator
G_Dev(CLKRef(4)).OutSsn				= NO_SESSION;		  %// This is a clock generator
G_Dev(CLKRef(4)).SubSsn				= NO_SESSION;		  %// Card is not divided in channels
G_Dev(CLKRef(4)).Type         =	'CLK';          %// clock type


%// TRIGGER connections
G_Dev(TRIGRef(1)).ClkSsn			= NO_SESSION ;    %// Generates its own reference clock
G_Dev(TRIGRef(1)).OutClk			= 'NON';					%// Generates an external clock ('NON','EXT','INT','VXI')
G_Dev(TRIGRef(1)).TrigSsn			= NO_SESSION;     %// We do not support sweeping, hence no trigger
G_Dev(TRIGRef(1)).OutTrig			= 'EXT';					%// No trigger generation ('NON','EXT','INT','VXI')
G_Dev(TRIGRef(1)).InSsn				= NO_SESSION;     %// This is a generator
G_Dev(TRIGRef(1)).OutSsn			= NO_SESSION;			%// Generator feeds the switches to the ports and the powermeter
G_Dev(TRIGRef(1)).SubSsn			= NO_SESSION;		  %// Card is not divided in channels
G_Dev(TRIGRef(1)).Type				=	'TRIG';         %// Generator type

G_Dev(TRIGRef(2)).ClkSsn			= NO_SESSION ;    %// Generates its own reference clock
G_Dev(TRIGRef(2)).OutClk			= 'NON';					%// Generates an external clock ('NON','EXT','INT','VXI')
G_Dev(TRIGRef(2)).TrigSsn			= TRIGRef(1);     %// We do not support sweeping, hence no trigger
G_Dev(TRIGRef(2)).OutTrig			= 'VXI';					%// No trigger generation ('NON','EXT','INT','VXI')
G_Dev(TRIGRef(2)).InSsn				= NO_SESSION;     %// This is a generator
G_Dev(TRIGRef(2)).OutSsn			= NO_SESSION;			%// Generator feeds the switches to the ports and the powermeter
G_Dev(TRIGRef(2)).SubSsn			= NO_SESSION;		  %// Card is not divided in channels
G_Dev(TRIGRef(2)).Type				=	'TRIG';         %// Generator type


% IF Generator connections
G_Dev(IFGenRef(1)).ClkSsn     = CLKRef(4);			% Gets the reference clock from ascquisition master
G_Dev(IFGenRef(1)).OutClk     = 'NON';					% No clock generation ('NON','EXT','INT','VXI')
G_Dev(IFGenRef(1)).TrigSsn    = TRIGRef(1);			% No trigger
G_Dev(IFGenRef(1)).OutTrig	  = 'NON';					% No trigger generation ('NON','EXT','INT','VXI')
G_Dev(IFGenRef(1)).InSsn      = NO_SESSION;     % This is a generator
G_Dev(IFGenRef(1)).OutSsn     = PortRef(1);			% Connection to the DownConvertors
G_Dev(IFGenRef(1)).SubSsn     = NO_SESSION;			% Card is not divided in channels
G_Dev(IFGenRef(1)).Type       = 'AWG';         % Generator type
G_Dev(IFGenRef(1)).Name       = 'AWG(LA81)';

% Acquisition connections
G_Dev(AcqRef(1)).ClkSsn       = CLKRef(2);      % Gets the reference clock from Acquisition Card (1) via the backplane
G_Dev(AcqRef(1)).OutClk       = 'NON';					% No clock generation ('NON','EXT','INT','VXI')
G_Dev(AcqRef(1)).TrigSsn      = TRIGRef(2);     % triggering from the generator marker 
G_Dev(AcqRef(1)).OutTrig      = 'NON';					% No trigger generation ('NON','EXT','INT','VXI')
G_Dev(AcqRef(1)).InSsn        = PortRef(1);			% Connected to port 1
G_Dev(AcqRef(1)).OutSsn       = NO_SESSION;     % No outputs
G_Dev(AcqRef(1)).SubSsn       = NO_SESSION;     % Card is not divided in channels
G_Dev(AcqRef(1)).Type         = 'ACQ';          % Acquisition type
G_Dev(AcqRef(1)).Name         = 'ACQ(LA128)';

G_Dev(AcqRef(2)).ClkSsn       = CLKRef(3);      % Gets the reference clock from Acquisition Card (4) via the backplane
G_Dev(AcqRef(2)).OutClk	      = 'NON';				% No clock generation ('NON','EXT','INT','VXI')
G_Dev(AcqRef(2)).TrigSsn      = TRIGRef(2);      % Gets the trigger from Acquisition Card (1) via the backplane
G_Dev(AcqRef(2)).OutTrig      = 'NON';				% No trigger generation ('NON','EXT','INT','VXI')
G_Dev(AcqRef(2)).InSsn        = PortRef(2);		% Connected to port 2
G_Dev(AcqRef(2)).OutSsn       = NO_SESSION;     % No outputs
G_Dev(AcqRef(2)).SubSsn       = NO_SESSION;     % Card is not divided in channels
G_Dev(AcqRef(2)).Type         = 'ACQ';          % Acquisition type
G_Dev(AcqRef(2)).Name         = 'ACQ(LA104)';


disp(' ANNA : hardware present & all communication channels open ')

% Hardware defaults to be loaded in the modules.

% Acquisition cards
G_DevDefault(AcqRef(1)).Range   	= '9';
G_DevDefault(AcqRef(1)).BlockSize	= BlockLength;
G_DevDefault(AcqRef(1)).Coupling	= 'DC';
G_DevDefault(AcqRef(1)).Delay			= 0;
G_DevDefault(AcqRef(1)).Offset		= 0;

G_DevDefault(AcqRef(2)).Range   	= '9';
G_DevDefault(AcqRef(2)).BlockSize	= BlockLength;
G_DevDefault(AcqRef(2)).Coupling	= 'DC';
G_DevDefault(AcqRef(2)).Delay			= 0;
G_DevDefault(AcqRef(2)).Offset		= 0;


%// CLK settings.
%// This is the primary clock, hence the absolute clock frequency is specified.
G_DevDefault(CLKRef(1)).Freq		    = 10e6;
G_DevDefault(CLKRef(1)).DivFac			= [];
G_DevDefault(CLKRef(1)).MulFac			= [];
G_DevDefault(CLKRef(1)).Offset			= 0;
G_DevDefault(CLKRef(1)).Span		    = [];
G_DevDefault(CLKRef(1)).Period			= [];
G_DevDefault(CLKRef(1)).Steps			= [];

%// A secundary clock scales the input frequency and deserves a scale factor
%// rather than an absolute frequency.
G_DevDefault(CLKRef(2)).Freq        = [];
G_DevDefault(CLKRef(2)).DivFac			= DivFac;				
G_DevDefault(CLKRef(2)).MulFac			= 1;		
G_DevDefault(CLKRef(2)).Offset			= 0;		
G_DevDefault(CLKRef(2)).Span		    = [];
G_DevDefault(CLKRef(2)).Period			= [];
G_DevDefault(CLKRef(2)).Steps			= [];

G_DevDefault(CLKRef(3)).Freq        = [];
G_DevDefault(CLKRef(3)).DivFac			= DivFac;		
G_DevDefault(CLKRef(3)).MulFac			= 1;		
G_DevDefault(CLKRef(3)).Offset			= 0;		
G_DevDefault(CLKRef(3)).Span		    = [];
G_DevDefault(CLKRef(3)).Period			= [];
G_DevDefault(CLKRef(3)).Steps			= [];

G_DevDefault(CLKRef(4)).Freq        = [];
G_DevDefault(CLKRef(4)).DivFac			= DivFac;		
G_DevDefault(CLKRef(4)).MulFac			= 1;		
G_DevDefault(CLKRef(4)).Offset			= 0;		
G_DevDefault(CLKRef(4)).Span		    = [];
G_DevDefault(CLKRef(4)).Period			= [];
G_DevDefault(CLKRef(4)).Steps			= [];

G_DevDefault(IFGenRef(1)).VMax			= 0.4;
G_DevDefault(IFGenRef(1)).Offset		= 0;
G_DevDefault(IFGenRef(1)).Wave			= sin(2*pi*(1:1024)/1024);


% HARDWARE SESSION DEFINITION
%
% DEFINITION OF THE STRUCTURE OF THE INSTRUMENT

% === SECTION 2 : PORT-LEVEL DEVICES ======
% CONVENTION : 1 COLUMN = ONE PORT
%
% Define all ports

ANNA.Ports        = [PortRef(1), PortRef(2)];



