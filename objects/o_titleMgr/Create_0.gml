center_x = window_get_width()/2;
center_y = window_get_height()/2;
global.bgm_volume = 0.7;
global.se_volume = 0.7;

load_score();//スコアをロード

random_set_seed(date_current_datetime());
randomize();


change_room_frame_1 = -1
change_room = false

global.double_speed = false;
instance_create_layer(0, 0, "UI", o_bgmMgr);

global.debugmode = DEBUGMODE;