// easy(9,9,10) nomal(16,16,40) hard(30,16,99)
var FIELD_W = 30;
var FIELD_H = 16;
var FIELD_M = 99;

var CELL_CLOSE = "close";
var CELL_OPEN = "open";
var CELL_FLAG = "flag";
var CELL_MINE = "mine";

var ICON = [];	// アイコン画像格納用
ICON[1] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAXUlEQVR4nOWSoRHAMAwDk1JTj5AdY5MQE2/hCTODAkpSVPd6RX0q/YmoAihpVPXIt09eCwDmnGbWWksJqsrMY4zsgrsDiIiscMsvhYIrvfc9JaI9FZH6+fmqiDwSFrUsOXOXOlP/AAAAAElFTkSuQmCC"
ICON[2] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAA2ElEQVR4nGP8//8/A9GgsrKSiXjVEECZhh8/fhQXF2toaHBxcUlKSsbFxT1//hyfho8fP16/fn3WrFkvX748fPjwo0ePQkJC0K34jxvs2bMHYgpcpKKiAp8fnj17xsPDw8vLi9NJyOD79+8dHR0xMTGMjIyENfz58yc2NpaXl7enpwefpyHgx48foaGhT5482b59Ozc3NwENb968cXZ2ZmZm3r9/v6CgIKZxKBru379vYWHh5OS0evVqTk5OrK5FCdbly5djKiguLkYOVkaaJz7GiooKkjQAAH4zimgKZm2tAAAAAElFTkSuQmCC"
ICON[3] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAA7UlEQVR4nLWSMa5FQBSGeShkCsVETSQUorEDDbagmnUMsQa2YQcWQDWtQiU09IKEYjK3uMnNfcnjeXm5f3lyvuT/cg7PGONuJ47jr/vbz/wPYIwlSeI4DgAAQuj7PiHkCqCUVlWVZdk4jm3bWpYVBMG+798Idp6maTiOG4bhNcEYiz8WpZT2fZ+mKUJI07TfpRVFMU1TEIQ8z68cXlmWZZomwzBc153n+a4DpVSW5aIo3h2u7rBt23EckiSdVirLEiFECFnXtes6hJCu62EYngK2bYuiGEWRqqqe50EI67oGALzv8B9/Ph5j/CfgAfefpFbPfI13AAAAAElFTkSuQmCC"
ICON[4] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAApklEQVR4nK2OsQ2EIBhGES9hAGdgBRyCjoQZmMAEeyZgBgt7ShiAihFYAAagw+KSi97pBRO/9n8v7+9qraB58zzDdvq954RlWSCEzrkmwVqrlOr7vqkQQhBCGGOahBgj53xdV4zxafwgpJQopVprQsgp/S0wxqZpopRe0QAAUHcbhuEXGMfxA0gpD4Wc895HCFlrvfeXL7XstvD6cyulPFDopJS3hA3TtlA7f698oAAAAABJRU5ErkJggg=="
ICON[5] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAw0lEQVR4nK2PKw6EMBBAtxsaQBE+AmwTjoEllfUExyFAYfFYuAcCPZygtlyCpKC6Yg0ky5b9PDfJvMwbpJS6Xaaqqvv17Sc/C5RSdKTrOs2Fuq7VjqIo/pr0jdA0DcY4DENKKQBohGEY1nWVUgJAHMdpmgoh9EmGYRBC2ra1LGscx6s/bNsmpTRN81TgnDPGAGBZlnme8zx3XZcxdipEUeT7fpZlQRAkSWLb9jRNjuMcaveD53l937+J1PzwElSW5UfCA1THSYYeYhrVAAAAAElFTkSuQmCC"
ICON[6] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAABDUlEQVR4nK2SMatGcBSH/W/KIIUYKKXe3UQMvoHRZFAWX4ASn8CHMCgyWmS2MNhMRpmMSlksuMOt2/vecq+37jOeznNO59cB53lCtwmC4ON+9xf/IfR9bxgGwzAIgpim+YfQNI2iKBzH1XW9bVuapj/nnU/s+/54PFzXPS/wff9lQ13XwzB4nnf3hq7rSJIMw5DneRRFBUGI4/g3YVkWAICqql3XTdPkOI5t23meXwoYhtE0res6QRA4jluWpWlaURSXgiRJ4zjO8/xd2bYNhuHLlI7jkGVZ07RhGNZ1jaIIQZC2bS9TAgCUZUmSpCiKLMtmWVZVlSzLzz2v6yCIoqgkSaBr3v4l4Pv+W8InxtyXYS+9ibIAAAAASUVORK5CYII="
ICON[7] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAvElEQVR4nGP8//8/A9GgsrKSiXjVEECZhjlz5jBigJycHJwaUlJS/qMCKysrRUVFYp20du3ae/fuZWZmEqXhz58/VVVVdXV1XFxcRGmYOXPm379/U1JS0MRZsKr+8uVLU1PThAkTWFlZ0aSw29DZ2SklJRUREYEphcWG58+f9/f3r1mzhpGREVMWiw11dXUmJiYeHh5YLUe34fr16wsWLDh8+DBW1Vg0aGpq/v79G5dq7E7CDxgrKipI0gAAPkJIlmv70nAAAAAASUVORK5CYII="
ICON[8] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAABGUlEQVR4nLWSsYqDQBRFVVBiERnt0vkF6UIgiIjCkNZfSC+k1MZKC7t8zNSWigTSCFailcVAQI0gBoTZYkESwSXLsre7773L4cKjCSHUx3Ich/n8+lt/Dtxut+PxKEkSAEDX9SiKfgpgjA3DUBSlKIqyLFVVhRBWVfWWIC9CCDEMMwzDNFmtVgihydq2/UbY7XYAgPP53LYtRVFRFK3X68PhsEgghKRpKkmSIAimaW632yzLXrdzQtM0p9MpCII8zw3DeD6flmV1XbdI8H1/v99Ptu97WZY9z1skPB6PcRwny/P8ZrPBGC8Srtcry7Ku697v97quL5cLx3FJkrwS5qXDMNQ0DQAgiiKEMI7jWWn635+Ptm37V4Eve5n2aDulmdYAAAAASUVORK5CYII="
ICON[CELL_CLOSE] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAJElEQVR4nGOsqKhgIBq0t7czEa8aAkY1jGoYMA2M////J0kDAJp+BhnlNCSXAAAAAElFTkSuQmCC"
ICON[CELL_OPEN] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAJElEQVR4nGP8//8/A9GgsrKSiXjVEDCqYVTDgGlgrKioIEkDAKybBe8o/6vDAAAAAElFTkSuQmCC"
ICON[CELL_FLAG] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAJElEQVR4nGNk2P6BgWjw34OfiXjVEDCqYVTDgGlg/P//P0kaAKWRBhlLmfA4AAAAAElFTkSuQmCC"
ICON[CELL_MINE] = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAIAAACQkWg2AAAAJElEQVR4nGN8qyLNQDQQuv2EiXjVEDCqYVTDgGlg/P//P0kaAI/yBhngMLANAAAAAElFTkSuQmCC"

// 座標定義用
var Position = function(x,y){
	this.x = x;
	this.y = y;
}

// 隣接座標用
var ROUNDS = [	new Position(-1,-1),	new Position(0,-1),	new Position(1,-1),
				new Position(-1,0),							new Position(1,0),
				new Position(-1,1),		new Position(0,1),	new Position(1,1)];

var CTRL = false;
var FIELD_INTERFACE;
var field;
var view;

var Cell = function(){
	this.open = false;
	this.flag = false;
	this.mine = false;
};
var Field = function(w,h,mine){
	this.x = w;
	this.y = h;
	this.mine = mine;
	this._gameOver = false;
	this._clear = false;
	this._cells = [];
	for(var i = 0;i < this.x *this.y;i++){
		this._cells.push(new Cell());
	}
	// ランダムでmineの位置を設定する
	for(var m = 0;m < mine;m++){
		while(true){
			var randomPosition = Math.floor(Math.random() * this.y * this.x);
			if(this._cells[randomPosition].mine == false){  // 設定済の場合は再度random()実行
				this._cells[randomPosition].mine = true;
				break;
			}
		}
	}
}
Field.prototype.cell = function(x,y){
	var cell = null;
	if(0 <= x && x < this.x && 0 <= y && y < this.y)
		cell = this._cells[y*this.x + x];
	return cell;
}
Field.prototype.isMine = function(x,y){
	var mine = false;
	var cell = this.cell(x,y);
	if(cell != null)
		mine = cell.mine;
	return mine;
}
Field.prototype.isOpen = function(x,y){  // 開いている=true 閉じている=false,範囲外=false
	var open = false;
	var cell = this.cell(x,y);
	if(cell != null)
		open = cell.open;
	return open;
}
Field.prototype.isFlag = function(x,y){  // 旗あり=true 旗なし=false,範囲外=false
	var flag = false;
	var cell = this.cell(x,y);
	if(cell != null)
		flag = cell.flag;
	return flag;
},
Field.prototype.isClose = function(x,y){  // 閉じている=true 開いている=false,範囲外=false
	var close = false;
	var cell = this.cell(x,y);
	if(cell != null)
		if(cell.open == false)
			close = true;
	return close;
}
Field.prototype.isUnsafe = function(x,y){  // 閉じている、旗なし=true それ以外=false,範囲外の場合=false
	var closeAndNoFlag = false;
	var cell = this.cell(x,y);
	if(cell != null)
		if(cell.open == false && cell.flag == false)
			closeAndNoFlag = true;
	return closeAndNoFlag;
}
Field.prototype.openCell = function(x,y){
	if(this.isUnsafe(x,y)){
		this.cell(x,y).open = true;
		// 開いた場所の隣接にmineが無い場合は隣接をすべて開く
		if(this.roundCount(x,y)== 0 && this.isMine(x,y) == false){
			for(var i = 0;i < ROUNDS.length;i++){
				this.openCell(x + ROUNDS[i].x,y + ROUNDS[i].y);
			}
		}
		this._validOver();
	}
}
Field.prototype.setFlag = function(x,y){
	if(this.isClose(x,y)){
		if(this.isFlag(x,y) == false)
			this.cell(x,y).flag = true;
		else
			this.cell(x,y).flag = false;
	}
}
Field.prototype._validOver = function(){
	var closeCellCount = 0;
	for(var y = 0;y < this.y;y++){
		for(var x = 0;x < this.x;x++){
			if(this.isClose(x,y))
				closeCellCount++;
			if(this.isOpen(x,y) && this.isMine(x,y)){
				this._gameOver = true;
				break;
			}
		}
		if(this._gameOver == true)
			break;
	}
	if(this._gameOver == false && closeCellCount == this.mine){
		this._gameOver = true;
		this._clear = true;
	}
}
Field.prototype.roundCount = function(x,y){	// セルに表示する数値を返す
	var count = 0;
	for( var i = 0 ; i < ROUNDS.length ; i++){
		if(this.isMine(x + ROUNDS[i].x,y + ROUNDS[i].y))
			count++;
	}
	return count;
}
Field.prototype.isClear = function(){
	return this._clear;
}
Field.prototype.isGameOver = function(){
	return this._gameOver;
}
Field.prototype.restCount = function(){
	var restCount = this.mine;
	for(var y = 0;y < this.y;y++){
		for(var x = 0;x < this.x;x++){
			if(this.isFlag(x,y))
				restCount--;
		}
	}
	return restCount;
}

var View = function(){
	this.autoPlayId = null;
	this.timerId = null;
	this.timeCount = 0;
	this.playCount = 0;
	this.clearCount = 0;
}
View.prototype.reset = function(){
	if(this.autoPlayId != null)
		clearTimeout(this.autoPlayId);
		this.autoPlayId = null;
	if(this.timerId != null){
		clearTimeout(this.timerId);
		this.timerId = null;
		this.playCount++;
	}
	this.timeCount = 0;
}
View.prototype.draw = function(drawField){
	this._drawField(drawField);
	this._drawRestCount(drawField);
	this.drawTimeCount();
}
View.prototype._drawField = function(drawField){
	var table = "";
	for(var y = 0;y < drawField.y;y++){
		for(var x = 0;x < drawField.x;x++){
			if(drawField.isMine(x,y) && (drawField.isOpen(x,y) || drawField.isGameOver())){
				table += this._drawCell(CELL_MINE,-1,-1);
			}
			else if(drawField.isFlag(x,y) && drawField.isOpen(x,y) == false){
				table += this._drawCell(CELL_FLAG,x,y);
			}
			else if(drawField.isOpen(x,y) == false){
				table += this._drawCell(CELL_CLOSE,x,y);
			}
			else{
				var roundCount = drawField.roundCount(x,y);
				if(roundCount != 0)
					table +=  this._drawCell(roundCount,-1,-1);
				else
					table +=  this._drawCell(CELL_OPEN,-1,-1);
			}
		}
		table += "<br/>";
	}
	document.getElementById('main_div').innerHTML = table;
}
View.prototype._drawCell = function(icon_name,x,y){
	if(x==-1 && y==-1)
		return "<img src=\"" + ICON[icon_name] + "\" ></img>";
	else
		return "<img id=\"image_num_" + x + "_" + y + "\" src=\"" + ICON[icon_name] + "\" onclick=\"return onClickCell(" + x + "," + y + ");\" ></img>";
}
View.prototype._drawRestCount = function(drawField){
	var clearPerPlay = 0;
	if(this.playCount > 0)
	clearPerPlay = (this.clearCount / this.playCount) * 100;
	document.getElementById("rest_label").innerHTML = "[Rest:" + drawField.restCount() + "]" + " (Clear:" + this.clearCount + "/Play:" + this.playCount + ") " + clearPerPlay.toFixed([2]) + "%";
}
View.prototype.drawTimeCount = function(){
	document.getElementById("time_label").innerHTML = "[Time:" + this.timeCount + "]";
}
View.prototype.updateTimer = function(drawField){
	if(this.timerId == null)
		this.timerId = setTimeout(onTimeCounter,1000);
	if(drawField.isGameOver())
		clearTimeout(this.timerId);
	this.drawTimeCount();
}
View.prototype.updateClear = function(drawField){
	if(drawField.isClear())
		this.clearCount++;
}

//////////////////////////////////////////////////////////////////////////////
// イベント関数
//////////////////////////////////////////////////////////////////////////////

function onLoad(){
	document.onkeydown = onKeyDown;
	document.onkeyup = onKeyUp;
	FIELD_INTERFACE = Field;
	view = new View();
	onButtonReset();
}

function onButtonReset(){
	view.reset();
	field = new FIELD_INTERFACE(FIELD_W,FIELD_H,FIELD_M);
    view.draw(field);
}

function onClickCell(x,y){
	if(field.isGameOver() == false){
		if(CTRL == true)
			field.setFlag(x,y);	// CTRLクリックした場合は旗を設置
		else
			field.openCell(x,y); // 普通にクリックした場合は開く
		view.updateTimer(field);
		view.updateClear(field);
	}
	view.draw(field);
}

function onTimeCounter(){
	view.timeCount++;
	view.drawTimeCount();
	view.timerId = setTimeout(onTimeCounter,1000);
}

function onKeyDown(e){
	if(getKeyCode(e) == '17')	// CTRLキーのDown状態を更新
		CTRL = true;
}
function onKeyUp(e){
	if(getKeyCode(e) == '17')	// CTRLキーのUp状態を更新
		CTRL = false;
}
function getKeyCode(e){
	if(document.all)
		return window.event.keyCode;
	else
		return e.keyCode;
}

