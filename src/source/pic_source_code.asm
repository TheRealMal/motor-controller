
_SPI_Ethernet_UserTCP:

;pic_source_code.c,36 :: 		unsigned int SPI_Ethernet_UserTCP(unsigned char *remoteHost, unsigned int remotePort, unsigned int localPort, unsigned int reqLength, TEthPktFlags *flags) {
;pic_source_code.c,38 :: 		for (length=0; length<10; ++length) {
	CLRF        SPI_Ethernet_UserTCP_length_L0+0 
	CLRF        SPI_Ethernet_UserTCP_length_L0+1 
L_SPI_Ethernet_UserTCP0:
	MOVLW       0
	SUBWF       SPI_Ethernet_UserTCP_length_L0+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__SPI_Ethernet_UserTCP11
	MOVLW       10
	SUBWF       SPI_Ethernet_UserTCP_length_L0+0, 0 
L__SPI_Ethernet_UserTCP11:
	BTFSC       STATUS+0, 0 
	GOTO        L_SPI_Ethernet_UserTCP1
;pic_source_code.c,39 :: 		getRequest[length]=SPI_Ethernet_getByte();
	MOVLW       _getRequest+0
	ADDWF       SPI_Ethernet_UserTCP_length_L0+0, 0 
	MOVWF       FLOC__SPI_Ethernet_UserTCP+0 
	MOVLW       hi_addr(_getRequest+0)
	ADDWFC      SPI_Ethernet_UserTCP_length_L0+1, 0 
	MOVWF       FLOC__SPI_Ethernet_UserTCP+1 
	CALL        _SPI_Ethernet_getByte+0, 0
	MOVFF       FLOC__SPI_Ethernet_UserTCP+0, FSR1
	MOVFF       FLOC__SPI_Ethernet_UserTCP+1, FSR1H
	MOVF        R0, 0 
	MOVWF       POSTINC1+0 
;pic_source_code.c,38 :: 		for (length=0; length<10; ++length) {
	INFSNZ      SPI_Ethernet_UserTCP_length_L0+0, 1 
	INCF        SPI_Ethernet_UserTCP_length_L0+1, 1 
;pic_source_code.c,40 :: 		}
	GOTO        L_SPI_Ethernet_UserTCP0
L_SPI_Ethernet_UserTCP1:
;pic_source_code.c,41 :: 		getRequest[length]=0;
	MOVLW       _getRequest+0
	ADDWF       SPI_Ethernet_UserTCP_length_L0+0, 0 
	MOVWF       FSR1 
	MOVLW       hi_addr(_getRequest+0)
	ADDWFC      SPI_Ethernet_UserTCP_length_L0+1, 0 
	MOVWF       FSR1H 
	CLRF        POSTINC1+0 
;pic_source_code.c,43 :: 		if (memcmp(getRequest, "GET /", 5)){
	MOVLW       _getRequest+0
	MOVWF       FARG_memcmp_s1+0 
	MOVLW       hi_addr(_getRequest+0)
	MOVWF       FARG_memcmp_s1+1 
	MOVLW       ?lstr1_pic_source_code+0
	MOVWF       FARG_memcmp_s2+0 
	MOVLW       hi_addr(?lstr1_pic_source_code+0)
	MOVWF       FARG_memcmp_s2+1 
	MOVLW       5
	MOVWF       FARG_memcmp_n+0 
	MOVLW       0
	MOVWF       FARG_memcmp_n+1 
	CALL        _memcmp+0, 0
	MOVF        R0, 0 
	IORWF       R1, 0 
	BTFSC       STATUS+0, 2 
	GOTO        L_SPI_Ethernet_UserTCP3
;pic_source_code.c,44 :: 		return(0);
	CLRF        R0 
	CLRF        R1 
	GOTO        L_end_SPI_Ethernet_UserTCP
;pic_source_code.c,45 :: 		}
L_SPI_Ethernet_UserTCP3:
;pic_source_code.c,47 :: 		if (!memcmp(getRequest + 6, "TA", 2)){
	MOVLW       _getRequest+6
	MOVWF       FARG_memcmp_s1+0 
	MOVLW       hi_addr(_getRequest+6)
	MOVWF       FARG_memcmp_s1+1 
	MOVLW       ?lstr2_pic_source_code+0
	MOVWF       FARG_memcmp_s2+0 
	MOVLW       hi_addr(?lstr2_pic_source_code+0)
	MOVWF       FARG_memcmp_s2+1 
	MOVLW       2
	MOVWF       FARG_memcmp_n+0 
	MOVLW       0
	MOVWF       FARG_memcmp_n+1 
	CALL        _memcmp+0, 0
	MOVF        R0, 0 
	IORWF       R1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_SPI_Ethernet_UserTCP4
;pic_source_code.c,48 :: 		RD0_bit = ~ RD0_bit;
	BTG         RD0_bit+0, BitPos(RD0_bit+0) 
;pic_source_code.c,49 :: 		} else if (!memcmp(getRequest + 6, "TB", 2)) {
	GOTO        L_SPI_Ethernet_UserTCP5
L_SPI_Ethernet_UserTCP4:
	MOVLW       _getRequest+6
	MOVWF       FARG_memcmp_s1+0 
	MOVLW       hi_addr(_getRequest+6)
	MOVWF       FARG_memcmp_s1+1 
	MOVLW       ?lstr3_pic_source_code+0
	MOVWF       FARG_memcmp_s2+0 
	MOVLW       hi_addr(?lstr3_pic_source_code+0)
	MOVWF       FARG_memcmp_s2+1 
	MOVLW       2
	MOVWF       FARG_memcmp_n+0 
	MOVLW       0
	MOVWF       FARG_memcmp_n+1 
	CALL        _memcmp+0, 0
	MOVF        R0, 0 
	IORWF       R1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L_SPI_Ethernet_UserTCP6
;pic_source_code.c,50 :: 		RD1_bit = ~ RD1_bit;
	BTG         RD1_bit+0, BitPos(RD1_bit+0) 
;pic_source_code.c,51 :: 		}
L_SPI_Ethernet_UserTCP6:
L_SPI_Ethernet_UserTCP5:
;pic_source_code.c,53 :: 		if (localPort != 80) {
	MOVLW       0
	XORWF       FARG_SPI_Ethernet_UserTCP_localPort+1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__SPI_Ethernet_UserTCP12
	MOVLW       80
	XORWF       FARG_SPI_Ethernet_UserTCP_localPort+0, 0 
L__SPI_Ethernet_UserTCP12:
	BTFSC       STATUS+0, 2 
	GOTO        L_SPI_Ethernet_UserTCP7
;pic_source_code.c,54 :: 		return(0);
	CLRF        R0 
	CLRF        R1 
	GOTO        L_end_SPI_Ethernet_UserTCP
;pic_source_code.c,55 :: 		}
L_SPI_Ethernet_UserTCP7:
;pic_source_code.c,57 :: 		length = SPI_Ethernet_putConstString(HTTPheader);
	MOVLW       _HTTPheader+0
	MOVWF       FARG_SPI_Ethernet_putConstString_ptr+0 
	MOVLW       hi_addr(_HTTPheader+0)
	MOVWF       FARG_SPI_Ethernet_putConstString_ptr+1 
	MOVLW       higher_addr(_HTTPheader+0)
	MOVWF       FARG_SPI_Ethernet_putConstString_ptr+2 
	CALL        _SPI_Ethernet_putConstString+0, 0
	MOVF        R0, 0 
	MOVWF       SPI_Ethernet_UserTCP_length_L0+0 
	MOVF        R1, 0 
	MOVWF       SPI_Ethernet_UserTCP_length_L0+1 
;pic_source_code.c,58 :: 		length += SPI_Ethernet_putConstString(HTTPMimeTypeHTML);
	MOVLW       _HTTPMimeTypeHTML+0
	MOVWF       FARG_SPI_Ethernet_putConstString_ptr+0 
	MOVLW       hi_addr(_HTTPMimeTypeHTML+0)
	MOVWF       FARG_SPI_Ethernet_putConstString_ptr+1 
	MOVLW       higher_addr(_HTTPMimeTypeHTML+0)
	MOVWF       FARG_SPI_Ethernet_putConstString_ptr+2 
	CALL        _SPI_Ethernet_putConstString+0, 0
	MOVF        R0, 0 
	ADDWF       SPI_Ethernet_UserTCP_length_L0+0, 1 
	MOVF        R1, 0 
	ADDWFC      SPI_Ethernet_UserTCP_length_L0+1, 1 
;pic_source_code.c,59 :: 		length += SPI_Ethernet_putString(IndexPage);
	MOVLW       _IndexPage+0
	MOVWF       FARG_SPI_Ethernet_putString_ptr+0 
	MOVLW       hi_addr(_IndexPage+0)
	MOVWF       FARG_SPI_Ethernet_putString_ptr+1 
	CALL        _SPI_Ethernet_putString+0, 0
	MOVF        SPI_Ethernet_UserTCP_length_L0+0, 0 
	ADDWF       R0, 1 
	MOVF        SPI_Ethernet_UserTCP_length_L0+1, 0 
	ADDWFC      R1, 1 
	MOVF        R0, 0 
	MOVWF       SPI_Ethernet_UserTCP_length_L0+0 
	MOVF        R1, 0 
	MOVWF       SPI_Ethernet_UserTCP_length_L0+1 
;pic_source_code.c,60 :: 		return length;
;pic_source_code.c,61 :: 		}
L_end_SPI_Ethernet_UserTCP:
	RETURN      0
; end of _SPI_Ethernet_UserTCP

_SPI_Ethernet_UserUDP:

;pic_source_code.c,66 :: 		unsigned int SPI_Ethernet_UserUDP(unsigned char *remoteHost, unsigned int remotePort, unsigned int destPort, unsigned int reqLength, TEthPktFlags *flags) {
;pic_source_code.c,67 :: 		return(0);
	CLRF        R0 
	CLRF        R1 
;pic_source_code.c,68 :: 		}
L_end_SPI_Ethernet_UserUDP:
	RETURN      0
; end of _SPI_Ethernet_UserUDP

_main:

;pic_source_code.c,73 :: 		void main() {
;pic_source_code.c,74 :: 		ANSELC = 0; // Configure PORTC as digital
	CLRF        ANSELC+0 
;pic_source_code.c,75 :: 		ANSELD = 0; // Configure PORTD as digital
	CLRF        ANSELD+0 
;pic_source_code.c,76 :: 		TRISD = 0; // Configure PORTD as output
	CLRF        TRISD+0 
;pic_source_code.c,77 :: 		PORTD = 0;
	CLRF        PORTD+0 
;pic_source_code.c,78 :: 		SPI1_Init(); // Initialize SPI module
	CALL        _SPI1_Init+0, 0
;pic_source_code.c,79 :: 		SPI_Ethernet_Init(MACAddr, IPAddr, 0x01); // Initialize Ethernet module
	MOVLW       _MACAddr+0
	MOVWF       FARG_SPI_Ethernet_Init_mac+0 
	MOVLW       hi_addr(_MACAddr+0)
	MOVWF       FARG_SPI_Ethernet_Init_mac+1 
	MOVLW       _IPAddr+0
	MOVWF       FARG_SPI_Ethernet_Init_ip+0 
	MOVLW       hi_addr(_IPAddr+0)
	MOVWF       FARG_SPI_Ethernet_Init_ip+1 
	MOVLW       1
	MOVWF       FARG_SPI_Ethernet_Init_fullDuplex+0 
	CALL        _SPI_Ethernet_Init+0, 0
;pic_source_code.c,81 :: 		while(1) {
L_main8:
;pic_source_code.c,82 :: 		SPI_Ethernet_doPacket(); // Process next received packet
	CALL        _SPI_Ethernet_doPacket+0, 0
;pic_source_code.c,83 :: 		}
	GOTO        L_main8
;pic_source_code.c,84 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
