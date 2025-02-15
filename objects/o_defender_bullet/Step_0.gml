switch(global.gamestate){
case gamestate.main:
	if(instance_exists(defender_id)){
		var effect_freeze = 0;
		var effect_fire = 0
		var penetration = 0;
		var penetration_plus = 0;
		var septuple_shot = 0;
		for(var i=0; i<EFFECT_SLOT_MAX; i++){
			if(defender_id.effect_now[i, effectnow.number] != -1){
				//何かしらのエフェクトがある
				switch(defender_id.effect_now[i, effectnow.number]){
				case 1:
					effect_fire++;
				break
				case 2:
					effect_freeze++;
				break
				case 6:
					penetration++;
				break
				case 7:
					penetration_plus++;
				break
				case 28:
					septuple_shot++;
				break
				}
			}
			else{
				break
			}
		}
	
	
		speed = bullet_speed
		if(speed_temp != -1){
			speed = speed_temp;
			speed_temp = -1;
		}
	
		if(!penetration and !penetration_plus){
			//数fごとに角度を変える
			--direction_change_cooldown;
			if(direction_change_cooldown >= 0){
				if(instance_exists(bullet_target)){//存在チェック
					direction = point_direction(x, y, bullet_target.x, bullet_target.y);
					direction_change_cooldown = direction_change_cooldown_default;
				}
				else{
					destroy_countdown = destroy_countdown_default;//ターゲットが存在しないので消滅
				}
			}
		}
		else{
			//貫通攻撃は射程外になると消える
			if(point_distance(x, y, defender_id.x, defender_id.y)+speed > defender_id.range){
				instance_destroy();
				//誰にもダメージを与えられないまま射程外になったときはターゲットにダメージを与える
				if(penetration_enemy_id[0] = -1){
					if(instance_exists(bullet_target)){//存在チェック
						damage_to_enemy(damage, bullet_target, defender_id);
					}
				}
			}
		}
	
		//色設定
		var bullet_fire_color = COLOR_BULLET_DEFAULT;
		if(effect_freeze){
			bullet_fire_color = COLOR_BULLET_FREEZE;
		}
		if(effect_fire){
			bullet_fire_color = COLOR_BULLET_FIRE;
		}
		if(effect_freeze and effect_fire){
			bullet_fire_color = COLOR_BULLET_MIX;
		}
		//弾道
		if(septuple_shot){//七連攻撃
			bullet_fire(x, y, xprev, yprev, direction, dirprev, bullet_fire_color, 0.7, 1, 2);
		}
		else{//普通
			bullet_fire(x, y, xprev, yprev, direction, dirprev, bullet_fire_color, 0.3, 5, 2);
		}
	}
	

#region 衝突判定
	if(!penetration and !penetration_plus){//インペリアルランス無し 普通の場合
		if(instance_exists(bullet_target)){//存在チェック
			if(collision_circle(bullet_target.x, bullet_target.y, SPRITE_SIZE, id, false, false)){
				var penetration = 0;
				var penetration_plus = 0;
				var other_object = bullet_target
				damage_to_enemy(damage, bullet_target, defender_id);
				instance_destroy();
				
			}
		}
	}
	else{//インペリアルランス有り
		for(var i=0; i<global.enemy_amount; i++){
			other_object = global.enemy_id[i]
			if(instance_exists(global.enemy_id[i])){//存在チェック
				if(collision_circle(other_object.x, other_object.y, SPRITE_SIZE*2, id, false, false)){
					var enemy_id_check = true//以前当たった敵と被りがないか
					for(var j=0; j<IMPERIALLANCE_PENETRATION_MAX; j++){
						if(penetration_enemy_id[j] = other_object){
							enemy_id_check = false//被りがあった
						}
					}
					if(enemy_id_check){//被りがなかった
						if(penetration_plus){
							//貫通攻撃は一定の敵接触回数を超えると消える
							var penetration_count_max = IMPERIALLANCE_PENETRATION_MAX;
						}
						else{
							var penetration_count_max = global.effectdata[6, effectdata.value]*penetration;
						}
		
						for(var k=0; k<IMPERIALLANCE_PENETRATION_MAX; k++){//開いてる所探す
							if(penetration_enemy_id[k] = -1){
								penetration_enemy_id[k] = other_object;//当たった敵を記録する

								if(k+1 >= penetration_count_max){
									instance_destroy();
								}
								break
							}
						}
						damage_to_enemy(damage, other_object, defender_id);
					}
				}
			}
		}
	}	


#endregion
	
break

case gamestate.pause://ポーズされたら止まる
	if(speed_temp = -1){
		speed_temp = speed;//speed_tempに一時的に保存
		speed = 0;
	}
break
case gamestate.rest:
	instance_destroy()//ステージが終わったので消す
break
}

if(destroy_countdown > 0){//消える
	if(point_distance(x, y, defender_id.x, defender_id.y)+speed > defender_id.range){//射程外になると消える
		instance_destroy();
	}
	speed = destroy_countdown/destroy_countdown_default*bullet_speed
	destroy_countdown--;
}
else if(destroy_countdown = 0){
	instance_destroy()
	
}

xprev = x
yprev = y
dirprev = direction

//ルーム外に行くと消える
if(x < -32 or y < -32 or y > room_width+32){
	instance_destroy();
}