!zone InitIrq
InitIrq
          lda #$37
          sta PROCESSOR_PORT
          cli

          lda #$7f
          sta CIA1.IRQ_CONTROL

          lda VIC.CONTROL_1
          and #$7f
          sta VIC.CONTROL_1

          lda #2
          sta VIC.RASTER_POS
          lda #$35
          sta PROCESSOR_PORT

          lda #<IrqTop
          sta KERNAL_IRQ_LO
          lda #>IrqTop
          sta KERNAL_IRQ_HI

          lda #$01
          sta VIC.IRQ_MASK
          rts



!zone IrqTop
IrqTop
          pha
          txa
          pha
          tya
          pha

          lda JOYSTICK_PORT_II
          sta JOY_VALUE
          and #$1f
          ora JOY_RELEASED
          sta JOY_RELEASED

          lda #147
          sta VIC.RASTER_POS

          lda #( ( SCREEN_CHAR % 16384 ) / 1024 ) | ( ( CHARSET_LOCATION % 16384 ) / 1024 )
          sta VIC.MEMORY_CONTROL

          lda #$10
          ora SCROLL_OFFSET_X
          sta VIC.CONTROL_2

          lda #$0b
          ora TOP_SCREEN_ACTIVE
          sta VIC.CONTROL_1

          lda SPRITES_ENABLED
          sta VIC.SPRITE_ENABLE


          lda #<IrqBelowGameField
          sta KERNAL_IRQ_LO
          lda #>IrqBelowGameField
          sta KERNAL_IRQ_HI

          lda #$ff
          sta VIC.IRQ_REQUEST

          ldy CURRENT_DECK
          lda DECK_BG_COLOR,y
          sta VIC.BACKGROUND_COLOR

          ;prepare sprites for next frame
          lda SPRITE_POS_X_EXTEND
          sta VIC.SPRITE_X_EXTEND
          ldx #0
          ldy #0
-
          lda SPRITE_IMAGE,x
          sta SPRITE_POINTER_BASE,x

          lda SPRITE_POS_X,x
          sta VIC.SPRITE_X_POS,y
          lda SPRITE_POS_Y,x
          sta VIC.SPRITE_Y_POS,y

          iny
          iny
          inx
          cpx #8
          bne -

          jsr SFXUpdate

          pla
          tay
          pla
          tax
          pla

          rti



!zone IrqBelowGameField
IrqBelowGameField
          pha
          txa
          pha
          tya
          pha

          lda #$1b
          sta VIC.CONTROL_1

          lda #154
          sta VIC.RASTER_POS

          lda #<IrqPanelTop
          sta KERNAL_IRQ_LO
          lda #>IrqPanelTop
          sta KERNAL_IRQ_HI

          lda #$ff
          sta VIC.IRQ_REQUEST

          pla
          tay
          pla
          tax
          pla

          rti



!zone IrqPanelTop
IrqPanelTop
          pha
          txa
          pha
          tya
          pha

          lda #6
          sta VIC.BACKGROUND_COLOR

          lda #2
          sta VIC.RASTER_POS

          lda #<IrqTop
          sta KERNAL_IRQ_LO
          lda #>IrqTop
          sta KERNAL_IRQ_HI

          lda #$ff
          sta VIC.IRQ_REQUEST

          lda #$18
          sta VIC.CONTROL_2

          lda #( ( SCREEN_CHAR % 16384 ) / 1024 ) | ( ( CHARSET_PANEL_LOCATION % 16384 ) / 1024 )
          sta VIC.MEMORY_CONTROL

          lda #$37
          sta PROCESSOR_PORT

          jsr KERNAL.SCNKEY
          jsr KERNAL.GETIN
          sta PRESSED_KEY

          lda #$35
          sta PROCESSOR_PORT

          pla
          tay
          pla
          tax
          pla

          rti



;a = char pos (on screen)
;returns a = tile pos
!lzone CalcTilePosFromCharPos
          bmi .Negative
          clc
          adc X_OFFSET_INSIDE_TILE
          lsr
          lsr
          clc
          adc X_OFFSET_TILE
          rts

.Negative
          sta PARAM11

          lda X_OFFSET_TILE
          asl
          asl
          clc
          adc PARAM1
          clc
          adc X_OFFSET_INSIDE_TILE
          lsr
          lsr
          rts



;char index from tile
!lzone CalcCharPosFromTilePos
          sec
          sbc X_OFFSET_TILE
          asl
          asl
          sec
          sbc X_OFFSET_INSIDE_TILE
          rts


JOY_VALUE
          !byte 0

JOY_RELEASED
          !byte 0

PRESSED_KEY
          !byte 0

;$10 = active, 0 = disabled
TOP_SCREEN_ACTIVE
          !byte $10