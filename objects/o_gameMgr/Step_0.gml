#region ゲームステート
switch(global.gamestate){
case gamestate.stagestart://ステージ開始時処理
	switch(room){
	case r_test:
		global.stage = -1;
	break
	case r_tutorial:
		global.stage = 1;
	break
	case r_stage1:
		global.stage = 1;
	break
	case r_stage2:
		global.stage = 2;
	break
	case r_stage3:
		global.stage = 3;
	break
	case r_stage4:
		global.stage = 4;
	break
	case r_stage5:
		global.stage = 5;
	break
	case r_stage6:
		global.stage = 6;
	break
	case r_stage7:
		global.stage = 7;
	break
	case r_stage8:
		global.stage = 8;
	break
	}
	
	global.double_speed = false;
	global.enemy_amount = 0;
	global.wave_now = 0;
	global.timemachine[timemachine.window_x] = window_get_width()-SHOP_WINDOW_WIDTH-TIMEMACHINE_WIDTH-4;
	global.timemachine[timemachine.window_y] = window_get_height()-TIMEMACHINE_HEIGHT-4;
	global.score_gold_minus = 0;
	global.all_enemy_total_hp = 0;
	global.enemy_last_dead_position_x = 0//敵死亡地点のデフォルトは画面中央
	global.enemy_last_dead_position_y = 0
	timemachine_button_state[0] = 0;
	timemachine_button_state[1] = 2;
	timemachine_button_state[2] = 0;
	stage_setting();
	
	instance_create_layer(0, 0, "Background", o_backgroundMgr);
	instance_create_layer(0, 0, "UI", o_menuMgr);
	global.gamestate = gamestate.reststart;
break

case gamestate.reststart://休憩タイム開始
	rest_time = REST_TIME;
	global.wave_now++;
	instance_create_layer(0, 0, "Instances", o_enemyGenerateMgr);
	arrow_create_cooldown = ARROW_CREATE_COOLDOWN_DEFAULT;
	calculate_enemy_total_hp();//敵hp計測
	if(global.wave_now = 1){
		global.gamestate = gamestate.restpause;//1ウェーブ目はポーズ状態で始める
	}
	else{
		global.gamestate = gamestate.rest;
	}
break



case gamestate.rest://ウェーブの間の休憩
	if(rest_time > 0){
		rest_time--;
		if(arrow_create_cooldown = 0){
			create_route_arrow(o_enemyGenerateMgr.spowner_amount);//ルート表示用の矢印表示
			arrow_create_cooldown = ARROW_CREATE_COOLDOWN_DEFAULT;
		}
		else{
			arrow_create_cooldown--
		}
	}
	else{
		global.gamestate = gamestate.wavestart;	
	}
		
break

case gamestate.wavestart://ウェーブ開始処理


	sdm("wave"+string(global.wave_now)+"開始")
	
	global.gamestate = gamestate.main;
break

case gamestate.main://ゲーム中処理
	#region ゲームメイン処理
	#region 敵データ格納

	if(instance_exists(o_enemy)){
		global.enemy_amount = instance_number(o_enemy);//敵の総数取得
	}
	else{
		global.enemy_amount = 0;
	}
	i = 0;
	//リセット
	//global.enemy_x = 0;
	//global.enemy_y = 0;
	global.enemy_position = 0;
	global.enemy_id = 0;
	global.enemy_hp = 0

	repeat(global.enemy_amount){
		if(instance_exists(o_enemy) != noone){//存在チェック
			//データを入れる
			//global.enemy_x[i] = instance_find(o_enemy, i).x;
			//global.enemy_y[i] = instance_find(o_enemy, i).y;
			global.enemy_hp[i] = instance_find(o_enemy, i).hp;
			global.enemy_id[i] = instance_find(o_enemy, i).id;
			
			//ポジション代入
			var position = instance_find(o_enemy, i).path_position*path_get_length(instance_find(o_enemy, i).path_index);
			position = path_get_length(instance_find(o_enemy, i).path_index)-position;
			global.enemy_position[i] = -position;
			i++;
		}
	}
	#endregion

	#region 敵データソート
	if(global.enemy_amount != 0){
		sort_enemydata(sorttype.neargoal)
	}


	#endregion
	#endregion
	if(global.enemy_wave_total_amount <= 0){//敵が全員居なくなった
		global.gamestate = gamestate.waveclear;
	}
	if(global.life <= 0){//ゲームオーバー
		global.gamestate = gamestate.gameover;
	}
break

case gamestate.waveclear://ウェーブクリア処理
	sdm("wave"+string(global.wave_now)+"をクリア")
	instance_destroy(o_enemyGenerateMgr);
	timeline_delete(global.generate_timeline_id);//タイムラインを一旦全部けしてリセットする
	with(o_defender){
		cooldown = 0;//全てのdefenderのクールダウンを解消
		state = state.idle
	}
	if(global.life <= 0){//ゲームオーバー
		global.gamestate = gamestate.gameover;
	}
	
	if(global.wave_now >= global.wave_total){
		//ステージクリア
		global.gamestate = gamestate.stageclear;
	}
	else{
		//次ウェーブへ
		global.gamestate = gamestate.reststart;
		global.gold += global.wave_clear_gold;//ウェーブクリアゴールド追加
		var gold_get_x = window_get_width()-SHOP_WINDOW_WIDTH+32
		rise_number("+ "+string(global.wave_clear_gold), gold_get_x, 6, 0, 180, COLOR_TEXT_YELLOW, 1, true, FONT_DEFAULT);
		if(global.wave_drop_item[global.wave_now] != -1){//ドロップアイテム
			var _x = global.enemy_last_dead_position_x;
			var _y = global.enemy_last_dead_position_y;
			
			get_drop_item(_x, _y, global.wave_drop_item[global.wave_now]);
		}
	}
	
break

case gamestate.stageclear://ステージクリア処理

break

case gamestate.gameover://ゲームオーバー処理
	//show_message("GameOver!");
	//game_restart();
break

case gamestate.pause:

break

case gamestate.restpause:
	if(arrow_create_cooldown = 0){//休憩時間中の矢印
			create_route_arrow(o_enemyGenerateMgr.spowner_amount);//ルート表示用の矢印表示
			arrow_create_cooldown = ARROW_CREATE_COOLDOWN_DEFAULT;
		}
		else{
			arrow_create_cooldown--
		}
break
}
#region shop処理 キーボード操作
switch(global.gamestate){
case gamestate.wavestart:
case gamestate.reststart:
case gamestate.rest:
case gamestate.restpause:
case gamestate.pause:
case gamestate.main:
case gamestate.waveclear:
	defender_shop();
	time_machine_process();
break
}
#endregion
#endregion

#region デバッグ用
	if(global.debugmode or debug_mode){
		if(keyboard_check(ord("G"))){
			global.gold += 10;
		}
		if(keyboard_check_pressed(ord("R"))){
			//game_restart();
		}
		if(keyboard_check_pressed(vk_escape)){
			game_end()
		}
		if(keyboard_check_pressed(ord("L"))){
			global.life++;
		}
	}
	#endregion
