!zone WaitFrame
;a = raster pos to wait for (<256)
WaitFrame
          cmp VIC.RASTER_POS
          bne WaitFrame

          rts



;------------------------------------------------------------
;generates a sometimes random number
;------------------------------------------------------------
!zone GenerateRandomNumber
GenerateRandomNumber
          lda $dc04
          eor $dc05
          eor $dd04
          adc $dd05
          eor $dd06
          eor $dd07
          rts



;------------------------------------------------------------
;CalcSpritePosFromCharPos
;calculates the real sprite coordinates from screen char pos
;and sets them directly
;PARAM1 = char_pos_x
;PARAM2 = char_pos_y
;X      = sprite index
;------------------------------------------------------------
!zone CalcSpritePosFromCharPos
CalcSpritePosFromCharPos

          ;offset screen to border 24,50
          lda BIT_TABLE,x
          eor #$ff
          and SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND
          sta VIC.SPRITE_X_EXTEND

          ;need extended x bit?
          lda PARAM1
          sta SPRITE_CHAR_POS_X,x
          cmp #30
          bcc .NoXBit

          lda BIT_TABLE,x
          ora SPRITE_POS_X_EXTEND
          sta SPRITE_POS_X_EXTEND
          sta VIC.SPRITE_X_EXTEND

.NoXBit
          ;calculate sprite positions (offset from border)
          txa
          asl
          tay

          lda PARAM1
          asl
          asl
          asl
          clc
          adc #( 24 - SPRITE_CENTER_OFFSET_X )
          sta SPRITE_POS_X,x
          sta VIC.SPRITE_X_POS,y

          lda PARAM2
          sta SPRITE_CHAR_POS_Y,x
          asl
          asl
          asl
          clc
          adc #( 50 - SPRITE_CENTER_OFFSET_Y )
          sta SPRITE_POS_Y,x
          sta VIC.SPRITE_Y_POS,y

          lda #0
          sta SPRITE_CHAR_POS_X_DELTA,x
          sta SPRITE_CHAR_POS_Y_DELTA,x
          rts



;checks if a released joystick control button is pressed
;a = control mask ($10 = button, $08 = r, $04 = l, $02 = d, $01 = u)
;returns 0 if pushed, 1 if not
!zone JoyReleasedControlPressed
JoyReleasedControlPressed
          sta PARAM1
          and JOY_VALUE
          bne .NotPushed

          lda JOY_RELEASED
          and PARAM1
          beq .NotReleased

          ;remove release bit
          lda PARAM1
          eor #$ff
          and JOY_RELEASED
          sta JOY_RELEASED

          lda #0
          rts

.NotPushed
          ;lda JOY_RELEASED
          ;ora PARAM1
          ;sta JOY_RELEASED
.NotReleased
          lda #1
          rts



!lzone DecreaseValue
          ldy #2

.DecreaseNextDigit
          lda (ZEROPAGE_POINTER_1),y
          cmp #48
          beq .IsZero
          sec
          sbc #1
          sta (ZEROPAGE_POINTER_1),y
          rts

.IsZero
          lda #48 + 9
          sta (ZEROPAGE_POINTER_1),y
          dey
          jmp .DecreaseNextDigit
