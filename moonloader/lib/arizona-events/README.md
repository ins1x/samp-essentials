# arizona-events

Это аналог библиотеки SAMP.Lua, позволяющий также удобно и просто взаимодействовать с новыми пакетами и CEF-интерфейсами Аризоны. На данный момент поддерживается как обычный клиент SAMP, так и RakSamp Lite.

## Установка

Скопируйте папку `arizona-events` в директорию `moonloader/lib`.

## Использование

### Подключение библиотеки

```lua
local acef = require("arizona-events")
```

## Обработка пакетов
Важно: в событии вместо передачи аргументов по порядку, они передаются таблицей.

```lua
function acef.onArizonaBotChatBubble(packet)
	sampAddChatMessage(("Бот[%s] сказал: %s"):format(packet.bot_id, packet.text), -1)
end
```

## API

### Эмуляция входящего пакета

```lua
---@param event string - название события
---@param packet table - заполненный пакет
--- acef.emul(event, packet)

acef.emul("onArizonaDisplay", {
	id = 17,  -- указывать не обязательно
	text = "..."
})
```

### Отправка исходящего пакета

```lua
---@param event string - название события
---@param packet table - заполненный пакет
--- acef.send(event, packet)

acef.send("onArizonaSend", {
	text = "...",
	server_id = 0
})
```

### Декодирование пакета onArizonaDisplay

```lua
---@param packet table
---@param decoder function - функция, декодирующая JSON в таблицу
---@return boolean status - успешность декодирования
--- local status = acef.decode(packet, [decoder = decodeJson])

function acef.onArizonaDisplay(packet)
	if acef.decode(packet) then
		print(packet.event, packet.json)
	end
end
```

### Кодирование пакета onArizonaDisplay

```lua
---@param packet table
---@param encoder function - функция, кодирующая таблицу в JSON
---@return boolean status - успешность кодирования
--- local status = acef.encode(packet, [encoder = encodeJson])

function acef.onArizonaDisplay(packet)
	if acef.decode(packet) then
		if packet.event == "event.inventory.playerInventory" then
			local t = packet.json[1]
			if t.action == 1 and t.data.skin then
				t.data.skin.model = math.random(0, 303)
				if acef.encode(packet) then
					return { packet }
				end
			end
		end
	end
end
```

### Исполнение JS-кода в CEF

```lua
---@param js_code string - JavaScript код для выполнения
---@param server_id number - ID сервера
--- acef.eval(js_code, [server_id = 0])

acef.eval("let i = 0")
```
