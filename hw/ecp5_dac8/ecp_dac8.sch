EESchema Schematic File Version 4
LIBS:ecp_dac8-cache
EELAYER 29 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "ECP5 Robotron DAC8"
Date "2019-05-28"
Rev "20190528"
Comp "ShareBrained Technology, Inc."
Comment1 "Copyright 2019 Jared Boone"
Comment2 "Open-source license to be determined."
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L analog_devices:AD5621BKSZ U1
U 1 1 5CECBFD4
P 6650 3150
F 0 "U1" H 6650 3615 50  0000 C CNN
F 1 "AD5611BKSZ" H 6650 3524 50  0000 C CNN
F 2 "ipc_sot:IPC_SOT23-6P65_210X110L36X22N" H 6650 3250 50  0001 C CNN
F 3 "https://www.analog.com/media/en/technical-documentation/data-sheets/AD5601_5611_5621.pdf" H 6650 3250 50  0001 C CNN
F 4 "Analog Devices" H 6650 3150 50  0001 C CNN "Mfr"
F 5 "AD5611BKSZ" H 6650 3150 50  0001 C CNN "Part"
	1    6650 3150
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0105
U 1 1 5CECC417
P 6850 3550
F 0 "#PWR0105" H 6850 3300 50  0001 C CNN
F 1 "GND" H 6855 3377 50  0000 C CNN
F 2 "" H 6850 3550 50  0001 C CNN
F 3 "" H 6850 3550 50  0001 C CNN
	1    6850 3550
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0106
U 1 1 5CECD777
P 5650 3650
F 0 "#PWR0106" H 5650 3500 50  0001 C CNN
F 1 "VCC" V 5668 3777 50  0000 L CNN
F 2 "" H 5650 3650 50  0001 C CNN
F 3 "" H 5650 3650 50  0001 C CNN
	1    5650 3650
	0    -1   -1   0   
$EndComp
$Comp
L Device:C_Small C2
U 1 1 5CECE785
P 6450 3850
F 0 "C2" H 6542 3896 50  0000 L CNN
F 1 "100N" H 6542 3805 50  0000 L CNN
F 2 "ipc_capc:IPC_CAPC100X50X55L25N" H 6450 3850 50  0001 C CNN
F 3 "~" H 6450 3850 50  0001 C CNN
F 4 "Murata" H 6450 3850 50  0001 C CNN "Mfr"
F 5 "GRM155R61A104KA01D" H 6450 3850 50  0001 C CNN "Part"
	1    6450 3850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0107
U 1 1 5CECEF2E
P 6450 4050
F 0 "#PWR0107" H 6450 3800 50  0001 C CNN
F 1 "GND" H 6455 3877 50  0000 C CNN
F 2 "" H 6450 4050 50  0001 C CNN
F 3 "" H 6450 4050 50  0001 C CNN
	1    6450 4050
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C1
U 1 1 5CED312A
P 6050 3850
F 0 "C1" H 6142 3896 50  0000 L CNN
F 1 "10U" H 6142 3805 50  0000 L CNN
F 2 "ipc_capc:IPC_CAPC200X125X135L45N" H 6050 3850 50  0001 C CNN
F 3 "~" H 6050 3850 50  0001 C CNN
F 4 "Samsung" H 6050 3850 50  0001 C CNN "Mfr"
F 5 "CL21A106KPCLQNC" H 6050 3850 50  0001 C CNN "Part"
	1    6050 3850
	1    0    0    -1  
$EndComp
$Comp
L Device:L_Small L1
U 1 1 5CED4137
P 5850 3650
F 0 "L1" V 6035 3650 50  0000 C CNN
F 1 "FB" V 5944 3650 50  0000 C CNN
F 2 "ipc_indc:IPC_INDC100X50X60L20N" H 5850 3650 50  0001 C CNN
F 3 "~" H 5850 3650 50  0001 C CNN
F 4 "Murata" H 5850 3650 50  0001 C CNN "Mfr"
F 5 "BLM15AG700SN1D" H 5850 3650 50  0001 C CNN "Part"
	1    5850 3650
	0    -1   -1   0   
$EndComp
Wire Wire Line
	5650 3650 5750 3650
$Comp
L power:GND #PWR0108
U 1 1 5CED4B48
P 6050 4050
F 0 "#PWR0108" H 6050 3800 50  0001 C CNN
F 1 "GND" H 6055 3877 50  0000 C CNN
F 2 "" H 6050 4050 50  0001 C CNN
F 3 "" H 6050 4050 50  0001 C CNN
	1    6050 4050
	1    0    0    -1  
$EndComp
Wire Wire Line
	5950 3650 6050 3650
Wire Wire Line
	6450 3550 6450 3650
Connection ~ 6450 3650
Wire Wire Line
	6450 3650 6450 3750
Wire Wire Line
	6050 3750 6050 3650
Connection ~ 6050 3650
Wire Wire Line
	6050 3650 6450 3650
Wire Wire Line
	6050 3950 6050 4050
Wire Wire Line
	6450 4050 6450 3950
Wire Wire Line
	6250 2950 5750 2950
Wire Wire Line
	5750 3050 6250 3050
Wire Wire Line
	5750 3150 6250 3150
$Comp
L Device:Opamp_Dual_Generic U2
U 1 1 5CF88A94
P 8300 3300
F 0 "U2" H 8450 3550 50  0000 C CNN
F 1 "LME49721MAX" H 8500 3450 50  0000 C CNN
F 2 "ipc_soic:IPC_SOIC8P127_490X599X175L84X41N" H 8300 3300 50  0001 C CNN
F 3 "~" H 8300 3300 50  0001 C CNN
F 4 "Texas Instruments" H 8300 3300 50  0001 C CNN "Mfr"
F 5 "LME49721MAX" H 8300 3300 50  0001 C CNN "Part"
	1    8300 3300
	1    0    0    -1  
$EndComp
$Comp
L Device:Opamp_Dual_Generic U2
U 2 1 5CF8A10A
P 8300 4600
F 0 "U2" H 8300 4967 50  0000 C CNN
F 1 "LME49721MAX" H 8300 4876 50  0000 C CNN
F 2 "ipc_soic:IPC_SOIC8P127_490X599X175L84X41N" H 8300 4600 50  0001 C CNN
F 3 "~" H 8300 4600 50  0001 C CNN
F 4 "Texas Instruments" H 8300 4600 50  0001 C CNN "Mfr"
F 5 "LME49721MAX" H 8300 4600 50  0001 C CNN "Part"
	2    8300 4600
	1    0    0    -1  
$EndComp
$Comp
L Device:Opamp_Dual_Generic U2
U 3 1 5CF8A688
P 8300 3300
F 0 "U2" H 8258 3300 50  0001 L CNN
F 1 "LME49721MAX" H 8258 3255 50  0001 L CNN
F 2 "ipc_soic:IPC_SOIC8P127_490X599X175L84X41N" H 8300 3300 50  0001 C CNN
F 3 "~" H 8300 3300 50  0001 C CNN
F 4 "Texas Instruments" H 8300 3300 50  0001 C CNN "Mfr"
F 5 "LME49721MAX" H 8300 3300 50  0001 C CNN "Part"
	3    8300 3300
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R4
U 1 1 5CF8BDF8
P 9200 3300
F 0 "R4" V 9004 3300 50  0000 C CNN
F 1 "150R" V 9095 3300 50  0000 C CNN
F 2 "ipc_resc:IPC_RESC100X50X40L25N" H 9200 3300 50  0001 C CNN
F 3 "~" H 9200 3300 50  0001 C CNN
F 4 "Yageo" H 9200 3300 50  0001 C CNN "Mfr"
F 5 "RC0402FR-07150RL" H 9200 3300 50  0001 C CNN "Part"
	1    9200 3300
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R5
U 1 1 5CF8C1FC
P 9200 4600
F 0 "R5" V 9004 4600 50  0000 C CNN
F 1 "150R" V 9095 4600 50  0000 C CNN
F 2 "ipc_resc:IPC_RESC100X50X40L25N" H 9200 4600 50  0001 C CNN
F 3 "~" H 9200 4600 50  0001 C CNN
F 4 "Yageo" H 9200 4600 50  0001 C CNN "Mfr"
F 5 "RC0402FR-07150RL" H 9200 4600 50  0001 C CNN "Part"
	1    9200 4600
	0    1    1    0   
$EndComp
$Comp
L Device:R_POT RV1
U 1 1 5CF8C94B
P 7450 3200
F 0 "RV1" H 7381 3246 50  0000 R CNN
F 1 "10K" H 7381 3155 50  0000 R CNN
F 2 "pot:NIDEC_ST-4EA" H 7450 3200 50  0001 C CNN
F 3 "~" H 7450 3200 50  0001 C CNN
F 4 "Nidec" H 7450 3200 50  0001 C CNN "Mfr"
F 5 "ST4ETA103" H 7450 3200 50  0001 C CNN "Part"
	1    7450 3200
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0109
U 1 1 5CF8CF60
P 8200 3800
F 0 "#PWR0109" H 8200 3550 50  0001 C CNN
F 1 "GND" H 8205 3627 50  0000 C CNN
F 2 "" H 8200 3800 50  0001 C CNN
F 3 "" H 8200 3800 50  0001 C CNN
	1    8200 3800
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0110
U 1 1 5CF8E094
P 9300 2400
F 0 "#PWR0110" H 9300 2250 50  0001 C CNN
F 1 "VCC" V 9318 2527 50  0000 L CNN
F 2 "" H 9300 2400 50  0001 C CNN
F 3 "" H 9300 2400 50  0001 C CNN
	1    9300 2400
	0    1    1    0   
$EndComp
$Comp
L Device:L_Small L2
U 1 1 5CF8E42B
P 9100 2400
F 0 "L2" V 9285 2400 50  0000 C CNN
F 1 "FB" V 9194 2400 50  0000 C CNN
F 2 "ipc_indc:IPC_INDC100X50X60L20N" H 9100 2400 50  0001 C CNN
F 3 "~" H 9100 2400 50  0001 C CNN
F 4 "Murata" H 9100 2400 50  0001 C CNN "Mfr"
F 5 "BLM15AG700SN1D" H 9100 2400 50  0001 C CNN "Part"
	1    9100 2400
	0    -1   -1   0   
$EndComp
$Comp
L Device:C_Small C3
U 1 1 5CF8E917
P 8500 2600
F 0 "C3" H 8592 2646 50  0000 L CNN
F 1 "100N" H 8592 2555 50  0000 L CNN
F 2 "ipc_capc:IPC_CAPC100X50X55L25N" H 8500 2600 50  0001 C CNN
F 3 "~" H 8500 2600 50  0001 C CNN
F 4 "Murata" H 8500 2600 50  0001 C CNN "Mfr"
F 5 "GRM155R61A104KA01D" H 8500 2600 50  0001 C CNN "Part"
	1    8500 2600
	1    0    0    -1  
$EndComp
$Comp
L Device:C_Small C4
U 1 1 5CF8ED92
P 8900 2600
F 0 "C4" H 8992 2646 50  0000 L CNN
F 1 "10U" H 8992 2555 50  0000 L CNN
F 2 "ipc_capc:IPC_CAPC200X125X135L45N" H 8900 2600 50  0001 C CNN
F 3 "~" H 8900 2600 50  0001 C CNN
F 4 "Samsung" H 8900 2600 50  0001 C CNN "Mfr"
F 5 "CL21A106KPCLQNC" H 8900 2600 50  0001 C CNN "Part"
	1    8900 2600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0111
U 1 1 5CFA0BCA
P 8900 2700
F 0 "#PWR0111" H 8900 2450 50  0001 C CNN
F 1 "GND" H 8905 2527 50  0000 C CNN
F 2 "" H 8900 2700 50  0001 C CNN
F 3 "" H 8900 2700 50  0001 C CNN
	1    8900 2700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0112
U 1 1 5CFA0F2A
P 8500 2700
F 0 "#PWR0112" H 8500 2450 50  0001 C CNN
F 1 "GND" H 8505 2527 50  0000 C CNN
F 2 "" H 8500 2700 50  0001 C CNN
F 3 "" H 8500 2700 50  0001 C CNN
	1    8500 2700
	1    0    0    -1  
$EndComp
Wire Wire Line
	9300 2400 9200 2400
Wire Wire Line
	8900 2400 8900 2500
Wire Wire Line
	9000 2400 8900 2400
Wire Wire Line
	8900 2400 8500 2400
Wire Wire Line
	8500 2400 8500 2500
Connection ~ 8900 2400
Wire Wire Line
	8500 2400 8200 2400
Wire Wire Line
	8200 2400 8200 3000
Connection ~ 8500 2400
Wire Wire Line
	8600 3300 8700 3300
Wire Wire Line
	8700 3700 7900 3700
Wire Wire Line
	7900 3700 7900 3400
Wire Wire Line
	7900 3400 8000 3400
Wire Wire Line
	8000 4700 7900 4700
Wire Wire Line
	7900 4700 7900 5000
Wire Wire Line
	7900 5000 8700 5000
Wire Wire Line
	8700 4600 8600 4600
Wire Wire Line
	8200 3800 8200 3600
Wire Wire Line
	8700 3700 8700 3300
Wire Wire Line
	8700 4600 8700 5000
$Comp
L Device:CP_Small C5
U 1 1 5CFC1075
P 8900 3300
F 0 "C5" V 9125 3300 50  0000 C CNN
F 1 "10U" V 9034 3300 50  0000 C CNN
F 2 "ipc_capae:IPC_CAPAE430X540N" H 8900 3300 50  0001 C CNN
F 3 "~" H 8900 3300 50  0001 C CNN
F 4 "Kemet" V 8900 3300 50  0001 C CNN "Mfr"
F 5 "EDK106M025A9BAA" V 8900 3300 50  0001 C CNN "Part"
	1    8900 3300
	0    -1   -1   0   
$EndComp
$Comp
L Device:CP_Small C6
U 1 1 5CFC3C41
P 8900 4600
F 0 "C6" V 9125 4600 50  0000 C CNN
F 1 "10U" V 9034 4600 50  0000 C CNN
F 2 "ipc_capae:IPC_CAPAE430X540N" H 8900 4600 50  0001 C CNN
F 3 "~" H 8900 4600 50  0001 C CNN
F 4 "Kemet" V 8900 4600 50  0001 C CNN "Mfr"
F 5 "EDK106M025A9BAA" V 8900 4600 50  0001 C CNN "Part"
	1    8900 4600
	0    -1   -1   0   
$EndComp
Wire Wire Line
	9500 3300 9400 3300
Wire Wire Line
	9100 3300 9000 3300
Wire Wire Line
	8800 3300 8700 3300
Connection ~ 8700 3300
Wire Wire Line
	9500 4600 9400 4600
Wire Wire Line
	9100 4600 9000 4600
Wire Wire Line
	8800 4600 8700 4600
Connection ~ 8700 4600
Wire Wire Line
	8000 3200 7700 3200
Wire Wire Line
	7700 3200 7700 4500
Wire Wire Line
	7700 4500 8000 4500
Wire Wire Line
	7600 3200 7700 3200
Connection ~ 7700 3200
$Comp
L power:GND #PWR0113
U 1 1 5CFD54F6
P 7450 3450
F 0 "#PWR0113" H 7450 3200 50  0001 C CNN
F 1 "GND" H 7455 3277 50  0000 C CNN
F 2 "" H 7450 3450 50  0001 C CNN
F 3 "" H 7450 3450 50  0001 C CNN
	1    7450 3450
	1    0    0    -1  
$EndComp
Wire Wire Line
	7050 2950 7450 2950
Wire Wire Line
	7450 2950 7450 3050
Wire Wire Line
	7450 3350 7450 3450
$Comp
L power:GND #PWR0114
U 1 1 5CFF9148
P 9700 4800
F 0 "#PWR0114" H 9700 4550 50  0001 C CNN
F 1 "GND" H 9705 4627 50  0000 C CNN
F 2 "" H 9700 4800 50  0001 C CNN
F 3 "" H 9700 4800 50  0001 C CNN
	1    9700 4800
	1    0    0    -1  
$EndComp
Text Label 5850 2950 0    50   ~ 0
SYNC#
Text Label 5850 3050 0    50   ~ 0
SCLK
Text Label 5850 3150 0    50   ~ 0
SDIN
$Comp
L Device:R_Small R1
U 1 1 5CFFE05E
P 2750 2800
F 0 "R1" V 2554 2800 50  0000 C CNN
F 1 "100R" V 2645 2800 50  0000 C CNN
F 2 "ipc_resc:IPC_RESC100X50X40L25N" H 2750 2800 50  0001 C CNN
F 3 "~" H 2750 2800 50  0001 C CNN
F 4 "Yageo" V 2750 2800 50  0001 C CNN "Mfr"
F 5 "RC0402FR-07100RL" V 2750 2800 50  0001 C CNN "Part"
	1    2750 2800
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R2
U 1 1 5CFFE89F
P 2750 3100
F 0 "R2" V 2554 3100 50  0000 C CNN
F 1 "100R" V 2645 3100 50  0000 C CNN
F 2 "ipc_resc:IPC_RESC100X50X40L25N" H 2750 3100 50  0001 C CNN
F 3 "~" H 2750 3100 50  0001 C CNN
F 4 "Yageo" H 2750 3100 50  0001 C CNN "Mfr"
F 5 "RC0402FR-07100RL" H 2750 3100 50  0001 C CNN "Part"
	1    2750 3100
	0    1    1    0   
$EndComp
$Comp
L Device:R_Small R3
U 1 1 5CFFEEF6
P 2750 3400
F 0 "R3" V 2554 3400 50  0000 C CNN
F 1 "100R" V 2645 3400 50  0000 C CNN
F 2 "ipc_resc:IPC_RESC100X50X40L25N" H 2750 3400 50  0001 C CNN
F 3 "~" H 2750 3400 50  0001 C CNN
F 4 "Yageo" H 2750 3400 50  0001 C CNN "Mfr"
F 5 "RC0402FR-07100RL" H 2750 3400 50  0001 C CNN "Part"
	1    2750 3400
	0    1    1    0   
$EndComp
Wire Wire Line
	2150 2800 2650 2800
Wire Wire Line
	2650 3100 2150 3100
Wire Wire Line
	2650 3400 2150 3400
Text Label 2250 3400 0    50   ~ 0
SYNC#
Text Label 2250 3100 0    50   ~ 0
SCLK
Text Label 2250 2800 0    50   ~ 0
SDIN
$Comp
L Connector_Generic:Conn_02x04_Odd_Even J1
U 1 1 5D06BA6C
P 3450 3000
F 0 "J1" H 3500 3225 50  0000 C CNN
F 1 "Conn_02x04_Odd_Even" H 3500 3226 50  0001 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x04_P2.54mm_Vertical" H 3450 3000 50  0001 C CNN
F 3 "~" H 3450 3000 50  0001 C CNN
F 4 "Samtec" H 3450 3000 50  0001 C CNN "Mfr"
F 5 "SSQ-104-01-T-D" H 3450 3000 50  0001 C CNN "Part"
	1    3450 3000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0101
U 1 1 5D06CE23
P 3850 3300
F 0 "#PWR0101" H 3850 3050 50  0001 C CNN
F 1 "GND" H 3855 3127 50  0000 C CNN
F 2 "" H 3850 3300 50  0001 C CNN
F 3 "" H 3850 3300 50  0001 C CNN
	1    3850 3300
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0102
U 1 1 5D06D521
P 3850 2800
F 0 "#PWR0102" H 3850 2650 50  0001 C CNN
F 1 "VCC" H 3867 2973 50  0000 C CNN
F 2 "" H 3850 2800 50  0001 C CNN
F 3 "" H 3850 2800 50  0001 C CNN
	1    3850 2800
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0103
U 1 1 5D06D99B
P 3150 2800
F 0 "#PWR0103" H 3150 2650 50  0001 C CNN
F 1 "VCC" H 3167 2973 50  0000 C CNN
F 2 "" H 3150 2800 50  0001 C CNN
F 3 "" H 3150 2800 50  0001 C CNN
	1    3150 2800
	1    0    0    -1  
$EndComp
Wire Wire Line
	3150 2800 3150 2900
Wire Wire Line
	3150 2900 3250 2900
Wire Wire Line
	3850 2900 3850 2800
Wire Wire Line
	3750 2900 3850 2900
Wire Wire Line
	3750 3100 4150 3100
Wire Wire Line
	4150 3000 3750 3000
Wire Wire Line
	3750 3200 3850 3200
Wire Wire Line
	3850 3200 3850 3300
Wire Wire Line
	2950 3200 2950 3400
Wire Wire Line
	2950 3400 2850 3400
Wire Wire Line
	2950 3200 3250 3200
Wire Wire Line
	2850 3100 3250 3100
Wire Wire Line
	2950 3000 2950 2800
Wire Wire Line
	2950 2800 2850 2800
Wire Wire Line
	2950 3000 3250 3000
NoConn ~ 4150 3000
NoConn ~ 4150 3100
Text Label 3050 3000 0    50   ~ 0
L19
Text Label 3050 3100 0    50   ~ 0
L20
Text Label 3050 3200 0    50   ~ 0
L16
Text Label 3850 3000 0    50   ~ 0
M19
Text Label 3850 3100 0    50   ~ 0
M20
$Comp
L Device:R_Small R6
U 1 1 5CEE71C7
P 9400 3500
F 0 "R6" V 9204 3500 50  0000 C CNN
F 1 "100K" V 9295 3500 50  0000 C CNN
F 2 "ipc_resc:IPC_RESC100X50X40L25N" H 9400 3500 50  0001 C CNN
F 3 "~" H 9400 3500 50  0001 C CNN
F 4 "Yageo" H 9400 3500 50  0001 C CNN "Mfr"
F 5 "RC0402FR-07100KL" H 9400 3500 50  0001 C CNN "Part"
	1    9400 3500
	1    0    0    -1  
$EndComp
$Comp
L Device:R_Small R7
U 1 1 5CEE7857
P 9400 4800
F 0 "R7" V 9204 4800 50  0000 C CNN
F 1 "100K" V 9295 4800 50  0000 C CNN
F 2 "ipc_resc:IPC_RESC100X50X40L25N" H 9400 4800 50  0001 C CNN
F 3 "~" H 9400 4800 50  0001 C CNN
F 4 "Yageo" H 9400 4800 50  0001 C CNN "Mfr"
F 5 "RC0402FR-07100KL" H 9400 4800 50  0001 C CNN "Part"
	1    9400 4800
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0104
U 1 1 5CEE7C00
P 9400 3700
F 0 "#PWR0104" H 9400 3450 50  0001 C CNN
F 1 "GND" H 9405 3527 50  0000 C CNN
F 2 "" H 9400 3700 50  0001 C CNN
F 3 "" H 9400 3700 50  0001 C CNN
	1    9400 3700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0115
U 1 1 5CEE7E83
P 9400 5000
F 0 "#PWR0115" H 9400 4750 50  0001 C CNN
F 1 "GND" H 9405 4827 50  0000 C CNN
F 2 "" H 9400 5000 50  0001 C CNN
F 3 "" H 9400 5000 50  0001 C CNN
	1    9400 5000
	1    0    0    -1  
$EndComp
Wire Wire Line
	9400 3300 9400 3400
Wire Wire Line
	9400 3600 9400 3700
Connection ~ 9400 3300
Wire Wire Line
	9400 3300 9300 3300
Wire Wire Line
	9400 4600 9400 4700
Wire Wire Line
	9400 4900 9400 5000
Connection ~ 9400 4600
Wire Wire Line
	9400 4600 9300 4600
$Comp
L Connector:Conn_Coaxial_x2_Isolated J2
U 2 1 5CEED02E
P 9700 3300
F 0 "J2" H 9800 3275 50  0000 L CNN
F 1 "Conn_Coaxial_x2_Isolated" H 9800 3184 50  0000 L CNN
F 2 "switchcraft:PJRAS2X1S0_X" H 9700 3300 50  0001 C CNN
F 3 " ~" H 9700 3300 50  0001 C CNN
F 4 "Switchcraft" H 9700 3300 50  0001 C CNN "Mfr"
F 5 "PJRAS2X1S01X" H 9700 3300 50  0001 C CNN "Part"
	2    9700 3300
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_Coaxial_x2_Isolated J2
U 1 1 5CEEDF38
P 9700 4600
F 0 "J2" H 9800 4575 50  0000 L CNN
F 1 "Conn_Coaxial_x2_Isolated" H 9800 4484 50  0000 L CNN
F 2 "switchcraft:PJRAS2X1S0_X" H 9700 4600 50  0001 C CNN
F 3 " ~" H 9700 4600 50  0001 C CNN
F 4 "Switchcraft" H 9700 4600 50  0001 C CNN "Mfr"
F 5 "PJRAS2X1S01X" H 9700 4600 50  0001 C CNN "Part"
	1    9700 4600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0116
U 1 1 5CEF6F2F
P 9700 3500
F 0 "#PWR0116" H 9700 3250 50  0001 C CNN
F 1 "GND" H 9705 3327 50  0000 C CNN
F 2 "" H 9700 3500 50  0001 C CNN
F 3 "" H 9700 3500 50  0001 C CNN
	1    9700 3500
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H1
U 1 1 5CF0531E
P 6550 4900
F 0 "H1" H 6650 4949 50  0000 L CNN
F 1 "MountingHole_Pad" H 6650 4858 50  0000 L CNN
F 2 "MountingHole:MountingHole_3.2mm_M3_Pad_Via" H 6550 4900 50  0001 C CNN
F 3 "~" H 6550 4900 50  0001 C CNN
	1    6550 4900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0117
U 1 1 5CF05719
P 6550 5000
F 0 "#PWR0117" H 6550 4750 50  0001 C CNN
F 1 "GND" H 6555 4827 50  0000 C CNN
F 2 "" H 6550 5000 50  0001 C CNN
F 3 "" H 6550 5000 50  0001 C CNN
	1    6550 5000
	1    0    0    -1  
$EndComp
$EndSCHEMATC
