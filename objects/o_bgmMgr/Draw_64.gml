/// @description Draw nowmusicUI
//ステージ中のみbgm表示
if(instance_exists(o_gameMgr)){
	if(global.gamestate != gamestate.gameover){
		draw_nowmusic();
	}
}
