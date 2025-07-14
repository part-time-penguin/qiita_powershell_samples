var INTERVAL = 50; // ms
var ACTION_OPEN = 0;
var ACTION_FLAG = 1;

// 自動操作で利用する機能をFieldクラスに拡張する
EnhancedField = function(w,h,mine) {
    Field.call(this,w,h,mine);
}
EnhancedField.prototype = Object.create(Field.prototype);
EnhancedField.prototype.constructor = EnhancedField;

EnhancedField.prototype.unsafeCount = function(){
	var unsafeCount = 0;
	for(var y = 0;y < this.y;y++){
		for(var x = 0;x < this.x;x++){
			if(this.isUnsafe(x,y))
				unsafeCount++;
		}
	}
	return unsafeCount;
}
EnhancedField.prototype.roundFlagCount = function(x,y){
	var flagCount = 0;
	for(var i = 0 ; i < ROUNDS.length ; i++){
		if(this.isFlag(x + ROUNDS[i].x,y + ROUNDS[i].y))
			flagCount++;
	}
	return flagCount;
}
EnhancedField.prototype.roundUnsafeCount = function(x,y){
	var unsafeCount = 0;
	for(var i = 0 ; i < ROUNDS.length ; i++){
		if(this.isUnsafe(x + ROUNDS[i].x,y + ROUNDS[i].y))
			unsafeCount++;
	}
	return unsafeCount;
}
EnhancedField.prototype.roundCloseCount = function(x,y){
	var closeCount = 0;
	for(var i = 0 ; i < ROUNDS.length ; i++){
		if(this.isClose(x + ROUNDS[i].x,y + ROUNDS[i].y))
			closeCount++;
	}
	return closeCount;
}
EnhancedField.prototype.getRoundUnsafeCells = function(x,y){
    var cells = [];
    for(var i = 0;i < ROUNDS.length;i++){
        if(this.isUnsafe(x + ROUNDS[i].x,y + ROUNDS[i].y))
            cells.push(new Position(x + ROUNDS[i].x,y + ROUNDS[i].y));
    }
    return cells;
}

// 自動操作のアクションと位置を管理する
AutoplayPosition = function(position,action) {
	this.action = -1;
    if(position != null){
        Position.call(this,position.x,position.y);
        this.action = action;
    }
}
AutoplayPosition.prototype = Object.create(Position.prototype);
AutoplayPosition.prototype.constructor = AutoplayPosition;

// mine情報をセルの固まりとして保持するクラス
var CellUnit = function(paramPositions,paramCount){
    this.positions = paramPositions; // このリストの座標を全部もっていたらmineCount個のmineが確定している
	this.mineCount = paramCount;
}

// 確率情報を保持するクラス
var Probabilities = function(targetField){
    this._field = targetField;
    this._probabilityList = [];
	for(var i = 0;i < this._field.x * this._field.y;i++){
		this._probabilityList.push(0);
	}
}
Probabilities.prototype.get = function(x,y){
	return this._probabilityList[y*this._field.x + x ]
}
Probabilities.prototype.set = function(x,y,value){
    this._probabilityList[y*this._field.x + x ] = value;
}
Probabilities.prototype.getMin = function(){
	var min = 1;
	for(var i = 0 ; i < this._probabilityList.length;i++ ){
		if( this._probabilityList[i] != 0 ){
			if( min > this._probabilityList[i])
				min = this._probabilityList[i];
		}
	}
	return min;
}
Probabilities.prototype.getMinPositions = function(){
	var positions = [];
	var min = this.getMin();
	for(var y = 0;y < this._field.y;y++){
		for(var x = 0;x < this._field.x;x++){
			if(min == this.get(x,y)){	// 確率が最低のセルのみを対象にする
				positions.push(new Position(x,y));
			}
		}
	}
	return positions;
}
Probabilities.prototype.getAvg = function(){
	return this._field.restCount() / this._field.unsafeCount();	// 全体をランダムで開く場合の確立 = 残りmine / 残りflagなしclose
}

// 隣接情報から次のアクションと座標を返す
function getAutoPlayPositionFromRound(){
    var flagPositions = [];
	var openPositions = [];
	for(var y = 0;y < field.y;y++){
		for(var x = 0;x < field.x;x++){
			if(field.isOpen(x,y) == true){
				if(field.roundCloseCount(x,y) == field.roundCount(x,y)) // 閉じている数 = mine数 → 残りはmine確定
					flagPositions = flagPositions.concat(field.getRoundUnsafeCells(x,y));
				else if(field.roundFlagCount(x,y) == field.roundCount(x,y)) // flag数 = mine数 → 残りは安全
					openPositions = openPositions.concat(field.getRoundUnsafeCells(x,y));
			}
		}
	}
    if(flagPositions.length > 0)
		return new AutoplayPosition(_randomArrayItem(flagPositions),ACTION_FLAG);
	if(openPositions.length > 0)
		return new AutoplayPosition(_randomArrayItem(openPositions),ACTION_OPEN);
	return new AutoplayPosition(null,-1);
}

// 全体の情報から次のアクションと座標を返す
function getAutoPlayPositionFromField(){
    var flagPositions = [];
	var openPositions = [];
    var probabilities = new Probabilities(field);

	var cellUnitList = _createCellUniList();
	if(cellUnitList.length > 0){
		for(var y = 0;y < field.y;y++){
			for(var x = 0;x < field.x;x++){
				if(field.isOpen(x,y)){
					var unsafeCells = field.getRoundUnsafeCells(x,y);
					if(unsafeCells.length >= 1){
						var roundCount = field.roundCount(x,y);
						var flagCount = field.roundFlagCount(x,y);
                        var unsafeList = unsafeCells;
                        var removeCount = 0;
                        var debugFlg = false;
						for(var m = 0;m < cellUnitList.length;m++){  // TODO _containAndRemoveList()の組み合わせを考慮すると確率上がるかも
                            var tmpList = _containAndRemoveList(unsafeList,cellUnitList[m].positions);
                            if(tmpList.length > 0){
                                unsafeList = tmpList;
                                removeCount += cellUnitList[m].mineCount;
                            }
                        }
                        if(unsafeList.length > 0){
							// mine数 - flag数 - CellUnitでmineが確定している数 = 閉じている数 → 残りはmine確定
                            if(roundCount - flagCount - removeCount == unsafeList.length)
								flagPositions = flagPositions.concat(unsafeList);
								// mine数 - flag数 - CellUnitでmineが確定している数 = 0 → 残りはmine確定
                            if(roundCount - flagCount - removeCount == 0)
								openPositions = openPositions.concat(unsafeList);
						}

						// 確率を保持しておく
						var probability = (roundCount - flagCount) / unsafeCells.length;
						for(var i = 0;i < unsafeCells.length;i++){
							if(probabilities.get(unsafeCells[i].x,unsafeCells[i].y) < probability){
								probabilities.set(unsafeCells[i].x,unsafeCells[i].y,probability); // 現在値より危険な場合に対象外になるように値を更新
							}
						}
					}
				}
			}
		}
	}

    if(flagPositions.length > 0)	// 旗が確定している座標
        return new AutoplayPosition(_randomArrayItem(flagPositions),ACTION_FLAG);
	if(openPositions.length > 0)	// 安全が確定している座標
		return new AutoplayPosition(_randomArrayItem(openPositions),ACTION_OPEN);

	// 確定している場所がないので、確率の低い場所を返す
	if( probabilities.getMin() < probabilities.getAvg() ){	// 平均値より高い場合は抽出したリストは使用しない
		var positions = probabilities.getMinPositions();
		if(positions.length > 0)
			return new AutoplayPosition(_randomArrayItem(positions),ACTION_OPEN);
	}
	return new AutoplayPosition(null,-1);
}
// 開いていないセルをランダムで選択
function getAutoPlayRandomPosition(){
	var positions = [];
	for(var y = 0;y < field.y;y++){
		for(var x = 0;x < field.x;x++){
			if(field.isUnsafe(x,y))
				positions.push(new Position(x,y));
		}
	}
	return new AutoplayPosition(_randomArrayItem(positions),ACTION_OPEN);
}
// 引数の配列からランダムでアイテムを返す
function _randomArrayItem(arrayItems){
	if(arrayItems.length >= 1)
		return arrayItems[Math.floor(Math.random() * arrayItems.length)];
	return null;
}
// listBaseと衝突するアイテムがlistCheckにある場合削除して返す。衝突しない場合は空の配列
function _containAndRemoveList(listBase,listCheck){
	var result = [];
    result = result.concat(listBase); // コピー配列の用意

	for(var m = 0;m < listCheck.length;m++){
		var hitIndex = -1;
		for(var n = 0;n < result.length;n++){
			if(result[n].x == listCheck[m].x &&
				result[n].y == listCheck[m].y){
					hitIndex = n;
					break;
			}
		}
		if(hitIndex != -1){
			result.splice(hitIndex,1);
		}
		else{
			return [];
		}
	}
	return result;
}
// field全体の情報からCellUnitの配列を生成する
function _createCellUniList(){
	var cellUnitList = [];
	for(var y = 0;y < field.y;y++){
		for(var x = 0;x < field.x;x++){
			if(field.isOpen(x,y)){
				var unsafePositions = field.getRoundUnsafeCells(x,y);
				if(unsafePositions.length > 0){
					var removeCount = field.roundCount(x,y) - field.roundFlagCount(x,y);
					if(removeCount > 0)
						cellUnitList.push(new CellUnit(unsafePositions,removeCount))
				}
			}
		}
	}
	return cellUnitList;
}

//////////////////////////////////////////////////////////////////////////////
// イベント関数
//////////////////////////////////////////////////////////////////////////////

var AUTO_PALY_FUNCTIONS = [];	// 自動操作関数を配列に格納。上から順番に処理する。
AUTO_PALY_FUNCTIONS.push(getAutoPlayPositionFromRound);
AUTO_PALY_FUNCTIONS.push(getAutoPlayPositionFromField);
AUTO_PALY_FUNCTIONS.push(getAutoPlayRandomPosition);

function autoPlay(){
	if(view.playCount >= 1000){	// 無限に実行しないように制限を入れておく
		return
	}

	if(field.isGameOver() == false){
		for(var i = 0;i < AUTO_PALY_FUNCTIONS.length;i++){
			var autoPosition = AUTO_PALY_FUNCTIONS[i]();
			if(autoPosition.action == ACTION_OPEN){
				onClickCell(autoPosition.x,autoPosition.y);
				break;
			}else if(autoPosition.action == ACTION_FLAG){
				field.setFlag(autoPosition.x,autoPosition.y);
				break;
			}
		}
	}
	else{
		onButtonReset();
	}
	view.autoPlayId = setTimeout(autoPlay,INTERVAL);
}

function onLoadAutoPlay(){
    document.onkeydown = onKeyDown;
    document.onkeyup = onKeyUp;
    FIELD_INTERFACE = EnhancedField;
    view = new View();
    onButtonReset();
	autoPlay();
}

