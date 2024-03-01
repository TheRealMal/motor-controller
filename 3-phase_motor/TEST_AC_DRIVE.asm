
_Interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;TEST_AC_DRIVE.c,16 :: 		void Interrupt()
;TEST_AC_DRIVE.c,20 :: 		for(j = 0; j < 10; j++) {
	CLRF       Interrupt_j_L0+0
	CLRF       Interrupt_j_L0+1
L_Interrupt0:
	MOVLW      128
	XORWF      Interrupt_j_L0+1, 0
	MOVWF      R0+0
	MOVLW      128
	SUBWF      R0+0, 0
	BTFSS      STATUS+0, 2
	GOTO       L__Interrupt26
	MOVLW      10
	SUBWF      Interrupt_j_L0+0, 0
L__Interrupt26:
	BTFSC      STATUS+0, 0
	GOTO       L_Interrupt1
;TEST_AC_DRIVE.c,21 :: 		if(bldc_step & 1) {
	BTFSS      _bldc_step+0, 0
	GOTO       L_Interrupt3
;TEST_AC_DRIVE.c,22 :: 		if(!C1OUT_bit)    j -= 1;
	BTFSC      C1OUT_bit+0, BitPos(C1OUT_bit+0)
	GOTO       L_Interrupt4
	MOVLW      1
	SUBWF      Interrupt_j_L0+0, 1
	BTFSS      STATUS+0, 0
	DECF       Interrupt_j_L0+1, 1
L_Interrupt4:
;TEST_AC_DRIVE.c,23 :: 		}
	GOTO       L_Interrupt5
L_Interrupt3:
;TEST_AC_DRIVE.c,25 :: 		if(C1OUT_bit)     j -= 1;
	BTFSS      C1OUT_bit+0, BitPos(C1OUT_bit+0)
	GOTO       L_Interrupt6
	MOVLW      1
	SUBWF      Interrupt_j_L0+0, 1
	BTFSS      STATUS+0, 0
	DECF       Interrupt_j_L0+1, 1
L_Interrupt6:
;TEST_AC_DRIVE.c,26 :: 		}
L_Interrupt5:
;TEST_AC_DRIVE.c,20 :: 		for(j = 0; j < 10; j++) {
	INCF       Interrupt_j_L0+0, 1
	BTFSC      STATUS+0, 2
	INCF       Interrupt_j_L0+1, 1
;TEST_AC_DRIVE.c,27 :: 		}
	GOTO       L_Interrupt0
L_Interrupt1:
;TEST_AC_DRIVE.c,28 :: 		bldc_move();
	CALL       _bldc_move+0
;TEST_AC_DRIVE.c,29 :: 		C1ON_bit = 1;      // clear the mismatch condition
	BSF        C1ON_bit+0, BitPos(C1ON_bit+0)
;TEST_AC_DRIVE.c,30 :: 		C1IF_bit = 0;      // Clear comparator 1 interrupt flag bit
	BCF        C1IF_bit+0, BitPos(C1IF_bit+0)
;TEST_AC_DRIVE.c,31 :: 		}
L_end_Interrupt:
L__Interrupt25:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _Interrupt

_bldc_move:

;TEST_AC_DRIVE.c,33 :: 		void bldc_move()        // BLDC motor commutation function
;TEST_AC_DRIVE.c,35 :: 		switch(bldc_step){
	GOTO       L_bldc_move7
;TEST_AC_DRIVE.c,36 :: 		case 0:
L_bldc_move9:
;TEST_AC_DRIVE.c,37 :: 		AH_BL();
	CALL       _AH_BL+0
;TEST_AC_DRIVE.c,38 :: 		CM1CON0 = 0xA2;   // Sense BEMF C (pin RA3 positive, RB3 negative)
	MOVLW      162
	MOVWF      CM1CON0+0
;TEST_AC_DRIVE.c,39 :: 		break;
	GOTO       L_bldc_move8
;TEST_AC_DRIVE.c,40 :: 		case 1:
L_bldc_move10:
;TEST_AC_DRIVE.c,41 :: 		AH_CL();
	CALL       _AH_CL+0
;TEST_AC_DRIVE.c,42 :: 		CM1CON0 = 0xA1;   // Sense BEMF B (pin RA3 positive, RA1 negative)
	MOVLW      161
	MOVWF      CM1CON0+0
;TEST_AC_DRIVE.c,43 :: 		break;
	GOTO       L_bldc_move8
;TEST_AC_DRIVE.c,44 :: 		case 2:
L_bldc_move11:
;TEST_AC_DRIVE.c,45 :: 		BH_CL();
	CALL       _BH_CL+0
;TEST_AC_DRIVE.c,46 :: 		CM1CON0 = 0xA0;   // Sense BEMF A (pin RA3 positive, RA0 negative)
	MOVLW      160
	MOVWF      CM1CON0+0
;TEST_AC_DRIVE.c,47 :: 		break;
	GOTO       L_bldc_move8
;TEST_AC_DRIVE.c,48 :: 		case 3:
L_bldc_move12:
;TEST_AC_DRIVE.c,49 :: 		BH_AL();
	CALL       _BH_AL+0
;TEST_AC_DRIVE.c,50 :: 		CM1CON0 = 0xA2;   // Sense BEMF C (pin RA3 positive, RB3 negative)
	MOVLW      162
	MOVWF      CM1CON0+0
;TEST_AC_DRIVE.c,51 :: 		break;
	GOTO       L_bldc_move8
;TEST_AC_DRIVE.c,52 :: 		case 4:
L_bldc_move13:
;TEST_AC_DRIVE.c,53 :: 		CH_AL();
	CALL       _CH_AL+0
;TEST_AC_DRIVE.c,54 :: 		CM1CON0 = 0xA1;   // Sense BEMF B (pin RA3 positive, RA1 negative)
	MOVLW      161
	MOVWF      CM1CON0+0
;TEST_AC_DRIVE.c,55 :: 		break;
	GOTO       L_bldc_move8
;TEST_AC_DRIVE.c,56 :: 		case 5:
L_bldc_move14:
;TEST_AC_DRIVE.c,57 :: 		CH_BL();
	CALL       _CH_BL+0
;TEST_AC_DRIVE.c,58 :: 		CM1CON0 = 0xA0;   // Sense BEMF A (pin RA3 positive, RA0 negative)
	MOVLW      160
	MOVWF      CM1CON0+0
;TEST_AC_DRIVE.c,59 :: 		break;
	GOTO       L_bldc_move8
;TEST_AC_DRIVE.c,60 :: 		}
L_bldc_move7:
	MOVLW      0
	XORWF      _bldc_step+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__bldc_move28
	MOVLW      0
	XORWF      _bldc_step+0, 0
L__bldc_move28:
	BTFSC      STATUS+0, 2
	GOTO       L_bldc_move9
	MOVLW      0
	XORWF      _bldc_step+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__bldc_move29
	MOVLW      1
	XORWF      _bldc_step+0, 0
L__bldc_move29:
	BTFSC      STATUS+0, 2
	GOTO       L_bldc_move10
	MOVLW      0
	XORWF      _bldc_step+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__bldc_move30
	MOVLW      2
	XORWF      _bldc_step+0, 0
L__bldc_move30:
	BTFSC      STATUS+0, 2
	GOTO       L_bldc_move11
	MOVLW      0
	XORWF      _bldc_step+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__bldc_move31
	MOVLW      3
	XORWF      _bldc_step+0, 0
L__bldc_move31:
	BTFSC      STATUS+0, 2
	GOTO       L_bldc_move12
	MOVLW      0
	XORWF      _bldc_step+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__bldc_move32
	MOVLW      4
	XORWF      _bldc_step+0, 0
L__bldc_move32:
	BTFSC      STATUS+0, 2
	GOTO       L_bldc_move13
	MOVLW      0
	XORWF      _bldc_step+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__bldc_move33
	MOVLW      5
	XORWF      _bldc_step+0, 0
L__bldc_move33:
	BTFSC      STATUS+0, 2
	GOTO       L_bldc_move14
L_bldc_move8:
;TEST_AC_DRIVE.c,61 :: 		bldc_step++;
	INCF       _bldc_step+0, 1
	BTFSC      STATUS+0, 2
	INCF       _bldc_step+1, 1
;TEST_AC_DRIVE.c,62 :: 		if(bldc_step >= 6)
	MOVLW      0
	SUBWF      _bldc_step+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__bldc_move34
	MOVLW      6
	SUBWF      _bldc_step+0, 0
L__bldc_move34:
	BTFSS      STATUS+0, 0
	GOTO       L_bldc_move15
;TEST_AC_DRIVE.c,63 :: 		bldc_step = 0;
	CLRF       _bldc_step+0
	CLRF       _bldc_step+1
L_bldc_move15:
;TEST_AC_DRIVE.c,64 :: 		}
L_end_bldc_move:
	RETURN
; end of _bldc_move

_set_pwm_duty:

;TEST_AC_DRIVE.c,67 :: 		void set_pwm_duty(unsigned int pwm_duty)
;TEST_AC_DRIVE.c,69 :: 		CCP1CON = ((pwm_duty << 4) & 0x30) | 0x0C;
	MOVLW      4
	MOVWF      R1+0
	MOVF       FARG_set_pwm_duty_pwm_duty+0, 0
	MOVWF      R0+0
	MOVF       R1+0, 0
L__set_pwm_duty36:
	BTFSC      STATUS+0, 2
	GOTO       L__set_pwm_duty37
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__set_pwm_duty36
L__set_pwm_duty37:
	MOVLW      48
	ANDWF      R0+0, 1
	MOVLW      12
	IORWF      R0+0, 0
	MOVWF      CCP1CON+0
;TEST_AC_DRIVE.c,70 :: 		CCPR1L  = pwm_duty >> 2;
	MOVF       FARG_set_pwm_duty_pwm_duty+0, 0
	MOVWF      R0+0
	MOVF       FARG_set_pwm_duty_pwm_duty+1, 0
	MOVWF      R0+1
	RRF        R0+1, 1
	RRF        R0+0, 1
	BCF        R0+1, 7
	RRF        R0+1, 1
	RRF        R0+0, 1
	BCF        R0+1, 7
	MOVF       R0+0, 0
	MOVWF      CCPR1L+0
;TEST_AC_DRIVE.c,71 :: 		}
L_end_set_pwm_duty:
	RETURN
; end of _set_pwm_duty

_main:

;TEST_AC_DRIVE.c,74 :: 		void main()
;TEST_AC_DRIVE.c,77 :: 		ANSEL = 0x10;     // configure AN4 (RA5) pin as analog
	MOVLW      16
	MOVWF      ANSEL+0
;TEST_AC_DRIVE.c,78 :: 		PORTD = 0;
	CLRF       PORTD+0
;TEST_AC_DRIVE.c,79 :: 		TRISD = 0;
	CLRF       TRISD+0
;TEST_AC_DRIVE.c,81 :: 		ADCON0 = 0xD0;    // select analog channel 4 (AN4)
	MOVLW      208
	MOVWF      ADCON0+0
;TEST_AC_DRIVE.c,82 :: 		ADFM_bit = 0;
	BCF        ADFM_bit+0, BitPos(ADFM_bit+0)
;TEST_AC_DRIVE.c,84 :: 		INTCON = 0xC0;   // enable global and peripheral interrupts
	MOVLW      192
	MOVWF      INTCON+0
;TEST_AC_DRIVE.c,85 :: 		C1IF_bit = 0;    // clear analog coparator interrupt flag bit
	BCF        C1IF_bit+0, BitPos(C1IF_bit+0)
;TEST_AC_DRIVE.c,88 :: 		CCP1CON = 0x0C;  // configure CCP1 module as PWM with single output & clear duty cycle 2 LSBs
	MOVLW      12
	MOVWF      CCP1CON+0
;TEST_AC_DRIVE.c,89 :: 		CCPR1L  = 0;     // clear duty cycle 8 MSBs
	CLRF       CCPR1L+0
;TEST_AC_DRIVE.c,91 :: 		TMR2IF_bit = 0;  // clear Timer2 interrupt flag bit
	BCF        TMR2IF_bit+0, BitPos(TMR2IF_bit+0)
;TEST_AC_DRIVE.c,92 :: 		T2CON = 0x04;    // enable Timer2 module with presacler = 1
	MOVLW      4
	MOVWF      T2CON+0
;TEST_AC_DRIVE.c,93 :: 		PR2   = 0xFF;    // Timer2 preload value = 255
	MOVLW      255
	MOVWF      PR2+0
;TEST_AC_DRIVE.c,96 :: 		set_pwm_duty(PWM_START_DUTY);                 // Set PWM duty cycle
	MOVLW      200
	MOVWF      FARG_set_pwm_duty_pwm_duty+0
	CLRF       FARG_set_pwm_duty_pwm_duty+1
	CALL       _set_pwm_duty+0
;TEST_AC_DRIVE.c,97 :: 		i = 5000;
	MOVLW      136
	MOVWF      _i+0
	MOVLW      19
	MOVWF      _i+1
;TEST_AC_DRIVE.c,98 :: 		while(i > 100)
L_main16:
	MOVF       _i+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__main39
	MOVF       _i+0, 0
	SUBLW      100
L__main39:
	BTFSC      STATUS+0, 0
	GOTO       L_main17
;TEST_AC_DRIVE.c,100 :: 		j = i;
	MOVF       _i+0, 0
	MOVWF      _j+0
	MOVF       _i+1, 0
	MOVWF      _j+1
;TEST_AC_DRIVE.c,101 :: 		while(j--) ;
L_main18:
	MOVF       _j+0, 0
	MOVWF      R0+0
	MOVF       _j+1, 0
	MOVWF      R0+1
	MOVLW      1
	SUBWF      _j+0, 1
	BTFSS      STATUS+0, 0
	DECF       _j+1, 1
	MOVF       R0+0, 0
	IORWF      R0+1, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main19
	GOTO       L_main18
L_main19:
;TEST_AC_DRIVE.c,102 :: 		bldc_move();
	CALL       _bldc_move+0
;TEST_AC_DRIVE.c,103 :: 		i = i - 50;
	MOVLW      50
	SUBWF      _i+0, 1
	BTFSS      STATUS+0, 0
	DECF       _i+1, 1
;TEST_AC_DRIVE.c,104 :: 		}
	GOTO       L_main16
L_main17:
;TEST_AC_DRIVE.c,106 :: 		ADON_bit = 1;
	BSF        ADON_bit+0, BitPos(ADON_bit+0)
;TEST_AC_DRIVE.c,107 :: 		C1IE_bit = 1;   // enable analog coparator interrupt
	BSF        C1IE_bit+0, BitPos(C1IE_bit+0)
;TEST_AC_DRIVE.c,109 :: 		while(1)
L_main20:
;TEST_AC_DRIVE.c,111 :: 		GO_DONE_bit = 1;  // start analog-to-digital conversion
	BSF        GO_DONE_bit+0, BitPos(GO_DONE_bit+0)
;TEST_AC_DRIVE.c,112 :: 		delay_ms(50);     // wait 50 ms
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_main22:
	DECFSZ     R13+0, 1
	GOTO       L_main22
	DECFSZ     R12+0, 1
	GOTO       L_main22
	NOP
	NOP
;TEST_AC_DRIVE.c,114 :: 		motor_speed = (ADRESH << 2) | (ADRESL >> 6); // read ADC registers
	MOVF       ADRESH+0, 0
	MOVWF      R3+0
	CLRF       R3+1
	RLF        R3+0, 1
	RLF        R3+1, 1
	BCF        R3+0, 0
	RLF        R3+0, 1
	RLF        R3+1, 1
	BCF        R3+0, 0
	MOVLW      6
	MOVWF      R1+0
	MOVF       ADRESL+0, 0
	MOVWF      R0+0
	MOVF       R1+0, 0
L__main40:
	BTFSC      STATUS+0, 2
	GOTO       L__main41
	RRF        R0+0, 1
	BCF        R0+0, 7
	ADDLW      255
	GOTO       L__main40
L__main41:
	MOVF       R0+0, 0
	IORWF      R3+0, 0
	MOVWF      R1+0
	MOVF       R3+1, 0
	MOVWF      R1+1
	MOVLW      0
	IORWF      R1+1, 1
	MOVF       R1+0, 0
	MOVWF      _motor_speed+0
	MOVF       R1+1, 0
	MOVWF      _motor_speed+1
;TEST_AC_DRIVE.c,116 :: 		if(motor_speed < PWM_MIN_DUTY)
	MOVLW      0
	SUBWF      R1+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__main42
	MOVLW      80
	SUBWF      R1+0, 0
L__main42:
	BTFSC      STATUS+0, 0
	GOTO       L_main23
;TEST_AC_DRIVE.c,117 :: 		motor_speed = PWM_MIN_DUTY;
	MOVLW      80
	MOVWF      _motor_speed+0
	MOVLW      0
	MOVWF      _motor_speed+1
L_main23:
;TEST_AC_DRIVE.c,118 :: 		set_pwm_duty(motor_speed);             // set PWM duty cycle
	MOVF       _motor_speed+0, 0
	MOVWF      FARG_set_pwm_duty_pwm_duty+0
	MOVF       _motor_speed+1, 0
	MOVWF      FARG_set_pwm_duty_pwm_duty+1
	CALL       _set_pwm_duty+0
;TEST_AC_DRIVE.c,120 :: 		}
	GOTO       L_main20
;TEST_AC_DRIVE.c,122 :: 		}
L_end_main:
	GOTO       $+0
; end of _main

_AH_BL:

;TEST_AC_DRIVE.c,124 :: 		void AH_BL()
;TEST_AC_DRIVE.c,126 :: 		CCP1CON = 0;        // PWM off
	CLRF       CCP1CON+0
;TEST_AC_DRIVE.c,127 :: 		PORTD   = 0x08;
	MOVLW      8
	MOVWF      PORTD+0
;TEST_AC_DRIVE.c,128 :: 		PSTRCON = 0x08;     // PWM output on pin P1D (RD7), others OFF
	MOVLW      8
	MOVWF      PSTRCON+0
;TEST_AC_DRIVE.c,129 :: 		CCP1CON = 0x0C;     // PWM on
	MOVLW      12
	MOVWF      CCP1CON+0
;TEST_AC_DRIVE.c,130 :: 		}
L_end_AH_BL:
	RETURN
; end of _AH_BL

_AH_CL:

;TEST_AC_DRIVE.c,132 :: 		void AH_CL()
;TEST_AC_DRIVE.c,134 :: 		PORTD = 0x04;
	MOVLW      4
	MOVWF      PORTD+0
;TEST_AC_DRIVE.c,135 :: 		}
L_end_AH_CL:
	RETURN
; end of _AH_CL

_BH_CL:

;TEST_AC_DRIVE.c,137 :: 		void BH_CL()
;TEST_AC_DRIVE.c,139 :: 		CCP1CON = 0;        // PWM off
	CLRF       CCP1CON+0
;TEST_AC_DRIVE.c,140 :: 		PORTD   = 0x04;
	MOVLW      4
	MOVWF      PORTD+0
;TEST_AC_DRIVE.c,141 :: 		PSTRCON = 0x04;     // PWM output on pin P1C (RD6), others OFF
	MOVLW      4
	MOVWF      PSTRCON+0
;TEST_AC_DRIVE.c,142 :: 		CCP1CON = 0x0C;     // PWM on
	MOVLW      12
	MOVWF      CCP1CON+0
;TEST_AC_DRIVE.c,143 :: 		}
L_end_BH_CL:
	RETURN
; end of _BH_CL

_BH_AL:

;TEST_AC_DRIVE.c,145 :: 		void BH_AL()
;TEST_AC_DRIVE.c,147 :: 		PORTD = 0x10;
	MOVLW      16
	MOVWF      PORTD+0
;TEST_AC_DRIVE.c,148 :: 		}
L_end_BH_AL:
	RETURN
; end of _BH_AL

_CH_AL:

;TEST_AC_DRIVE.c,150 :: 		void CH_AL()
;TEST_AC_DRIVE.c,152 :: 		CCP1CON = 0;        // PWM off
	CLRF       CCP1CON+0
;TEST_AC_DRIVE.c,153 :: 		PORTD   = 0x10;
	MOVLW      16
	MOVWF      PORTD+0
;TEST_AC_DRIVE.c,154 :: 		PSTRCON = 0x02;     // PWM output on pin P1B (RD5), others OFF
	MOVLW      2
	MOVWF      PSTRCON+0
;TEST_AC_DRIVE.c,155 :: 		CCP1CON = 0x0C;     // PWM on
	MOVLW      12
	MOVWF      CCP1CON+0
;TEST_AC_DRIVE.c,156 :: 		}
L_end_CH_AL:
	RETURN
; end of _CH_AL

_CH_BL:

;TEST_AC_DRIVE.c,158 :: 		void CH_BL()
;TEST_AC_DRIVE.c,160 :: 		PORTD = 0x08;
	MOVLW      8
	MOVWF      PORTD+0
;TEST_AC_DRIVE.c,161 :: 		}
L_end_CH_BL:
	RETURN
; end of _CH_BL
