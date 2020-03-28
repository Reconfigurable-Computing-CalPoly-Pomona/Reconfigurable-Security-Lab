### This file is a general .xdc for the Nexys4 DDR Rev. C
### To use it in a project:
### - uncomment the lines corresponding to used pins
### - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

##======================================================================================================================
## Clock signal
##======================================================================================================================
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets reset_IBUF]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk]
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 10.000} -add [get_ports clk]

##======================================================================================================================
## To facilitate Quad-SPI flash programming
##======================================================================================================================
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]


##======================================================================================================================
##Switches
##======================================================================================================================
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports {SW[0]}]
set_property -dict {PACKAGE_PIN L16 IOSTANDARD LVCMOS33} [get_ports {SW[1]}]
set_property -dict {PACKAGE_PIN M13 IOSTANDARD LVCMOS33} [get_ports {SW[2]}]
set_property -dict {PACKAGE_PIN R15 IOSTANDARD LVCMOS33} [get_ports {SW[3]}]
set_property -dict {PACKAGE_PIN R17 IOSTANDARD LVCMOS33} [get_ports {SW[4]}]
set_property -dict {PACKAGE_PIN T18 IOSTANDARD LVCMOS33} [get_ports {SW[5]}]
set_property -dict {PACKAGE_PIN U18 IOSTANDARD LVCMOS33} [get_ports {SW[6]}]
set_property -dict {PACKAGE_PIN R13 IOSTANDARD LVCMOS33} [get_ports {SW[7]}]
set_property -dict {PACKAGE_PIN T8 IOSTANDARD LVCMOS33} [get_ports {SW[8]}]
set_property -dict {PACKAGE_PIN U8 IOSTANDARD LVCMOS33} [get_ports {SW[9]}]
set_property -dict {PACKAGE_PIN R16 IOSTANDARD LVCMOS33} [get_ports {SW[10]}]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports {SW[11]}]
set_property -dict {PACKAGE_PIN H6 IOSTANDARD LVCMOS33} [get_ports {SW[12]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {SW[13]}]
set_property -dict {PACKAGE_PIN U11 IOSTANDARD LVCMOS33} [get_ports {SW[14]}]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports {SW[15]}]

##======================================================================================================================
##Buttons
##======================================================================================================================
## ***** CPU_reset button; active low
#set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports reset_n]
## ***** Other buttons; active high
## ***** btn(0): btnu;  btn(1): btnr;  btn(2): btnd; btn(3): btnl;  btn(4): btnc;
set_property -dict {PACKAGE_PIN N17 IOSTANDARD LVCMOS33} [get_ports reset]
#set_property -dict {PACKAGE_PIN M18 IOSTANDARD LVCMOS33} [get_ports {btn[0]}]
#set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVCMOS33} [get_ports {btn[3]}]
#set_property -dict {PACKAGE_PIN M17 IOSTANDARD LVCMOS33} [get_ports {btn[1]}]
#set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVCMOS33} [get_ports {btn[2]}]

##======================================================================================================================
## discrete LEDs
##======================================================================================================================
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]
set_property -dict {PACKAGE_PIN R18 IOSTANDARD LVCMOS33} [get_ports {led[4]}]
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports {led[5]}]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports {led[6]}]
set_property -dict {PACKAGE_PIN U16 IOSTANDARD LVCMOS33} [get_ports {led[7]}]
set_property -dict {PACKAGE_PIN V16 IOSTANDARD LVCMOS33} [get_ports {led[8]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {led[9]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {led[10]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {led[11]}]
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {led[12]}]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports {led[13]}]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports {led[14]}]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports {led[15]}]

##======================================================================================================================
## tri-color LEDs
##======================================================================================================================
#set_property -dict {PACKAGE_PIN R12 IOSTANDARD LVCMOS33} [get_ports {rgb_led1[0]}]
#set_property -dict {PACKAGE_PIN M16 IOSTANDARD LVCMOS33} [get_ports {rgb_led1[1]}]
#set_property -dict {PACKAGE_PIN N15 IOSTANDARD LVCMOS33} [get_ports {rgb_led1[2]}]
#set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {rgb_led2[0]}]
#set_property -dict {PACKAGE_PIN R11 IOSTANDARD LVCMOS33} [get_ports {rgb_led2[1]}]
#set_property -dict {PACKAGE_PIN N16 IOSTANDARD LVCMOS33} [get_ports {rgb_led2[2]}]

##======================================================================================================================
##7 segment display
##======================================================================================================================
#set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {Seg[0]}]
#set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {Seg[1]}]
#set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {Seg[2]}]
#set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {Seg[3]}]
#set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {Seg[4]}]
#set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {Seg[5]}]
#set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {Seg[6]}]
#decimal point
#set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {sseg[7]}]
## enable
#set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {An[0]}]
#set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {An[1]}]
#set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {An[2]}]
#set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {An[3]}]
#set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {An[4]}]
#set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {An[5]}]
#set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {An[6]}]
#set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {An[7]}]


##====================================================================================================
## PWM Audio Amplifier
##====================================================================================================
#set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports audio_pdm]
#set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports audio_on]


##====================================================================================================
## USB-RS232 Interface
##====================================================================================================
##set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS33} [get_ports tx]
##set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS33} [get_ports rx]
## ************CTS/RTS not used
##set_property -dict { PACKAGE_PIN D3    IOSTANDARD LVCMOS33 } [get_ports { uart_cts }]; #IO_L12N_T1_MRCC_35 Sch=uart_cts
##set_property -dict { PACKAGE_PIN E5    IOSTANDARD LVCMOS33 } [get_ports { uart_rts }]; #IO_L5N_T0_AD13N_35 Sch=uart_rts

##====================================================================================================
## USB HID (PS/2)
##====================================================================================================
#set_property -dict {PACKAGE_PIN F4 IOSTANDARD LVCMOS33} [get_ports ps2c]
#set_property -dict {PACKAGE_PIN B2 IOSTANDARD LVCMOS33} [get_ports ps2d]


##====================================================================================================
## I2C temperature sensor
## tmp_int / tmp_ct signals are not used
##====================================================================================================
#set_property -dict {PACKAGE_PIN C14 IOSTANDARD LVCMOS33} [get_ports tmp_i2c_scl]
#set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33} [get_ports tmp_i2c_sda]
## ************ tmp_int / tmp_ct not used
##set_property -dict { PACKAGE_PIN D13   IOSTANDARD LVCMOS33 } [get_ports { tmp_int }]; #IO_L6N_T0_VREF_15 Sch=tmp_int
##set_property -dict { PACKAGE_PIN B14   IOSTANDARD LVCMOS33 } [get_ports { tmp_ct }]; #IO_L2N_T0_AD8N_15 Sch=tmp_ct


##====================================================================================================
## SPI Accelerometer
## aclInt1 / aclInt2 signals are not used
##====================================================================================================
#set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33} [get_ports acl_miso]
#set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports acl_mosi]
#set_property -dict {PACKAGE_PIN F15 IOSTANDARD LVCMOS33} [get_ports acl_sclk]
#set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33} [get_ports acl_ss_n]
## *********** aclInt1 / aclInt2 signals are not used
##set_property -dict { PACKAGE_PIN B13   IOSTANDARD LVCMOS33 } [get_ports { aclInt1[1] }]; #IO_L2P_T0_AD8P_15 Sch=acl_int[1]
##set_property -dict { PACKAGE_PIN C16   IOSTANDARD LVCMOS33 } [get_ports { aclInt1[2] }]; #IO_L20P_T3_A20_15 Sch=acl_int[2]


##====================================================================================================
## VGA Port
##====================================================================================================
#set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports hsync]
#set_property -dict {PACKAGE_PIN B12 IOSTANDARD LVCMOS33} [get_ports vsync]
#set_property -dict {PACKAGE_PIN A3 IOSTANDARD LVCMOS33} [get_ports {rgb[8]}]
#set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS33} [get_ports {rgb[9]}]
#set_property -dict {PACKAGE_PIN C5 IOSTANDARD LVCMOS33} [get_ports {rgb[10]}]
#set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS33} [get_ports {rgb[11]}]
#set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS33} [get_ports {rgb[4]}]
#set_property -dict {PACKAGE_PIN A5 IOSTANDARD LVCMOS33} [get_ports {rgb[5]}]
#set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVCMOS33} [get_ports {rgb[6]}]
#set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS33} [get_ports {rgb[7]}]
#set_property -dict {PACKAGE_PIN B7 IOSTANDARD LVCMOS33} [get_ports {rgb[0]}]
#set_property -dict {PACKAGE_PIN C7 IOSTANDARD LVCMOS33} [get_ports {rgb[1]}]
#set_property -dict {PACKAGE_PIN D7 IOSTANDARD LVCMOS33} [get_ports {rgb[2]}]
#set_property -dict {PACKAGE_PIN D8 IOSTANDARD LVCMOS33} [get_ports {rgb[3]}]

##====================================================================================================
##micro SD card Connector
##====================================================================================================
#set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS33} [get_ports sd_reset]
#set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS33} [get_ports sd_sclk]
#set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS33} [get_ports sd_mosi]
#set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports sd_miso]
##set_property -dict { PACKAGE_PIN E1    IOSTANDARD LVCMOS33 } [get_ports { SD_DAT[1] }]; #IO_L18N_T2_35 Sch=sd_dat[1]
##set_property -dict { PACKAGE_PIN F1    IOSTANDARD LVCMOS33 } [get_ports { SD_DAT[2] }]; #IO_L18P_T2_35 Sch=sd_dat[2]
#set_property -dict {PACKAGE_PIN D2 IOSTANDARD LVCMOS33} [get_ports sd_ss_n]
##set_property -dict { PACKAGE_PIN A1    IOSTANDARD LVCMOS33 } [get_ports { SD_CD }]; #IO_L9N_T1_DQS_AD7N_35 Sch=sd_cd  //** card detect not used

##set_property -dict { PACKAGE_PIN E2    IOSTANDARD LVCMOS33 } [get_ports { SD_RESET }]; #IO_L14P_T2_SRCC_35 Sch=sd_reset
##set_property -dict { PACKAGE_PIN A1    IOSTANDARD LVCMOS33 } [get_ports { SD_CD }]; #IO_L9N_T1_DQS_AD7N_35 Sch=sd_cd
##set_property -dict { PACKAGE_PIN B1    IOSTANDARD LVCMOS33 } [get_ports { SD_SCK }]; #IO_L9P_T1_DQS_AD7P_35 Sch=sd_sck
##set_property -dict { PACKAGE_PIN C1    IOSTANDARD LVCMOS33 } [get_ports { SD_CMD }]; #IO_L16N_T2_35 Sch=sd_cmd
##set_property -dict { PACKAGE_PIN C2    IOSTANDARD LVCMOS33 } [get_ports { SD_DAT[0] }]; #IO_L16P_T2_35 Sch=sd_dat[0]
##set_property -dict { PACKAGE_PIN E1    IOSTANDARD LVCMOS33 } [get_ports { SD_DAT[1] }]; #IO_L18N_T2_35 Sch=sd_dat[1]
##set_property -dict { PACKAGE_PIN F1    IOSTANDARD LVCMOS33 } [get_ports { SD_DAT[2] }]; #IO_L18P_T2_35 Sch=sd_dat[2]
##set_property -dict { PACKAGE_PIN D2    IOSTANDARD LVCMOS33 } [get_ports { SD_DAT[3] }]; #IO_L14N_T2_SRCC_35 Sch=sd_dat[3]
##-----------SPI mode pin map-------------------------------------------------------------------
##Clock	 [SCK]
##CMD/DI	 [MOSI]
##DAT0/D0 [MISO]
##DAT1/IRQ Unused/I
##DAT2/NC Unused
##DAT3/CS [SS]
##VSS1	 Ground
##Vss2	 Ground
##Vdd	 voltage
##===============================================================================================

##===============================================================================================
## PMOD xadc (JXADC)
## originally with LVDS (error for adcn/p[3]); not LVCOMS33
##===============================================================================================
#set_property -dict {PACKAGE_PIN A14 IOSTANDARD LVCMOS33} [get_ports {adc_n[0]}]
#set_property -dict {PACKAGE_PIN A13 IOSTANDARD LVCMOS33} [get_ports {adc_p[0]}]
#set_property -dict {PACKAGE_PIN A16 IOSTANDARD LVCMOS33} [get_ports {adc_n[1]}]
#set_property -dict {PACKAGE_PIN A15 IOSTANDARD LVCMOS33} [get_ports {adc_p[1]}]
#set_property -dict {PACKAGE_PIN B17 IOSTANDARD LVCMOS33} [get_ports {adc_n[2]}]
#set_property -dict {PACKAGE_PIN B16 IOSTANDARD LVCMOS33} [get_ports {adc_p[2]}]
#set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports {adc_n[3]}]
#set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports {adc_p[3]}]



##====================================================================================================
##Pmod Header JA
## 4 out of 10 pins are for Vcc/Gnd
## use two signals (for top and bottom rows) to maintain pin#
##====================================================================================================
#set_property -dict {PACKAGE_PIN C17 IOSTANDARD LVCMOS33} [get_ports {rx}]
#set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {tx}]
#set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports {ja_top[3]}]
#set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33} [get_ports {ja_top[4]}]
#set_property -dict {PACKAGE_PIN D17 IOSTANDARD LVCMOS33} [get_ports {ja_btm[7]}]
#set_property -dict {PACKAGE_PIN E17 IOSTANDARD LVCMOS33} [get_ports {ja_btm[8]}]
#set_property -dict {PACKAGE_PIN F18 IOSTANDARD LVCMOS33} [get_ports {ja_btm[9]}]
#set_property -dict {PACKAGE_PIN G18 IOSTANDARD LVCMOS33} [get_ports {ja_btm[10]}]

##====================================================================================================
##Pmod Header JB
## 4 out of 10 pins are for Vcc/Gnd
## use two signals (for top and bottom rows) to maintain pin#
##====================================================================================================
#set_property -dict {PACKAGE_PIN D14 IOSTANDARD LVCMOS33} [get_ports {jb_top[1]}]
#set_property -dict {PACKAGE_PIN F16 IOSTANDARD LVCMOS33} [get_ports {jb_top[2]}]
#set_property -dict {PACKAGE_PIN G16 IOSTANDARD LVCMOS33} [get_ports {jb_top[3]}]
#set_property -dict {PACKAGE_PIN H14 IOSTANDARD LVCMOS33} [get_ports {jb_top[4]}]
#set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports {jb_btm[7]}]
#set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports {jb_btm[8]}]
#set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports {jb_btm[9]}]
#set_property -dict {PACKAGE_PIN H16 IOSTANDARD LVCMOS33} [get_ports {jb_btm[10]}]

##====================================================================================================
##Pmod Header JC
## 4 out of 10 pins are for Vcc/Gnd
## use two signals (for top and bottom rows) to maintain pin#
##====================================================================================================
#set_property -dict {PACKAGE_PIN K1 IOSTANDARD LVCMOS33} [get_ports {jc_top[1]}]
#set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS33} [get_ports {jc_top[2]}]
#set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {jc_top[3]}]
#set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS33} [get_ports {jc_top[4]}]
#set_property -dict {PACKAGE_PIN E7 IOSTANDARD LVCMOS33} [get_ports {jc_btm[7]}]
#set_property -dict {PACKAGE_PIN J3 IOSTANDARD LVCMOS33} [get_ports {jc_btm[8]}]
#set_property -dict {PACKAGE_PIN J4 IOSTANDARD LVCMOS33} [get_ports {jc_btm[9]}]
#set_property -dict {PACKAGE_PIN E6 IOSTANDARD LVCMOS33} [get_ports {jc_btm[10]}]


##====================================================================================================
##Pmod Header JD
## 4 out of 10 pins are for Vcc/Gnd
## use two signals (for top and bottom rows) to maintain pin#
##====================================================================================================
#set_property -dict {PACKAGE_PIN H4 IOSTANDARD LVCMOS33} [get_ports {jd_top[1]}]
#set_property -dict {PACKAGE_PIN H1 IOSTANDARD LVCMOS33} [get_ports {jd_top[2]}]
#set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS33} [get_ports {jd_top[3]}]
#set_property -dict {PACKAGE_PIN G3 IOSTANDARD LVCMOS33} [get_ports {jd_top[4]}]
#set_property -dict {PACKAGE_PIN H2 IOSTANDARD LVCMOS33} [get_ports {jd_btm[7]}]
#set_property -dict {PACKAGE_PIN G4 IOSTANDARD LVCMOS33} [get_ports {jd_btm[8]}]
#set_property -dict {PACKAGE_PIN G2 IOSTANDARD LVCMOS33} [get_ports {jd_btm[9]}]
#set_property -dict {PACKAGE_PIN F3 IOSTANDARD LVCMOS33} [get_ports {jd_btm[10]}]

##====================================================================================================
## **** not used in the FPro system
##====================================================================================================

###Omnidirectional Microphone
##set_property -dict { PACKAGE_PIN J5    IOSTANDARD LVCMOS33 } [get_ports { M_CLK }]; #IO_25_35 Sch=m_clk
##set_property -dict { PACKAGE_PIN H5    IOSTANDARD LVCMOS33 } [get_ports { M_DATA }]; #IO_L24N_T3_35 Sch=m_data
##set_property -dict { PACKAGE_PIN F5    IOSTANDARD LVCMOS33 } [get_ports { M_LRSEL }]; #IO_0_35 Sch=m_lrsel


###Quad SPI Flash

##set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ[0] }]; #IO_L1P_T0_D00_MOSI_14 Sch=qspi_dq[0]
##set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ[1] }]; #IO_L1N_T0_D01_DIN_14 Sch=qspi_dq[1]
##set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ[2] }]; #IO_L2P_T0_D02_14 Sch=qspi_dq[2]
##set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { QSPI_DQ[3] }]; #IO_L2N_T0_D03_14 Sch=qspi_dq[3]
##set_property -dict { PACKAGE_PIN L13   IOSTANDARD LVCMOS33 } [get_ports { QSPI_CSN }]; #IO_L6P_T0_FCS_B_14 Sch=qspi_csn


###SMSC Ethernet PHY

##set_property -dict { PACKAGE_PIN C9    IOSTANDARD LVCMOS33 } [get_ports { ETH_MDC }]; #IO_L11P_T1_SRCC_16 Sch=eth_mdc
##set_property -dict { PACKAGE_PIN A9    IOSTANDARD LVCMOS33 } [get_ports { ETH_MDIO }]; #IO_L14N_T2_SRCC_16 Sch=eth_mdio
##set_property -dict { PACKAGE_PIN B3    IOSTANDARD LVCMOS33 } [get_ports { ETH_RSTN }]; #IO_L10P_T1_AD15P_35 Sch=eth_rstn
##set_property -dict { PACKAGE_PIN D9    IOSTANDARD LVCMOS33 } [get_ports { ETH_CRSDV }]; #IO_L6N_T0_VREF_16 Sch=eth_crsdv
##set_property -dict { PACKAGE_PIN C10   IOSTANDARD LVCMOS33 } [get_ports { ETH_RXERR }]; #IO_L13N_T2_MRCC_16 Sch=eth_rxerr
##set_property -dict { PACKAGE_PIN C11   IOSTANDARD LVCMOS33 } [get_ports { ETH_RXD[0] }]; #IO_L13P_T2_MRCC_16 Sch=eth_rxd[0]
##set_property -dict { PACKAGE_PIN D10   IOSTANDARD LVCMOS33 } [get_ports { ETH_RXD[1] }]; #IO_L19N_T3_VREF_16 Sch=eth_rxd[1]
##set_property -dict { PACKAGE_PIN B9    IOSTANDARD LVCMOS33 } [get_ports { ETH_TXEN }]; #IO_L11N_T1_SRCC_16 Sch=eth_txen
##set_property -dict { PACKAGE_PIN A10   IOSTANDARD LVCMOS33 } [get_ports { ETH_TXD[0] }]; #IO_L14P_T2_SRCC_16 Sch=eth_txd[0]
##set_property -dict { PACKAGE_PIN A8    IOSTANDARD LVCMOS33 } [get_ports { ETH_TXD[1] }]; #IO_L12N_T1_MRCC_16 Sch=eth_txd[1]
##set_property -dict { PACKAGE_PIN D5    IOSTANDARD LVCMOS33 } [get_ports { ETH_REFCLK }]; #IO_L11P_T1_SRCC_35 Sch=eth_refclk
##set_property -dict { PACKAGE_PIN B8    IOSTANDARD LVCMOS33 } [get_ports { ETH_INTN }]; #IO_L12P_T1_MRCC_16 Sch=eth_intn











set_property MARK_DEBUG false [get_nets done_OBUF]
set_property MARK_DEBUG false [get_nets tag_OBUF]
set_property MARK_DEBUG false [get_nets {enc/C[0]}]
set_property MARK_DEBUG false [get_nets {enc/C[8]}]
set_property MARK_DEBUG false [get_nets {enc/C[10]}]
set_property MARK_DEBUG false [get_nets {enc/C[13]}]
set_property MARK_DEBUG false [get_nets {enc/C[16]}]
set_property MARK_DEBUG false [get_nets {enc/C[18]}]
set_property MARK_DEBUG false [get_nets {enc/C[28]}]
set_property MARK_DEBUG false [get_nets {enc/C[9]}]
set_property MARK_DEBUG false [get_nets {enc/C[4]}]
set_property MARK_DEBUG false [get_nets {enc/C[5]}]
set_property MARK_DEBUG false [get_nets {enc/C[6]}]
set_property MARK_DEBUG false [get_nets {enc/C[12]}]
set_property MARK_DEBUG false [get_nets {enc/C[17]}]
set_property MARK_DEBUG false [get_nets {enc/C[24]}]
set_property MARK_DEBUG false [get_nets {enc/C[27]}]
set_property MARK_DEBUG false [get_nets {enc/C[31]}]
set_property MARK_DEBUG false [get_nets {enc/C[30]}]
set_property MARK_DEBUG false [get_nets {enc/C[11]}]
set_property MARK_DEBUG false [get_nets {enc/C[1]}]
set_property MARK_DEBUG false [get_nets {enc/C[2]}]
set_property MARK_DEBUG false [get_nets {enc/C[7]}]
set_property MARK_DEBUG false [get_nets {enc/C[15]}]
set_property MARK_DEBUG false [get_nets {enc/C[20]}]
set_property MARK_DEBUG false [get_nets {enc/C[22]}]
set_property MARK_DEBUG false [get_nets {enc/C[23]}]
set_property MARK_DEBUG false [get_nets {enc/C[25]}]
set_property MARK_DEBUG false [get_nets {enc/C[3]}]
set_property MARK_DEBUG false [get_nets {enc/C[14]}]
set_property MARK_DEBUG false [get_nets {enc/C[19]}]
set_property MARK_DEBUG false [get_nets {enc/C[21]}]
set_property MARK_DEBUG false [get_nets {enc/C[26]}]
set_property MARK_DEBUG false [get_nets {enc/C[29]}]
set_property MARK_DEBUG false [get_nets {enc/P[0]}]
set_property MARK_DEBUG false [get_nets {enc/P[4]}]
set_property MARK_DEBUG false [get_nets {enc/P[5]}]
set_property MARK_DEBUG false [get_nets {enc/P[7]}]
set_property MARK_DEBUG false [get_nets {enc/P[9]}]
set_property MARK_DEBUG false [get_nets {enc/P[10]}]
set_property MARK_DEBUG false [get_nets {enc/P[1]}]
set_property MARK_DEBUG false [get_nets {enc/P[6]}]
set_property MARK_DEBUG false [get_nets {enc/P[13]}]
set_property MARK_DEBUG false [get_nets {enc/P[3]}]
set_property MARK_DEBUG false [get_nets {enc/P[12]}]
set_property MARK_DEBUG false [get_nets {enc/P[15]}]
set_property MARK_DEBUG false [get_nets {enc/P[2]}]
set_property MARK_DEBUG false [get_nets {enc/P[8]}]
set_property MARK_DEBUG false [get_nets {enc/P[11]}]
set_property MARK_DEBUG false [get_nets {enc/P[14]}]
set_property MARK_DEBUG false [get_nets resetEnc]
connect_debug_port u_ila_0/probe0 [get_nets [list {enc/TAG[0]}]]
connect_debug_port u_ila_0/probe1 [get_nets [list {enc/KS/cReg[0]} {enc/KS/cReg[1]} {enc/KS/cReg[2]} {enc/KS/cReg[3]} {enc/KS/cReg[4]} {enc/KS/cReg[5]} {enc/KS/cReg[6]} {enc/KS/cReg[7]} {enc/KS/cReg[8]} {enc/KS/cReg[9]} {enc/KS/cReg[10]} {enc/KS/cReg[11]} {enc/KS/cReg[12]} {enc/KS/cReg[13]} {enc/KS/cReg[14]} {enc/KS/cReg[15]} {enc/KS/cReg[16]} {enc/KS/cReg[17]} {enc/KS/cReg[18]} {enc/KS/cReg[19]} {enc/KS/cReg[20]} {enc/KS/cReg[21]} {enc/KS/cReg[22]} {enc/KS/cReg[23]} {enc/KS/cReg[24]} {enc/KS/cReg[25]} {enc/KS/cReg[26]} {enc/KS/cReg[27]} {enc/KS/cReg[28]} {enc/KS/cReg[29]} {enc/KS/cReg[30]} {enc/KS/cReg[31]} {enc/KS/cReg[32]} {enc/KS/cReg[33]} {enc/KS/cReg[34]} {enc/KS/cReg[35]} {enc/KS/cReg[36]} {enc/KS/cReg[37]} {enc/KS/cReg[38]} {enc/KS/cReg[39]} {enc/KS/cReg[40]} {enc/KS/cReg[41]} {enc/KS/cReg[42]} {enc/KS/cReg[43]} {enc/KS/cReg[44]} {enc/KS/cReg[45]} {enc/KS/cReg[46]} {enc/KS/cReg[47]} {enc/KS/cReg[48]} {enc/KS/cReg[49]} {enc/KS/cReg[50]} {enc/KS/cReg[51]} {enc/KS/cReg[52]} {enc/KS/cReg[53]} {enc/KS/cReg[54]} {enc/KS/cReg[55]} {enc/KS/cReg[56]} {enc/KS/cReg[57]} {enc/KS/cReg[58]} {enc/KS/cReg[59]} {enc/KS/cReg[60]} {enc/KS/cReg[61]} {enc/KS/cReg[62]} {enc/KS/cReg[63]} {enc/KS/cReg[64]} {enc/KS/cReg[65]} {enc/KS/cReg[66]} {enc/KS/cReg[67]} {enc/KS/cReg[68]} {enc/KS/cReg[69]} {enc/KS/cReg[70]} {enc/KS/cReg[71]} {enc/KS/cReg[72]} {enc/KS/cReg[73]} {enc/KS/cReg[74]} {enc/KS/cReg[75]} {enc/KS/cReg[76]} {enc/KS/cReg[77]} {enc/KS/cReg[78]} {enc/KS/cReg[79]} {enc/KS/cReg[80]} {enc/KS/cReg[81]} {enc/KS/cReg[82]} {enc/KS/cReg[83]} {enc/KS/cReg[84]} {enc/KS/cReg[85]} {enc/KS/cReg[86]} {enc/KS/cReg[87]} {enc/KS/cReg[88]} {enc/KS/cReg[89]} {enc/KS/cReg[90]} {enc/KS/cReg[91]} {enc/KS/cReg[92]} {enc/KS/cReg[93]} {enc/KS/cReg[94]} {enc/KS/cReg[95]} {enc/KS/cReg[96]} {enc/KS/cReg[97]} {enc/KS/cReg[98]} {enc/KS/cReg[99]} {enc/KS/cReg[100]} {enc/KS/cReg[101]} {enc/KS/cReg[102]} {enc/KS/cReg[103]} {enc/KS/cReg[104]} {enc/KS/cReg[105]} {enc/KS/cReg[106]} {enc/KS/cReg[107]} {enc/KS/cReg[108]} {enc/KS/cReg[109]} {enc/KS/cReg[110]} {enc/KS/cReg[111]} {enc/KS/cReg[112]} {enc/KS/cReg[113]} {enc/KS/cReg[114]} {enc/KS/cReg[115]} {enc/KS/cReg[116]} {enc/KS/cReg[117]} {enc/KS/cReg[118]} {enc/KS/cReg[119]} {enc/KS/cReg[120]} {enc/KS/cReg[121]} {enc/KS/cReg[122]} {enc/KS/cReg[123]} {enc/KS/cReg[124]} {enc/KS/cReg[125]} {enc/KS/cReg[126]} {enc/KS/cReg[127]} {enc/KS/cReg[128]} {enc/KS/cReg[129]} {enc/KS/cReg[130]} {enc/KS/cReg[131]} {enc/KS/cReg[132]} {enc/KS/cReg[133]} {enc/KS/cReg[134]} {enc/KS/cReg[135]} {enc/KS/cReg[136]} {enc/KS/cReg[137]} {enc/KS/cReg[138]} {enc/KS/cReg[139]} {enc/KS/cReg[140]} {enc/KS/cReg[141]} {enc/KS/cReg[142]} {enc/KS/cReg[143]} {enc/KS/cReg[144]} {enc/KS/cReg[145]} {enc/KS/cReg[146]} {enc/KS/cReg[147]} {enc/KS/cReg[148]} {enc/KS/cReg[149]} {enc/KS/cReg[150]} {enc/KS/cReg[151]} {enc/KS/cReg[152]} {enc/KS/cReg[153]} {enc/KS/cReg[154]} {enc/KS/cReg[155]} {enc/KS/cReg[156]} {enc/KS/cReg[157]} {enc/KS/cReg[158]} {enc/KS/cReg[159]} {enc/KS/cReg[160]} {enc/KS/cReg[161]} {enc/KS/cReg[162]} {enc/KS/cReg[163]} {enc/KS/cReg[164]} {enc/KS/cReg[165]} {enc/KS/cReg[166]} {enc/KS/cReg[167]} {enc/KS/cReg[168]} {enc/KS/cReg[169]} {enc/KS/cReg[170]} {enc/KS/cReg[171]} {enc/KS/cReg[172]} {enc/KS/cReg[173]} {enc/KS/cReg[174]} {enc/KS/cReg[175]} {enc/KS/cReg[176]} {enc/KS/cReg[177]} {enc/KS/cReg[178]} {enc/KS/cReg[179]} {enc/KS/cReg[180]} {enc/KS/cReg[181]} {enc/KS/cReg[182]} {enc/KS/cReg[183]} {enc/KS/cReg[184]} {enc/KS/cReg[185]} {enc/KS/cReg[186]} {enc/KS/cReg[187]} {enc/KS/cReg[188]} {enc/KS/cReg[189]} {enc/KS/cReg[190]} {enc/KS/cReg[191]} {enc/KS/cReg[192]} {enc/KS/cReg[193]} {enc/KS/cReg[194]} {enc/KS/cReg[195]} {enc/KS/cReg[196]} {enc/KS/cReg[197]} {enc/KS/cReg[198]} {enc/KS/cReg[199]} {enc/KS/cReg[200]} {enc/KS/cReg[201]} {enc/KS/cReg[202]} {enc/KS/cReg[203]} {enc/KS/cReg[204]} {enc/KS/cReg[205]} {enc/KS/cReg[206]} {enc/KS/cReg[207]} {enc/KS/cReg[208]} {enc/KS/cReg[209]} {enc/KS/cReg[210]} {enc/KS/cReg[211]} {enc/KS/cReg[212]} {enc/KS/cReg[213]} {enc/KS/cReg[214]} {enc/KS/cReg[215]} {enc/KS/cReg[216]} {enc/KS/cReg[217]} {enc/KS/cReg[218]} {enc/KS/cReg[219]} {enc/KS/cReg[220]} {enc/KS/cReg[221]} {enc/KS/cReg[222]} {enc/KS/cReg[223]} {enc/KS/cReg[224]} {enc/KS/cReg[225]} {enc/KS/cReg[226]} {enc/KS/cReg[227]} {enc/KS/cReg[228]} {enc/KS/cReg[229]} {enc/KS/cReg[230]} {enc/KS/cReg[231]} {enc/KS/cReg[232]} {enc/KS/cReg[233]} {enc/KS/cReg[234]} {enc/KS/cReg[235]} {enc/KS/cReg[236]} {enc/KS/cReg[237]} {enc/KS/cReg[238]} {enc/KS/cReg[239]} {enc/KS/cReg[240]} {enc/KS/cReg[241]} {enc/KS/cReg[242]} {enc/KS/cReg[243]} {enc/KS/cReg[244]} {enc/KS/cReg[245]} {enc/KS/cReg[246]} {enc/KS/cReg[247]} {enc/KS/cReg[248]} {enc/KS/cReg[249]} {enc/KS/cReg[250]} {enc/KS/cReg[251]} {enc/KS/cReg[252]} {enc/KS/cReg[253]} {enc/KS/cReg[254]} {enc/KS/cReg[255]} {enc/KS/cReg[256]} {enc/KS/cReg[257]} {enc/KS/cReg[258]} {enc/KS/cReg[259]} {enc/KS/cReg[260]} {enc/KS/cReg[261]} {enc/KS/cReg[262]} {enc/KS/cReg[263]} {enc/KS/cReg[264]} {enc/KS/cReg[265]} {enc/KS/cReg[266]} {enc/KS/cReg[267]} {enc/KS/cReg[268]} {enc/KS/cReg[269]} {enc/KS/cReg[270]} {enc/KS/cReg[271]} {enc/KS/cReg[272]} {enc/KS/cReg[273]} {enc/KS/cReg[274]} {enc/KS/cReg[275]} {enc/KS/cReg[276]} {enc/KS/cReg[277]} {enc/KS/cReg[278]} {enc/KS/cReg[279]} {enc/KS/cReg[280]} {enc/KS/cReg[281]} {enc/KS/cReg[282]} {enc/KS/cReg[283]} {enc/KS/cReg[284]} {enc/KS/cReg[285]} {enc/KS/cReg[286]} {enc/KS/cReg[287]} {enc/KS/cReg[288]} {enc/KS/cReg[289]} {enc/KS/cReg[290]} {enc/KS/cReg[291]} {enc/KS/cReg[292]} {enc/KS/cReg[293]} {enc/KS/cReg[294]} {enc/KS/cReg[295]} {enc/KS/cReg[296]} {enc/KS/cReg[297]} {enc/KS/cReg[298]} {enc/KS/cReg[299]} {enc/KS/cReg[300]} {enc/KS/cReg[301]} {enc/KS/cReg[302]} {enc/KS/cReg[303]} {enc/KS/cReg[304]} {enc/KS/cReg[305]} {enc/KS/cReg[306]} {enc/KS/cReg[307]} {enc/KS/cReg[308]} {enc/KS/cReg[309]} {enc/KS/cReg[310]} {enc/KS/cReg[311]} {enc/KS/cReg[312]} {enc/KS/cReg[313]} {enc/KS/cReg[314]} {enc/KS/cReg[315]} {enc/KS/cReg[316]} {enc/KS/cReg[317]} {enc/KS/cReg[318]} {enc/KS/cReg[319]}]]
connect_debug_port u_ila_0/probe2 [get_nets [list resetEnc]]
connect_debug_port u_ila_0/probe3 [get_nets [list enc/rstK]]
connect_debug_port u_ila_1/clk [get_nets [list n_1_15328_BUFG]]
connect_debug_port u_ila_1/probe0 [get_nets [list {enc/KS/xout[0]} {enc/KS/xout[1]} {enc/KS/xout[2]} {enc/KS/xout[3]} {enc/KS/xout[4]} {enc/KS/xout[5]} {enc/KS/xout[6]} {enc/KS/xout[7]} {enc/KS/xout[8]} {enc/KS/xout[9]} {enc/KS/xout[10]} {enc/KS/xout[11]} {enc/KS/xout[12]} {enc/KS/xout[13]} {enc/KS/xout[14]} {enc/KS/xout[15]} {enc/KS/xout[16]} {enc/KS/xout[17]} {enc/KS/xout[18]} {enc/KS/xout[19]} {enc/KS/xout[20]} {enc/KS/xout[21]} {enc/KS/xout[22]} {enc/KS/xout[23]} {enc/KS/xout[24]} {enc/KS/xout[25]} {enc/KS/xout[26]} {enc/KS/xout[27]} {enc/KS/xout[28]} {enc/KS/xout[29]} {enc/KS/xout[30]} {enc/KS/xout[31]} {enc/KS/xout[32]} {enc/KS/xout[33]} {enc/KS/xout[34]} {enc/KS/xout[35]} {enc/KS/xout[36]} {enc/KS/xout[37]} {enc/KS/xout[38]} {enc/KS/xout[39]} {enc/KS/xout[40]} {enc/KS/xout[41]} {enc/KS/xout[42]} {enc/KS/xout[43]} {enc/KS/xout[44]} {enc/KS/xout[45]} {enc/KS/xout[46]} {enc/KS/xout[47]} {enc/KS/xout[48]} {enc/KS/xout[49]} {enc/KS/xout[50]} {enc/KS/xout[51]} {enc/KS/xout[52]} {enc/KS/xout[53]} {enc/KS/xout[54]} {enc/KS/xout[55]} {enc/KS/xout[56]} {enc/KS/xout[57]} {enc/KS/xout[58]} {enc/KS/xout[59]} {enc/KS/xout[60]} {enc/KS/xout[61]} {enc/KS/xout[62]} {enc/KS/xout[63]} {enc/KS/xout[64]} {enc/KS/xout[65]} {enc/KS/xout[66]} {enc/KS/xout[67]} {enc/KS/xout[68]} {enc/KS/xout[69]} {enc/KS/xout[70]} {enc/KS/xout[71]} {enc/KS/xout[72]} {enc/KS/xout[73]} {enc/KS/xout[74]} {enc/KS/xout[75]} {enc/KS/xout[76]} {enc/KS/xout[77]} {enc/KS/xout[78]} {enc/KS/xout[79]} {enc/KS/xout[80]} {enc/KS/xout[81]} {enc/KS/xout[82]} {enc/KS/xout[83]} {enc/KS/xout[84]} {enc/KS/xout[85]} {enc/KS/xout[86]} {enc/KS/xout[87]} {enc/KS/xout[88]} {enc/KS/xout[89]} {enc/KS/xout[90]} {enc/KS/xout[91]} {enc/KS/xout[92]} {enc/KS/xout[93]} {enc/KS/xout[94]} {enc/KS/xout[95]} {enc/KS/xout[96]} {enc/KS/xout[97]} {enc/KS/xout[98]} {enc/KS/xout[99]} {enc/KS/xout[100]} {enc/KS/xout[101]} {enc/KS/xout[102]} {enc/KS/xout[103]} {enc/KS/xout[104]} {enc/KS/xout[105]} {enc/KS/xout[106]} {enc/KS/xout[107]} {enc/KS/xout[108]} {enc/KS/xout[109]} {enc/KS/xout[110]} {enc/KS/xout[111]} {enc/KS/xout[112]} {enc/KS/xout[113]} {enc/KS/xout[114]} {enc/KS/xout[115]} {enc/KS/xout[116]} {enc/KS/xout[117]} {enc/KS/xout[118]} {enc/KS/xout[119]} {enc/KS/xout[120]} {enc/KS/xout[121]} {enc/KS/xout[122]} {enc/KS/xout[123]} {enc/KS/xout[124]} {enc/KS/xout[125]} {enc/KS/xout[126]} {enc/KS/xout[127]}]]
connect_debug_port dbg_hub/clk [get_nets n_1_15328_BUFG]

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]
