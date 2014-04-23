$(document).ready(function() {
  
  /*** Constants ***/
  var TILESIZE = 32;
  
  var TILE_WALL = 0;
  var TILE_EMPTY = 1;
  var TILE_START = 2;
  var TILE_FINISH = 3;
  
  var DX = [0, 1, 0, -1];
  var DY = [-1, 0, 1, 0];
  
  /*** Result text area ***/
  var dirLetters = ['U', 'R', 'D', 'L', 'P'];
  var resultArea = $('#resultarea');
  
  resultArea.focus(function() {
    this.select();
  });
  
  /*** Level selection ***/
  for (var i = 0; i < levels.length; i++)
    $('#levelselect').append(
      '<option value="' + i + '">' + levels[i].name + '</option>'
    );
  
  $('#selectbutton').click(function() {
    window.location.href = '#' + $('#levelselect').val();
    window.location.reload();
  });
  
  
  /*** Map box resizing ***/
  var boxWidth = 0;
  var boxHeight = 0;
  var tileArray = [];
  var finished = false;
  
  $('#widthexpander').click(function() {
    for (var y = 0; y < boxHeight; y++) {
      var tile = $('<div class="tile"></div>').css({
        left: (boxWidth * TILESIZE) + 'px',
        top: (y * TILESIZE) + 'px'
      });
      
      tileArray[y].push(tile);
      $('#mapbox').append(tile);
    }

    ++boxWidth;
    $('#widthcontractor').show();    
    resizeBox();
  });
        
  $('#widthcontractor').click(function() {
    if (boxWidth == 3) return;
    
    for (var y = 0; y < boxHeight; y++) {
      tileArray[y][boxWidth - 1].remove();
      tileArray[y].pop();
    }
    
    --boxWidth;
    if (boxWidth == 3) $('#widthcontractor').hide();
    resizeBox();
  });

  $('#heightexpander').click(function() {
    tileArray.push([]);
    
    for (var x = 0; x < boxWidth; x++) {
      var tile = $('<div class="tile"></div>').css({
        left: (x * TILESIZE) + 'px',
        top: (boxHeight * TILESIZE) + 'px'
      });
      
      tileArray[boxHeight].push(tile);
      $('#mapbox').append(tile);
    }
        
    ++boxHeight;
    $('#heightcontractor').show();
    resizeBox();    
  });
  
  $('#heightcontractor').click(function() {
    if (boxHeight == 3) return;
                               
    for (var x = 0; x < boxWidth; x++) {
      tileArray[boxHeight - 1][x].remove();
    }
    tileArray.pop();
                               
    --boxHeight;
    if (boxHeight == 3) $('#heightcontractor').hide();    
    resizeBox();    
  });
  
  function resizeBox() {
    $('#mapbox').css({
      width: (boxWidth * TILESIZE) + 'px',
      height: (boxHeight * TILESIZE) + 'px'
    });
        
    panMap();
    redrawMap();
  }
  
  /*** Window resizing ***/
  $(window).resize(function() {
    $('#widthexpbox').css({
      top: (($(window).height() - 42) / 2) + 'px',
    });
    
    $('#heightexpbox').css({
      left: (($(window).width() - 42) / 2) + 'px',
    });
    
  });
  
  function initializeMapBox(width, height) {
    for (var y = 0; y < height; y++) $('#widthexpander').click();
    for (var x = 0; x < height; x++) $('#heightexpander').click();
  }
  
  /*** Level loading ***/
  var map;
  var playerX, playerY, playerD;
  var mapWidth, mapHeight;
    
  function loadLevel(index) {
    map = levels[index].data;
    
    mapHeight = map.length;
    mapWidth = map[0].length;
    
    for (var y = 0; y < mapHeight; y++)
      for (var x = 0; x < mapWidth; x++)
        if (map[y][x] == TILE_START) {
          playerX = x;
          playerY = y;
        }
    
    playerD = 1;
    
    panMap();
  }
  
  
  /*** Moving and panning ***/
  var panX;
  var panY;

  function panMap() {
    oldPanX = panX;
    oldPanY = panY;
    
    panX = playerX - Math.floor(boxWidth / 2);
    panY = playerY - Math.floor(boxHeight / 2);
    
    if (panX + boxWidth >= mapWidth)
      panX = mapWidth - boxWidth;
    if (panY + boxHeight >= mapHeight)
      panY = mapHeight - boxHeight;

    if (panX < 0)
      panX = 0;
    if (panY < 0)
      panY = 0;    

    if (oldPanY != panY || oldPanX != panX)
      redrawMap();
  }
  
  
  /*** Redrawing ***/
  playerTile = $('#playertile');
  
  function redrawPlayer() {
    playerTile.css({
      'background-position': -32 * (playerD + 3) + 'px 0px',
      'left': (32 * (playerX - panX)) + 'px',
      'top': (32 * (playerY - panY)) + 'px'
    });    
  }
  
  function getName(tileType) {
    if (tileType < 100) return '';
    
    var id = (tileType % 100);
    if (id < 26) return String.fromCharCode(65 + id);
    if (id < 52) return String.fromCharCode(97 + id - 26);
    if (id < 78) return String.fromCharCode(65 + id - 52, 97 + id - 52);
    if (id < 104) return String.fromCharCode(104 + id - 78, 104 + id - 78);
  }
  
  function redrawMap() {
    if (!boxWidth || !boxHeight) return;
    
    for (var y = 0; y < boxHeight; y++)
      for (var x = 0; x < boxWidth; x++) {
        var tileType;
        
        if (
          x + panX < 0 ||
          y + panY < 0 ||
          x + panX >= mapWidth ||
          y + panY >= mapHeight
        ) {
          tileType = 0;                        
        } else {
          tileType = map[y + panY][x + panX];
        }
        
        var offsetX = 0;
        var offsetY = 0;
        
        $(tileArray[y][x]).css({
          'background-image':
            ((tileType < 100) ? 'url("special.png")' : 'url("tiles.png")')
        });
        
        offsetY = 0;
        if (tileType >= 100 && tileType < 200) offsetY = 0;
        if (tileType >= 200 && tileType < 300) offsetY = -32;
        if (tileType >= 300 && tileType < 400) offsetY = -64;
        
        switch (tileType) {
          case 0: offsetX = 0; break;
          case 1: case 2: offsetX = -32; break;
          case 3: offsetX = -64; break;
          default: offsetX = -32 * (tileType % 100); break;
        }
        
        $(tileArray[y][x]).css({
          'background-position': offsetX + 'px ' + offsetY + 'px'
        }).html(
          getName(tileType)
        );                
      }
        
    redrawPlayer();
  }
  
  
  /*** Controls ***/
  function pushButton() {
    if (finished) return;
    var type = map[playerY][playerX];
    if (type < 100 || type >= 200) return;
    type %= 100;
    
    for (var y = 0; y < mapHeight; y++)
      for (var x = 0; x < mapWidth; x++)
        if ((map[y][x] >= 200) && (map[y][x] % 100 == type)) {
          if (map[y][x] < 300)
            map[y][x] += 100;
          else
            map[y][x] -= 100;
        }

    resultArea.val(resultArea.val() + dirLetters[4]);
    redrawMap();
  }
  
  function passable(type) {
    return ((type != TILE_WALL) && (type < 200 || type >= 300));
  }
  
  function move(d) {    
    if (finished) return;
    if (
      playerX + DX[d] >= 0 &&
      playerX + DX[d] < mapWidth &&
      playerY + DY[d] >= 0 &&
      playerY + DY[d] < mapHeight &&
      passable(map[playerY + DY[d]][playerX + DX[d]])
    ) {
      playerX += DX[d];
      playerY += DY[d];
      playerD = d;
      
      resultArea.val(resultArea.val() + dirLetters[d]);
      panMap();
      redrawPlayer();
      
      if (map[playerY][playerX] == 3) {
        finished = true;

        var message = $(
          '<div class="message">Congratulations! You have solved this level.<br />'+
          'Don\'t forget to copy the result sequence into your output file.</div>'
        )
        
        $(document.body).append(message);
        
        message.css({
          'line-height': ((message.height() - 20) / 2) + 'px'
        });
        
        message.delay(3000).fadeOut('slow', function() {
          this.remove();
        });
      }
      
    }
  }
  
  $(document).keydown(function(e) {
    var charCode = e.which || e.charCode || e.keyCode || 0;
    
    switch (charCode) {
      case 38: case 104: move(0); break;
      case 39: case 102: move(1); break;
      case 40: case 98: move(2); break;
      case 37: case 100: move(3); break;
      case 37: case 100: move(3); break;
      case 13: case 80: case 101: pushButton(); break;
      default: return true;
    }
    
    return false;
  });
  
  $('.control').click(function() {
    switch (this.id.charAt(7)) {
      case 'u': move(0); break;
      case 'r': move(1); break;
      case 'd': move(2); break;
      case 'l': move(3); break;
      default: pushButton();
    }
  });
  
  /*** Initialization ***/
  if (
    !window.location.hash ||
    parseInt(window.location.hash) < 0 ||
    parseInt(window.location.hash) >= levels.length    
  ) {
    window.location.hash = 0;
  }

  var loadedLevel = parseInt(window.location.hash.substring(1));
  $('#levelselect option').removeAttr('selected');
  $('#levelselect option[value="' + loadedLevel + '"]').attr('selected', true);
  
  loadLevel(loadedLevel);
  resultArea.val('');
  resizeBox();  
  initializeMapBox(15, 12);
  panMap();
  redrawMap();  
  $(window).resize();
  
  /*** Finalization ***/
  $(window).unload(function() {
    try {
      return confirm('Are you sure you want to leave or reload this page? You will lose your game progress!');
    } catch (e) {
      return true;
    }
  });
  
});
