extends Object

var parent

func _init(p_parent: Node):
	parent = p_parent

func _on_HTTPRequest_json_request_completed(result:int, response_code:int, headers:PoolStringArray, body:PoolByteArray, http, callback, extra, on_error):
	if response_code != 200:
		print("Http request error!")
		if on_error:
			parent.call(on_error, extra)
		return
	var json_result = JSON.parse(body.get_string_from_utf8())
	if json_result.error != OK:
		print("Json parse error")
		print(json_result.error_string)
		if on_error:
			parent.call(on_error, extra)
		return
	var json = json_result.result
	if extra != null:
		parent.call(callback, json, extra)
	else:
		parent.call(callback, json, extra)
	http.queue_free()

func _on_HTTPRequest_image_request_completed(result:int, response_code:int, headers:PoolStringArray, body:PoolByteArray, http, callback, extra, on_error):
	if response_code != 200:
		print("Http request error!")
		if on_error:
			parent.call(on_error, extra)
		return
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		error = image.load_jpg_from_buffer(body)
		if error != OK:
			print("Couldn't load the image as png or jpg")
			if on_error:
				parent.call(on_error, extra)
			return
			# push_error("Couldn't load the image.")

	var texture = ImageTexture.new()
	texture.create_from_image(image)
	if extra != null:
		parent.call(callback, texture, extra)
	else:
		parent.call(callback, texture, extra)

func new_http_request() -> HTTPRequest:
	var http = HTTPRequest.new()
	if OS.get_name() != "HTML5":
		http.use_threads = true
	parent.add_child(http)
	return http

func json_get_request(url, headers=[], callback="debug", extra=null, on_error=""):
	var http = new_http_request()
	http.connect("request_completed", self, "_on_HTTPRequest_json_request_completed", [http, callback, extra, on_error])
	http.request(url, headers)

func json_post_request(url, headers=[], body={}, callback="debug", extra=null, on_error=""):
	var http = new_http_request()
	http.connect("request_completed", self, "_on_HTTPRequest_json_request_completed", [http, callback, extra, on_error])
	http.request(url, headers, true, HTTPClient.METHOD_POST, str(body))

func image_get_request(url, headers=[], callback="debug_img", extra=null, on_error=""):
	var http = new_http_request()
	http.connect("request_completed", self, "_on_HTTPRequest_image_request_completed", [http, callback, extra, on_error])
	http.request(url, headers)
