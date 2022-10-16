!lzone Title
          jsr RemoveAllObjects

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

          ldx #0
-
          lda #69
          sta SCREEN_CHAR,x
          sta SCREEN_CHAR + 240,x
          lda #8
          sta SCREEN_COLOR,x
          sta SCREEN_COLOR + 240,x

          inx
          cpx #240
          bne -

          lda #5
          sta CURRENT_DECK

.RestartTitleMap
          lda #0
          sta X_OFFSET_TILE

          ldy #19
          jsr SetupMapData


          ;"scroll" left
          sec
          lda CURRENT_MAP_TILE_DATA
          sbc #<( GAME_FIELD_HEIGHT_IN_TILES * 9 )
          sta CURRENT_MAP_TILE_DATA
          lda CURRENT_MAP_TILE_DATA + 1
          sbc #>( GAME_FIELD_HEIGHT_IN_TILES * 9 )
          sta CURRENT_MAP_TILE_DATA + 1


          lda #0
          sta X_OFFSET_INSIDE_TILE
          lda #-9
          sta X_OFFSET_TILE

          lda #0
          sta CURRENT_DISPLAY_TEXT
          sta CURRENT_DISPLAY_TEXT_POS
          sta CURRENT_DISPLAY_TEXT + 1

          lda #TEXT_TITLE_1
          jsr AddText

          jsr ScreenOn

TitleLoop
          lda #150
          jsr WaitFrame

          jsr ScrollRightToLeftForced
          jsr HandleDisplayText

          lda #JOY_BUTTON
          jsr JoyReleasedControlPressed
          bne +

          jmp StartGame
+
          lda X_OFFSET_TILE
          cmp #20
          beq .RestartTitleMap

          jmp TitleLoop