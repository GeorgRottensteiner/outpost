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

          lda #<IrqBelowGameField
          sta KERNAL_IRQ_LO
          lda #>IrqBelowGameField
          sta KERNAL_IRQ_HI

          lda #$ff
          sta VIC.IRQ_REQUEST

          lda #12
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

          pla
          tay
          pla
          tax
          pla

          rti



JOY_VALUE
          !byte 0

JOY_RELEASED
          !byte 0