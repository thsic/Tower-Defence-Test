music_database();
global.nowmusic_number = -1;
global.nowmusic_time = 0;
global.nextmusic_number = select_music_random();
music_fade_out_frame = -1;//音楽がフェードアウトする時に使う
music_fade_in_frame = -1//音楽がフェードインする時に使う
music_pause = false//音楽が一時停止中
fade_mode = false//フェードモードがtrueの時は曲切り替えが行われない
nowmusic_volume = 0.5//ゲームオーバー時に変更される 再生中の曲のVolume
draw_nowmusic_ui = true;//BGM表示UI
global.text_scroll_surface = noone;
global.text_scroll_position = 0;