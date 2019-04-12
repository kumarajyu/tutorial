# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

  class MyCanvas

    PI2 = Math.PI * 2
    
    constructor: (@canvas)->
      @ctx = @canvas.getContext('2d')
      @lineWidth = 10
      @prevPos = {x:0, y:0}
      @mouse_down = false
      @historyData = [@ctx.getImageData(0, 0, @canvas.width, @canvas.height)]
      @historyIdx = @historyData.length - 1
      @color = '#000000'
      
    setMouseState:  (flag) ->
      @addHistory() if @mouse_down is true and flag is false
      @mouse_down = flag
    setLineWidth: (val) -> @lineWidth = val
    getLineWidth: -> @lineWidth
    setColor: (@color) ->
      @ctx.strokeStyle = @color
      @ctx.fillStyle = @color
    getColor: -> @color

    addHistory: ->
      @historyData = @historyData.slice(0, @historyIdx + 1)
      @historyData.push @ctx.getImageData(0, 0, @canvas.width, @canvas.height)
      @historyIdx = @historyData.length - 1

    showHistoryAt: (idx = @historyIdx)->
      if (idx < 0 or idx >= @historyData.length)
        false
      else
        @ctx.putImageData(@historyData[idx], 0, 0)
        @historyIdx = idx
        true

    showHistory: (step) -> @showHistoryAt(@historyIdx + step)

    clear: ->
      @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
      @addHistory()

    save: ->
      dataURL = @canvas.toDataURL()
      $.post '/pictures', {data: dataURL}
      null

    download : ->
      # See http://tech.pro/tutorial/1084/saving-canvas-data-as-an-image
      dataURL = @canvas.toDataURL('image/png');
      # window.open(dataURL, "Canvas Image");
      dataURL = dataURL.replace("image/png", "image/octet-stream");
      document.location.href = dataURL;

    reload: (image) ->
      @ctx.clearRect(0, 0, @canvas.width, @canvas.height)
      @ctx.drawImage(image, 0, 0)
      @addHistory()

    mousedown: (e) ->
      @mouse_down = true
      @prevPos = @getPointPosition(e)
      @putPoint(@prevPos)

    mousemove: (e) ->
      return unless @mouse_down
      curPos = @getPointPosition(e)
      @drawLine(@prevPos, curPos)
      @putPoint(curPos)
      @prevPos = {x:curPos.x, y:curPos.y}

    getPointPosition: (e) ->
      rect = canvas.getBoundingClientRect()
      x: e.pageX - rect.left;
      y: e.pageY - rect.top;

    putPoint: (pos, width = @lineWidth, color = @color) ->
      @ctx.beginPath()
      @ctx.arc(pos.x, pos.y, width / 2.0, 0, PI2, false)
      @ctx.fillStyle = color
      @ctx.fill()
      @ctx.closePath()

    drawLine: (posS, posE, lineWidth = @lineWidth, color = @color) ->
      @ctx.lineWidth = lineWidth
      @ctx.beginPath()
      @ctx.moveTo(posS.x, posS.y)
      @ctx.lineTo(posE.x, posE.y)
      @ctx.strokeStyle = color
      @ctx.stroke()
      @ctx.closePath()

    # 画像が読み込まれていれば true を返す。読み込まれていなければアラートを表示し false を返す
    checkImage: (img) ->
      if (img.width > 0) is false
        alert "画像がありません。"
        return false
      true

    # 適切な画像タイプならば true。対応していないタイプならばアラートを表示して false を返す
    checkFileType: (text) ->
      # ファイルタイプの確認
      if text.match(/^image\/(png|jpeg|gif)$/) is null
        alert "対応していないファイル形式です。\nファイルはPNG, JPEG, GIFに対応しています。"
        return false
      true

    loadImg: (width, height) ->
      _mycanvas = this
      ->
        try
          width = width || @width;
          height = height || @height;
          _mycanvas.reload(@)
          $(@).remove()
        catch e
          alert "画像を開けませんでした。"

    # 画像読込ハンドラ
    readFile: (reader) ->
      =>
        # img へオブジェクトを読み込む
        this.img = $("<img>").get(0)
        this.img.onload = @loadImg()
        this.img.setAttribute "src", reader.result

    loadFile: (file) ->
      # ファイルタイプの確認
      return false  if @checkFileType(file.type) is false
      # canvasに描画
      reader = new FileReader()
      reader.onload = @readFile(reader)
      reader.readAsDataURL file

    ondrop: (event) ->
      if event.dataTransfer.files.length is 0
        alert "画像を開けませんでした。"
        return false
      file = event.dataTransfer.files[0]  # ドロップされたファイル情報
      # ファイルタイプの確認
      return false  if @checkFileType(file.type) is false
      # canvas への描画
      reader = new FileReader()
      reader.onload = @readFile(reader)
      reader.readAsDataURL file
      # バブリング・デフォルト処理停止
      event.stopPropagation()
      event.preventDefault()

  # ====================================
  # 保存した画像の一覧を表示
  listPictures = (myCanvas) ->
      $.get '/pictures/list.txt', (result)->
        # console.log result
        ids = result.split(',')
        pictures = $("#pictures")
        pictures.empty()
        ids.forEach (id, i) ->
          pictures.append("<img src=\"/images/#{id}.png\" class=\"pict_thumbnail\" />") if parseInt(id, 10) > 0

        thumb_pics = $("#pictures .pict_thumbnail")
        thumb_pics.click ->
          image = new Image()
          image.src = $(@).attr('src')
          image.onload = -> myCanvas.reload(image)

        thumb_pics.mouseenter -> $(@).addClass('pict_thumbnail-over')
        thumb_pics.mouseout   -> $(@).removeClass('pict_thumbnail-over')
        null

  # ====================================
  canvas = $('#draw-area')[0]

  if canvas
    myCanvas = new MyCanvas(canvas)

    $(canvas).mousedown (e) -> myCanvas.mousedown(e)
    $(canvas).mousemove (e) -> myCanvas.mousemove(e)
    $(canvas).mouseup   (e) -> myCanvas.setMouseState(false)
    $(canvas).mouseout  (e) -> myCanvas.setMouseState(false)

    # 線の太さ
    $("#show-pen-width").text(myCanvas.getLineWidth())
    $("#pen-width-slider").change ->
      v = $(@).val()
      myCanvas.setLineWidth(v)
      $("#pen").css("height", v)
      $("#pen").css("margin-top", 90 - v)
      $("#show-pen-width").text(myCanvas.getLineWidth())

    # 線の色
    $("#color-choice").change ->
      v = $(@).val()
      myCanvas.setColor(v)
      $("#pen").css("background-color", v)

    # 消去
    $("#clear-button").click -> myCanvas.clear()
    # undo
    $("#undo-button").click -> myCanvas.showHistory(-1)
    # redo
    $("#redo-button").click -> myCanvas.showHistory(1)
    # 保存
    $("#save-button").click ->
      myCanvas.save()
      listPictures(myCanvas)
    # ダウンロード
    $("#download-button").click -> myCanvas.download()

    listPictures(myCanvas)  # 保存した画像の一覧を表示

    # 参照ボタンで読込処理
    $("#upload").change ->　myCanvas.loadFile(@files[0])

    # ドラッグアンドドロップで読込む
    canvas.ondragover = -> false
    canvas.ondrop = (event) -> myCanvas.ondrop(event)

    null

