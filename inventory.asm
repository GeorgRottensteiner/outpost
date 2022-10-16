NUM_KNOWN_ITEMS = 8

ITEM_NONE           = 0
ITEM_PISTOL         = 1
ITEM_KEYCARD_1      = 2
ITEM_KEYCARD_2      = 3
ITEM_KEYCARD_3      = 4
ITEM_KEYCARD_4      = 5
ITEM_KEYCARD_BRIDGE = 6
ITEM_CROWBAR        = 7



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
          bmi .NextLine

          sta (ZEROPAGE_POINTER_2),y

          inc CURRENT_DISPLAY_TEXT_POS
          rts

.Done
          lda #0
          sta CURRENT_DISPLAY_TEXT + 1
          sta DISPLAY_TEXT_SHIFT_PAUSE
          rts

.NextLine
          jsr ShiftTextUp

          lda CURRENT_DISPLAY_TEXT_POS
          sec
          adc CURRENT_DISPLAY_TEXT
          sta CURRENT_DISPLAY_TEXT
          bcc +
          inc CURRENT_DISPLAY_TEXT + 1
+

          lda #0
          sta CURRENT_DISPLAY_TEXT_POS
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

DISPLAY_TEXT_SHIFT_PAUSE
          !byte 0


TEXT_FOUND_PISTOL     = 0
TEXT_FOUND_NOTHING    = 1
TEXT_INTRO            = 2
TEXT_FOUND_KEYCARD_1  = 3
TEXT_FOUND_KEYCARD_2  = 4
TEXT_FOUND_KEYCARD_3  = 5
TEXT_FOUND_KEYCARD_4  = 6
TEXT_DOOR_LOCKED      = 7
TEXT_DOESNT_WORK      = 8
TEXT_CHARGED          = 9
TEXT_UNLOCKED         = 13
TEXT_FOUND_KEYCARD_BRIDGE = 17
TEXT_BIOLABS_FOUND        = 18
TEXT_GAME_OVER            = 19

;text bridge 1 to 6 = 20 - 25

TEXT_POD_OPEN           = 26
TEXT_GAME_COMPLETED     = 27
TEXT_FOUND_CROWBAR      = 28
TEXT_TITLE_1            = 29
TEXT_OVERRIDE           = 30


TEXT_LO
          !byte <TX_FOUND_PISTOL
          !byte <TX_FOUND_NOTHING
          !byte <TX_INTRO
          !byte <TX_FOUND_KEYCARD_1
          !byte <TX_FOUND_KEYCARD_2
          !byte <TX_FOUND_KEYCARD_3
          !byte <TX_FOUND_KEYCARD_4
          !byte <TX_DOOR_LOCKED
          !byte <TX_DOESNT_WORK
          !byte <TX_CHARGED
          !byte <TX_NAVCOM1_1
          !byte <TX_NAVCOM1_2
          !byte <TX_NAVCOM1_3
          !byte <TX_UNLOCKED
          !byte <TX_CONTROL_ROOM_1
          !byte <TX_CONTROL_ROOM_2
          !byte <TX_CONTROL_ROOM_3
          !byte <TX_FOUND_KEYCARD_BRIDGE
          !byte <TX_BIOLABS_FOUND
          !byte <TX_GAME_OVER
          !byte <TX_BRIDGE_1
          !byte <TX_BRIDGE_2
          !byte <TX_BRIDGE_3
          !byte <TX_BRIDGE_4
          !byte <TX_BRIDGE_5
          !byte <TX_BRIDGE_6
          !byte <TX_POD_OPEN
          !byte <TX_GAME_COMPLETED
          !byte <TX_FOUND_CROWBAR
          !byte <TX_TITLE_1
          !byte <TX_NAVCOM_OVERRIDE

TEXT_HI
          !byte >TX_FOUND_PISTOL
          !byte >TX_FOUND_NOTHING
          !byte >TX_INTRO
          !byte >TX_FOUND_KEYCARD_1
          !byte >TX_FOUND_KEYCARD_2
          !byte >TX_FOUND_KEYCARD_3
          !byte >TX_FOUND_KEYCARD_4
          !byte >TX_DOOR_LOCKED
          !byte >TX_DOESNT_WORK
          !byte >TX_CHARGED
          !byte >TX_NAVCOM1_1
          !byte >TX_NAVCOM1_2
          !byte >TX_NAVCOM1_3
          !byte >TX_UNLOCKED
          !byte >TX_CONTROL_ROOM_1
          !byte >TX_CONTROL_ROOM_2
          !byte >TX_CONTROL_ROOM_3
          !byte >TX_FOUND_KEYCARD_BRIDGE
          !byte >TX_BIOLABS_FOUND
          !byte >TX_GAME_OVER
          !byte >TX_BRIDGE_1
          !byte >TX_BRIDGE_2
          !byte >TX_BRIDGE_3
          !byte >TX_BRIDGE_4
          !byte >TX_BRIDGE_5
          !byte >TX_BRIDGE_6
          !byte >TX_POD_OPEN
          !byte >TX_GAME_COMPLETED
          !byte >TX_FOUND_CROWBAR
          !byte >TX_TITLE_1
          !byte >TX_NAVCOM_OVERRIDE


TX_FOUND_PISTOL
          !scr "you find a gun",0

TX_FOUND_NOTHING
          !scr "you find nothing",0

TX_INTRO
          !scr "ugh. my head!",0

TX_FOUND_KEYCARD_2
          !scr "you find keycard 2",0

TX_DOOR_LOCKED
          !scr "it's locked!",0

TX_DOESNT_WORK
          !scr "that doesn't work!",0

TX_CHARGED
          !scr "it's charged",0

TX_NAVCOM1_1
          !scr "jenna! finally!",$80,"i need your help!",$80,"get up to the",$80,"bio lab!",0

TX_FOUND_KEYCARD_1
          !scr "keycard 1",0

TX_FOUND_KEYCARD_3
          !scr "keycard 3",0

TX_FOUND_KEYCARD_4
          !scr "keycard 4",0

TX_NAVCOM1_2
          !scr "the doors are",$80,"jammed! try to",$80,"override them from",$80,"the machine deck!",0

TX_NAVCOM1_3
          !scr "reactors 100%",$80,"operational",0

TX_UNLOCKED
          !scr "unlocked the bio",$80,"lab doors",0

TX_CONTROL_ROOM_1
          !scr "the auto pilot.",$80,"i better not mess",$80,"with that.",0

TX_CONTROL_ROOM_2
          !scr "life support system",$80,"i better not mess",$80,"with that.",0

TX_CONTROL_ROOM_3
          !scr "reactor controls.",$80,"i better not mess",$80,"with them.",0

TX_FOUND_KEYCARD_BRIDGE
          !scr "you find the",$80,"keycard for the",$80,"bridge.",0

TX_BIOLABS_FOUND
          !scr "jenna! it's alive!",$80,"you have to self",$80,"destruct the ship.",$80,"the keycard...",0

TX_GAME_OVER
          !scr "life signs depleted.",0

TX_BRIDGE_6
          !scr "course is set to",$80,"inner sol system",0

TX_BRIDGE_5
          !scr "arrival estimated",$80,"in 5 days",0

TX_BRIDGE_4
          !scr "crew status:",$80,"1 alive, 7 dead",0

TX_BRIDGE_3
          !scr "ship status:",$80,"hull 100%",$80,"fuel 77%",$80,"crew 12%",0

TX_BRIDGE_2
          !scr "auto pilot has",$80,"been locked",$80,"remotely.",0

TX_BRIDGE_1
          !scr "self destruct",$80,"sequence initiated.",$80,"escape pod access",$80,"locked",0

TX_POD_OPEN
          !scr "the pod doors",$80,"slide open.",0

TX_GAME_COMPLETED
          !scr "well done!",$80,"you escaped from",$80,"outpost omega 6",$80,"alive...",0

TX_FOUND_CROWBAR
          !scr "you find a crowbar",0

TX_TITLE_1
          !scr "written by georg",$80,"rottensteiner",$80,"for the retro",$80,"platform jam #5 2022",0

TX_NAVCOM_OVERRIDE
          !scr "this panel allows",$80,"overriding door",$80,"locks. no need for",$80,"that.",0