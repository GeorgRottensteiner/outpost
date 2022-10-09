NUM_KNOWN_ITEMS = 3

ITEM_NONE         = 0
ITEM_PISTOL       = 1
ITEM_KEYCARD_A    = 2



!lzone ClearInventory
          ldx #0
          txa
-
          sta ITEM_COLLECTED,x
          inx
          cpx #NUM_KNOWN_ITEMS
          bne -

          ;we always have the "none" item
          lda #1
          sta ITEM_COLLECTED + ITEM_NONE

          rts



;x,y = pos on screen
;a = item
!lzone DrawItem
          pha

          lda SCREEN_LINE_OFFSET_TABLE_LO,y
          sta ZEROPAGE_POINTER_1
          sta ZEROPAGE_POINTER_2
          lda SCREEN_LINE_OFFSET_TABLE_HI,y
          sta ZEROPAGE_POINTER_1 + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta ZEROPAGE_POINTER_2 + 1

          txa
          tay
          lda #3
          sta PARAM2

          ;* 6
          pla
          sta PARAM1
          asl
          clc
          adc PARAM1
          asl

          tax
-
          lda ITEMS_0_CHARS,x
          sta (ZEROPAGE_POINTER_1),y
          lda ITEMS_0_COLORS,x
          sta (ZEROPAGE_POINTER_2),y

          inx
          iny
          dec PARAM2
          bne -

          tya
          clc
          adc #37
          tay

          lda #3
          sta PARAM2

-
          lda ITEMS_0_CHARS,x
          sta (ZEROPAGE_POINTER_1),y
          lda ITEMS_0_COLORS,x
          sta (ZEROPAGE_POINTER_2),y

          inx
          iny
          dec PARAM2
          bne -

          rts



!lzone DisplayInventory
          ldx ACTIVE_ITEM

          ldy #15
          sty PARAM12
          lda #0
          sta PARAM11
-
          stx CURRENT_INDEX
          lda ITEM_COLLECTED,x
          beq .DontHaveItem

          ldx #3
          ldy PARAM12
          lda CURRENT_INDEX
          jsr DrawItem

          lda PARAM12
          clc
          adc #3
          sta PARAM12
          cmp #24
          beq .Done

.DontHaveItem
          ;only go around once
          inc PARAM11
          lda PARAM11
          cmp #NUM_KNOWN_ITEMS
          beq .Wrap

          ldx CURRENT_INDEX
          inx
          cpx #NUM_KNOWN_ITEMS
          bne -

          ldx #0
          jmp -

.Done
          rts


          ;fill with empty
.Wrap
          ldx #3
          ldy PARAM12
          lda #0
          jsr DrawItem

          lda PARAM12
          clc
          adc #3
          sta PARAM12
          cmp #24
          bne .Wrap
          rts


;a = text index
!lzone AddText
          tay

          lda CURRENT_DISPLAY_TEXT + 1
          bne .StillDisplayingText

          ;shift other text up
          jsr ShiftTextUp

          lda TEXT_LO,y
          sta CURRENT_DISPLAY_TEXT
          lda TEXT_HI,y
          sta CURRENT_DISPLAY_TEXT + 1
          lda #0
          sta CURRENT_DISPLAY_TEXT_POS
          rts


.StillDisplayingText
          rts


!lzone ShiftTextUp
          ldx #0
-
          lda SCREEN_CHAR + 21 * 40 + 10,x
          sta SCREEN_CHAR + 20 * 40 + 10,x
          lda SCREEN_CHAR + 22 * 40 + 10,x
          sta SCREEN_CHAR + 21 * 40 + 10,x
          lda SCREEN_CHAR + 23 * 40 + 10,x
          sta SCREEN_CHAR + 22 * 40 + 10,x
          lda #32
          sta SCREEN_CHAR + 23 * 40 + 10,x
          inx
          cpx #20
          bne -
          rts


!lzone HandleDisplayText
          lda CURRENT_DISPLAY_TEXT + 1
          bne .HaveText

          ;automated shift
          inc DISPLAY_TEXT_SHIFT_PAUSE
          bpl +

          lda #0
          sta DISPLAY_TEXT_SHIFT_PAUSE
          jmp ShiftTextUp
+
          rts

.HaveText
          lda CURRENT_DISPLAY_TEXT
          sta ZEROPAGE_POINTER_1
          lda CURRENT_DISPLAY_TEXT + 1
          sta ZEROPAGE_POINTER_1 + 1

          lda #<( SCREEN_PANEL_POS + $122 + 3 * 40 )
          sta ZEROPAGE_POINTER_2
          lda #>( SCREEN_PANEL_POS + $122 + 3 * 40 )
          sta ZEROPAGE_POINTER_2 + 1

          ldy CURRENT_DISPLAY_TEXT_POS
          lda (ZEROPAGE_POINTER_1),y
          beq .Done

          sta (ZEROPAGE_POINTER_2),y

          inc CURRENT_DISPLAY_TEXT_POS
          rts

.Done
          lda #0
          sta CURRENT_DISPLAY_TEXT + 1
          sta DISPLAY_TEXT_SHIFT_PAUSE
          rts


CURRENT_DISPLAY_TEXT
          !word 0

CURRENT_DISPLAY_TEXT_POS
          !byte 0

;active item (the actual item ID)
ACTIVE_ITEM
          !byte 0

ITEM_COLLECTED
          !fill NUM_KNOWN_ITEMS

ITEM_NAME_LO
          !byte <IN_PISTOL
          !byte <IN_KEYCARD_A

ITEM_NAME_HI
          !byte >IN_PISTOL
          !byte >IN_KEYCARD_A

IN_PISTOL
          !text "pistol",0

IN_KEYCARD_A
          !text "keycard a",0

DISPLAY_TEXT_SHIFT_PAUSE
          !byte 0


TEXT_FOUND_PISTOL     = 0
TEXT_FOUND_NOTHING    = 1
TEXT_INTRO            = 2
TEXT_FOUND_KEYCARD_A  = 3
TEXT_DOOR_LOCKED      = 4
TEXT_DOESNT_WORK      = 5
TEXT_CHARGED          = 6


TEXT_LO
          !byte <TX_FOUND_PISTOL
          !byte <TX_FOUND_NOTHING
          !byte <TX_INTRO
          !byte <TX_FOUND_KEYCARD_A
          !byte <TX_DOOR_LOCKED
          !byte <TX_DOESNT_WORK
          !byte <TX_CHARGED

TEXT_HI
          !byte >TX_FOUND_PISTOL
          !byte >TX_FOUND_NOTHING
          !byte >TX_INTRO
          !byte >TX_FOUND_KEYCARD_A
          !byte >TX_DOOR_LOCKED
          !byte >TX_DOESNT_WORK
          !byte >TX_CHARGED


TX_FOUND_PISTOL
          !scr "you find a gun",0

TX_FOUND_NOTHING
          !scr "you find nothing",0

TX_INTRO
          !scr "ugh. my head!",0

TX_FOUND_KEYCARD_A
          !scr "your keycard",0

TX_DOOR_LOCKED
          !scr "it's locked!",0

TX_DOESNT_WORK
          !scr "that doesn't work!",0

TX_CHARGED
          !scr "it's charged",0