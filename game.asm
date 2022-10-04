GAME_FIELD_FIRST_LINE       = 0
GAME_FIELD_HEIGHT_IN_TILES  = 6

MAX_NUM_EXITS   = 5
MAX_NUM_OBJECTS = 5


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

          lda #100
          sta PLAYER_HEALTH

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



          ;jsr FullDraw

;          lda #19
;          sta PARAM1
;          lda #7
;          sta PARAM2
;          lda #TYPE_PLAYER
;          sta PARAM3
;          jsr SpawnObject
;          lda #2
;          sta SPRITE_COUNT
;
;          lda #19
;          sta PARAM1
;          lda #10
;          sta PARAM2
;          lda #TYPE_PLAYER + 1
;          sta PARAM3
;          jsr SpawnObject

          lda #TEXT_INTRO
          jsr AddText



!zone GameLoop
GameLoop
          lda #150
          jsr WaitFrame

          jsr ObjectControl

          jsr HandleDisplayText

          lda GAME_PROGRESS
          beq .NoEnemies

          inc ENEMY_SPAWN_DELAY
          bne .NoMore

          lda ACTIVE_ENEMY_COUNT
          cmp #4
          beq .NoMore

          jsr GenerateRandomNumber
          and #$01
          beq .SpawnRight

          lda #0
          sta PARAM1
          lda #8
          sta PARAM2
          lda #TYPE_BLOB
          sta PARAM3
          jsr SpawnObject

          jmp .Spawned



.SpawnRight
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
          ldx #2
-
          lda SPRITE_ACTIVE,x
          beq .Skip1

          inc SPRITE_CHAR_POS_X,x

.Skip1
          inx
          cpx #8
          bne -

.NoHardScroll
          ;move sprites
          ldx #2
          stx CURRENT_SUB_INDEX
-
          lda SPRITE_ACTIVE,x
          beq .Skip

          jsr ObjectMoveLeft
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
          ldx #2
-
          lda SPRITE_ACTIVE,x
          beq .Skip1

          dec SPRITE_CHAR_POS_X,x

.Skip1
          inx
          cpx #8
          bne -

.NoHardScroll
          ;move sprites
          ldx #2
          stx CURRENT_SUB_INDEX
-
          lda SPRITE_ACTIVE,x
          beq .Skip

          jsr ObjectMoveRight

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



!zone SetupMapData
;y = map-index
SetupMapData
          sty CURRENT_MAP_INDEX

          lda #0
          sta NUM_EXITS
          sta NUM_MAP_OBJECTS

          lda MAP_MAP_LIST_LO,y
          sta CURRENT_MAP_TILE_DATA
          lda MAP_MAP_LIST_HI,y
          sta CURRENT_MAP_TILE_DATA + 1

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
          sta EXIT_X_POS,x

          ;exit target
          iny
          lda (ZEROPAGE_POINTER_1),y
          sta EXIT_TARGET_MAP,x

          ;exit target x
          iny
          lda (ZEROPAGE_POINTER_1),y
          sta EXIT_TARGET_X_POS,x

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



!zone WalkInDoor
WalkInDoor
          ;calc tile index
          lda X_OFFSET_INSIDE_TILE
          clc
          adc SPRITE_CHAR_POS_X
          lsr
          lsr
          clc
          adc X_OFFSET_TILE
          sta PARAM1

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

          rts

.ThisExit
          ;exit index in y
          lda EXIT_TARGET_MAP,y
          sta CURRENT_MAP_INDEX

          lda EXIT_TARGET_X_POS,y

;a = target tile X
;map set in CURRENT_MAP_INDEX
SetupPlayerInMap
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

          lda #10
          sta PARAM2
          lda #TYPE_PLAYER + 1
          sta PARAM3
          ldx #1
          jsr SpawnObjectInSlot


          rts





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

MAP_OBJECT_X_POS
          !fill MAX_NUM_OBJECTS

;0 for empty, or item index
MAP_OBJECT_CONTENT
          !fill MAX_NUM_OBJECTS


X_OFFSET_TILE
          !byte 0

X_OFFSET_INSIDE_TILE
          !byte 0

;pointer to current map data
CURRENT_MAP_TILE_DATA
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


MAP_OBJECT_NAME_LO
          !byte <MO_LOCKER

MAP_OBJECT_NAME_HI
          !byte >MO_LOCKER

MO_LOCKER
          !scr "locker",0

;map object index behind player, $ff = none
PLAYER_MAP_OBJECT
          !byte $ff

;0 = start, 1 = picked gun
GAME_PROGRESS
          !byte 0