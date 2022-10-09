GAME_FIELD_FIRST_LINE       = 0
GAME_FIELD_HEIGHT_IN_TILES  = 6

MAX_NUM_EXITS   = 5
MAX_NUM_OBJECTS = 5

NUM_UNLOCKABLE_DOORS    = 4


!zone StartGame
StartGame
          jsr RemoveAllObjects
          jsr ClearInventory

          ;setup panel
          ldx #0
-
          lda PANEL_SCREEN,x
          sta SCREEN_PANEL_POS,x
          lda PANEL_SCREEN + 240,x
          sta SCREEN_PANEL_POS + 6 * 40,x

          lda PANEL_SCREEN + 40 * 12,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + GAME_FIELD_HEIGHT_IN_TILES * 2 + 1 ) * 40,x
          lda PANEL_SCREEN + 40 * 12  + 240,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + GAME_FIELD_HEIGHT_IN_TILES * 2 + 1 + 6 ) * 40,x

          inx
          cpx #240
          bne -

          ldx #0
-
          lda #69
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + GAME_FIELD_HEIGHT_IN_TILES * 2 ) * 40,x
          lda #0
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + GAME_FIELD_HEIGHT_IN_TILES * 2 ) * 40,x
          inx
          cpx #40
          bne -

          ;init game values
          lda #0
          sta X_OFFSET_TILE
          sta X_OFFSET_INSIDE_TILE
          sta SCROLL_OFFSET_X
          sta ACTIVE_ENEMY_COUNT
          sta CURRENT_DISPLAY_TEXT
          sta CURRENT_DISPLAY_TEXT_POS
          sta GAME_PROGRESS
          sta ACTIVE_ITEM
          sta PLAYER_KNEELING

          ldx #0
-
          sta UNLOCKED_DOOR,x
          inx
          cpx #NUM_UNLOCKABLE_DOORS
          bne -

          lda #100
          sta PLAYER_HEALTH

          lda #3
          sta CURRENT_DECK

          lda #10
          sta PLAYER_ENERGY
          lda #0
          sta PLAYER_ENERGY + 1

          lda #$ff
          sta PLAYER_MAP_OBJECT

          ;start location
          ldy #4
          sty CURRENT_MAP_INDEX
          ;jsr SetupMapData

          ;a = target tile X
          ;map set in CURRENT_MAP_INDEX
          lda #3
          jsr SetupPlayerInMap



!ifdef SHOW_DEBUG_VALUES {
          lda #1
          sta SCREEN_COLOR + 13 * 40
          sta SCREEN_COLOR + 13 * 40 + 1
          sta SCREEN_COLOR + 13 * 40 + 2
          sta SCREEN_COLOR + 13 * 40 + 3
          sta SCREEN_COLOR + 13 * 40 + 4
          sta SCREEN_COLOR + 13 * 40 + 5
          sta SCREEN_COLOR + 13 * 40 + 6
          sta SCREEN_COLOR + 13 * 40 + 7

          sta SCREEN_COLOR + 13 * 40 + 10
          sta SCREEN_COLOR + 13 * 40 + 10 + 1
          sta SCREEN_COLOR + 13 * 40 + 10 + 2
          sta SCREEN_COLOR + 13 * 40 + 10 + 3
          sta SCREEN_COLOR + 13 * 40 + 10 + 4
          sta SCREEN_COLOR + 13 * 40 + 10 + 5
          sta SCREEN_COLOR + 13 * 40 + 10 + 6
          sta SCREEN_COLOR + 13 * 40 + 10 + 7
}

          lda #TEXT_INTRO
          jsr AddText


!zone GameLoop
GameLoop
          lda #150
          jsr WaitFrame

!ifdef SHOW_DEBUG_VALUES {
SPRITE_INDEX_TO_SHOW = 0

          lda SPRITE_TILE_POS_X + SPRITE_INDEX_TO_SHOW
          lsr
          lsr
          lsr
          lsr
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS
          lda SPRITE_TILE_POS_X + SPRITE_INDEX_TO_SHOW
          and #$0f
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + 1

          lda SPRITE_TILE_POS_X_DELTA + SPRITE_INDEX_TO_SHOW
          lsr
          lsr
          lsr
          lsr
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + 2
          lda SPRITE_TILE_POS_X_DELTA + SPRITE_INDEX_TO_SHOW
          and #$0f
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + 3

          lda SPRITE_CHAR_POS_X + SPRITE_INDEX_TO_SHOW
          lsr
          lsr
          lsr
          lsr
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + 4
          lda SPRITE_CHAR_POS_X + SPRITE_INDEX_TO_SHOW
          and #$0f
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + 5

          lda SPRITE_CHAR_POS_X_DELTA + SPRITE_INDEX_TO_SHOW
          lsr
          lsr
          lsr
          lsr
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + 6
          lda SPRITE_CHAR_POS_X_DELTA + SPRITE_INDEX_TO_SHOW
          and #$0f
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + 7

SPRITE_INDEX_TO_SHOW = 2
SHOW_X = 10

          lda SPRITE_TILE_POS_X + SPRITE_INDEX_TO_SHOW
          lsr
          lsr
          lsr
          lsr
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + SHOW_X
          lda SPRITE_TILE_POS_X + SPRITE_INDEX_TO_SHOW
          and #$0f
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + SHOW_X + 1

          lda SPRITE_TILE_POS_X_DELTA + SPRITE_INDEX_TO_SHOW
          lsr
          lsr
          lsr
          lsr
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + SHOW_X + 2
          lda SPRITE_TILE_POS_X_DELTA + SPRITE_INDEX_TO_SHOW
          and #$0f
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + SHOW_X + 3

          lda SPRITE_CHAR_POS_X + SPRITE_INDEX_TO_SHOW
          lsr
          lsr
          lsr
          lsr
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + SHOW_X + 4
          lda SPRITE_CHAR_POS_X + SPRITE_INDEX_TO_SHOW
          and #$0f
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + SHOW_X + 5

          lda SPRITE_CHAR_POS_X_DELTA + SPRITE_INDEX_TO_SHOW
          lsr
          lsr
          lsr
          lsr
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + SHOW_X + 6
          lda SPRITE_CHAR_POS_X_DELTA + SPRITE_INDEX_TO_SHOW
          and #$0f
          tay
          lda HEX,y
          sta SCREEN_PANEL_POS + SHOW_X + 7
}

          jsr ObjectControl

          jsr HandleDisplayText

          lda GAME_PROGRESS
          bne .CanSpawnEnemies
          jmp .NoEnemies

.CanSpawnEnemies
          inc ENEMY_SPAWN_DELAY
          bne .NoMore

          lda ACTIVE_ENEMY_COUNT
          ;cmp #4
          cmp #1
          beq .NoMore

          jsr GenerateRandomNumber
          and #$01
          beq .SpawnRight

          lda #0
          jsr CalcTilePosFromCharPos
          bmi .NoEnemies

          ;spawns in blocked area?
          tay
          lda CURRENT_MAP_DATA
          clc
          adc MAP_DATA_OFFSET_LO,y
          sta ZEROPAGE_POINTER_1
          lda CURRENT_MAP_DATA + 1
          adc MAP_DATA_OFFSET_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ldy #4
          lda (ZEROPAGE_POINTER_1),y
          jsr IsTileBlocking
          bne .NoEnemies

          lda #0
          sta PARAM1
          lda #8
          sta PARAM2
          lda #TYPE_BLOB
          sta PARAM3
          jsr SpawnObject

          jmp .Spawned

!ifdef SHOW_DEBUG_VALUES {
HEX
          !scr "0123456789abcdef"
}


.SpawnRight
          lda #39
          jsr CalcTilePosFromCharPos
          cmp CURRENT_MAP_WIDTH
          bcs .NoEnemies

          ;spawns in blocked area?
          tay
          lda CURRENT_MAP_DATA
          clc
          adc MAP_DATA_OFFSET_LO,y
          sta ZEROPAGE_POINTER_1
          lda CURRENT_MAP_DATA + 1
          adc MAP_DATA_OFFSET_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ldy #4
          lda (ZEROPAGE_POINTER_1),y
          jsr IsTileBlocking
          bne .NoEnemies

          lda #39
          sta PARAM1
          lda #8
          sta PARAM2
          lda #TYPE_BLOB
          sta PARAM3
          jsr SpawnObject

          lda #1
          sta SPRITE_DIRECTION,x


.Spawned
          inc ACTIVE_ENEMY_COUNT

.NoEnemies
.NoMore

          jmp GameLoop



!zone FullDraw
FullDraw
          ldy #0
          sty PARAM2
          lda #0
          sta PARAM1


          ;x offset in screen
          lda #0
          sta PARAM3

          lda SCREEN_LINE_OFFSET_TABLE_LO + GAME_FIELD_FIRST_LINE
          sta ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_3
          lda SCREEN_LINE_OFFSET_TABLE_HI + GAME_FIELD_FIRST_LINE
          sta ZEROPAGE_POINTER_2 + 1
          lda #>SCREEN_COLOR
          sta ZEROPAGE_POINTER_3 + 1

          lda ZEROPAGE_POINTER_2
          clc
          adc #<40
          sta ZEROPAGE_POINTER_4
          sta ZEROPAGE_POINTER_5
          lda ZEROPAGE_POINTER_2 + 1
          adc #>40
          sta ZEROPAGE_POINTER_4 + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta ZEROPAGE_POINTER_5 + 1

          lda CURRENT_MAP_TILE_DATA
          sta ZEROPAGE_POINTER_1
          lda CURRENT_MAP_TILE_DATA + 1
          sta ZEROPAGE_POINTER_1 + 1

.NextRow
          ldy PARAM1
          lda (ZEROPAGE_POINTER_1),y
          tax
          ;offset in screen
          ldy PARAM3

          lda X_OFFSET_INSIDE_TILE
          cmp #3
          beq .Col3
          cmp #2
          beq .Col2
          cmp #1
          beq .Col1

.Col0
          lda MAP_TILE_CHARS_0_0,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_0_0,x
          sta (ZEROPAGE_POINTER_3),y

          lda MAP_TILE_CHARS_0_1,x
          sta (ZEROPAGE_POINTER_4),y
          lda MAP_TILE_COLORS_0_1,x
          sta (ZEROPAGE_POINTER_5),y

          iny
          cpy #40
          beq .RowDone

.Col1
          lda MAP_TILE_CHARS_1_0,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_1_0,x
          sta (ZEROPAGE_POINTER_3),y

          lda MAP_TILE_CHARS_1_1,x
          sta (ZEROPAGE_POINTER_4),y
          lda MAP_TILE_COLORS_1_1,x
          sta (ZEROPAGE_POINTER_5),y

          iny
          cpy #40
          beq .RowDone

.Col2
          lda MAP_TILE_CHARS_2_0,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_2_0,x
          sta (ZEROPAGE_POINTER_3),y

          lda MAP_TILE_CHARS_2_1,x
          sta (ZEROPAGE_POINTER_4),y
          lda MAP_TILE_COLORS_2_1,x
          sta (ZEROPAGE_POINTER_5),y

          iny
          cpy #40
          beq .RowDone

.Col3
          lda MAP_TILE_CHARS_3_0,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_3_0,x
          sta (ZEROPAGE_POINTER_3),y

          lda MAP_TILE_CHARS_3_1,x
          sta (ZEROPAGE_POINTER_4),y
          lda MAP_TILE_COLORS_3_1,x
          sta (ZEROPAGE_POINTER_5),y

          iny
          cpy #40
          beq .RowDone

          ;map height is offset to next column
          lda PARAM1
          clc
          adc #GAME_FIELD_HEIGHT_IN_TILES
          sta PARAM1
          tay
          lda (ZEROPAGE_POINTER_1),y
          tax
          lda PARAM3
          clc
          adc #4
          sta PARAM3
          tay
          jmp .Col0

.RowDone
          inc PARAM2
          lda PARAM2
          cmp #GAME_FIELD_HEIGHT_IN_TILES
          bne .NextRowSetup

          rts

.NextRowSetup
          lda ZEROPAGE_POINTER_2
          clc
          adc #<80
          sta ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_3
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
          inc ZEROPAGE_POINTER_3 + 1
+
          lda ZEROPAGE_POINTER_4
          clc
          adc #<80
          sta ZEROPAGE_POINTER_4
          sta ZEROPAGE_POINTER_5
          bcc +
          inc ZEROPAGE_POINTER_4 + 1
          inc ZEROPAGE_POINTER_5 + 1
+
          lda #0
          sta PARAM3
          ;lda X_OFFSET_TILE
          ;clc
          ;adc PARAM2
          lda PARAM2
          sta PARAM1
          jmp .NextRow



!zone ScrollRightToLeft
;returns a = 0 if scrolled
ScrollRightToLeft
          ;at right border?
          lda X_OFFSET_INSIDE_TILE
          cmp #2
          bne +
          lda X_OFFSET_TILE
          clc
          adc #10
          cmp CURRENT_MAP_WIDTH
          bne +

          ;at right border
          lda #1
          rts

+

          dec SCROLL_OFFSET_X
          lda SCROLL_OFFSET_X
          and #$07
          sta SCROLL_OFFSET_X
          cmp #7
          beq .HardScroll
          jmp .NoHardScroll

.HardScroll
          inc X_OFFSET_INSIDE_TILE
          lda X_OFFSET_INSIDE_TILE
          and #$03
          sta X_OFFSET_INSIDE_TILE
          bne +
          inc X_OFFSET_TILE
          lda CURRENT_MAP_TILE_DATA
          clc
          adc #<GAME_FIELD_HEIGHT_IN_TILES
          sta CURRENT_MAP_TILE_DATA
          bcc +
          inc CURRENT_MAP_TILE_DATA + 1
+
          ldx #1
-
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 0 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 0 ) * 40 - 1,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 1 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 1 ) * 40 - 1,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 2 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 2 ) * 40 - 1,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 3 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 3 ) * 40 - 1,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 4 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 4 ) * 40 - 1,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 5 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 5 ) * 40 - 1,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 6 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 6 ) * 40 - 1,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 7 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 7 ) * 40 - 1,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 8 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 8 ) * 40 - 1,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 9 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 9 ) * 40 - 1,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 10 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 10 ) * 40 - 1,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 11 ) * 40,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 11 ) * 40 - 1,x

          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 0 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 0 ) * 40 - 1,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 1 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 1 ) * 40 - 1,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 2 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 2 ) * 40 - 1,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 3 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 3 ) * 40 - 1,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 4 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 4 ) * 40 - 1,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 5 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 5 ) * 40 - 1,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 6 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 6 ) * 40 - 1,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 7 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 7 ) * 40 - 1,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 8 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 8 ) * 40 - 1,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 9 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 9 ) * 40 - 1,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 10 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 10 ) * 40 - 1,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 11 ) * 40,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 11 ) * 40 - 1,x

          inx
          cpx #39
          beq .Done
          jmp -

.Done
          ;add right column!
          lda SCREEN_LINE_OFFSET_TABLE_LO + GAME_FIELD_FIRST_LINE
          clc
          adc #38
          sta ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_3
          lda SCREEN_LINE_OFFSET_TABLE_HI + GAME_FIELD_FIRST_LINE
          adc #0
          sta ZEROPAGE_POINTER_2 + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta ZEROPAGE_POINTER_3 + 1

          ;calc tile offsets
          lda CURRENT_MAP_TILE_DATA
          clc
          adc #<( GAME_FIELD_HEIGHT_IN_TILES * 9 )
          sta ZEROPAGE_POINTER_1
          lda CURRENT_MAP_TILE_DATA + 1
          adc #>( GAME_FIELD_HEIGHT_IN_TILES * 9 )
          sta ZEROPAGE_POINTER_1 + 1

          lda X_OFFSET_INSIDE_TILE
          clc
          adc #2
          and #$03
          tax
          cpx #2
          ;bne +
          bcs +

          ;1 tile more
          lda ZEROPAGE_POINTER_1
          clc
          adc #GAME_FIELD_HEIGHT_IN_TILES
          sta ZEROPAGE_POINTER_1
          bcc +
          inc ZEROPAGE_POINTER_1 + 1
+
          jsr DrawColumn

          ;move sprites hard
          ldx #0
-
          lda SPRITE_ACTIVE,x
          beq .Skip1

          ;lda SPRITE_TILE_POS_X_DELTA,x
;          clc
;          adc #8
;          cmp #32
;          bcc +
;
;          sec
;          sbc #32
;          inc SPRITE_TILE_POS_X,x
;+
;          sta SPRITE_TILE_POS_X_DELTA,x

!if 0 {
          lda SPRITE_CHAR_POS_X_DELTA,x
          clc
          adc #8
          cmp #8
          bcc +

          sec
          sbc #8
          inc SPRITE_CHAR_POS_X,x
+
          sta SPRITE_CHAR_POS_X_DELTA,x

}
.Skip1
          inx
          cpx #8
          bne -

.NoHardScroll
          ;move sprites
          ldx #0
          stx CURRENT_SUB_INDEX
-
          lda SPRITE_ACTIVE,x
          beq .Skip

          jsr ObjectShiftLeft
.Skip
          lda CURRENT_SUB_INDEX
          clc
          adc SPRITE_COUNT,x
          tax
          stx CURRENT_SUB_INDEX
          cpx #8
          bne -

          ldx #0
          lda #0
          rts



!zone ScrollLeftToRight
;returns a = 0 if scrolled
ScrollLeftToRight
          ;at left border?
          lda X_OFFSET_INSIDE_TILE
          bne +
          lda X_OFFSET_TILE
          bne +

          ;at left border
          lda #1
          rts

+

          inc SCROLL_OFFSET_X
          lda SCROLL_OFFSET_X
          and #$07
          sta SCROLL_OFFSET_X
          beq .HardScroll

          jmp .NoHardScroll

.HardScroll
          dec X_OFFSET_INSIDE_TILE
          lda X_OFFSET_INSIDE_TILE
          and #$03
          sta X_OFFSET_INSIDE_TILE
          cmp #3
          bne +
          dec X_OFFSET_TILE
          lda CURRENT_MAP_TILE_DATA
          sec
          sbc #<GAME_FIELD_HEIGHT_IN_TILES
          sta CURRENT_MAP_TILE_DATA
          bcs +
          dec CURRENT_MAP_TILE_DATA + 1
+
          ldx #39
-
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 0 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 0 ) * 40,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 1 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 1 ) * 40,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 2 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 2 ) * 40,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 3 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 3 ) * 40,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 4 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 4 ) * 40,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 5 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 5 ) * 40,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 6 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 6 ) * 40,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 7 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 7 ) * 40,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 8 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 8 ) * 40,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 9 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 9 ) * 40,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 10 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 10 ) * 40,x
          lda SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 11 ) * 40 - 1,x
          sta SCREEN_CHAR + ( GAME_FIELD_FIRST_LINE + 11 ) * 40,x

          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 0 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 0 ) * 40,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 1 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 1 ) * 40,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 2 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 2 ) * 40,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 3 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 3 ) * 40,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 4 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 4 ) * 40,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 5 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 5 ) * 40,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 6 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 6 ) * 40,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 7 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 7 ) * 40,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 8 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 8 ) * 40,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 9 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 9 ) * 40,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 10 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 10 ) * 40,x
          lda SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 11 ) * 40 - 1,x
          sta SCREEN_COLOR + ( GAME_FIELD_FIRST_LINE + 11 ) * 40,x

          dex
          beq .Done
          jmp -

.Done
          ;add left column!
          lda SCREEN_LINE_OFFSET_TABLE_LO + GAME_FIELD_FIRST_LINE
          sta ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_3
          lda SCREEN_LINE_OFFSET_TABLE_HI + GAME_FIELD_FIRST_LINE
          sta ZEROPAGE_POINTER_2 + 1
          clc
          adc #>( SCREEN_COLOR - SCREEN_CHAR )
          sta ZEROPAGE_POINTER_3 + 1

          ;calc tile offsets
          lda CURRENT_MAP_TILE_DATA
          sta ZEROPAGE_POINTER_1
          lda CURRENT_MAP_TILE_DATA + 1
          sta ZEROPAGE_POINTER_1 + 1
          ldx X_OFFSET_INSIDE_TILE
          jsr DrawColumn

          ;move sprites hard
          ldx #0
-
          lda SPRITE_ACTIVE,x
          beq .Skip1

          ;lda SPRITE_TILE_POS_X_DELTA,x
;          sec
;          sbc #8
;          bpl +
;
;          dec SPRITE_TILE_POS_X,x
;          clc
;          adc #32
;
;+
;          sta SPRITE_TILE_POS_X_DELTA,x

!if 0 {
          lda SPRITE_CHAR_POS_X_DELTA,x
          sec
          sbc #8
          bpl +

          dec SPRITE_CHAR_POS_X,x
          clc
          adc #8

+
          sta SPRITE_CHAR_POS_X_DELTA,x
}

.Skip1
          inx
          cpx #8
          bne -

.NoHardScroll
          ;move sprites
          ldx #0
          stx CURRENT_SUB_INDEX
-
          lda SPRITE_ACTIVE,x
          beq .Skip

          jsr ObjectShiftRight

.Skip
          lda CURRENT_SUB_INDEX
          clc
          adc SPRITE_COUNT,x
          tax
          stx CURRENT_SUB_INDEX
          cpx #8
          bne -

          ldx #0

          lda #0
          rts



!zone DrawColumn
.DrawColumnDone2
          rts
;ZEROPAGE_POINTER_1 = tile at column
;x = offset inside tile
DrawColumn
          ldy #0
          lda #GAME_FIELD_HEIGHT_IN_TILES
          sta PARAM2
          lda #0
          sta PARAM3

          cpx #0
          beq .Col0
          cpx #1
          beq .Col1
          cpx #2
          beq .Col2
          jmp .Col3


.Col0
          ldy PARAM3
          lda (ZEROPAGE_POINTER_1),y
          tax

          ldy #0
          lda MAP_TILE_CHARS_0_0,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_0_0,x
          sta (ZEROPAGE_POINTER_3),y

          tya
          clc
          adc #40
          tay

          lda MAP_TILE_CHARS_0_1,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_0_1,x
          sta (ZEROPAGE_POINTER_3),y

          dec PARAM2
          beq .DrawColumnDone2

          lda ZEROPAGE_POINTER_2
          clc
          adc #80
          sta ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_3
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
          inc ZEROPAGE_POINTER_3 + 1
+
          inc PARAM3
          jmp .Col0

.Col1
          ldy PARAM3
          lda (ZEROPAGE_POINTER_1),y
          tax

          ldy #0
          lda MAP_TILE_CHARS_1_0,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_1_0,x
          sta (ZEROPAGE_POINTER_3),y

          tya
          clc
          adc #40
          tay

          lda MAP_TILE_CHARS_1_1,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_1_1,x
          sta (ZEROPAGE_POINTER_3),y

          dec PARAM2
          beq .DrawColumnDone2

          lda ZEROPAGE_POINTER_2
          clc
          adc #80
          sta ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_3
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
          inc ZEROPAGE_POINTER_3 + 1
+
          inc PARAM3
          jmp .Col1

.Col2
          ldy PARAM3
          lda (ZEROPAGE_POINTER_1),y
          tax

          ldy #0
          lda MAP_TILE_CHARS_2_0,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_2_0,x
          sta (ZEROPAGE_POINTER_3),y

          tya
          clc
          adc #40
          tay

          lda MAP_TILE_CHARS_2_1,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_2_1,x
          sta (ZEROPAGE_POINTER_3),y

          dec PARAM2
          beq .DrawColumnDone

          lda ZEROPAGE_POINTER_2
          clc
          adc #80
          sta ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_3
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
          inc ZEROPAGE_POINTER_3 + 1
+
          inc PARAM3
          jmp .Col2

.Col3
          ldy PARAM3
          lda (ZEROPAGE_POINTER_1),y
          tax

          ldy #0
          lda MAP_TILE_CHARS_3_0,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_3_0,x
          sta (ZEROPAGE_POINTER_3),y

          tya
          clc
          adc #40
          tay

          lda MAP_TILE_CHARS_3_1,x
          sta (ZEROPAGE_POINTER_2),y
          lda MAP_TILE_COLORS_3_1,x
          sta (ZEROPAGE_POINTER_3),y

          dec PARAM2
          beq .DrawColumnDone

          lda ZEROPAGE_POINTER_2
          clc
          adc #80
          sta ZEROPAGE_POINTER_2
          sta ZEROPAGE_POINTER_3
          bcc +
          inc ZEROPAGE_POINTER_2 + 1
          inc ZEROPAGE_POINTER_3 + 1
+
          inc PARAM3
          jmp .Col3


.DrawColumnDone
          rts



;y = map-index
!lzone SetupMapData
          sty CURRENT_MAP_INDEX

          lda #0
          sta NUM_EXITS
          sta NUM_MAP_OBJECTS

          lda MAP_MAP_LIST_LO,y
          sta CURRENT_MAP_TILE_DATA
          sta CURRENT_MAP_DATA
          lda MAP_MAP_LIST_HI,y
          sta CURRENT_MAP_TILE_DATA + 1
          sta CURRENT_MAP_DATA + 1

          lda MAP_MAP_EXTRA_DATA_LIST_LO,y
          sta ZEROPAGE_POINTER_1
          lda MAP_MAP_EXTRA_DATA_LIST_HI,y
          sta ZEROPAGE_POINTER_1 + 1

          ;width
          ldy #0
          lda (ZEROPAGE_POINTER_1),y
          sta CURRENT_MAP_WIDTH

          ;num exits
          iny
          lda (ZEROPAGE_POINTER_1),y
          lsr
          lsr
          lsr
          lsr
          sta NUM_MAP_OBJECTS

          lda (ZEROPAGE_POINTER_1),y
          and #$0f
          sta NUM_EXITS
          sta PARAM2
          beq .NoExits

          ldx #0

-
          ;exit x
          iny
          lda (ZEROPAGE_POINTER_1),y
          sta PARAM3
          and #$7f
          sta EXIT_X_POS,x

          ;exit target
          iny
          lda (ZEROPAGE_POINTER_1),y
          sta EXIT_TARGET_MAP,x

          ;exit target x
          iny
          lda (ZEROPAGE_POINTER_1),y
          sta EXIT_TARGET_X_POS,x

          lda #0
          sta EXIT_KEY_OBJECT,x
          lda #$ff
          sta EXIT_UNLOCK_INDEX,x

          ;key object?
          lda PARAM3
          bpl .NoLockedDoor

          iny
          lda (ZEROPAGE_POINTER_1),y
          sta EXIT_KEY_OBJECT,x

          iny
          lda (ZEROPAGE_POINTER_1),y
          sta EXIT_UNLOCK_INDEX,x

.NoLockedDoor
          inx
          dec PARAM2
          bne -

.NoExits

          lda NUM_MAP_OBJECTS
          sta PARAM2
          beq .NoMapObjects

          ldx #0

-
          ;object x
          iny
          lda (ZEROPAGE_POINTER_1),y
          sta MAP_OBJECT_X_POS,x

          ;object type
          iny
          lda (ZEROPAGE_POINTER_1),y
          sta MAP_OBJECT_TYPE,x

          ;object content
          iny
          lda (ZEROPAGE_POINTER_1),y
          sta MAP_OBJECT_CONTENT,x

          inx
          dec PARAM2
          bne -

.NoMapObjects

          ;sanitize x-offset-tile so we don't scroll outside!
          lda CURRENT_MAP_WIDTH
          sec
          sbc #10
          cmp X_OFFSET_TILE
          bcs +
          sta X_OFFSET_TILE

+

          ;move offset of tile data
          lda X_OFFSET_TILE
          sta PARAM1
          beq +
-
          lda CURRENT_MAP_TILE_DATA
          clc
          adc #<GAME_FIELD_HEIGHT_IN_TILES
          sta CURRENT_MAP_TILE_DATA
          bcc ++
          inc CURRENT_MAP_TILE_DATA + 1
++
          dec PARAM1
          bne -

+
          rts



;y = tile x pos of door
!lzone WalkInDoor
          sty PARAM1

          ldy #0
          ;assume
          ;and #$fe
-
          lda EXIT_X_POS,y
          cmp PARAM1
          beq .ThisExit

          sec
          sbc #1
          cmp PARAM1
          beq .ThisExit

          iny
          cpy NUM_EXITS
          bne -


.ExitIsLocked
          ;...or door is not properly configured!
          lda #TEXT_DOOR_LOCKED
          jmp AddText

.CantOpen
          lda #TEXT_DOESNT_WORK
          jmp AddText

.ThisExit
          ;exit index in y
          ldx EXIT_UNLOCK_INDEX,y
          bmi .NotUnlockable

          ;already unlocked
          lda UNLOCKED_DOOR,x
          bne .Opening


.NotUnlockable
          lda EXIT_KEY_OBJECT,y
          bmi .ExitIsLocked
          beq .Opening
          cmp ACTIVE_ITEM
          beq .OpeningWithItem

          lda ACTIVE_ITEM
          beq .ExitIsLocked
          jmp .CantOpen

.OpeningWithItem
          ;mark as unlocked
          ldx EXIT_UNLOCK_INDEX,y
          lda #1
          sta UNLOCKED_DOOR,x

.Opening
          sty PARAM1
          lda EXIT_X_POS,y
          jsr OpenDoorAndWalkOut

          lda #3
          sta SPRITES_ENABLED

          jsr ScreenOff

          ldy PARAM1

          lda EXIT_TARGET_MAP,y
          sta CURRENT_MAP_INDEX

          lda EXIT_TARGET_X_POS,y
          sta OPEN_DOOR_X_POS
          jsr SetupPlayerInMap

          ldy #10
-
          jsr ObjectMoveUp
          dey
          bne -

          lda #SPRITE_PLAYER_DOWN
          sta SPRITE_IMAGE
          lda #SPRITE_PLAYER_DOWN + 8
          sta SPRITE_IMAGE + 1

          jsr ScreenOn

          jmp WalkOutAndCloseDoor



!lzone ScreenOff
          lda #150
          jsr WaitFrame

          lda #$70
          sta TOP_SCREEN_ACTIVE

          lda SPRITES_ENABLED
          sta STORED_ENABLED_SPRITES
          lda #0
          sta SPRITES_ENABLED

          rts


STORED_ENABLED_SPRITES
          !byte 0



!lzone ScreenOn
          lda #150
          jsr WaitFrame

          lda STORED_ENABLED_SPRITES
          sta SPRITES_ENABLED

          lda #$10
          sta TOP_SCREEN_ACTIVE
          rts



;a = target tile X
;map set in CURRENT_MAP_INDEX
!lzone SetupPlayerInMap
          sta .PLAYER_TARGET_TILE
          sec
          sbc #5
          sta X_OFFSET_TILE
          bpl +
          lda #0
          sta X_OFFSET_TILE
+

          lda #0
          sta X_OFFSET_INSIDE_TILE

          ldy CURRENT_MAP_INDEX
          jsr SetupMapData

          jsr FullDraw

          jsr RemoveAllObjects

.PLAYER_TARGET_TILE = * + 1
          lda #$ff
          sec
          sbc X_OFFSET_TILE
          asl
          asl
          ;+2 to center on door
          clc
          adc #2
          sta PARAM1
          lda #7
          sta PARAM2
          lda #TYPE_PLAYER
          sta PARAM3
          ldx #0
          jsr SpawnObjectInSlot
          lda #2
          sta SPRITE_COUNT

          lda #16
          sta SPRITE_TILE_POS_X_DELTA


          lda #10
          sta PARAM2
          lda #TYPE_PLAYER + 1
          sta PARAM3
          ldx #1
          jsr SpawnObjectInSlot

          rts



;a = tile pos of door
!lzone OpenDoorAndWalkOut
          jsr CalcCharPosFromTilePos
          sta OPEN_DOOR_X_POS

          ldy #0
          sty DOOR_OPEN_DELAY
          sty SPRITE_STATE_POS
          sty DOOR_OPEN_POS

          lda #1
          sta SPRITE_STATE

          lda OPEN_DOOR_TILE
          cmp #18
          bne +

          ;it's a closed door, we need the open door anim
          inc SPRITE_STATE_POS

+

.OpenDoorLoop
          lda #150
          jsr WaitFrame

          ldx #0
          jsr BHPlayer

          lda SPRITE_STATE
          cmp #2
          bne .OpenDoorLoop
          rts


!lzone WalkOutAndCloseDoor
          ;char index from tile
          lda OPEN_DOOR_X_POS
          sec
          sbc X_OFFSET_TILE
          asl
          asl
          sec
          sbc X_OFFSET_INSIDE_TILE
          sta OPEN_DOOR_X_POS

          lda #3
          sta SPRITE_STATE

          ;inject open door!
          ldy #4
          lda DOOR_TOP_TILES,y
          sta PARAM3

          ldx OPEN_DOOR_X_POS
          ldy #4
          lda PARAM3
          jsr DrawTile
          ldx OPEN_DOOR_X_POS
          ldy #6
          lda PARAM3
          clc
          adc #1
          jsr DrawTile
          ldx OPEN_DOOR_X_POS
          ldy #8
          lda PARAM3
          clc
          adc #2
          jsr DrawTile

.CloseDoorLoop
          lda #150
          jsr WaitFrame

          ldx #0
          jsr BHPlayer

          lda SPRITE_STATE
          cmp #5
          bne .CloseDoorLoop
          rts


DOOR_OPEN_POS
          !byte 0
DOOR_OPEN_DELAY
          !byte 0

DOOR_TOP_TILES
          !byte 21      ;closed
          !byte 25      ;opening 1
          !byte 28      ;opening 2
          !byte 31      ;opening 3
          !byte 16      ;open


;x,y = pos on screen
;a = tile index
!lzone DrawTile
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

          pla
          tax

          lda MAP_TILE_CHARS_0_0,x
          sta (ZEROPAGE_POINTER_1),y
          lda MAP_TILE_COLORS_0_0,x
          sta (ZEROPAGE_POINTER_2),y
          iny
          lda MAP_TILE_CHARS_1_0,x
          sta (ZEROPAGE_POINTER_1),y
          lda MAP_TILE_COLORS_1_0,x
          sta (ZEROPAGE_POINTER_2),y
          iny
          lda MAP_TILE_CHARS_2_0,x
          sta (ZEROPAGE_POINTER_1),y
          lda MAP_TILE_COLORS_2_0,x
          sta (ZEROPAGE_POINTER_2),y
          iny
          lda MAP_TILE_CHARS_3_0,x
          sta (ZEROPAGE_POINTER_1),y
          lda MAP_TILE_COLORS_3_0,x
          sta (ZEROPAGE_POINTER_2),y

          tya
          clc
          adc #37
          tay

          lda MAP_TILE_CHARS_0_1,x
          sta (ZEROPAGE_POINTER_1),y
          lda MAP_TILE_COLORS_0_1,x
          sta (ZEROPAGE_POINTER_2),y
          iny
          lda MAP_TILE_CHARS_1_1,x
          sta (ZEROPAGE_POINTER_1),y
          lda MAP_TILE_COLORS_1_1,x
          sta (ZEROPAGE_POINTER_2),y
          iny
          lda MAP_TILE_CHARS_2_1,x
          sta (ZEROPAGE_POINTER_1),y
          lda MAP_TILE_COLORS_2_1,x
          sta (ZEROPAGE_POINTER_2),y
          iny
          lda MAP_TILE_CHARS_3_1,x
          sta (ZEROPAGE_POINTER_1),y
          lda MAP_TILE_COLORS_3_1,x
          sta (ZEROPAGE_POINTER_2),y

          rts



;a = elevator index
!lzone HandleElevator
          tay
          ldx #0
-
          lda ELEVATOR_CHOICE,x
          beq .Done
          sta SCREEN_PANEL_POS + $82,x
          inx
          jmp -

.Done
          lda ELEVATOR_RANGE_TOP,y
          sta PARAM1
-
          lda PARAM1
          clc
          adc #'0'
          sta SCREEN_PANEL_POS + $83,x

          lda PARAM1
          cmp ELEVATOR_RANGE_BOTTOM,y
          beq .DisplayDone

          inc PARAM1

          inx
          inx
          jmp -


.DisplayDone
          lda #0
          sta PARAM1

          sty PARAM4

          lda CURRENT_DECK
          sta PARAM3
          sec
          sbc ELEVATOR_RANGE_TOP,y
          asl
          clc
          adc #$84 + 12
          sta PARAM2

.ElevatorLoop
          lda #150
          jsr WaitFrame

          lda PARAM10
          lsr
          tay
          lda COLOR_FADE_TABLE,y
          ldx PARAM2
          sta SCREEN_COLOR + ( SCREEN_PANEL_POS - SCREEN_CHAR ),x

          inc PARAM10
          lda PARAM10
          and #$0f
          sta PARAM10

          lda #JOY_LEFT
          jsr JoyReleasedControlPressed
          bne .NotLeft

          ldy PARAM4
          lda PARAM3
          cmp ELEVATOR_RANGE_TOP,y
          beq .NotLeft

          lda #1
          ldx PARAM2
          sta SCREEN_COLOR + ( SCREEN_PANEL_POS - SCREEN_CHAR ),x
          dec PARAM2
          dec PARAM2
          dec PARAM3

.NotLeft

          lda #JOY_RIGHT
          jsr JoyReleasedControlPressed
          bne .NotRight

          ldy PARAM4
          lda PARAM3
          cmp ELEVATOR_RANGE_BOTTOM,y
          beq .NotRight

          lda #1
          ldx PARAM2
          sta SCREEN_COLOR + ( SCREEN_PANEL_POS - SCREEN_CHAR ),x
          inc PARAM2
          inc PARAM2
          inc PARAM3

.NotRight
          lda #JOY_BUTTON
          jsr JoyReleasedControlPressed
          bne .ElevatorLoop

          lda PARAM3
          cmp CURRENT_DECK
          bne +

          ;stay in deck, restore display
          jmp ClearMapObjectDisplay

+
          lda PARAM3
          sta CURRENT_DECK

          ldy PARAM4
          sty .ELEVATOR_INDEX
          lda PARAM3
          sec
          sbc ELEVATOR_RANGE_TOP,y
          sta .ELEVATOR_TARGET_DECK

          lda #23
          sta OPEN_DOOR_TILE
          lda SPRITE_TILE_POS_X
          jsr OpenDoorAndWalkOut

          lda #3
          sta SPRITES_ENABLED

          jsr ScreenOff

.ELEVATOR_TARGET_DECK = * + 1
          lda #$ff
          asl
          sta PARAM1

          ;* 6
          lda .ELEVATOR_INDEX
          asl
          clc
          adc .ELEVATOR_INDEX
          asl
          clc
          adc PARAM1
          tay

          lda ELEVATOR_EXIT_MAP,y
          sta CURRENT_MAP_INDEX

          iny
          lda ELEVATOR_EXIT_MAP,y
          sta OPEN_DOOR_X_POS
          jsr SetupPlayerInMap

          ldy #10
-
          jsr ObjectMoveUp
          dey
          bne -

          lda #SPRITE_PLAYER_DOWN
          sta SPRITE_IMAGE
          lda #SPRITE_PLAYER_DOWN + 8
          sta SPRITE_IMAGE + 1

          jsr ScreenOn

          jmp WalkOutAndCloseDoor


.ELEVATOR_INDEX
          !byte 0



!lzone ClearMapObjectDisplay
          ldx #0
-
          lda #1
          sta SCREEN_COLOR + ( SCREEN_PANEL_POS - SCREEN_CHAR ) + $82,x
          lda #32
          sta SCREEN_PANEL_POS + $82,x
          inx
          cpx #20
          bne -
          rts



ELEVATOR_CHOICE
          !scr " target deck:",0

COLOR_FADE_TABLE
          !byte 1,3,6,0,0,6,3,1



NUM_EXITS
          !byte 0

NUM_MAP_OBJECTS
          !byte 0

EXIT_X_POS
          !fill MAX_NUM_EXITS
EXIT_TARGET_MAP
          !fill MAX_NUM_EXITS
EXIT_TARGET_X_POS
          !fill MAX_NUM_EXITS
EXIT_KEY_OBJECT
          !fill MAX_NUM_EXITS
EXIT_UNLOCK_INDEX
          !fill MAX_NUM_EXITS

UNLOCKED_DOOR
          !fill NUM_UNLOCKABLE_DOORS


MAP_OBJECT_X_POS
          !fill MAX_NUM_OBJECTS

;0 for empty, or item index
MAP_OBJECT_CONTENT
          !fill MAX_NUM_OBJECTS

;type of object
MAP_OBJECT_TYPE
          !fill MAX_NUM_OBJECTS

X_OFFSET_TILE
          !byte 0

X_OFFSET_INSIDE_TILE
          !byte 0

;pointer to current map data (data of first visible column on screen)
CURRENT_MAP_TILE_DATA
          !word 0

;pointer to current map data (data of left most column)
CURRENT_MAP_DATA
          !word 0

;current map width in tiles
CURRENT_MAP_WIDTH
          !byte 0

CURRENT_MAP_INDEX
          !byte 0

SCROLL_OFFSET_X
          !byte 0

;0 or 16
PLAYER_CARRIES_GUN
          !byte 0

ACTIVE_ENEMY_COUNT
          !byte 0

ENEMY_SPAWN_DELAY
          !byte 0

PLAYER_HEALTH
          !byte 0

PLAYER_ENERGY
          !word 0

PLAYER_KNEELING
          !byte 0

CURRENT_DECK
          !byte 0

MAP_OBJECT_NAME_LO
          !byte <MO_LOCKER
          !byte <MO_POWER_OUTLET
          !byte <MO_COM
          !byte <MO_ELEVATOR

MAP_OBJECT_NAME_HI
          !byte >MO_LOCKER
          !byte >MO_POWER_OUTLET
          !byte >MO_COM
          !byte >MO_ELEVATOR

MO_LOCKER
          !scr "locker",0

MO_POWER_OUTLET
          !scr "power outlet",0

MO_COM
          !scr "navcom",0

MO_ELEVATOR
          !scr "elevator",0

;tile index of detected door (18 or 23)
OPEN_DOOR_TILE
          !byte 0
OPEN_DOOR_X_POS
          !byte 0

;map object index behind player, $ff = none
PLAYER_MAP_OBJECT
          !byte $ff

MAP_OBJECT_ACTION_LO
          !byte <PlayerSearchObject       ;locker
          !byte <ChargeObject
          !byte <NavCom
          !byte <Elevator

MAP_OBJECT_ACTION_HI
          !byte >PlayerSearchObject           ;locker
          !byte >ChargeObject
          !byte >NavCom
          !byte >Elevator

;0 = start, 1 = picked gun
GAME_PROGRESS
          !byte 0

MAP_DATA_OFFSET_LO
!for COL = 0 to 31
          !byte <( COL * 6 )
!end

MAP_DATA_OFFSET_HI
!for COL = 0 to 31
          !byte >( COL * 6 )
!end


SPRITES_ENABLED
          !byte 0

ELEVATOR_RANGE_TOP
          !byte 2

ELEVATOR_RANGE_BOTTOM
          !byte 4

;3 two byte entries per elevator  target map, exit x
ELEVATOR_EXIT_MAP
          !byte 7, 9, 2, 3, 8, 9