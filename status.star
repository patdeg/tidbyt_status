load("render.star", "render")
load("http.star", "http")
load("encoding/base64.star", "base64")
load("cache.star", "cache")


STATUS_URL = "https://status.changehealthcare.com/api/v2/status.json"

GREEN_TICK_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7EAAAOxAGVKw4bAAABJ0lEQVQ4jZXTvyvFURjH8df1NSglg1Ims51NnZD8GsxiEyVllEGdwWLAoPwJZpsM6psfd1HKwHCzMBkMJhEug+/l63Jz77Odz/P5vJ+eczqJRitqEWwJEqlS0jAgWMcSpgTthQanBxyiKVNK9QOiNlygO1PKGGyqGfhdG7kw7IjS+gDRCGZzyjWW4f8VonZcoitTyugXFalcRtQjGqqB2M6FYbMS/gREfTjFgWiuavokpnPKFVbzlkRQRGe2zrjgXupM1IF9tGbeV0yIbqsBzRjOzgWMCu6xiN6cd020W71fIlUUvGAwBxlHT853jhmp8m8ApI4FbxioNuAJY6K7P3q+/0LqqAZkRbT3V/gn4BvyzNeTnmBe6r0+wCfkRHCDRyyIHmqF4QOXNEVifR8AhwAAAABJRU5ErkJggg==
""")

RED_ERROR_ICON = base64.decode("""
iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAmElEQVQ4jcWTMQ7CQAwEh1OKvIDP0OWHPOaULh9IgVB+gpAu3dIYKYKzL0DBSlvZXvtOu7CBoBdkQXGYBT012PAoUIPjm4gzXAQXY3FFgs3LZsHVvcTeVTu1JSBBTsBQ/ZR9GNIPwwD8X6CLaoJjq+8gKHjuamNNwOQU78DJeHN6pshI87NLMIeWDkTOxq/zsC9MLyIfxfkBwePUR+MF4csAAAAASUVORK5CYII=
""")

def main():


    indicator_cached = cache.get("indicator")
    description_cached = cache.get("description")
    
    if (indicator_cached != None) and (description_cached != None):
        indicator = indicator_cached
        description = description_cached
    else:
        rep = http.get(STATUS_URL)
        if rep.status_code != 200:
            fail("Status request failed with status %d", rep.status_code)

        indicator = rep.json()["status"]["indicator"]
        description = rep.json()["status"]["description"]
        cache.set("indicator", indicator, ttl_seconds=240)
        cache.set("description", description, ttl_seconds=240)

    color = "#090"
    icon = RED_ERROR_ICON
        
    if indicator == "none":
        indicator = "OK"
        icon = GREEN_TICK_ICON

    return render.Root(
        child = render.Column(
            children=[
                render.Row(
                    children = [
                        render.Text("Change Status:"),
                    ],
                ),
                render.Row(
                    expanded=True, # Use as much horizontal space as possible
                    main_align="space_evenly", # Controls horizontal alignment
                    cross_align="center", # Controls vertical alignment
                    children = [
                        render.Image(src=icon),
                        render.WrappedText(
                              content=description,
                              font="tom-thumb",
                              width=50,
                              color=color,
                        ),
                    ],
                ),
            ],
        ),
    )