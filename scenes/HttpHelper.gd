extends Object

var parent

func _init(p_parent: Node):
	parent = p_parent

func _on_HTTPRequest_json_request_completed(result:int, response_code:int, headers:PoolStringArray, body:PoolByteArray, http, callback):
	if response_code != 200:
		print("Http request error!")
		return
	var json_result = JSON.parse(body.get_string_from_utf8())
	if json_result.error != OK:
		print("Json parse error")
		print(json_result.error_string)
		return
	var json = json_result.result
	parent.call(callback, json)
	http.queue_free()

func _on_HTTPRequest_image_request_completed(result:int, response_code:int, headers:PoolStringArray, body:PoolByteArray, http, callback):
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error != OK:
		print("Couldn't load the image.")
		# push_error("Couldn't load the image.")
		return

	var texture = ImageTexture.new()
	texture.create_from_image(image)
	parent.call(callback, texture)

func new_http_request() -> HTTPRequest:
	var http = HTTPRequest.new()
	parent.add_child(http)
	return http

func json_get_request(url, headers, callback="debug"):
	var http = new_http_request()
	http.connect("request_completed", self, "_on_HTTPRequest_json_request_completed", [http, callback])
	http.request(url, headers)

func json_post_request(url, headers, body, callback="debug"):
	var http = new_http_request()
	http.connect("request_completed", self, "_on_HTTPRequest_json_request_completed", [http, callback])
	http.request(url, headers, true, HTTPClient.METHOD_POST, str(body))

func image_get_request(url, headers, callback="debug_img"):
	var http = new_http_request()
	http.connect("request_completed", self, "_on_HTTPRequest_image_request_completed", [http, callback])
	http.request(url, headers)
