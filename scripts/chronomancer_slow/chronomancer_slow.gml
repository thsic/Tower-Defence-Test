///@param dotdamage,demonsfireLV,freeze_all

var dot_damage = argument0;
var demonsfire_level = argument1;
var freeze_all = argument2;

if(chronomancer_timing <= 0){
	for(var i=0; i<global.enemy_amount; i++){
		var target_id = global.enemy_id[i];
		var target_x = global.enemy_id[i].x;
		var target_y = global.enemy_id[i].y;
		if(point_distance(x, y, target_x, target_y) <= range){
			if(freeze_all){//ブリザードがあるならスローの効果を上げる 隠れ効果
				slow_to_enemy(target_id, 2, FREEZE_INTERVAL/2+1);
			}
			else{
				slow_to_enemy(target_id, 1, FREEZE_INTERVAL/2+1);
			}
			
			if(dot_damage){//ダメージを与える
				var damage = fire_damage*global.effectdata[27, effectdata.value];
				if(demonsfire_level){
					damage += global.effectdata[3, effectdata.value]*demonsfire_level;
				}
				target_id.hp -= damage

				if(target_id.hp <= 0){//ダメージ記録
					record_damage(id, damage+target_id.hp);//敵を倒した場合
				}
				else{
					record_damage(id, damage);
				}
				
				if(target_id.hp <= 0){//敵が死んだ
					target_id.destroy_enemy = true;
					global.gold += global.enemydata[enemy_id_conversion(target_id.object_index), enemydata.dropgold]//ゴールドを落とす
				}
			}
		}
	}
	chronomancer_timing = FREEZE_INTERVAL;
}
else{
	chronomancer_timing--;
}